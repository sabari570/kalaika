export const REGION = "asia-south1";

export const MAX_INSTANCES = 5;

export const PAYMENT_MODES = ["cash", "upi", "bank", "other"] as const;

export type PaymentMode = (typeof PAYMENT_MODES)[number];

export const STATUS_PAID = "paid";
export const STATUS_SENT = "sent";
export const STATUS_VOIDED = "voided";

export const KEYS = {
  users: "users",
  branches: "branches",
  batches: "batches",
  students: "students",
  fullName: "fullName",
  payments: "payments",
  meta: "meta",
  counters: "counters",
  summaries: "summaries",
  receiptSeq: "receiptSeq",
  ownerId: "ownerId",
  branchId: "branchId",
  batchId: "batchId",
  studentId: "studentId",
  studentName: "studentName",
  guardianName: "guardianName",
  whatsappNumber: "whatsappNumber",
  month: "month",
  amount: "amount",
  batchFee: "batchFee",
  mode: "mode",
  paidOn: "paidOn",
  note: "note",
  status: "status",
  receiptNo: "receiptNo",
  receiptPath: "receiptPath",
  receiptUrl: "receiptUrl",
  sentAt: "sentAt",
  sentVia: "sentVia",
  voided: "voided",
  createdAt: "createdAt",
  institute: "institute",
  name: "name",
  tagline: "tagline",
  addressLines: "addressLines",
  phone: "phone",
  footerNote: "footerNote",
  signatory: "signatory",
  danceStyle: "danceStyle",
  branchName: "branchName",
  defaultFee: "defaultFee",
  collected: "collected",
  paidCount: "paidCount",
  sentCount: "sentCount",
  byBatch: "byBatch",
  updatedAt: "updatedAt",
} as const;
