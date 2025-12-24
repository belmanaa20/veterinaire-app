import 'package:intl/intl.dart';

class Formatters {
  static final _currencyFormat = NumberFormat.currency(
    locale: 'fr_FR',
    symbol: 'DH',
    decimalDigits: 2,
  );

  static final _dateFormat = DateFormat('dd/MM/yyyy', 'fr_FR');
  static final _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm', 'fr_FR');

  static String formatCurrency(double amount) {
    return _currencyFormat.format(amount);
  }

  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }

  static String formatNumber(double number, {int decimals = 2}) {
    return number.toStringAsFixed(decimals);
  }
}
