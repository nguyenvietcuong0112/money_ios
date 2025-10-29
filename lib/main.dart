import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_localizations.dart';
import 'models/transaction_model.dart';
import 'models/budget_model.dart';
import 'providers/app_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'screens/transactions_screen.dart';
import 'screens/budget_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/language_selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TransactionModelAdapter());
  Hive.registerAdapter(BudgetModelAdapter());
  await Hive.openBox<TransactionModel>('transactions');
  await Hive.openBox<BudgetModel>('budgets');

  final prefs = await SharedPreferences.getInstance();
  final isSetupComplete = prefs.getBool('is_setup_complete') ?? false;
  final languageCode = prefs.getString('language_code') ?? 'en';
  final currencyCode = prefs.getString('currency_code') ?? 'USD';

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) => AppProvider()
            ..setLocale(Locale(languageCode, ''))
            ..setCurrency(currencyCode),
        ),
      ],
      child: MyApp(isSetupComplete: isSetupComplete),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isSetupComplete;
  const MyApp({super.key, required this.isSetupComplete});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, AppProvider>(
      builder: (context, themeProvider, appProvider, child) {
        return MaterialApp(
          title: 'Money Manager',
          theme: ThemeData(
            primarySwatch: Colors.green,
            textTheme: GoogleFonts.latoTextTheme(
              Theme.of(context).textTheme,
            ),
          ),
          darkTheme: ThemeData.dark(),
          themeMode: themeProvider.themeMode,
          locale: appProvider.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            // Add other delegates here
          ],
          supportedLocales: const [
            Locale('en', ''),
            Locale('vi', ''),
            Locale('fr', ''),
          ],
          home: isSetupComplete ? const MainScreen() : const LanguageSelectionScreen(),
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    TransactionsScreen(),
    BudgetScreen(),
    StatisticsScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: localizations.translate('home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: localizations.translate('transactions'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: localizations.translate('budget'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: localizations.translate('statistics'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: localizations.translate('settings'),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
