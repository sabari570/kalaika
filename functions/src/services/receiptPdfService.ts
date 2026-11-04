import * as fs from "node:fs";
import * as path from "node:path";
import fontkit from "@pdf-lib/fontkit";
import { PDFDocument, rgb } from "pdf-lib";

export interface ReceiptPdfInput {
  instituteName: string;
  tagline: string;
  addressLines: string[];
  phone: string;
  footerNote: string;
  signatory: string;
  receiptNo: string;
  paidOn: Date;
  receivedFrom: string;
  studentName: string;
  branchName: string;
  batchName: string;
  danceStyle: string;
  monthLabel: string;
  yearLabel: string;
  mode: string;
  amount: number;
  note?: string;
}

const COPPER = rgb(0.88, 0.48, 0.18);
const TEXT = rgb(0.1, 0.1, 0.1);
const MUTED = rgb(0.35, 0.35, 0.35);

let fontsPromise: Promise<{
  regular: Uint8Array;
  bold: Uint8Array;
  display: Uint8Array;
}> | null = null;

function loadFonts(): Promise<{
  regular: Uint8Array;
  bold: Uint8Array;
  display: Uint8Array;
}> {
  if (!fontsPromise) {
    fontsPromise = Promise.resolve().then(() => {
      const base = path.join(__dirname, "..", "..", "assets", "fonts");
      const regularPath = path.join(base, "NotoSans-Regular.ttf");
      const boldPath = path.join(base, "NotoSans-Bold.ttf");
      const displayPath = path.join(base, "NotoSans-Bold.ttf");
      return {
        regular: fs.readFileSync(regularPath),
        bold: fs.readFileSync(boldPath),
        display: fs.readFileSync(displayPath),
      };
    });
  }
  return fontsPromise;
}

export async function buildReceiptPdf(input: ReceiptPdfInput): Promise<Uint8Array> {
  const fonts = await loadFonts();
  const pdf = await PDFDocument.create();
  pdf.registerFontkit(fontkit);
  const regular = await pdf.embedFont(fonts.regular);
  const bold = await pdf.embedFont(fonts.bold);
  const display = await pdf.embedFont(fonts.display);

  const page = pdf.addPage([595.28, 841.89]);
  const { width, height } = page.getSize();
  let y = height - 48;

  page.drawLine({
    start: { x: 48, y: y + 8 },
    end: { x: width - 48, y: y + 8 },
    thickness: 2,
    color: COPPER,
  });

  page.drawText(input.instituteName, {
    x: 48,
    y,
    size: 22,
    font: display,
    color: COPPER,
  });
  y -= 22;
  page.drawText(input.tagline, { x: 48, y, size: 10, font: regular, color: MUTED });
  y -= 14;
  for (const line of input.addressLines) {
    page.drawText(line, { x: 48, y, size: 10, font: regular, color: MUTED });
    y -= 12;
  }
  if (input.phone.length > 0) {
    page.drawText(`Phone: ${input.phone}`, {
      x: 48,
      y,
      size: 10,
      font: regular,
      color: MUTED,
    });
    y -= 12;
  }

  y -= 16;
  page.drawText("FEE RECEIPT", {
    x: 48,
    y,
    size: 16,
    font: bold,
    color: TEXT,
  });
  page.drawText(input.receiptNo, {
    x: width - 48 - bold.widthOfTextAtSize(input.receiptNo, 11),
    y,
    size: 11,
    font: bold,
    color: TEXT,
  });
  y -= 16;
  const dateText = input.paidOn.toLocaleDateString("en-IN", {
    day: "numeric",
    month: "short",
    year: "numeric",
  });
  page.drawText(dateText, {
    x: width - 48 - regular.widthOfTextAtSize(dateText, 10),
    y,
    size: 10,
    font: regular,
    color: MUTED,
  });

  y -= 28;
  const rows: [string, string][] = [
    ["Received from", input.receivedFrom],
    ["Student", input.studentName],
    ["Branch", input.branchName],
    ["Batch", input.batchName],
    ["Dance style", input.danceStyle],
    ["Month", `${input.monthLabel} ${input.yearLabel}`],
    ["Payment mode", input.mode.toUpperCase()],
    ["Paid on", dateText],
  ];
  for (const [label, value] of rows) {
    page.drawText(label, { x: 48, y, size: 10, font: bold, color: TEXT });
    page.drawText(value, { x: 180, y, size: 10, font: regular, color: TEXT });
    y -= 16;
  }

  y -= 8;
  page.drawRectangle({
    x: 48,
    y: y - 52,
    width: width - 96,
    height: 56,
    borderColor: COPPER,
    borderWidth: 1,
    color: rgb(1, 1, 1),
  });
  const amountFigures = formatIndianCurrency(input.amount);
  page.drawText("Amount", { x: 60, y: y - 18, size: 10, font: bold, color: TEXT });
  page.drawText(`\u20B9 ${amountFigures}`, {
    x: 60,
    y: y - 36,
    size: 18,
    font: bold,
    color: TEXT,
  });
  const words = `${amountInWords(input.amount)} Rupees Only`;
  page.drawText(words, {
    x: 60,
    y: y - 50,
    size: 9,
    font: regular,
    color: MUTED,
  });
  y -= 72;

  if (input.note) {
    page.drawText(`Note: ${input.note}`, {
      x: 48,
      y,
      size: 10,
      font: regular,
      color: TEXT,
    });
    y -= 20;
  }

  y = 96;
  page.drawText("Received with thanks", {
    x: 48,
    y,
    size: 10,
    font: regular,
    color: TEXT,
  });
  y -= 14;
  if (input.signatory.length > 0) {
    page.drawText(input.signatory, {
      x: 48,
      y,
      size: 10,
      font: bold,
      color: TEXT,
    });
    y -= 14;
  }
  if (input.footerNote.length > 0) {
    page.drawText(input.footerNote, {
      x: 48,
      y,
      size: 9,
      font: regular,
      color: MUTED,
    });
    y -= 12;
  }
  page.drawText("This is a computer generated receipt.", {
    x: 48,
    y: 48,
    size: 8,
    font: regular,
    color: MUTED,
  });

  return pdf.save();
}

