import { initializeApp } from "firebase-admin/app";
import { setGlobalOptions } from "firebase-functions/v2";
import { REGION } from "./config/constants";
import { generateReceipt } from "./callables/generateReceipt";
import { voidPayment } from "./callables/voidPayment";
import { onPaymentWritten } from "./triggers/onPaymentWritten";

initializeApp();
setGlobalOptions({ region: REGION });

export { generateReceipt, voidPayment, onPaymentWritten };
