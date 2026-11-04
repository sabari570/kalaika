import { DocumentData, FieldValue, getFirestore, Timestamp } from "firebase-admin/firestore";
import { getStorage } from "firebase-admin/storage";
import { logger } from "firebase-functions";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { KEYS, MAX_INSTANCES, REGION, STATUS_PAID } from "../config/constants";
import { buildReceiptPdf } from "../services/receiptPdfService";
import {
  countersRef,
  formatReceiptNumber,
  paymentDocumentId,
  paymentRef,
  receiptStoragePath,
} from "../services/paymentPaths";
import {
  deleteReceiptFile,
  uploadReceiptPdf,
} from "../services/storageService";
import { parseGenerateReceiptInput } from "../validators/paymentValidators";

interface InstituteSettings {
  name: string;
  tagline: string;
  addressLines: string[];
  phone: string;
  footerNote: string;
  signatory: string;
}

export const generateReceipt = onCall(
  {
    region: REGION,
    maxInstances: MAX_INSTANCES,
  },
  async (request) => {
    if (!request.auth?.uid) {
      throw new HttpsError("unauthenticated", "Authentication is required.");
    }
    const uid = request.auth.uid;
    const input = parseGenerateReceiptInput(request.data);
    const db = getFirestore();
    const paymentId = paymentDocumentId(input.studentId, input.month);
    const payRef = paymentRef(
      db,
      uid,
      input.branchId,
      input.batchId,
      paymentId,
    );

    const existingSnap = await payRef.get();
    if (existingSnap.exists) {
      const existing = existingSnap.data() ?? {};
      const voided = Boolean(existing[KEYS.voided]);
      if (!voided) {
        return {
          receiptNo: String(existing[KEYS.receiptNo] ?? ""),
          receiptUrl: String(existing[KEYS.receiptUrl] ?? ""),
          status: String(existing[KEYS.status] ?? STATUS_PAID),
        };
      }
    }

    const userSnap = await db.collection(KEYS.users).doc(uid).get();
    const studentSnap = await db
      .collection(KEYS.users)
      .doc(uid)
      .collection(KEYS.branches)
      .doc(input.branchId)
      .collection(KEYS.batches)
      .doc(input.batchId)
      .collection(KEYS.students)
      .doc(input.studentId)
      .get();
    const batchSnap = await db
      .collection(KEYS.users)
      .doc(uid)
      .collection(KEYS.branches)
      .doc(input.branchId)
      .collection(KEYS.batches)
      .doc(input.batchId)
      .get();
    const branchSnap = await db
      .collection(KEYS.users)
      .doc(uid)
      .collection(KEYS.branches)
      .doc(input.branchId)
      .get();

    if (!userSnap.exists || !studentSnap.exists || !batchSnap.exists) {
      throw new HttpsError("not-found", "Required records were not found.");
    }
    if (!branchSnap.exists) {
      throw new HttpsError("not-found", "Required records were not found.");
    }

    const institute = readInstitute(userSnap.data() ?? {});
    const student = studentSnap.data() ?? {};
    const batch = batchSnap.data() ?? {};
    const branch = branchSnap.data() ?? {};
    const paidOnDate = new Date(input.paidOn);
    const year = Number(input.month.slice(0, 4));

    let receiptNo = "";
    await db.runTransaction(async (transaction) => {
      const counterSnap = await transaction.get(countersRef(db, uid));
      const currentSeq = Number(counterSnap.data()?.[KEYS.receiptSeq] ?? 0);
      const nextSeq = currentSeq + 1;
      receiptNo = formatReceiptNumber(year, nextSeq);
      transaction.set(
        countersRef(db, uid),
        { [KEYS.receiptSeq]: nextSeq },
        { merge: true },
      );
      transaction.set(payRef, {
        [KEYS.ownerId]: uid,
        [KEYS.branchId]: input.branchId,
        [KEYS.batchId]: input.batchId,
        [KEYS.studentId]: input.studentId,
        [KEYS.studentName]: String(student[KEYS.fullName] ?? ""),
        [KEYS.guardianName]: student[KEYS.guardianName] ?? null,
        [KEYS.whatsappNumber]: String(student[KEYS.whatsappNumber] ?? ""),
        [KEYS.month]: input.month,
        [KEYS.amount]: input.amount,
        [KEYS.batchFee]: Number(batch[KEYS.defaultFee] ?? 0),
        [KEYS.mode]: input.mode,
        [KEYS.paidOn]: Timestamp.fromDate(paidOnDate),
        [KEYS.note]: input.note ?? null,
        [KEYS.status]: STATUS_PAID,
        [KEYS.receiptNo]: receiptNo,
        [KEYS.receiptPath]: "",
        [KEYS.receiptUrl]: "",
        [KEYS.sentAt]: null,
        [KEYS.sentVia]: null,
        [KEYS.voided]: false,
        [KEYS.createdAt]: FieldValue.serverTimestamp(),
      });
    });

    const bucketName = getStorage().bucket().name;
    if (bucketName.length === 0) {
      await payRef.delete();
      throw new HttpsError(
        "failed-precondition",
        "Storage is not configured for this project.",
      );
    }

    const storagePath = receiptStoragePath(uid, input.month, receiptNo);
    try {
      const guardian = String(student[KEYS.guardianName] ?? "").trim();
      const studentName = String(student[KEYS.fullName] ?? "");
      const receivedFrom = guardian.length > 0 ? guardian : studentName;
      const [yearPart, monthPart] = input.month.split("-");
      const monthDate = new Date(Number(yearPart), Number(monthPart) - 1, 1);
      const monthLabel = monthDate.toLocaleString("en-IN", { month: "long" });

      const pdfBytes = await buildReceiptPdf({
        instituteName: institute.name,
        tagline: institute.tagline,
        addressLines: institute.addressLines,
        phone: institute.phone,
        footerNote: institute.footerNote,
        signatory: institute.signatory,
        receiptNo,
        paidOn: paidOnDate,
        receivedFrom,
        studentName,
        branchName: String(branch[KEYS.name] ?? batch[KEYS.branchName] ?? ""),
        batchName: String(batch[KEYS.name] ?? ""),
        danceStyle: String(batch[KEYS.danceStyle] ?? ""),
        monthLabel,
        yearLabel: yearPart,
        mode: input.mode,
        amount: input.amount,
        note: input.note,
      });

      const uploaded = await uploadReceiptPdf(bucketName, storagePath, pdfBytes);
      await payRef.update({
        [KEYS.receiptPath]: uploaded.path,
        [KEYS.receiptUrl]: uploaded.url,
      });

      return {
        receiptNo,
        receiptUrl: uploaded.url,
        status: STATUS_PAID,
      };
    } catch (error) {
      logger.error("Receipt generation failed", error);
      await payRef.delete();
      await deleteReceiptFile(bucketName, storagePath);
      throw new HttpsError(
        "internal",
        "The receipt could not be generated. Please try again.",
      );
    }
  },
);

function readInstitute(data: DocumentData): InstituteSettings {
  const institute = (data[KEYS.institute] ?? {}) as Record<string, unknown>;
  const addressRaw = institute[KEYS.addressLines];
  const addressLines = Array.isArray(addressRaw)
    ? addressRaw.map((line) => String(line))
    : [];
  return {
    name: String(institute[KEYS.name] ?? "Kalaika"),
    tagline: String(institute[KEYS.tagline] ?? ""),
    addressLines,
    phone: String(institute[KEYS.phone] ?? ""),
    footerNote: String(institute[KEYS.footerNote] ?? ""),
    signatory: String(institute[KEYS.signatory] ?? ""),
  };
}
