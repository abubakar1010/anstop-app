import 'package:ride_sharing/services/session_controller.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ride_sharing/app/helpers/prefs_helper.dart';
import 'package:ride_sharing/app/utils/app_snackbar.dart';
import 'package:ride_sharing/custom_assets/app_image.dart';
import 'package:ride_sharing/routes/app_routes.dart';
import 'package:ride_sharing/services/api_client.dart';
import 'package:ride_sharing/services/api_urls.dart';
import 'package:ride_sharing/services/socket_services.dart';
import 'package:ride_sharing/utils/user_info_section.dart';
import 'package:ride_sharing/widgets/auth_links/auth_link.dart';
import 'package:ride_sharing/widgets/custom_horizontal_line.dart';
import 'package:ride_sharing/widgets/custom_vertical_line.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';
import 'package:ride_sharing/app/helpers/price_format.dart';

class PassengerPaymentScreen extends StatefulWidget {
  final String driverName;
  final String? driverProfilePicture;
  final double driverRating;
  final int driverTotalReviews;
  final String bidAmount;
  final String tripDistance;
  final String pickUpAddress;
  final String destinationAddress;
  final String paymentMethod; // WALLET, CASH, CARD from socket
  final String rideId;
  final String driverId;

  const PassengerPaymentScreen({
    super.key,
    this.driverName = '',
    this.driverProfilePicture,
    this.driverRating = 0.0,
    this.driverTotalReviews = 0,
    this.bidAmount = '',
    this.tripDistance = '',
    this.pickUpAddress = '',
    this.destinationAddress = '',
    this.paymentMethod = '',
    this.rideId = '',
    this.driverId = '',
  });

  @override
  State<PassengerPaymentScreen> createState() => _PassengerPaymentScreenState();
}

class _PassengerPaymentScreenState extends State<PassengerPaymentScreen> {
  bool _isProcessingPayment = false;
  double _selectedRating = 4.0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmittingRating = false;
  final _logger = Logger();

  @override
  void initState() {
    super.initState();
    _initPaymentConfirmedListener();
  }

  @override
  void dispose() {
    SocketIoService.to.offPaymentConfirmed();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitRating(BuildContext dialogContext) async {
    if (_isSubmittingRating) return;
    setState(() => _isSubmittingRating = true);

    try {
      final accessToken = await SessionController.to.accessToken();
      _logger.i('Submitting rating — rideId: ${widget.rideId}, revieweeId (driverId): ${widget.driverId}, rating: $_selectedRating');
      final response = await ApiClient().postRequest(
        ApiUrls.createReview,
        body: {
          'rideId': widget.rideId,
          'revieweeId': widget.driverId,
          'rating': _selectedRating,
          'comment': _commentController.text.trim(),
        },
        accessToken: accessToken,
      );

      if (!mounted) return;

      if (response.isSuccess) {
        _showThankYouDialog(dialogContext);
      } else {
        AppSnackbar.snackbar(
          AppLocalization.tr.errorTitle,
          AppLocalization.tr.genericErrorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.snackbar(
          AppLocalization.tr.errorTitle,
          AppLocalization.tr.ratingSubmitFailedMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmittingRating = false);
    }
  }

  void _initPaymentConfirmedListener() {
    SocketIoService.to.onPaymentConfirmed((data) {
      if (mounted) {
        AppSnackbar.snackbar(
          AppLocalization.tr.paymentConfirmedTitle,
          AppLocalization.tr.paymentConfirmedMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        _showRatingDialog(context);
      }
    });
  }

  bool _requiresOnlinePayment() {
    final method = widget.paymentMethod.toUpperCase();
    return method == 'WALLET' || method == 'CARD';
  }

  // Calls POST /ride-requests/pay-ride-fare/{rideId}
  // ok is false when the request failed (the error has already been shown).
  // For CARD/WALLET: url is the Stripe Checkout URL from the response
  // For CASH: notifies the server and url is null
  Future<({bool ok, String? url})> _callPayRideFareApi(BuildContext context) async {
    final accessToken = await SessionController.to.accessToken();
    final apiClient = ApiClient();
    final response = await apiClient.postRequest(
      ApiUrls.payRideFare(widget.rideId),
      body: {},
      accessToken: accessToken,
    );

    if (!response.isSuccess) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.errorMessage,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Colors.white,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            duration: const Duration(seconds: 4),
            elevation: 8,
          ),
        );
      }
      return (ok: false, url: null);
    }

    // Extract checkout URL from response data
    final data = response.responseData?['data'];
    if (data != null && data is Map<String, dynamic>) {
      return (ok: true, url: data['url'] as String?);
    }
    return (ok: true, url: null);
  }

