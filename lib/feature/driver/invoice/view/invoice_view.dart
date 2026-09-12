import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ride_sharing/app/utils/app_colors.dart';
import 'package:ride_sharing/widgets/auth_links/auth_link.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';

class InvoicePage extends StatelessWidget {
  const InvoicePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Invoice Card
              Container(
               // height: MediaQuery.of(context).size.height * 0.5,
                margin:  EdgeInsets.symmetric(horizontal: 16.sp),
                padding:  EdgeInsets.all(24.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Logo
                    IconWidget(
                      height: 40.h,
                      width: 42.w,
                      fontSize: 15.sp,
                    ),

                    const SizedBox(height: 16),

                    // Title
                    const Text(
                      'SIMPLIFIED TAX INVOICE',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Supplier Information
                    _buildInfoRow(
                      'Supplier Name',
                      'Electronic Speed Trading Company',
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      'Address',
                      'Al-manna Trading Company\nAl Fakir Street, South Hoifa Mall, PO\nBox 32002, Jeddah 21425, Saudi\nArabia',
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      'VAT Number',
                      '300997189500003',
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      'Invoice Number',
                      'JNYD-AAAABIJ-335687',
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      'Invoice Issuance Date',
                      '2024-08-09',
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      'Customer Name',
                      'Salem',
                    ),

                    const SizedBox(height: 24),

                    // Details Section
                    Container(
                    //  padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(

                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalization.tr.detailsLabel,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Table Header
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 5,
                            ),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryColor,

                            ),
                            child:  Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    'Name of Service',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Unit\nPrice',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    AppLocalization.tr.quantityLabel,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Subtotal\n(Excl. VAT)',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Subtotal\n(Incl. VAT)',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Table Row
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,

                            ),
                            child: const Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    'Ride Hailing\nSurcharge',
                                    style: TextStyle(
                                      fontSize: 11,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '0.5 SAR',
                                    style: TextStyle(
                                      fontSize: 11,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '1',
                                    style: TextStyle(
                                      fontSize: 11,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '0.5 SAR',
                                    style: TextStyle(
                                      fontSize: 11,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '0.575 SAR',
                                    style: TextStyle(
                                      fontSize: 11,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                     SizedBox(height: 5.h),

                    // Total Amounts Section
                    Container(
                     // padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                       // color: const Color(0xFFF8F9FA),
                       // borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                           Container(
                             height: 20.h ,
                             padding: EdgeInsets.symmetric(horizontal: 8),
                             decoration: BoxDecoration(

                               color:  AppColors.primaryColor,
                              // borderRadius: BorderRadius.circular(8),
                             ),
                             child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Total Amounts:',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white
                                ),
                              ),
                                                       ),
                           ),
                          const SizedBox(height: 12),
                          _buildTotalRow(
                            'Total (Excluding VAT)',
                            '0.5 SAR',
                          ),
                          const SizedBox(height: 8),
                          _buildTotalRow(
                            'Total VAT',
                            '0.075 SAR',
                          ),
                          const SizedBox(height: 8),
                          _buildTotalRow(
                            'Total Amount Due',
                            '0.575 SAR',
                            isBold: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // QR Code
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: const Color(0xFFE0E0E0),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Container(
                        width: 50.w,
                        height: 50.h,
                        color: Colors.black,
                        child: const Center(
                          child: Text(
                            'QR',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Thank You Message
                    const Text(
                      'Thank you for using Dara',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Divider
                    Container(
                      height: 1,
                      color: const Color(0xFFE0E0E0),
                    ),

                    const SizedBox(height: 12),

                    // Footer Text
                    const Text(
                      'This is a system-generated document.\nNo stamp or signature is required.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF757575),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

            //  const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF757575),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}