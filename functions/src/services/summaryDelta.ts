import { FieldValue } from "firebase-admin/firestore";
import {
  KEYS,
  STATUS_PAID,
  STATUS_SENT,
  STATUS_VOIDED,
} from "../config/constants";

export interface PaymentSnapshot {
  month: string;
  amount: number;
  status: string;
  voided: boolean;
  batchId: string;
  branchId: string;
}

export interface SummaryDelta {
  collected: number;
  paidCount: number;
  sentCount: number;
}

export function readPaymentSnapshot(
  data: FirebaseFirestore.DocumentData | undefined,
): PaymentSnapshot | null {
  if (!data) {
    return null;
  }
  return {
    month: String(data[KEYS.month] ?? ""),
    amount: Number(data[KEYS.amount] ?? 0),
    status: String(data[KEYS.status] ?? ""),
    voided: Boolean(data[KEYS.voided]),
    batchId: String(data[KEYS.batchId] ?? ""),
    branchId: String(data[KEYS.branchId] ?? ""),
  };
}

export function summaryContribution(
  payment: PaymentSnapshot | null,
): SummaryDelta {
  if (!payment || payment.voided || payment.month.length === 0) {
    return { collected: 0, paidCount: 0, sentCount: 0 };
  }
  const active =
    payment.status === STATUS_PAID || payment.status === STATUS_SENT;
  if (!active) {
    return { collected: 0, paidCount: 0, sentCount: 0 };
  }
  return {
    collected: payment.amount,
    paidCount: 1,
    sentCount: payment.status === STATUS_SENT ? 1 : 0,
  };
}

export function deltaSummary(
  before: PaymentSnapshot | null,
  after: PaymentSnapshot | null,
): SummaryDelta {
  const beforeContribution = summaryContribution(before);
  const afterContribution = summaryContribution(after);
  return {
    collected: afterContribution.collected - beforeContribution.collected,
    paidCount: afterContribution.paidCount - beforeContribution.paidCount,
    sentCount: afterContribution.sentCount - beforeContribution.sentCount,
  };
}

export function buildSummaryUpdate(
  monthKey: string,
  batchId: string,
  branchId: string,
  delta: SummaryDelta,
): Record<string, FirebaseFirestore.FieldValue | string> {
  if (
    delta.collected === 0 &&
    delta.paidCount === 0 &&
    delta.sentCount === 0
  ) {
    return {};
  }
  const update: Record<string, FirebaseFirestore.FieldValue | string> = {
    [KEYS.month]: monthKey,
    [KEYS.updatedAt]: FieldValue.serverTimestamp(),
  };
  if (delta.collected !== 0) {
    update[KEYS.collected] = FieldValue.increment(delta.collected);
  }
  if (delta.paidCount !== 0) {
    update[KEYS.paidCount] = FieldValue.increment(delta.paidCount);
  }
  if (delta.sentCount !== 0) {
    update[KEYS.sentCount] = FieldValue.increment(delta.sentCount);
  }
  const batchPrefix = `${KEYS.byBatch}.${batchId}`;
  if (delta.collected !== 0) {
    update[`${batchPrefix}.${KEYS.collected}`] = FieldValue.increment(
      delta.collected,
    );
  }
  if (delta.paidCount !== 0) {
    update[`${batchPrefix}.${KEYS.paidCount}`] = FieldValue.increment(
      delta.paidCount,
    );
  }
  if (delta.sentCount !== 0) {
    update[`${batchPrefix}.${KEYS.sentCount}`] = FieldValue.increment(
      delta.sentCount,
    );
  }
  update[`${batchPrefix}.${KEYS.branchId}`] = branchId;
  return update;
}

export function isVoidedStatus(status: string, voided: boolean): boolean {
  return voided || status === STATUS_VOIDED;
}
