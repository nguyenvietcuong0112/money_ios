import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_manager/localization/app_localizations.dart';
import 'package:money_manager/providers/app_provider.dart';
import 'package:money_manager/providers/budget_provider.dart';
import 'package:money_manager/providers/theme_provider.dart';
import 'package:money_manager/providers/wallet_provider.dart';
import 'package:money_manager/providers/transaction_provider.dart';
import 'package:money_manager/screens/screens.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final isFirstTime = prefs.getBool('isFirstTime') ?? true;
  final language = prefs.getString('language');
  final currency = prefs.getString('currency');

  runApp(MyApp(
    isFirstTime: isFirstTime,
    language: language,
    currency: currency,
  ));
}

class MyApp extends StatelessWidget {
  final bool isFirstTime;
  final String? language;
  final String? currency;

  const MyApp({
    super.key,
    required this.isFirstTime,
    this.language,
    this.currency,
  });

  @override
  Widget build(BuildContext context) {
    const Color primarySeedColor = Colors.blue;

    final TextTheme appTextTheme = TextTheme(
      displayLarge:
          GoogleFonts.oswald(fontSize: 57, fontWeight: FontWeight.bold),
      titleLarge:
          GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.w500),
      bodyMedium: GoogleFonts.openSans(fontSize: 14),
    );

    final ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.light,
      ),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: primarySeedColor,
        foregroundColor: Colors.white,
        titleTextStyle:
            GoogleFonts.oswald(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: primarySeedColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle:
              GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );

    final ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.dark,
      ),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        titleTextStyle:
            GoogleFonts.oswald(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: primarySeedColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle:
              GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => AppProvider(
                  initialLocale: language != null ? Locale(language!) : null,
                  initialCurrency: currency,
                )),
        ChangeNotifierProvider(create: (context) => BudgetProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => WalletProvider()),
        ChangeNotifierProvider(create: (context) => TransactionProvider()),
      ],
      child: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return MaterialApp(
                title: 'Money Manager',
                theme: lightTheme,
                darkTheme: darkTheme,
                themeMode: themeProvider.themeMode,
                locale: appProvider.locale,
                supportedLocales: const [
                  Locale('en', ''),
                  Locale('fr', ''),
                  Locale('vi', '')
                ],
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                home: const LanguageSelectionScreen(isInitialSetup: true),
              );
            },
          );
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    RecordScreen(),
    WalletScreen(),
    StatisticsScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    developer.log('Tapped index: $index', name: 'MyHomePage');
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    developer.log('Building with selected index: $_selectedIndex',
        name: 'MyHomePage');
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: localizations?.translate('home') ?? 'Home',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.edit_calendar_outlined),
            label: localizations?.translate('transactions') ?? 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.account_balance_wallet),
            label: localizations?.translate('my_wallet') ?? 'My Wallet',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.bar_chart),
            label: localizations?.translate('statistics') ?? 'Statistics',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: localizations?.translate('settings') ?? 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        showUnselectedLabels: true,
      ),
    );
  }
}
