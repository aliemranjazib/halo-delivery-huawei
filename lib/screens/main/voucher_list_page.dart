import 'package:flutter/material.dart';
import 'package:haloapp/components/input_textfield.dart';
import 'package:haloapp/components/model_progress_hud.dart';
import 'package:haloapp/components_new/coupon_card.dart';
import 'package:haloapp/models/coupon_model.dart';
import 'package:haloapp/screens/general/custom_alert_dialog.dart';
import 'package:haloapp/screens/main/voucher_detail_page.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/constants/styles.dart';
import 'package:haloapp/utils/debouncer.dart';
import 'package:haloapp/utils/services/datetime_formatter.dart';

class VoucherListPage extends StatefulWidget {
  static const String id = '/vouchertList';

  VoucherListPage({
    this.coupons,
  });

  final List<Coupon> coupons;

  @override
  _VoucherListPageState createState() => _VoucherListPageState();
}

class _VoucherListPageState extends State<VoucherListPage> {
  bool _showSpinner = false;
  List<Coupon> _coupons = [];
  final _debouncer = Debouncer(delay: Duration(milliseconds: 500));

  @override
  void initState() {
    super.initState();
    _coupons = widget.coupons;
  }

  searchCoupon(String searchText) {
    setState(() {
      _coupons = widget.coupons
          .where((element) => element.couponName
              .toLowerCase()
              .contains(searchText.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: arrowBack,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          AppTranslations.of(context).text('promo_label'),
          style: kAppBarTextStyle,
        ),
      ),
      body: SafeArea(
        child: ModalProgressHUD(
          inAsyncCall: _showSpinner,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InputTextField(
                    hintText:
                        AppTranslations.of(context).text('enter_promo_code'),
                    onChange: (value) {
                      _debouncer.run(() => searchCoupon(value));
                    },
                  ),
                  SizedBox(height: 10),
                  Text(
                    AppTranslations.of(context)
                        .text('available_voucher_for_you'),
                    style: TextStyle(fontFamily: poppinsMedium),
                  ),
                  SizedBox(height: 10),
                  ..._coupons.map((e) => CouponCard(coupon: e))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
