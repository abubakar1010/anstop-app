import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ride_sharing/widgets/auth_links/auth_link.dart';

class TripIdWidget extends StatelessWidget {


  // Constructor
  TripIdWidget({
    Key? key,

  }) : super(key: key);
  final TextEditingController supportNoteTEController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(

      child: Padding(
        padding:  EdgeInsets.symmetric(horizontal: 20.sp),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
             crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalization.tr.tripIdLabel,style: TextStyle(fontSize: 15.sp,fontWeight: FontWeight.bold),),
                SizedBox(height: 2.h,),
                Text(AppLocalization.tr.tripIdExample,style: TextStyle(fontSize: 20.sp,fontWeight: FontWeight.bold),),


              ],
            ),
            Spacer(),
            GestureDetector(
              onTap: (){},
              child: Icon(Icons.copy,color: AppColors.appGreyColor,),
            )
          ],
        ),
      ),
    );
  }
}
