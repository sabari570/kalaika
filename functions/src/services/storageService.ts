import { randomUUID } from "node:crypto";
import { getStorage } from "firebase-admin/storage";
import { buildReceiptDownloadUrl } from "./paymentPaths";

export async function uploadReceiptPdf(
  bucketName: string,
  storagePath: string,
  pdfBytes: Uint8Array,
): Promise<{ path: string; url: string }> {
  const token = randomUUID();
  const bucket = getStorage().bucket(bucketName);
  const file = bucket.file(storagePath);
  await file.save(Buffer.from(pdfBytes), {
    contentType: "application/pdf",
    metadata: {
      metadata: {
        firebaseStorageDownloadTokens: token,
      },
    },
  });
  const url = buildReceiptDownloadUrl(bucketName, storagePath, token);
  return { path: storagePath, url };
}

export async function deleteReceiptFile(
  bucketName: string,
  storagePath: string,
): Promise<void> {
  if (storagePath.length === 0) {
    return;
  }
  const bucket = getStorage().bucket(bucketName);
  await bucket.file(storagePath).delete({ ignoreNotFound: true });
}
