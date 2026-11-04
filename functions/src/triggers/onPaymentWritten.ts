import { getFirestore } from "firebase-admin/firestore";
import { logger } from "firebase-functions";
import { onDocumentWritten } from "firebase-functions/v2/firestore";
import { MAX_INSTANCES, REGION } from "../config/constants";
import { summaryRef } from "../services/paymentPaths";
import {
  buildSummaryUpdate,
  deltaSummary,
  readPaymentSnapshot,
} from "../services/summaryDelta";

export const onPaymentWritten = onDocumentWritten(
  {
    region: REGION,
    maxInstances: MAX_INSTANCES,
    document:
      "users/{uid}/branches/{branchId}/batches/{batchId}/payments/{paymentId}",
  },
  async (event) => {
    const uid = event.params.uid;
    const batchId = event.params.batchId;
    const before = readPaymentSnapshot(event.data?.before.data());
    const after = readPaymentSnapshot(event.data?.after.data());
    const delta = deltaSummary(before, after);
    const monthKey = after?.month ?? before?.month ?? "";
    const branchId = after?.branchId ?? before?.branchId ?? "";
    if (monthKey.length === 0 || branchId.length === 0) {
      return;
    }
    const update = buildSummaryUpdate(monthKey, batchId, branchId, delta);
    if (Object.keys(update).length === 0) {
      return;
    }
    const db = getFirestore();
    try {
      await summaryRef(db, uid, monthKey).set(update, { merge: true });
    } catch (error) {
      logger.error("Summary update failed", error);
      throw error;
    }
  },
);
