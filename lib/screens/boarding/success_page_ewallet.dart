import 'package:flutter/material.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/models/top_up_method_model.dart';
import 'package:haloapp/screens/boarding/location_access_page.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/components/model_progress_hud.dart';
import 'package:haloapp/utils/constants/payment_method.dart';
import 'package:haloapp/utils/constants/styles.dart';
import 'package:haloapp/utils/utils.dart';

class SuccessEwalletPage extends StatefulWidget {
  static const String id = 'successEwalletPage';

  final bool status;
  final double topUpAmount;
  final String dateTime;
  final String refNo;
  final TopUpMethodModel topUpMethodModel;

  SuccessEwalletPage({
    @required this.status,
    @required this.topUpAmount,
    @required this.dateTime,
    @required this.refNo,
    @required this.topUpMethodModel,
  });

  @override
  _SuccessEwalletPageState createState() => _SuccessEwalletPageState();
}

class _SuccessEwalletPageState extends State<SuccessEwalletPage> {
  bool _showSpinner = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            centerTitle: true,
            leading: IconButton(
              icon: arrowBack,
              onPressed: () => {Navigator.pop(context)},
            ),
            title: Text(
              AppTranslations.of(context).text('success_title'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              // IconButton(
              //   icon: Icon(
              //     Icons.close,
              //     color: Colors.white,
              //   ),
              //   onPressed: () => {},
              // ),
            ],
          ),
          body: ModalProgressHUD(
            inAsyncCall: _showSpinner,
            child: SafeArea(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    getContainer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        ActionButton(
                          onPressed: () {
                            Navigator.pop(
                                context, widget.status ? "success" : "retry");
                          },
                          buttonText: widget.status
                              ? AppTranslations.of(context).text('confirm')
                              : AppTranslations.of(context).text('btn_retry'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getContainer() {
    if (widget.status) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            child: Image.asset(
              'images/success.png',
              fit: BoxFit.contain,
              width: 200.0,
              height: 200.0,
            ) /* add child content here */,
          ),
          Text(
            AppTranslations.of(context).text('title_topup_success'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: poppinsRegular,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          Container(
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
                color: light3Grey,
                borderRadius: BorderRadius.all(Radius.circular(6.0)),
                boxShadow: [elevation]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppTranslations.of(context).text('title_order_summary'),
                  textAlign: TextAlign.center,
                  style: kLabelSemiBoldTextStyle,
                ),
                SizedBox(
                  height: 10.0,
                ),
                Row(
                  children: [
                    Text(
                      AppTranslations.of(context).text('title_date_time'),
                      textAlign: TextAlign.center,
                      style: kDetailsTextStyle,
                    ),
                    Expanded(
                        child: Container(
                      alignment: Alignment.centerRight,
                      child: Text(
                        widget.dateTime,
                        textAlign: TextAlign.end,
                        style: kDetailsSemiBoldTextStyle,
                      ),
                    ))
                  ],
                ),
                SizedBox(
                  height: 10.0,
                ),
                Row(
                  children: [
                    Text(
                      AppTranslations.of(context).text('title_reference_no'),
                      textAlign: TextAlign.center,
                      style: kDetailsTextStyle,
                    ),
                    Expanded(
                        child: Container(
                      alignment: Alignment.centerRight,
                      child: Text(
                        widget.refNo,
                        textAlign: TextAlign.end,
                        style: kDetailsSemiBoldTextStyle,
                      ),
                    ))
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                  height: 1,
                  color: darkGrey,
                ),
                Row(
                  children: [
                    Expanded(
                        child: Row(
                      children: [
                        Image.asset(
                          widget.topUpMethodModel.paymentIcon,
                          width: 50.0,
                          height: 40.0,
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        Text(
                            "${AppTranslations.of(context).text(widget.topUpMethodModel.paymentTitle)}",
                            style: kDetailsTextStyle),
                      ],
                    )),
                    Text(
                      "${AppTranslations.of(context).text('currency_my')} ${Utils.getFormattedPrice(widget.topUpAmount)}",
                      textAlign: TextAlign.end,
                      style: kDetailsSemiBoldTextStyle,
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      );
    } else {
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            child: Image.asset(
              widget.status ? 'images/success.png' : 'images/ic_failed.png',
              fit: BoxFit.contain,
              width: 200.0,
              height: 200.0,
            ) /* add child content here */,
          ),
          Text(
            AppTranslations.of(context).text('success_description'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: poppinsRegular,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            child: Image.asset(
              'images/ic_failed.png',
              fit: BoxFit.contain,
              width: 200.0,
              height: 200.0,
            ) /* add child content here */,
          ),
          Text(
            AppTranslations.of(context).text('title_topup_failed'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: poppinsRegular,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          Container(
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
                color: light3Grey,
                borderRadius: BorderRadius.all(Radius.circular(6.0)),
                boxShadow: [elevation]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppTranslations.of(context).text('title_order_summary'),
                  textAlign: TextAlign.center,
                  style: kLabelSemiBoldTextStyle,
                ),
                SizedBox(
                  height: 10.0,
                ),
                Row(
                  children: [
                    Text(
                      AppTranslations.of(context).text('title_date_time'),
                      textAlign: TextAlign.center,
                      style: kDetailsTextStyle,
                    ),
                    Expanded(
                        child: Container(
                      alignment: Alignment.centerRight,
                      child: Text(
                        widget.dateTime,
                        textAlign: TextAlign.end,
                        style: kDetailsSemiBoldTextStyle,
                      ),
                    ))
                  ],
                ),
                SizedBox(
                  height: 10.0,
                ),
                Row(
                  children: [
                    Text(
                      AppTranslations.of(context).text('title_reference_no'),
                      textAlign: TextAlign.center,
                      style: kDetailsTextStyle,
                    ),
                    Expanded(
                        child: Container(
                      alignment: Alignment.centerRight,
                      child: Text(
                        widget.refNo,
                        textAlign: TextAlign.end,
                        style: kDetailsSemiBoldTextStyle,
                      ),
                    ))
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                  height: 1,
                  color: darkGrey,
                ),
                Row(
                  children: [
                    Expanded(
                        child: Row(
                      children: [
                        Image.asset(
                          widget.topUpMethodModel.paymentIcon,
                          width: 50.0,
                          height: 40.0,
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        Text(
                            "${AppTranslations.of(context).text(widget.topUpMethodModel.paymentTitle)}",
                            style: kDetailsTextStyle),
                      ],
                    )),
                    Text(
                      "${AppTranslations.of(context).text('currency_my')} ${Utils.getFormattedPrice(widget.topUpAmount)}",
                      textAlign: TextAlign.end,
                      style: kDetailsSemiBoldTextStyle,
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      );
    }
  }
}
