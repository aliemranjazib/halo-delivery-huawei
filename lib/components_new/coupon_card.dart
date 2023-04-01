import 'package:flutter/material.dart';
import 'package:haloapp/models/coupon_model.dart';
import 'package:haloapp/screens/general/custom_alert_dialog.dart';
import 'package:haloapp/screens/main/voucher_detail_page.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';

import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/services/datetime_formatter.dart';

class CouponCard extends StatelessWidget {
  CouponCard({
    this.coupon,
    this.isDetail = false,
  });

  final Coupon coupon;
  final bool isDetail;

  showWarningDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CustomAlertDialog(
        title: AppTranslations.of(context).text('warning'),
        message: coupon.couponInactiveReason,
      ),
    );
  }

  renderValidDate(BuildContext context, Coupon coupon) {
    if (coupon.couponStartedDatetime != null &&
        coupon.couponExpiryDatetime != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${AppTranslations.of(context).text('start')}: ${DatetimeFormatter().getFormattedDateStr(format: 'dd MMM yyyy', datetime: coupon.couponStartedDatetime)}',
            style: TextStyle(
              fontSize: 10,
              fontFamily: poppinsRegular,
              color: Colors.grey,
            ),
          ),
          Text(
            '${AppTranslations.of(context).text('end')}: ${DatetimeFormatter().getFormattedDateStr(format: 'dd MMM yyyy', datetime: coupon.couponExpiryDatetime)}',
            style: TextStyle(
              fontSize: 10,
              fontFamily: poppinsRegular,
              color: Colors.grey,
            ),
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isActive = coupon.couponActiveStatus.toLowerCase() == 'active';
    return Opacity(
      opacity: (isActive || isDetail) ? 1 : 0.4,
      child: GestureDetector(
        onTap: () async {
          if (!isDetail) {
            var isApply = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VoucherDetailsPage(
                  coupon: coupon,
                ),
              ),
            );

            if (isApply == true) {
              Navigator.pop(context, coupon);
            }
          }
        },
        child: Container(
          height: 90,
          margin: EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Color(0xffFC8D0D),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        coupon.couponType.toLowerCase() == 'percentage'
                            ? '${coupon.couponDiscount.split('.')[0]} %'
                            : '${AppTranslations.of(context).text('currency_my')} ${coupon.couponDiscount}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize:
                              coupon.couponType.toLowerCase() == 'percentage'
                                  ? 25
                                  : 16,
                          fontFamily: poppinsSemiBold,
                        ),
                      ),
                      Text(
                        AppTranslations.of(context).text('offer'),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontFamily: poppinsMedium,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(width: 4),
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Color(0xffF8F0E7),
                  ),
                  child: Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              coupon.couponName.toUpperCase(),
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: poppinsSemiBold,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '${AppTranslations.of(context).text('currency_my')} ${coupon.couponMinPurchase} Min Spend',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontFamily: poppinsRegular,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            renderValidDate(context, coupon),
                          ],
                        ),
                      ),
                      if (!isDetail)
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () {
                              if (isActive) {
                                Navigator.pop(context, coupon);
                              } else {
                                showWarningDialog(context);
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 5,
                                horizontal: 10,
                              ),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                                color: Colors.white,
                                border: Border.all(
                                  width: 1,
                                  color: Colors.black,
                                ),
                              ),
                              child: Text(
                                AppTranslations.of(context).text('use_now'),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontFamily: poppinsMedium,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