  // This screen is reached via Get.offAll, so it is the only route: popping
  // it would close the app. Leave to the home screen instead.
  void _leaveToHome() => Get.offAllNamed(AppRoutes.passengerHomeScreen);

  Future<void> _handleConfirmPayment(BuildContext context) async {
    if (_isProcessingPayment) return;

    setState(() => _isProcessingPayment = true);

    try {
      if (_requiresOnlinePayment()) {
        // CARD / WALLET: call API → get Stripe Checkout URL → open in browser
        final result = await _callPayRideFareApi(context);
        // A failed request has already shown the server's reason.
        if (!result.ok) return;
        final checkoutUrl = result.url;
        if (checkoutUrl == null || checkoutUrl.isEmpty) {
          // The request succeeded but carried no checkout URL. Staying silent
          // here is what made this look like "the button does nothing" — say
          // so instead, and log the payload for whoever is debugging.
          _logger.e(
            'pay-ride-fare returned no checkout URL for rideId=${widget.rideId}, '
            'method=${widget.paymentMethod}',
          );
          if (mounted) {
            AppSnackbar.error(
              AppLocalization.tr.errorTitle,
              AppLocalization.tr.paymentLinkMissingMessage,
            );
          }
          return;
        }

        final uri = Uri.parse(checkoutUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (mounted) {
            AppSnackbar.error(
              AppLocalization.tr.errorTitle,
              AppLocalization.tr.paymentLinkOpenFailedMessage,
            );
          }
        }
      } else {
        // CASH: notify server then show rating dialog immediately
        await _callPayRideFareApi(context);
        if (context.mounted) {
          _showRatingDialog(context);
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessingPayment = false);
      }
    }
  }

