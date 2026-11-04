import 'package:feemanager/core/utils/amount_in_words_utils.dart';
import 'package:feemanager/core/utils/indian_currency_utils.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Input for building a fee receipt PDF on device.
class ReceiptPdfInput {
  /// Creates PDF input.
  const ReceiptPdfInput({
    required this.instituteName,
    required this.tagline,
    required this.addressLines,
    required this.phone,
    required this.footerNote,
    required this.signatory,
    required this.receiptNo,
    required this.paidOn,
    required this.receivedFrom,
    required this.studentName,
    required this.branchName,
    required this.batchName,
    required this.danceStyle,
    required this.monthLabel,
    required this.yearLabel,
    required this.mode,
    required this.amount,
    this.note,
  });

  /// Institute name.
  final String instituteName;

  /// Tagline.
  final String tagline;

  /// Address lines.
  final List<String> addressLines;

  /// Phone.
  final String phone;

  /// Footer note.
  final String footerNote;

  /// Signatory.
  final String signatory;

  /// Receipt number.
  final String receiptNo;

  /// Paid date.
  final DateTime paidOn;

  /// Received from line.
  final String receivedFrom;

  /// Student name.
  final String studentName;

  /// Branch name.
  final String branchName;

  /// Batch name.
  final String batchName;

  /// Dance style.
  final String danceStyle;

  /// Month label.
  final String monthLabel;

  /// Year label.
  final String yearLabel;

  /// Payment mode.
  final String mode;

  /// Amount in rupees.
  final int amount;

  /// Optional note.
  final String? note;
}

/// Builds fee receipt PDFs matching the Cloud Functions layout.
class ReceiptPdfBuilder {
  /// Creates the builder and loads fonts.
  ReceiptPdfBuilder._({
    required this._regular,
    required this._bold,
  });

  static ReceiptPdfBuilder? _cached;
  static Future<ReceiptPdfBuilder>? _loading;

  final pw.Font _regular;
  final pw.Font _bold;

  static const PdfColor _copper = PdfColor(0.88, 0.48, 0.18);
  static const PdfColor _text = PdfColor(0.1, 0.1, 0.1);
  static const PdfColor _muted = PdfColor(0.35, 0.35, 0.35);

  /// Shared instance with bundled Noto fonts.
  static Future<ReceiptPdfBuilder> instance() {
    return _loading ??= _load();
  }

  static Future<ReceiptPdfBuilder> _load() async {
    if (_cached != null) {
      return _cached!;
    }
    final regularData = await rootBundle.load(
      'assets/fonts/receipt/NotoSans-Regular.ttf',
    );
    final boldData = await rootBundle.load(
      'assets/fonts/receipt/NotoSans-Bold.ttf',
    );
    _cached = ReceiptPdfBuilder._(
      regular: pw.Font.ttf(regularData),
      bold: pw.Font.ttf(boldData),
    );
    return _cached!;
  }

