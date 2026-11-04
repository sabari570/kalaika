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

/// Builds fee receipt PDFs matching the product design system.
class ReceiptPdfBuilder {
  ReceiptPdfBuilder._({
    required this._regular,
    required this._bold,
    required this._logo,
  });

  static ReceiptPdfBuilder? _cached;
  static Future<ReceiptPdfBuilder>? _loading;

  final pw.Font _regular;
  final pw.Font _bold;
  final pw.MemoryImage _logo;

  static const double _pageMargin = 48;

  // AppPalette-aligned print colors.
  static const PdfColor _copper = PdfColor.fromInt(0xFFE07B2F);
  static const PdfColor _gold = PdfColor.fromInt(0xFFF0B35C);
  static const PdfColor _text = PdfColor.fromInt(0xFF1A1A1A);
  static const PdfColor _muted = PdfColor.fromInt(0xFF5C5348);
  static const PdfColor _creamPanel = PdfColor.fromInt(0xFFF8F4EF);
  static const PdfColor _creamRowAlt = PdfColor.fromInt(0xFFFCFAF7);

  /// Shared instance with bundled fonts and logo.
  static Future<ReceiptPdfBuilder> instance() {
    return _loading ??= _load();
  }

  static Future<ReceiptPdfBuilder> _load() async {
    if (_cached != null) {
      return _cached!;
    }
    final results = await Future.wait<ByteData>(<Future<ByteData>>[
      rootBundle.load('assets/fonts/receipt/NotoSans-Regular.ttf'),
      rootBundle.load('assets/fonts/receipt/NotoSans-Bold.ttf'),
      rootBundle.load('assets/images/logo.png'),
    ]);
    _cached = ReceiptPdfBuilder._(
      regular: pw.Font.ttf(results[0]),
      bold: pw.Font.ttf(results[1]),
      logo: pw.MemoryImage(results[2].buffer.asUint8List()),
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
        margin: const pw.EdgeInsets.all(_pageMargin),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: <pw.Widget>[
              _buildHeader(input),
              pw.SizedBox(height: 20),
              _buildMetaBand(input, dateText),
              pw.SizedBox(height: 16),
              _buildDetailsTable(input, dateText),
              pw.SizedBox(height: 16),
              _buildAmountBox(amountFigures, words),
              if (input.note != null && input.note!.trim().isNotEmpty) ...<
                pw.Widget
              >[
                pw.SizedBox(height: 12),
                pw.Text(
                  'Note: ${input.note!.trim()}',
                  style: _textStyle(size: 10),
                ),
              ],
              pw.Spacer(),
              _buildFooter(input),
            ],
          );
        },
      ),
    );

    return doc.save();
  }

  pw.Widget _buildHeader(ReceiptPdfInput input) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: <pw.Widget>[
        pw.Container(height: 2, color: _copper),
        pw.SizedBox(height: 3),
        pw.Container(height: 1, color: _gold),
        pw.SizedBox(height: 14),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: <pw.Widget>[
            pw.Container(
              constraints: const pw.BoxConstraints(
                maxWidth: 200,
                maxHeight: 48,
              ),
              child: pw.Image(_logo),
            ),
            pw.SizedBox(width: 16),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: <pw.Widget>[
                  pw.Text(
                    input.instituteName,
                    style: pw.TextStyle(
                      font: _bold,
                      fontSize: 19,
                      color: _copper,
                    ),
                  ),
                  if (input.tagline.isNotEmpty) ...<pw.Widget>[
                    pw.SizedBox(height: 4),
                    pw.Text(
                      input.tagline,
                      style: _mutedStyle(size: 10),
                    ),
                  ],
                  pw.SizedBox(height: 6),
                  for (final line in input.addressLines)
                    if (line.trim().isNotEmpty)
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 2),
                        child: pw.Text(line, style: _mutedStyle(size: 9)),
                      ),
                  if (input.phone.isNotEmpty)
                    pw.Text(
                      'Phone: ${input.phone}',
                      style: _mutedStyle(size: 9),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildMetaBand(ReceiptPdfInput input, String dateText) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: pw.BoxDecoration(
        color: _creamPanel,
        border: pw.Border.all(color: _copper, width: 0.75),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Text(
            'FEE RECEIPT',
            style: pw.TextStyle(
              font: _bold,
              fontSize: 15,
              color: _text,
              letterSpacing: 0.5,
            ),
          ),
          pw.Spacer(),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: <pw.Widget>[
              pw.Text(
                input.receiptNo,
                style: pw.TextStyle(
                  font: _bold,
                  fontSize: 11,
                  color: _text,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(dateText, style: _mutedStyle(size: 10)),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildDetailsTable(ReceiptPdfInput input, String dateText) {
    final rows = _detailRowData(input, dateText);
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _copper, width: 0.75),
      ),
      child: pw.Column(
        children: <pw.Widget>[
          for (var i = 0; i < rows.length; i++)
            pw.Container(
              width: double.infinity,
              color: i.isOdd ? _creamRowAlt : PdfColors.white,
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 7,
              ),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: <pw.Widget>[
                  pw.SizedBox(
                    width: 118,
                    child: pw.Text(
                      rows[i].$1,
                      style: pw.TextStyle(
                        font: _bold,
                        fontSize: 9,
                        color: _muted,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      rows[i].$2,
                      style: _textStyle(size: 10),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  pw.Widget _buildAmountBox(String amountFigures, String words) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _copper, width: 1.25),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Text(
            'Amount received',
            style: pw.TextStyle(
              font: _bold,
              fontSize: 10,
              color: _copper,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            '\u20B9 $amountFigures',
            style: pw.TextStyle(
              font: _bold,
              fontSize: 22,
              color: _text,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(words, style: _mutedStyle(size: 9)),
        ],
      ),
    );
  }

  pw.Widget _buildFooter(ReceiptPdfInput input) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.Container(
          width: 120,
          height: 0.5,
          color: _gold,
          margin: const pw.EdgeInsets.only(bottom: 10),
        ),
        pw.Text('Received with thanks', style: _textStyle(size: 10)),
        if (input.signatory.isNotEmpty) ...<pw.Widget>[
          pw.SizedBox(height: 6),
          pw.Text(
            input.signatory,
            style: pw.TextStyle(font: _bold, fontSize: 10, color: _text),
          ),
        ],
        if (input.footerNote.isNotEmpty) ...<pw.Widget>[
          pw.SizedBox(height: 6),
          pw.Text(input.footerNote, style: _mutedStyle(size: 9)),
        ],
        pw.SizedBox(height: 10),
        pw.Text(
          'This is a computer generated receipt.',
          style: _mutedStyle(size: 8),
        ),
      ],
    );
  }

  List<(String, String)> _detailRowData(
    ReceiptPdfInput input,
    String dateText,
  ) {
    return <(String, String)>[
      ('Received from', input.receivedFrom),
      ('Student', input.studentName),
      ('Branch', input.branchName),
      ('Batch', input.batchName),
      ('Dance style', input.danceStyle),
      ('Month', '${input.monthLabel} ${input.yearLabel}'),
      ('Payment mode', input.mode.toUpperCase()),
      ('Paid on', dateText),
    ];
  }

  pw.TextStyle _textStyle({required double size}) {
    return pw.TextStyle(font: _regular, fontSize: size, color: _text);
  }

  pw.TextStyle _mutedStyle({required double size}) {
    return pw.TextStyle(font: _regular, fontSize: size, color: _muted);
  }
}