export function formatIndianCurrency(amount: number): string {
  return amount.toLocaleString("en-IN");
}

export function amountInWords(amount: number): string {
  if (amount <= 0) {
    return "Zero";
  }
  const ones = [
    "",
    "One",
    "Two",
    "Three",
    "Four",
    "Five",
    "Six",
    "Seven",
    "Eight",
    "Nine",
    "Ten",
    "Eleven",
    "Twelve",
    "Thirteen",
    "Fourteen",
    "Fifteen",
    "Sixteen",
    "Seventeen",
    "Eighteen",
    "Nineteen",
  ];
  const tens = [
    "",
    "",
    "Twenty",
    "Thirty",
    "Forty",
    "Fifty",
    "Sixty",
    "Seventy",
    "Eighty",
    "Ninety",
  ];

  function twoDigits(n: number): string {
    if (n < 20) {
      return ones[n] ?? "";
    }
    const t = Math.floor(n / 10);
    const o = n % 10;
    return `${tens[t]}${o > 0 ? ` ${ones[o]}` : ""}`.trim();
  }

  function section(n: number, label: string): string {
    if (n === 0) {
      return "";
    }
    return `${twoDigits(n)} ${label}`.trim();
  }

  let n = amount;
  const crore = Math.floor(n / 10000000);
  n %= 10000000;
  const lakh = Math.floor(n / 100000);
  n %= 100000;
  const thousand = Math.floor(n / 1000);
  n %= 1000;
  const hundred = Math.floor(n / 100);
  n %= 100;

  const parts = [
    section(crore, "Crore"),
    section(lakh, "Lakh"),
    section(thousand, "Thousand"),
    section(hundred, "Hundred"),
    n > 0 ? twoDigits(n) : "",
  ].filter((part) => part.length > 0);

  return parts.join(" ");
}
