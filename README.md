# Kalaika (feemanager)

Fee management for dance classes: branches, batches, students, monthly fee tracking, PDF receipts, and WhatsApp delivery. The product specification lives in [docs/KALAIKA_PLAN_v2.md](docs/KALAIKA_PLAN_v2.md).

## Prerequisites

- [FVM](https://fvm.app/) with Flutter **3.44.3** (`fvm use 3.44.3`)
- Node.js **20** (matches `functions/package.json`)
- Firebase CLI (`npm install -g firebase-tools`)
- A Firebase project (`kalaika`) with Google Sign-In configured for Android

## Run the app (Spark production)

Production uses **Firebase Authentication + Firestore on the Spark plan**. Receipts are generated on the device and shared with `share_plus`; no Cloud Functions deploy is required.

Deploy security rules when they change:

```bash
firebase deploy --only firestore:rules,firestore:indexes
```

Run the app against your Firebase project:

```bash
fvm flutter pub get
fvm flutter run
```

Use debug SHA-1/SHA-256 in the Firebase console and keep `android/app/google-services.json` in sync after `flutterfire configure`.

## Firebase emulators (optional)

### Quick start (two terminals)

**Terminal 1 — build functions and start emulators** (repo root):

```bash
cd functions && npm install && npm run build && cd ..
firebase emulators:start --only firestore,functions,storage
```

Leave this running. Emulator UI: http://127.0.0.1:4000/

**Terminal 2 — run the app** (repo root):

Find your computer's LAN IP (physical phone on the same Wi-Fi):

```bash
hostname -I | awk '{print $1}'
```

Use that address as `EMULATOR_HOST` (example `10.10.15.122`):

```bash
fvm flutter run \
  --dart-define=USE_EMULATORS=true \
  --dart-define=EMULATOR_HOST=10.10.15.122
```

For an **Android AVD** on the same machine, use `10.0.2.2` instead of the LAN IP.
For **Linux desktop** on the same machine as the emulators, use `127.0.0.1`:

```bash
fvm flutter run -d linux \
  --dart-define=USE_EMULATORS=true \
  --dart-define=EMULATOR_HOST=127.0.0.1
```

After changing `--dart-define` values, stop the app and run `fvm flutter run` again (hot reload is not enough).

### App Check debug token (removes logcat warning)

Debug builds activate the **App Check debug provider** automatically. If you enforce App Check on Cloud Functions in the Firebase Console, register a debug token once:

1. Run the app once (commands above).
2. In Android **logcat**, filter for `DebugAppCheckProvider` or `AppCheck`. Copy the **debug secret** line (a UUID).
3. Open [Firebase Console](https://console.firebase.google.com/) → project **kalaika** → **App Check** → your Android app → **Manage debug tokens** → **Add debug token** → paste → Save.
4. Restart the app.

Emulator testing usually works even before step 3; registration is required only if callables reject requests for missing App Check.

### Detailed setup

1. Install function dependencies and build:

```bash
cd functions
npm install
npm run build
cd ..
```

2. Start emulators (from the repo root):

```bash
firebase emulators:start --only firestore,functions,storage
```

3. Run the app against emulators (see **Quick start** above for `EMULATOR_HOST`).

Restart the emulator suite after changing `firebase.json` so services bind to
`0.0.0.0` and accept connections from a phone on your LAN.

Receipt links stored by Cloud Functions use a production Storage URL shape.
While `USE_EMULATORS=true`, the app rewrites those links to the local Storage
emulator so **Open receipt** works during development.

### M6 acceptance (generateReceipt)

With emulators running and a signed-in user who has a branch, batch, and active student:

1. Call `generateReceipt` with `{ branchId, batchId, studentId, month: "yyyy-MM", amount, mode, paidOn, note? }`.
2. Confirm a payment document at `users/{uid}/branches/{branchId}/batches/{batchId}/payments/{studentId}_{yyyyMM}` with `status: paid`, `receiptNo`, and `receiptUrl`.
3. Confirm a PDF under `receipts/{uid}/{yyyyMM}/{receiptNo}.pdf` in the Storage emulator.
4. Call the same function again with identical input; the response must return the same `receiptNo` and `receiptUrl` (idempotency).

Deploy rules and indexes to Spark when ready:

```bash
firebase deploy --only firestore:rules,firestore:indexes,storage
```

Deploy functions only after enabling Blaze and setting a budget alert:

```bash
cd functions && npm run deploy
```

Functions use region `asia-south1` and `maxInstances: 5`.

Receipt PDFs embed Noto Sans (Regular and Bold) under `functions/assets/fonts/` for Indian currency and text. The institute title uses Noto Sans Bold; add `Cinzel-Bold.ttf` to the same folder and point `receiptPdfService` at it if you want the Cinzel header from the plan.

## Architecture

Flutter app under `lib/` follows clean architecture (domain / data / presentation) per Section 2 of the plan. Cloud Functions live in `functions/` (`callables/`, `triggers/`, `services/`, `validators/`).

## Quality

After Dart changes:

```bash
fvm flutter analyze
```

After TypeScript changes:

```bash
cd functions && npm run lint && npm run build
```
