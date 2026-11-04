/// Converts whole rupee amounts to words for receipts.
abstract final class AmountInWordsUtils {
  /// Returns English words for [amount] in whole rupees.
  static String toWords(int amount) {
    if (amount <= 0) {
      return 'Zero';
    }
    var n = amount;
    final crore = n ~/ 10000000;
    n %= 10000000;
    final lakh = n ~/ 100000;
    n %= 100000;
    final thousand = n ~/ 1000;
    n %= 1000;
    final hundred = n ~/ 100;
    n %= 100;

    final parts = <String>[
      if (crore > 0) '${_twoDigits(crore)} Crore',
      if (lakh > 0) '${_twoDigits(lakh)} Lakh',
      if (thousand > 0) '${_twoDigits(thousand)} Thousand',
      if (hundred > 0) '${_twoDigits(hundred)} Hundred',
      if (n > 0) _twoDigits(n),
    ];
    return parts.join(' ').trim();
  }

  static String _twoDigits(int n) {
    const ones = <String>[
      '',
      'One',
      'Two',
      'Three',
      'Four',
      'Five',
      'Six',
      'Seven',
      'Eight',
      'Nine',
      'Ten',
      'Eleven',
      'Twelve',
      'Thirteen',
      'Fourteen',
      'Fifteen',
      'Sixteen',
      'Seventeen',
      'Eighteen',
      'Nineteen',
    ];
    const tens = <String>[
      '',
      '',
      'Twenty',
      'Thirty',
      'Forty',
      'Fifty',
      'Sixty',
      'Seventy',
      'Eighty',
      'Ninety',
    ];
    if (n < 20) {
      return ones[n];
    }
    final t = n ~/ 10;
    final o = n % 10;
    if (o == 0) {
      return tens[t];
    }
    return '${tens[t]} ${ones[o]}';
  }
}
