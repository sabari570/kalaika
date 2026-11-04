import { getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { KEYS, MAX_INSTANCES, REGION, STATUS_VOIDED } from "../config/constants";
import {
  paymentDocumentId,
  paymentRef,
} from "../services/paymentPaths";
import { parseVoidPaymentInput } from "../validators/paymentValidators";

export const voidPayment = onCall(
  {
    region: REGION,
    maxInstances: MAX_INSTANCES,
  },
  async (request) => {
    if (!request.auth?.uid) {
      throw new HttpsError("unauthenticated", "Authentication is required.");
    }
    const uid = request.auth.uid;
    const input = parseVoidPaymentInput(request.data);
    const db = getFirestore();
    const paymentId = paymentDocumentId(input.studentId, input.month);
    const payRef = paymentRef(
      db,
      uid,
      input.branchId,
      input.batchId,
      paymentId,
    );
    const snap = await payRef.get();
    if (!snap.exists) {
      throw new HttpsError("not-found", "No payment exists for this month.");
    }
    const data = snap.data() ?? {};
    if (data[KEYS.voided]) {
      return { status: STATUS_VOIDED };
    }
    await payRef.update({
      [KEYS.voided]: true,
      [KEYS.status]: STATUS_VOIDED,
    });
    return { status: STATUS_VOIDED };
  },
);
