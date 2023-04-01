import 'package:flutter/material.dart';
import 'package:haloapp/components_new/transaction_tag.dart';
import 'package:haloapp/models/top_up_transaction_model.dart';
import 'package:haloapp/models/wallet_transaction_model.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/payment_method.dart';
import 'package:haloapp/utils/constants/styles.dart';
import 'package:haloapp/utils/services/datetime_formatter.dart';

class EwalletTopUpDetailPage extends StatefulWidget {
  static const String id = 'ewalletTopUpDetailPage';

  final WalletTransaction walletTransaction;
  final TopupTransaction topUpTransaction;

  EwalletTopUpDetailPage({this.walletTransaction, this.topUpTransaction});

  @override
  _EwalletTopUpDetailState createState() => _EwalletTopUpDetailState();
}

class _EwalletTopUpDetailState extends State<EwalletTopUpDetailPage> {
  SizedBox space = SizedBox(
    height: 10.0,
  );

  double titleWidth = 130.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: Container(
          child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: arrowBack),
        ),
        title: Text(
            '${AppTranslations.of(context).text("title_transaction_detail")}',
            textAlign: TextAlign.center,
            style: kAppBarTextStyle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child:
              Container(padding: EdgeInsets.all(16.0), child: getContainer()),
        ),
      ),
    );
  }

  Widget getContainer() {
    if (widget.walletTransaction != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: titleWidth,
                child: Text(
                  "${AppTranslations.of(context).text("title_summary")}",
                  style: kLabelSemiBoldTextStyle,
                ),
              ),
              SizedBox(
                width: 10.0,
              ),
              Expanded(
                  child: Container(
                alignment: Alignment.centerRight,
                child: Text(
                  "${widget.walletTransaction.transactionRemark}",
                  textAlign: TextAlign.end,
                  style: kLabelSemiBoldTextStyle,
                ),
              ))
            ],
          ),
          if (widget.topUpTransaction != null) getTransactionTag(),
          space,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: titleWidth,
                child: Text(
                  AppTranslations.of(context).text("${widget.walletTransaction.transactionType}"),
                  style: kLabelSemiBoldTextStyle,
                ),
              ),
              SizedBox(
                width: 10.0,
              ),
              Expanded(
                  child: Container(
                alignment: Alignment.centerRight,
                child: Text(
                  "${AppTranslations.of(context).text("currency_my")} ${widget.walletTransaction.transactionAmount}",
                  textAlign: TextAlign.end,
                  style: kTitleSemiBoldTextStyle.copyWith(
                    color: isDeduct()?kColorRed:Colors.green
                  ),
                ),
              ))
            ],
          ),
          // Row(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: [
          //     Text("${AppTranslations.of(context).text("title_fee_amount")}",style: kLabelSemiBoldTextStyle,),
          //     Expanded(
          //         child: Container(
          //           alignment: Alignment.centerRight,
          //           child:Text("${AppTranslations.of(context).text("currency_my")} ${widget.walletTransaction}",
          //             style: kLabelSemiBoldTextStyle,
          //           ),
          //         )
          //     )
          //   ],
          // ),
          space,
          Container(
            height: 1,
            color: darkGrey,
          ),
          space,
          Row(
            children: [
              Container(
                width: titleWidth,
                child: Text(
                  "${AppTranslations.of(context).text("title_date_time")}",
                  style: kLabelTextStyle,
                ),
              ),
              SizedBox(
                width: 10.0,
              ),
              Expanded(
                  child: Container(
                alignment: Alignment.centerRight,
                child: Text(
                  "${DatetimeFormatter().getFormattedDateStrWithDate(datetime: widget.walletTransaction.transactionCreatedDatetime, format: "dd MMM yyyy, hh:mm a")}",
                  style: kLabelSemiBoldTextStyle,
                ),
              ))
            ],
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: titleWidth,
                child: Text(
                  "${AppTranslations.of(context).text("title_topup_summary")}",
                  style: kLabelSemiBoldTextStyle,
                ),
              ),
              SizedBox(
                width: 10.0,
              ),
              Expanded(
                  child: Container(
                alignment: Alignment.centerRight,
                child: Text(
                  "${widget.topUpTransaction.topupNumber}",
                  textAlign: TextAlign.end,
                  style: kLabelSemiBoldTextStyle,
                ),
              ))
            ],
          ),
          if (widget.topUpTransaction != null) getTransactionTag(),
          space,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: titleWidth,
                child: Text(
                  AppTranslations.of(context).text('you_topped_up'),
                  style: kLabelSemiBoldTextStyle,
                ),
              ),
              SizedBox(
                width: 10.0,
              ),
              Expanded(
                  child: Container(
                alignment: Alignment.centerRight,
                child: getTransactionTopUp()
              ))
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: titleWidth,
                child: Text(
                  "${AppTranslations.of(context).text("title_fee_amount")}",
                  style: kLabelSemiBoldTextStyle,
                ),
              ),
              SizedBox(
                width: 10.0,
              ),
              Expanded(
                  child: Container(
                alignment: Alignment.centerRight,
                child: Text(
                  "${AppTranslations.of(context).text("currency_my")} ${widget.topUpTransaction.topupCharges}",
                  style: kTitleSemiBoldTextStyle,
                ),
              ))
            ],
          ),
          space,
          Container(
            height: 1,
            color: darkGrey,
          ),
          space,
          Row(
            children: [
              Text(
                "${AppTranslations.of(context).text("title_date_time")}",
                style: kLabelTextStyle,
              ),
              SizedBox(
                width: 10.0,
              ),
              Expanded(
                  child: Container(
                alignment: Alignment.centerRight,
                child: Text(
                  "${DatetimeFormatter().getFormattedDateStrWithDate(datetime: widget.topUpTransaction.topupDatetime, format: "dd MMM yyyy, hh:mm a")}",
                  style: kLabelSemiBoldTextStyle,
                ),
              ))
            ],
          ),
          space,
          Row(
            children: [
              Text(
                "${AppTranslations.of(context).text("payment_method")}",
                style: kLabelTextStyle,
              ),
              SizedBox(
                width: 10.0,
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Image.asset(PaymentMethod().getPaymentMethod(widget.topUpTransaction.topupMethod).image,width: 40.0,height: 40.0,),
                      SizedBox(width: 6.0,),
                      Text(
                        "${AppTranslations.of(context).text(PaymentMethod().getPaymentMethod(widget.topUpTransaction.topupMethod).name)}",
                        style: kLabelSemiBoldTextStyle,
                      ),
                    ],
                  )
                )
              )
            ],
          ),
        ],
      );
    }
  }

  Widget getTransactionAmount(BuildContext context){
    return Container(
      child: Text(
        "${AppTranslations.of(context).text("currency_my")} ${widget.walletTransaction.transactionAmount}",
        style: kTitleSemiBoldTextStyle.copyWith(
            color: isDeduct()?kColorRed:Colors.green
        ),
      ),
    );
  }

  bool isDeduct(){
    try{
      double previousAmount = double.parse(widget.walletTransaction.transactionAmountPrevious);
      double currentAmount = double.parse(widget.walletTransaction.transactionAmountBalance);

      double amount = double.parse(widget.walletTransaction.transactionAmount);

      return (amount) <= 0.0;
    }catch(e){

    }

    return false;
  }

  Widget getTransactionTopUp(){
    if(widget.topUpTransaction.topupStatus.toLowerCase() == "success"){
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            child: Text(
              "+ ${AppTranslations.of(context).text("currency_my")} ${widget.topUpTransaction.topupAmount}",
              style: kTitleSemiBoldTextStyle.copyWith(
                  color: Colors.green
              ),
            ),
          )
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          child: Text(
            "${AppTranslations.of(context).text("currency_my")} ${widget.topUpTransaction.topupAmount}",
            style: kTitleSemiBoldTextStyle.copyWith(
                color: Colors.black
            ),
          ),
        )
      ],
    );
  }

  Widget getTransactionTag() {
    return TransactionTag(
      tag: AppTranslations.of(context)
          .text("topup_${widget.topUpTransaction.topupStatus}")
          .toUpperCase(),
      bgColor: getBgColor(),
      titleColor: getTextColor(),
    );
  }

  Color getBgColor() {
    if (widget.topUpTransaction.topupStatus == "success") {
      return kColorLightGreen;
    } else if (widget.topUpTransaction.topupStatus == "pending") {
      return kColorLightBlue2;
    } else if (widget.topUpTransaction.topupStatus == "failed") {
      return kColorLightRed6;
    } else {
      return Colors.white;
    }
  }

  Color getTextColor() {
    if (widget.topUpTransaction.topupStatus == "success") {
      return Colors.green;
    } else if (widget.topUpTransaction.topupStatus == "pending") {
      return Colors.blueAccent;
    } else if (widget.topUpTransaction.topupStatus == "failed") {
      return Colors.red;
    } else {
      return Colors.black;
    }
  }
}
