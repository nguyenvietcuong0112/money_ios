import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:money_manager/common/color.dart';
import 'package:money_manager/common/text_styles.dart';
import 'package:money_manager/controllers/app_controller.dart';
import 'package:money_manager/controllers/wallet_controller.dart';
import 'package:money_manager/screens/add_wallet_screen.dart';
import 'package:money_manager/screens/wallet_detail_screen.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final WalletController walletController = Get.find();
    final AppController appController = Get.find();

    return Scaffold(
      backgroundColor: AppColors.textColorGreyContainer,
      appBar: AppBar(
        title: Text('my_wallet'.tr, style: AppTextStyles.title), // Dịch
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Obx(() {
              return _buildTotalBalanceCard(
                  context, walletController.totalBalance, appController);
            }),
            const SizedBox(height: 24.0),
            Expanded(
              child: Obx(() {
                return ListView.builder(
                  itemCount: walletController.wallets.length,
                  itemBuilder: (context, index) {
                    final wallet = walletController.wallets[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12)
                      ),
                      margin: EdgeInsets.only(bottom: 5.h),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10.0),
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey.shade100,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SvgPicture.asset(wallet.iconPath),
                          ),
                        ),
                        title: Text(wallet.name,
                            style: AppTextStyles.body
                                .copyWith(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          '${wallet.balance.toStringAsFixed(0)} ${appController.currencySymbol}',
                          style: AppTextStyles.body.copyWith(
                            color: wallet.balance < 0
                                ? AppColors.textColorRed
                                : AppColors.textColorGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios,
                            size: 16, color: Colors.grey),
                        onTap: () {
                          Get.to(() => WalletDetailScreen(wallet: wallet));
                        },
                      ),
                    );
                  },
                );
              }),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Get.to(() => const AddWalletScreen());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E9E54),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28.0),
                ),
              ),
              child: Text(
                '+ ${('add_wallet'.tr)}',
                style: AppTextStyles.button.copyWith(fontSize: 18),
              ),
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalBalanceCard(
      BuildContext context, double totalBalance, AppController appController) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w,vertical: 10.h),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          SvgPicture.asset(
            "assets/icons/ic_total.svg",
            width: 50.w,
            height: 50.w,
          ),
          const SizedBox(width: 16.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'total_balance'.tr,
                style: AppTextStyles.subtitle
                    .copyWith(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4.0),
              Text(
                '${totalBalance.toStringAsFixed(0)} ${appController.currencySymbol}',
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.textColorBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
