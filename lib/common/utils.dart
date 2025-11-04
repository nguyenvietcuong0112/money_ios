
import 'package:currency_picker/currency_picker.dart';

class Utils {
  static String currencyToEmoji(Currency currency) {
    // Special case for Euro
    if (currency.code == 'EUR') {
      return '🇪🇺';
    }
    // Use the first two letters of the currency code to create the flag emoji
    String countryCode = currency.code.substring(0, 2);
    return countryCode.toUpperCase().replaceAllMapped(RegExp(r'[A-Z]'),
        (match) => String.fromCharCode(match.group(0)!.codeUnitAt(0) + 127397));
  }
}
