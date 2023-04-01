import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/components/model_progress_hud.dart';
import 'package:haloapp/models/user_model.dart';
import 'package:haloapp/screens/main/points/redeem_success_page.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:http/http.dart' as http;
import '../../../utils/constants/styles.dart';

extension NumberParsing on String {
  double toDouble() {
    return double.parse(this);
  }
}

class RedeemPointsPage extends StatefulWidget {
  String points;
  RedeemPointsPage({this.points});
  static const String id = 'redeempoints';

  @override
  State<RedeemPointsPage> createState() => _RedeemPointsPageState();
}

class _RedeemPointsPageState extends State<RedeemPointsPage> {
  double _value = 20;
  bool _showSpinner = false;
  String date;

  redeemPoints() async {
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
          Uri.parse('https://userapi.halo.express/Point/redeem'),
          headers: headers,
          body: jsonEncode({
            "data": {"amount": "$_value"}
          }));
      switch (response.statusCode) {
        case 200:
          Map<String, dynamic> data = json.decode(response.body);
          print("===== ${data['response']['transactionNumber']}");
          // print("opop ${data['response']['expireDetails']['pointAmount']}");
          setState(() {
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
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => RedeemSucessPage(
                        amount: this._value,
                        transactionNumber:
                            "${data['response']['transactionNumber']}",
                      )));
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
  Widget build(BuildContext context) {
    double gettedPoints = double.parse(widget.points.replaceAll(',', ''));
    // print(myDouble.toStringAsFixed(0)); // 123.45
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: arrowBack,
          onPressed: () => {Navigator.pop(context)},
        ),
        title: Text(
          AppTranslations.of(context).text('Points'),
          style: kAppBarTextStyle,
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _showSpinner,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              heading(context),
              centre("${_value * 0.01}".toDouble().toStringAsFixed(2), context),

              Column(
                children: [
                  Text(
                    AppTranslations.of(context)
                        .text('${_value.round()} points'),
                    style: TextStyle(
                        fontFamily: poppinsRegular,
                        fontSize: 20,
                        color: Colors.black),
                  ),
                  Container(
                    width: double.maxFinite,
                    child: Column(
                      children: [
                        Container(
                          width: double.maxFinite,
                          child: CupertinoSlider(
                            min: 1.0,
                            max: gettedPoints,
                            activeColor: kColorRed,
                            value: _value,
                            onChanged: (value) {
                              setState(() {
                                gettedPoints = value;
                                _value = gettedPoints;
                              });
                            },
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppTranslations.of(context).text('1'),
                              style: TextStyle(
                                  fontFamily: poppinsRegular,
                                  fontSize: 14,
                                  color: Colors.black),
                            ),
                            Text(
                              AppTranslations.of(context)
                                  .text('${widget.points}'),
                              style: TextStyle(
                                  fontFamily: poppinsRegular,
                                  fontSize: 14,
                                  color: Colors.black),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),

              // halo_slider(widget.points, context),
              // Text(
              //   AppTranslations.of(context).text('Enter Manually'),
              //   style: TextStyle(
              //       fontFamily: poppinsSemiBold, fontSize: 24, color: kColorRed),
              // ),
              Divider(
                // height: 10,
                thickness: 5,
                color: Colors.grey.shade100,
              ),
              SizedBox(height: 10),
              ActionWithColorButton(
                buttonText: AppTranslations.of(context).text('redeem'),
                onPressed: () {
                  redeemPoints();
                  // Navigator.push(context,
                  //     MaterialPageRoute(builder: (_) => RedeemSucessPage()));
                  // Navigator.pushNamed(context, RedeemPointsPage.id);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Column halo_slider(String points, BuildContext context) {
    return Column(
      children: [
        Text(
          AppTranslations.of(context).text('${_value.round()} points'),
          style: TextStyle(
              fontFamily: poppinsRegular, fontSize: 20, color: Colors.black),
        ),
        Container(
          width: double.maxFinite,
          child: Column(
            children: [
              Container(
                width: double.maxFinite,
                child: CupertinoSlider(
                  min: 1.0,
                  max: 100.0,
                  activeColor: kColorRed,
                  value: _value,
                  onChanged: (value) {
                    setState(() {
                      _value = value;
                    });
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppTranslations.of(context).text('1'),
                    style: TextStyle(
                        fontFamily: poppinsRegular,
                        fontSize: 14,
                        color: Colors.black),
                  ),
                  Text(
                    AppTranslations.of(context).text('$points'),
                    style: TextStyle(
                        fontFamily: poppinsRegular,
                        fontSize: 14,
                        color: Colors.black),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget centre(String text, BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'images/halo_logo.png',
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                ),
                SizedBox(width: 20),
                Text("RM"),
                SizedBox(width: 10),
                Container(
                  constraints: BoxConstraints(maxWidth: 120, minWidth: 120),
                  child: Text(
                    AppTranslations.of(context).text('$text'),
                    style: TextStyle(
                        fontFamily: poppinsSemiBold,
                        fontSize: 34,
                        color: Colors.black),
                  ),
                ),
              ],
            ),
            // Text(
            //   AppTranslations.of(context).text('1 point = RM 0.01'),
            //   style: TextStyle(
            //       fontFamily: poppinsRegular,
            //       fontSize: 14,
            //       color: Colors.black54),
            // ),
          ],
        ),
      ),
    );
  }

  Column heading(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          AppTranslations.of(context).text('Redeem halo Points'),
          style: TextStyle(
              fontFamily: poppinsRegular, fontSize: 24, color: Colors.black),
        ),
        Text(
          AppTranslations.of(context).text('Convert Halo Points'),
          textAlign: TextAlign.center,
          style: TextStyle(
              fontFamily: poppinsRegular,
              fontSize: 12,
              color: Colors.black.withOpacity(0.7)),
        ),
      ],
    );
  }
}
