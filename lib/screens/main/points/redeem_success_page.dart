import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/components/model_progress_hud.dart';
import 'package:haloapp/screens/main/home_page_new.dart';
import 'package:haloapp/screens/main/tab_bar_controller.dart';
import 'package:http/http.dart' as http;
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:intl/intl.dart';

import '../../../models/user_model.dart';
import '../../../utils/app_translations/app_translations.dart';

class RedeemSucessPage extends StatefulWidget {
  double amount;
  String transactionNumber;
  RedeemSucessPage({Key key, this.amount, this.transactionNumber})
      : super(key: key);

  @override
  State<RedeemSucessPage> createState() => _RedeemSucessPageState();
}

class _RedeemSucessPageState extends State<RedeemSucessPage> {
  var date;
  bool _showSpinner = false;
  String redeemAmount;

  redeemCalculate() async {
    try {
      setState(() {
        _showSpinner = true;
      });
      print('ttoken ${User().getAuthToken()}');
      var headers = {
        'Authorization': '${User().getAuthToken()}',
        'Content-Type': 'application/json; charset=UTF-8',
      };
      http.Response response = await http.post(
          Uri.parse('https://userapi.halo.express/Point/redeemCalculation'),
          headers: headers,
          body: jsonEncode({
            "data": {"amount": "${widget.amount}"}
          }));
      switch (response.statusCode) {
        case 200:
          Map<String, dynamic> data = json.decode(response.body);
          print("===== ${data['response']['haloWalletAmount']}");
          // print("opop ${data['response']['expireDetails']['pointAmount']}");
          setState(() {
            redeemAmount = "${data['response']['haloWalletAmount']}";
            // pm = PointsModel.fromJson(data);
          });
          // print("ttttt $pm");
          // print(pm.response.pointTransactions.first.transactionAmount);
          setState(() {
            _showSpinner = false;

            // if (pm.response.expireDetails.expireDate != null) {
            //   DateTime dt1 = DateTime.parse(
            //     "${pm.response.expireDetails.expireDate}",
            //   );
            //   var outputFormat = DateFormat('dd MMM yyyy hh:mm a');
            //   date = outputFormat.format(dt1);
            // }
          });
          // Navigator.push(
          //     context, MaterialPageRoute(builder: (_) => RedeemSucessPage()));
          break;
        case 400:
          break;
        case 514:
          break;
        case 500:
          break;
        case 504:
          break;
        default:
      }
    } catch (e) {
      setState(() {
        _showSpinner = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    redeemCalculate();
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
                  child: Text(
                    AppTranslations.of(context).text('Redeem Successful'),
                    style: TextStyle(
                        fontFamily: poppinsBold,
                        fontSize: 24,
                        color: Colors.black),
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
                              "${widget.transactionNumber}",
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: poppinsBold,
                              ),
                            ),
                          ],
                        ),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     Text(
                        //       "Reference No.",
                        //       style: TextStyle(
                        //         fontSize: 14,
                        //         fontFamily: poppinsRegular,
                        //       ),
                        //     ),
                        //     Text(
                        //       "2323232",
                        //       style: TextStyle(
                        //         fontSize: 14,
                        //         fontFamily: poppinsBold,
                        //       ),
                        //     ),
                        //   ],
                        // ),

                        Divider(),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppTranslations.of(context).text('Redeem Amount'),
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: poppinsRegular,
                              ),
                            ),
                            Text(
                              "$redeemAmount",
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
