import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/components/model_progress_hud.dart';
import 'package:haloapp/models/food_history_model.dart';
import 'package:haloapp/screens/main/home_page_new.dart';
import 'package:haloapp/screens/main/tab_bar_controller.dart';
import 'package:http/http.dart' as http;
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:intl/intl.dart';

import '../../../models/user_model.dart';
import '../../../utils/app_translations/app_translations.dart';

class CharitySucessPage extends StatefulWidget {
  final FoodHistoryModel history;
  final bool success;
  CharitySucessPage({
    this.history,
    this.success,
    Key key,
  }) : super(key: key);

  @override
  State<CharitySucessPage> createState() => _CharitySucessPageState();
}

class _CharitySucessPageState extends State<CharitySucessPage> {
  var date;
  bool _showSpinner = false;
  String redeemAmount;

  @override
  void initState() {
    super.initState();
    // redeemCalculate();
    var outputFormat = DateFormat('dd MMM yyyy hh:mm a');
    date = outputFormat.format(DateTime.now());
    print(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: _showSpinner,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                    padding: EdgeInsets.all(0.0),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.close)),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 200,
                    child: Image.asset(
                      'images/new/redeem_success.png',
                      height: 200,
                      width: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Text(
                          AppTranslations.of(context).text('Donate Successful'),
                          style: TextStyle(
                              fontFamily: poppinsBold,
                              fontSize: 24,
                              color: Colors.black)),
                      Text(
                          AppTranslations.of(context)
                              .text('Paid RM ${widget.history.orderPrice}'),
                          style: TextStyle(
                              fontFamily: poppinsBold,
                              fontSize: 24,
                              color: Colors.black)),
                    ],
                  ),
                ),
                SizedBox(height: 15),
                Container(
                  // height: 180,
                  decoration: BoxDecoration(
                      color: Color(0xFFF8F8F8),
                      boxShadow: [
                        BoxShadow(
                          spreadRadius: 3,
                          blurRadius: 3,
                          offset: Offset(1, 1),
                          color: Colors.grey.shade200,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(10)),
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10),
                        Text(
                          AppTranslations.of(context).text('Order Summary'),
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: poppinsBold,
                          ),
                        ),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppTranslations.of(context).text('Date and Time'),
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: poppinsRegular,
                              ),
                            ),
                            Text(
                              "$date",
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: poppinsBold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppTranslations.of(context)
                                  .text('Refference No.'),
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: poppinsRegular,
                              ),
                            ),
                            Text(
                              "${widget.history.orderNum}",
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: poppinsBold,
                              ),
                            ),
                          ],
                        ),
                        Divider(),
                        // SizedBox(height: 11),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppTranslations.of(context)
                                  .text('${widget.history.paymentMethod}'),
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: poppinsRegular,
                              ),
                            ),
                            Text(
                              "${widget.history.orderPrice}",
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: poppinsBold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
                Spacer(),
                ActionButtonOutline(
                  buttonText: AppTranslations.of(context).text('done'),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => TabBarPage()));
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
