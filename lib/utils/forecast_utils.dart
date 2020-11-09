import 'package:intl/intl.dart';

class Utils {
  static String appId = 'ed60fcfbd110ee65c7150605ea8aceea';
  static String getFormattedDate(DateTime dateTime) {
    return new DateFormat("EEE, MMM d, ''y'").format(dateTime);
  }
}
