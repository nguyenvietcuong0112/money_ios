import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:money_manager/common/app_translations.dart';
import 'package:money_manager/controllers/app_controller.dart';
import 'package:money_manager/controllers/theme_controller.dart';
import 'package:money_manager/controllers/transaction_controller.dart';
import 'package:money_manager/controllers/wallet_controller.dart';
import 'package:money_manager/models/budget_model.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/models/wallet_model.dart';
import 'package:money_manager/screens/language_selection_screen.dart';
import 'package:money_manager/screens/my_home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final translations = await loadTranslations();

  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);

  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(TransactionTypeAdapter());
  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(WalletAdapter());
  Hive.registerAdapter(BudgetModelAdapter());

  await Hive.openBox<Wallet>('wallets');
  await Hive.openBox<Transaction>('transactions');
  await Hive.openBox<BudgetModel>('budgets');

  final prefs = await SharedPreferences.getInstance();
  final bool isFirstTime = prefs.getBool('isFirstTime') ?? true;
  final String? languageCode = prefs.getString('languageCode');
  final String? countryCode = prefs.getString('countryCode');
  final String? currencyCode = prefs.getString('currencyCode');
  final String? currencySymbol = prefs.getString('currencySymbol');

  Locale? initialLocale;
  if (languageCode != null) {
    initialLocale = Locale(languageCode, countryCode);
  }

  Get.put(AppController(
    initialLocale: initialLocale,
    initialCurrencyCode: currencyCode,
    initialCurrencySymbol: currencySymbol,
  ));
  Get.put(ThemeController());
  Get.put(WalletController());
  Get.put(TransactionController());

  runApp(MyApp(
    isFirstTime: isFirstTime,
    translations: translations,
  ));
}

class MyApp extends StatelessWidget {
  final bool isFirstTime;
  final Map<String, Map<String, String>> translations;

  const MyApp({super.key, required this.isFirstTime, required this.translations});

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    final themeController = Get.find<ThemeController>();

    return GetMaterialApp(
      title: 'Money Manager',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeController.themeMode,
      locale: appController.locale ?? const Locale('vi', 'VN'), // Ngôn ngữ mặc định
      fallbackLocale: const Locale('en', 'US'), // Ngôn ngữ dự phòng
      translations: AppTranslations(translations),
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('vi', 'VN'),
        Locale('zh', 'CN'),
        Locale('hi', 'IN'),
        Locale('es', 'ES'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: isFirstTime
          ? const LanguageSelectionScreen(isInitialSetup: true)
          : const MyHomePage(),
    );
  }
}

// --- Themes --- (Giữ nguyên không đổi)

final TextTheme appTextTheme = TextTheme(
  displayLarge: GoogleFonts.oswald(fontSize: 57, fontWeight: FontWeight.bold),
  titleLarge: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.w500),
  bodyMedium: GoogleFonts.openSans(fontSize: 14),
);

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: Brightness.light,
  ),
  textTheme: appTextTheme,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
    titleTextStyle: GoogleFonts.oswald(fontSize: 24, fontWeight: FontWeight.bold),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: Colors.blue,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      textStyle: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500),
    ),
  ),
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: Brightness.dark,
  ),
  textTheme: appTextTheme,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.grey[900],
    foregroundColor: Colors.white,
    titleTextStyle: GoogleFonts.oswald(fontSize: 24, fontWeight: FontWeight.bold),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.black,
      backgroundColor: Colors.blue,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      textStyle: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500),
    ),
  ),
);
