import 'package:flutter/material.dart';
import 'package:haloapp/components/action_button.dart';

import 'package:haloapp/components/model_progress_hud.dart';
import 'package:haloapp/components_new/coupon_card.dart';
import 'package:haloapp/components_new/shadow_card.dart';
import 'package:haloapp/models/coupon_model.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/constants/styles.dart';

class VoucherDetailsPage extends StatefulWidget {
  static const String id = '/vouchertList';

  VoucherDetailsPage({
    this.coupon,
  });

  final Coupon coupon;

  @override
  _VoucherDetailsPageState createState() => _VoucherDetailsPageState();
}

class _VoucherDetailsPageState extends State<VoucherDetailsPage> {
  bool _showSpinner = false;

  @override
  Widget build(BuildContext context) {
    bool isActive = widget.coupon.couponActiveStatus.toLowerCase() == 'active';

    return Scaffold(
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        margin: EdgeInsets.symmetric(vertical: 6.0, horizontal: 20),
        child: ActionButton(
          buttonText: AppTranslations.of(context).text('apply_voucher'),
          onPressed: isActive
              ? () {
                  Navigator.pop(context, true);
                }
              : null,
        ),
      ),
      body: SafeArea(
        top: false,
        child: ModalProgressHUD(
          inAsyncCall: _showSpinner,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 170 + MediaQuery.of(context).padding.top,
                      decoration: kAppBarGradient,
                    ),
                    Positioned.fill(
                      top: 100 + MediaQuery.of(context).padding.top,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        height: double.infinity,
                        color: Colors.white,
                      ),
                    ),
                    Positioned(
                      top: 30+MediaQuery.of(context).padding.top,
                      left: 0,
                      right: 0,
                      child: ShadowCard(
                        showShadow: false,
                        child: CouponCard(
                          coupon: widget.coupon,
                          isDetail: true,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: IconButton(
                            icon: Icon(
                              Icons.chevron_left,
                              size: 36,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.pop(context, false);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                  child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 22.0,
                  vertical: 10.0,
                ),
                color: Colors.white,
                child: Text(
                  widget.coupon.couponDescription,
                  style: TextStyle(
                    fontFamily: poppinsRegular,
                    color: Colors.black,
                  ),
                ),
              ))
            ],
          ),
        ),
      ),
    );
  }
}
