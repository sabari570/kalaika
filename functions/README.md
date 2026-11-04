# Cloud Functions (development reference)

This folder contains the **original server-side receipt pipeline** (`generateReceipt`, PDF upload to Storage, `onPaymentWritten`, `voidPayment`).

**Spark production does not deploy these functions.** The Flutter app records payments, updates summaries, and builds PDFs on device (see `docs/KALAIKA_PLAN_v2.md` Section 9.6).

## When to use

- Compare PDF layout between `receiptPdfService.ts` and `lib/features/fees/data/services/receipt_pdf_builder.dart`
- Experiment with Firebase emulators locally

## Build and emulators

```bash
npm install
npm run build
firebase emulators:start --only firestore,functions,storage
```

Do not assume the mobile app calls these callables in normal production runs.