  /// Renders [input] to PDF bytes.
  Future<Uint8List> build(ReceiptPdfInput input) async {
    final doc = pw.Document();
    final dateText = DateFormat('d MMM y').format(input.paidOn);
    final amountFigures = IndianCurrencyUtils.format(input.amount);
    final words =
        '${AmountInWordsUtils.toWords(input.amount)} Rupees Only';

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          const left = 48.0;
          const right = 48.0;
          final width = context.page.pageFormat.width;
          final height = context.page.pageFormat.height;
          final topY = height - 48.0;

          return pw.Stack(
            children: <pw.Widget>[
              pw.Positioned(
                left: left,
                right: right,
                top: 0,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: <pw.Widget>[
                    pw.Container(
                      margin: pw.EdgeInsets.only(top: topY - height + 48),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: <pw.Widget>[
                          pw.Container(
                            width: width - left - right,
                            height: 2,
                            color: _copper,
                            margin: const pw.EdgeInsets.only(bottom: 8),
                          ),
                          pw.Text(
                            input.instituteName,
                            style: pw.TextStyle(
                              font: _bold,
                              fontSize: 22,
                              color: _copper,
                            ),
                          ),
                          pw.SizedBox(height: 6),
                          pw.Text(
                            input.tagline,
                            style: pw.TextStyle(
                              font: _regular,
                              fontSize: 10,
                              color: _muted,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          for (final line in input.addressLines)
                            pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 2),
                              child: pw.Text(
                                line,
                                style: pw.TextStyle(
                                  font: _regular,
                                  fontSize: 10,
                                  color: _muted,
                                ),
                              ),
                            ),
                          if (input.phone.isNotEmpty)
                            pw.Text(
                              'Phone: ${input.phone}',
                              style: pw.TextStyle(
                                font: _regular,
                                fontSize: 10,
                                color: _muted,
                              ),
                            ),
                          pw.SizedBox(height: 20),
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: <pw.Widget>[
                              pw.Text(
                                'FEE RECEIPT',
                                style: pw.TextStyle(
                                  font: _bold,
                                  fontSize: 16,
                                  color: _text,
                                ),
                              ),
                              pw.Text(
                                input.receiptNo,
                                style: pw.TextStyle(
                                  font: _bold,
                                  fontSize: 11,
                                  color: _text,
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 4),
                          pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text(
                              dateText,
                              style: pw.TextStyle(
                                font: _regular,
                                fontSize: 10,
                                color: _muted,
                              ),
                            ),
                          ),
                          pw.SizedBox(height: 20),
                          ..._detailRows(input, dateText),
                          pw.SizedBox(height: 12),
                          pw.Container(
                            width: width - left - right,
                            padding: const pw.EdgeInsets.all(12),
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(color: _copper),
                            ),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: <pw.Widget>[
                                pw.Text(
                                  'Amount',
                                  style: pw.TextStyle(
                                    font: _bold,
                                    fontSize: 10,
                                    color: _text,
                                  ),
                                ),
                                pw.SizedBox(height: 4),
                                pw.Text(
                                  '\u20B9 $amountFigures',
                                  style: pw.TextStyle(
                                    font: _bold,
                                    fontSize: 18,
                                    color: _text,
                                  ),
                                ),
                                pw.SizedBox(height: 4),
                                pw.Text(
                                  words,
                                  style: pw.TextStyle(
                                    font: _regular,
                                    fontSize: 9,
                                    color: _muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (input.note != null &&
                              input.note!.trim().isNotEmpty) ...<pw.Widget>[
                            pw.SizedBox(height: 12),
                            pw.Text(
                              'Note: ${input.note}',
                              style: pw.TextStyle(
                                font: _regular,
                                fontSize: 10,
                                color: _text,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              pw.Positioned(
                left: left,
                bottom: 72,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: <pw.Widget>[
                    pw.Text(
                      'Received with thanks',
                      style: pw.TextStyle(
                        font: _regular,
                        fontSize: 10,
                        color: _text,
                      ),
                    ),
                    if (input.signatory.isNotEmpty) ...<pw.Widget>[
                      pw.SizedBox(height: 4),
                      pw.Text(
                        input.signatory,
                        style: pw.TextStyle(
                          font: _bold,
                          fontSize: 10,
                          color: _text,
                        ),
                      ),
                    ],
                    if (input.footerNote.isNotEmpty) ...<pw.Widget>[
                      pw.SizedBox(height: 4),
                      pw.Text(
                        input.footerNote,
                        style: pw.TextStyle(
                          font: _regular,
                          fontSize: 9,
                          color: _muted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              pw.Positioned(
                left: left,
                bottom: 48,
                child: pw.Text(
                  'This is a computer generated receipt.',
                  style: pw.TextStyle(
                    font: _regular,
                    fontSize: 8,
                    color: _muted,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return doc.save();
  }

  List<pw.Widget> _detailRows(ReceiptPdfInput input, String dateText) {
    final rows = <(String, String)>[
      ('Received from', input.receivedFrom),
      ('Student', input.studentName),
      ('Branch', input.branchName),
      ('Batch', input.batchName),
      ('Dance style', input.danceStyle),
      ('Month', '${input.monthLabel} ${input.yearLabel}'),
      ('Payment mode', input.mode.toUpperCase()),
      ('Paid on', dateText),
    ];
    return rows
        .map(
          (row) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 6),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                pw.SizedBox(
                  width: 120,
                  child: pw.Text(
                    row.$1,
                    style: pw.TextStyle(
                      font: _bold,
                      fontSize: 10,
                      color: _text,
                    ),
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    row.$2,
                    style: pw.TextStyle(
                      font: _regular,
                      fontSize: 10,
                      color: _text,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }
}
