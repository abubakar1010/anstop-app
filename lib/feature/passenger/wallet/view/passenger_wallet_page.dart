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
    // Deferred to after the first frame: initState runs inside the build
    // phase, and these calls synchronously set isLoading/errorMessage (and on
    // failure show a snackbar), which marked the Obx below dirty mid-build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _walletController.getTransactions();
      _walletController.getBalance();
    });
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
            Obx(() => BalanceCard(
              balance:_walletController.balance.value.toString(),
             // onWithdraw: _showWithdrawDialog,
              onDeposit: () async {
                final result = await Get.toNamed(AppRoutes.addMoneyScreen);
                if (result == true) {
                  _walletController.getTransactions();
                  _walletController.getBalance();
                }
              },
            )),

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

                    final hasMore = _walletController.hasMoreTransactions.value;
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      // One extra row for the "load older" button.
                      itemCount: _walletController.transactions.length + (hasMore ? 1 : 0),
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        if (index == _walletController.transactions.length) {
                          return Center(
                            child: _walletController.isLoadingMoreTransactions.value
                                ? const Padding(
                                    padding: EdgeInsets.all(8),
                                    child: CircularProgressIndicator(),
                                  )
                                : TextButton(
                                    onPressed: _walletController.loadMoreTransactions,
                                    child: Text(AppLocalization.tr.loadOlderTransactionsButton),
                                  ),
                          );
                        }
                        final tx = _walletController.transactions[index];
                        final view = tx.viewFor(_walletController.currentUserId.value);

                        return TransactionItem(
                          title: view.title,
                          time: _formatTransactionTime(tx.createdAt),
                          amount: view.amount.toStringAsFixed(2),
                          isPositive: view.isPositive,
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
      return AppLocalization.tr.todayAtLabel(TimeOfDay.fromDateTime(date).format(context));
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

}