import { DocumentReference, Firestore } from "firebase-admin/firestore";
import { KEYS } from "../config/constants";

export function paymentDocumentId(
  studentId: string,
  monthKey: string,
): string {
  const compact = monthKey.replace("-", "");
  return `${studentId}_${compact}`;
}

export function paymentRef(
  db: Firestore,
  uid: string,
  branchId: string,
  batchId: string,
  paymentId: string,
): DocumentReference {
  return db
    .collection(KEYS.users)
    .doc(uid)
    .collection(KEYS.branches)
    .doc(branchId)
    .collection(KEYS.batches)
    .doc(batchId)
    .collection(KEYS.payments)
    .doc(paymentId);
}

export function countersRef(
  db: Firestore,
  uid: string,
): DocumentReference {
  return db
    .collection(KEYS.users)
    .doc(uid)
    .collection(KEYS.meta)
    .doc(KEYS.counters);
}

export function summaryRef(
  db: Firestore,
  uid: string,
  monthKey: string,
): DocumentReference {
  return db
    .collection(KEYS.users)
    .doc(uid)
    .collection(KEYS.summaries)
    .doc(monthKey);
}

export function receiptStoragePath(
  uid: string,
  monthKey: string,
  receiptNo: string,
): string {
  const folder = monthKey.replace("-", "");
  return `receipts/${uid}/${folder}/${receiptNo}.pdf`;
}

export function buildReceiptDownloadUrl(
  bucketName: string,
  storagePath: string,
  token: string,
): string {
  const encoded = encodeURIComponent(storagePath);
  return (
    "https://firebasestorage.googleapis.com/v0/b/" +
    `${bucketName}/o/${encoded}?alt=media&token=${token}`
  );
}

export function formatReceiptNumber(year: number, sequence: number): string {
  const padded = sequence.toString().padStart(6, "0");
  return `KLK-${year}-${padded}`;
}
