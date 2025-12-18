import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:money_manager/common/color.dart';
import 'package:money_manager/controllers/wallet_controller.dart';
import 'package:money_manager/screens/home_screen.dart';
import 'package:money_manager/screens/more_screen.dart';
import 'package:money_manager/screens/record_screen.dart';
import 'package:money_manager/screens/report_screen.dart';
import 'package:money_manager/screens/wallet_screen.dart';
import 'dart:developer' as developer;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      HomeScreen(onScreenChanged: _onItemTapped),
      RecordScreen(onScreenChanged: _onItemTapped),
      const WalletScreen(),
      ReportScreen(onScreenChanged: _onItemTapped),
      const MoreScreen(),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<WalletController>().setupInitialWallets(context);
    });
  }

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
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/home.svg',
              colorFilter: const ColorFilter.mode(
                Colors.grey,
                BlendMode.srcIn,
              ),
            ),
            activeIcon: SvgPicture.asset(
              'assets/icons/home.svg',
              colorFilter: const ColorFilter.mode(
                AppColors.colorHeader,
                BlendMode.srcIn,
              ),
            ),
            label: 'home'.tr,
          ),

          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/record.svg',
              colorFilter: const ColorFilter.mode(
                Colors.grey,
                BlendMode.srcIn,
              ),
            ),
            activeIcon: SvgPicture.asset(
              'assets/icons/record.svg',
              colorFilter: ColorFilter.mode(
                AppColors.colorHeader,
                BlendMode.srcIn,
              ),
            ),
            label: 'record'.tr,
          ),

          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/wallet.svg',
              colorFilter: const ColorFilter.mode(
                Colors.grey,
                BlendMode.srcIn,
              ),
            ),
            activeIcon: SvgPicture.asset(
              'assets/icons/wallet.svg',
              colorFilter: const ColorFilter.mode(
                AppColors.colorHeader,
                BlendMode.srcIn,
              ),
            ),
            label: 'my_wallet'.tr,
          ),

          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/report.svg',
              colorFilter: const ColorFilter.mode(
                Colors.grey,
                BlendMode.srcIn,
              ),
            ),
            activeIcon: SvgPicture.asset(
              'assets/icons/report.svg',
              colorFilter: const ColorFilter.mode(
                AppColors.colorHeader,
                BlendMode.srcIn,
              ),
            ),
            label: 'report'.tr,
          ),

          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/more.svg',
              colorFilter: const ColorFilter.mode(
                Colors.grey,
                BlendMode.srcIn,
              ),
            ),
            activeIcon: SvgPicture.asset(
              'assets/icons/more.svg',
              colorFilter: const ColorFilter.mode(
                AppColors.colorHeader,
                BlendMode.srcIn,
              ),
            ),
            label: 'more'.tr,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.colorHeader,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        showUnselectedLabels: true,
        backgroundColor: Colors.white,
      ),
    );
  }
}
