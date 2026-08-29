import 'package:intl/intl.dart';

/// Shared date/price formatting for the booking flow, replacing the
/// hand-rolled month-name lists and price regexes that were duplicated
/// across the state and view files.
class BookingFormats {
  BookingFormats._();

  static final DateFormat _date = DateFormat('MMM d, y');
  static final NumberFormat _price = NumberFormat('#,##0');

  static String date(DateTime date) => _date.format(date);

  static String price(num value) => '\$${_price.format(value)}';

  static String money(num value, String currency) =>
      '\$${_price.format(value)}';
}
