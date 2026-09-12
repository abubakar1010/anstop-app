import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing/feature/passenger/wallet/view/passenger_wallet_dialog_view.dart';
import 'package:ride_sharing/feature/wallet/controller/wallet_controller.dart';
import 'package:ride_sharing/routes/app_routes.dart';
import 'package:ride_sharing/utils/balanced_card.dart';
import 'package:ride_sharing/utils/passenger/passenger_custom_drawer.dart';
import 'package:ride_sharing/utils/transaction_items.dart';
import 'package:ride_sharing/widgets/custom_app_bar_title.dart';
import '../../../../app/utils/app_colors.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';


class PassengerWalletPage extends StatefulWidget {
   PassengerWalletPage({Key? key}) : super(key: key);
  @override
  State<PassengerWalletPage> createState() => _PassengerWalletPageState();
}

class _PassengerWalletPageState extends State<PassengerWalletPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final WalletController _walletController = Get.put(WalletController());

  void _showWithdrawDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => WithdrawDialog(
        onConfirm: () {
          Navigator.pop(context);
          _showSuccessDialog();
        },
        onCancel: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => WithdrawSuccessDialog(
        onGoToWallet: () {
          Navigator.pop(context);
        },
      ),
    );
  }
  @override
  void initState() {
    super.initState();
    _walletController.getTransactions();
    _walletController.getBalance();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: PassengerCustomDrawer(),
      backgroundColor: AppColors.backgroundColor,
      appBar:  CustomAppBarTitle(
        scaffoldKey: _scaffoldKey,
        title: AppLocalization.tr.walletTitle,
        titleColor: AppColors.blackShade300,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Balance Card
            BalanceCard(
              balance:_walletController.balance.value.toString(),
             // onWithdraw: _showWithdrawDialog,
            ),

            const SizedBox(height: 32),

            // Transactions Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalization.tr.transactionsTitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Transaction List
                  Obx(() {
                    if (_walletController.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (_walletController.transactions.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text(
                            AppLocalization.tr.noTransactionsMessage,
                            style: TextStyle(color: AppColors.secondaryText),
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _walletController.transactions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final tx = _walletController.transactions[index];

                        return TransactionItem(
                          title: tx.type == 'DEPOSIT' ? 'Wallet Deposit' : 'Wallet Withdrawal',
                          time: _formatTransactionTime(tx.createdAt),
                          amount: tx.amount.toStringAsFixed(2),
                          isPositive: tx.type == 'DEPOSIT',
                        );
                      },
                    );
                  }),


                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTransactionTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today at ${TimeOfDay.fromDateTime(date).format(context)}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

}