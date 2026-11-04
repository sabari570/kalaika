import { HttpsError } from "firebase-functions/v2/https";
import { PAYMENT_MODES, PaymentMode } from "../config/constants";

export interface GenerateReceiptInput {
  branchId: string;
  batchId: string;
  studentId: string;
  month: string;
  amount: number;
  mode: string;
  paidOn: string;
  note?: string;
}

const MONTH_PATTERN = /^\d{4}-(0[1-9]|1[0-2])$/;

export function parseGenerateReceiptInput(
  data: unknown,
): GenerateReceiptInput {
  if (typeof data !== "object" || data === null) {
    throw new HttpsError("invalid-argument", "Invalid request payload.");
  }
  const payload = data as Record<string, unknown>;
  const branchId = readString(payload, "branchId");
  const batchId = readString(payload, "batchId");
  const studentId = readString(payload, "studentId");
  const month = readString(payload, "month");
  const mode = readString(payload, "mode");
  const paidOn = readString(payload, "paidOn");
  const note = readOptionalString(payload, "note");
  const amount = readAmount(payload, "amount");

  if (!MONTH_PATTERN.test(month)) {
    throw new HttpsError("invalid-argument", "Month must use yyyy-MM format.");
  }
  if (!PAYMENT_MODES.includes(mode as PaymentMode)) {
    throw new HttpsError("invalid-argument", "Payment mode is not valid.");
  }
  const paidDate = new Date(paidOn);
  if (Number.isNaN(paidDate.getTime())) {
    throw new HttpsError("invalid-argument", "Paid date is not valid.");
  }

  return {
    branchId,
    batchId,
    studentId,
    month,
    amount,
    mode,
    paidOn,
    note,
  };
}

export interface VoidPaymentInput {
  branchId: string;
  batchId: string;
  studentId: string;
  month: string;
}

export function parseVoidPaymentInput(data: unknown): VoidPaymentInput {
  if (typeof data !== "object" || data === null) {
    throw new HttpsError("invalid-argument", "Invalid request payload.");
  }
  const payload = data as Record<string, unknown>;
  const branchId = readString(payload, "branchId");
  const batchId = readString(payload, "batchId");
  const studentId = readString(payload, "studentId");
  const month = readString(payload, "month");
  if (!MONTH_PATTERN.test(month)) {
    throw new HttpsError("invalid-argument", "Month must use yyyy-MM format.");
  }
  return { branchId, batchId, studentId, month };
}

function readString(payload: Record<string, unknown>, key: string): string {
  const value = payload[key];
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new HttpsError("invalid-argument", `${key} is required.`);
  }
  return value.trim();
}

function readOptionalString(
  payload: Record<string, unknown>,
  key: string,
): string | undefined {
  const value = payload[key];
  if (value === undefined || value === null) {
    return undefined;
  }
  if (typeof value !== "string") {
    throw new HttpsError("invalid-argument", `${key} must be text.`);
  }
  const trimmed = value.trim();
  return trimmed.length === 0 ? undefined : trimmed;
}

function readAmount(payload: Record<string, unknown>, key: string): number {
  const value = payload[key];
  if (typeof value !== "number" || !Number.isInteger(value) || value <= 0) {
    throw new HttpsError(
      "invalid-argument",
      "Amount must be a positive whole number.",
    );
  }
  return value;
}