  String _formatPaymentMethod(String method) {
    switch (method.toUpperCase()) {
      case 'CARD':
        return AppLocalization.tr.paymentMethodCard.toLowerCase();
      case 'CASH':
        return AppLocalization.tr.paymentMethodCash.toLowerCase();
      default:
        return AppLocalization.tr.paymentMethodWallet.toLowerCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    // final displayName = widget.driverName.isNotEmpty ? widget.driverName : 'John Doe';
    final displayName = widget.driverName;
    // final displayImageUrl = widget.driverProfilePicture ?? 'https://picsum.photos/250?image=9';
    final displayImageUrl = widget.driverProfilePicture ?? '';
    // final displayRating = widget.driverRating > 0 ? widget.driverRating : 3.54;
    final displayRating = widget.driverRating;
    // final displayTrips = widget.driverTotalReviews > 0 ? widget.driverTotalReviews : 3;
    final displayTrips = widget.driverTotalReviews;
    // final displayPrice = widget.bidAmount.isNotEmpty ? '€${widget.bidAmount}' : '€24';
    final displayPrice = widget.bidAmount.isNotEmpty ? formatPrice(widget.bidAmount) : '';
    // final displayDistance = widget.tripDistance.isNotEmpty ? '${widget.tripDistance} km' : '28 km';
    final displayDistance = widget.tripDistance.isNotEmpty ? '${widget.tripDistance} km' : '';
    final displayPickup = widget.pickUpAddress.isNotEmpty
        ? widget.pickUpAddress
        : AppLocalization.tr.pickupLocationExample;
    final displayDestination = widget.destinationAddress.isNotEmpty
        ? widget.destinationAddress
        : AppLocalization.tr.dropoffLocationExample;
    final displayPaymentMethod = AppLocalization.tr.payViaLabel(_formatPaymentMethod(widget.paymentMethod));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leaveToHome();
      },
      child: Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      appBar: AppBar(
        leading: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: const BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _leaveToHome,
          ),
        ),
        backgroundColor: const Color(0xFFEEEEEE),
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 50, color: Colors.transparent),
          Container(
            color: AppColors.white,
            child: UserInfoSection(
              imageUrl: displayImageUrl,
              name: displayName,
              rating: displayRating,
              trips: displayTrips,
              profession: AppLocalization.tr.professionalLabel,
              price: displayPrice,
              distance: displayDistance,
            ),
          ),
          SizedBox(height: 8.sp),
          CustomHorizontalLine(thickness: 20.sp),
          Container(
            color: AppColors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalization.tr.yourTripLabel,
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.sp),
                  Row(children: [
                    Image.asset(AppImage.greetings),
                    SizedBox(width: 5.sp),
                    Expanded(
                      child: Text(
                        displayPickup,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ]),
                  CustomVerticalLine(height: 20.h, color: Colors.black),
                  Row(children: [
                    Icon(Icons.location_on, color: AppColors.green300),
                    SizedBox(width: 5.sp),
                    Expanded(
                      child: Text(
                        displayDestination,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ]),
                  SizedBox(height: 8.sp),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalization.tr.distanceLabel,
                        style: TextStyle(fontSize: 18.sp, color: Colors.black),
                      ),
                      SizedBox(width: 5.sp),
                      Text(displayDistance),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalization.tr.timeExample,
                        style: TextStyle(fontSize: 18.sp, color: Colors.black),
                      ),
                      SizedBox(width: 5.sp),
                      Text(AppLocalization.tr.durationExample),
                    ],
                  ),
                ],
              ),
            ),
          ),
          CustomHorizontalLine(thickness: 20.sp),
          Container(
            color: AppColors.white,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Image.asset(AppImage.wallet),
                  SizedBox(width: 2.sp),
                  Text(displayPaymentMethod, style: TextStyle(fontSize: 20.sp)),
                  const Spacer(),
                  Text(displayPrice, style: TextStyle(fontSize: 20.sp)),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: CustomButton(
          onPressed: _isProcessingPayment
              ? null
              : () => _handleConfirmPayment(context),
          title: _isProcessingPayment
              ? SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: CircularProgressIndicator(
                    color: AppColors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  AppLocalization.tr.confirmPaymentTitle,
                  style: const TextStyle(color: AppColors.white),
                ),
        ),
      ),
      ),
    );
  }

  void _showRatingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
                child: Stack(
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          AppLocalization.tr.giveYourRatingsLabel,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    RatingBar.builder(
                      initialRating: _selectedRating,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemSize: 30.0,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        setDialogState(() => _selectedRating = rating);
                      },
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _commentController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: AppLocalization.tr.writeCommentsHint,
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.all(10),
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      onPressed: _isSubmittingRating
                          ? null
                          : () => _submitRating(context),
                      title: _isSubmittingRating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: AppColors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              AppLocalization.tr.submitButton,
                              style: TextStyle(fontSize: 20, color: AppColors.white),
                            ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        );
          },
        );
      },
    );
  }

  void _showThankYouDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          contentPadding: EdgeInsets.zero,
          content: SizedBox(
            height: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Image.asset(
                    AppImage.thankyou,
                    height: 100,
                    width: 100,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    AppLocalization.tr.thankYouFeedbackAndTipMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: CustomButton(
                    onPressed: () => Get.offAllNamed(AppRoutes.passengerHomeScreen),
                    title: Text(
                      AppLocalization.tr.backToHomeButton,
                      style: const TextStyle(fontSize: 20, color: AppColors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
