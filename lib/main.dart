
import 'package:flutter/material.dart';
import 'package:money_manager/providers/app_provider.dart';
import 'package:money_manager/providers/budget_provider.dart';
import 'package:money_manager/providers/theme_provider.dart';
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppProvider(
          initialLocale: language != null ? Locale(language!) : null,
          initialCurrency: currency,
        )),
        ChangeNotifierProvider(create: (context) => BudgetProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return MaterialApp(
                title: 'Money Manager',
                theme: ThemeData(
                  primarySwatch: Colors.blue,
                  visualDensity: VisualDensity.adaptivePlatformDensity,
                  brightness: Brightness.light,
                ),
                darkTheme: ThemeData(
                  primarySwatch: Colors.blue,
                  visualDensity: VisualDensity.adaptivePlatformDensity,
                  brightness: Brightness.dark,
                ),
                themeMode: themeProvider.themeMode,
                locale: appProvider.locale,
                supportedLocales: const [Locale('en', ''), Locale('fr', ''), Locale('vi', '')],
                home: isFirstTime ? const LanguageSelectionScreen() : const MyHomePage(),
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

  static final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(),
    const TransactionsScreen(),
    const BudgetScreen(),
    const StatisticsScreen(),
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    developer.log('Tapped index: $index', name: 'MyHomePage');
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    developer.log('Building with selected index: $_selectedIndex', name: 'MyHomePage');
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'Budget',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Statistics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
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
