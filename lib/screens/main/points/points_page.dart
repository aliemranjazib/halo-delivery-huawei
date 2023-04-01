import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/models/user_model.dart';
import 'package:haloapp/models/wallet_transaction_model.dart';
import 'package:haloapp/screens/main/points/points_model.dart';
import 'package:haloapp/screens/main/points/redeem_points_page.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/styles.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../../components/model_progress_hud.dart';
import '../../../utils/app_translations/app_translations.dart';
import '../../../utils/constants/fonts.dart';

class PointsPage extends StatefulWidget {
  static const String id = 'points';

  const PointsPage({Key key}) : super(key: key);

  @override
  State<PointsPage> createState() => _PointsPageState();
}

class _PointsPageState extends State<PointsPage> {
  PointsModel pm;
  bool _showSpinner = true;
  String date;
  gett() async {
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
          Uri.parse('https://userapi.halo.express/Point/transaction'),
          headers: headers,
          body: jsonEncode({
            'userToken': '${User().getUserToken()}',
          }));
      switch (response.statusCode) {
        case 200:
          Map<String, dynamic> data = json.decode(response.body);
          print("opop ${data['response']['expireDetails']['pointAmount']}");

          setState(() {
            pm = PointsModel.fromJson(data);
          });
          print("ttttt $pm");
          // print(pm.response.pointTransactions.first.transactionAmount);
          setState(() {
            _showSpinner = false;
            if (pm.response.expireDetails.expireDate != null) {
              DateTime dt1 = DateTime.parse(
                "${pm.response.expireDetails.expireDate}",
              );
              var outputFormat = DateFormat('dd MMM yyyy hh:mm a');
              date = outputFormat.format(dt1);
            }
          });
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
    gett();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _showSpinner,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          leading: IconButton(
            icon: arrowBack,
            onPressed: () => {Navigator.pop(context)},
          ),
          title: Text(
            AppTranslations.of(context).text('points'),
            style: kAppBarTextStyle,
          ),
        ),
        body: SafeArea(
            child: pm == null
                ? Container()
                : Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            height: 130,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage("images/referral-bg.png"),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              children: [
                                Text(
                                  AppTranslations.of(context)
                                      .text('Halo Points'),
                                  style: TextStyle(
                                      fontFamily: poppinsRegular,
                                      fontSize: 14,
                                      color: Colors.white),
                                ),
                                Text(
                                  AppTranslations.of(context)
                                      .text('you_have_earned'),
                                  style: TextStyle(
                                      fontFamily: poppinsRegular,
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.7)),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 36, left: 16.0, right: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.symmetric(
                                          vertical: 16, horizontal: 16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(3)),
                                        boxShadow: [elevation],
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    height: 50,
                                                    width: 50,
                                                    decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                          image: AssetImage(
                                                              "images/new/points.png"),
                                                          fit: BoxFit.contain,
                                                          scale: 30),
                                                    ),
                                                  ),
                                                  SizedBox(width: 10),
                                                  Column(
                                                    children: [
                                                      Text(
                                                        pm.response
                                                                .pointBalance ??
                                                            "",
                                                        style: TextStyle(
                                                            fontFamily:
                                                                poppinsRegular,
                                                            fontSize: 25,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                      Text(
                                                        AppTranslations.of(
                                                                context)
                                                            .text('points'),
                                                        style: TextStyle(
                                                            fontFamily:
                                                                poppinsRegular,
                                                            fontSize: 14,
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.7)),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              Visibility(
                                                visible:
                                                    pm.response.pointBalance ==
                                                            "0"
                                                        ? false
                                                        : true,
                                                child: ActionWithColorButton(
                                                  buttonText:
                                                      AppTranslations.of(
                                                              context)
                                                          .text('Redeem'),
                                                  onPressed: () {
                                                    // showDialog(context: context, builder:(){} );
                                                    // share();
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (_) =>
                                                                RedeemPointsPage(
                                                                  points:
                                                                      "${pm.response.pointBalance}",
                                                                )));
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                          Visibility(
                                            visible:
                                                pm.response.pointBalance == "0"
                                                    ? false
                                                    : true,
                                            child: Text(
                                              '${pm.response.expireDetails.pointAmount} points expiring on $date',
                                              style: TextStyle(
                                                  fontFamily: poppinsRegular,
                                                  fontSize: 14,
                                                  color: Colors.black),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 10, left: 16.0, right: 16),
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  AppTranslations.of(context)
                                      .text('Points History'),
                                  style: kTitleBoldTextStyle,
                                ),
                              ),
                              Divider(
                                // height: 10,
                                thickness: 5,
                              ),
                              SizedBox(height: 10),
                              Expanded(
                                child: Container(
                                  // height:
                                  //     MediaQuery.of(context).size.height * 0.45,
                                  child: ListView.builder(
                                    // shrinkWrap: true,
                                    itemCount:
                                        pm.response.pointTransactions.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      final data =
                                          pm.response.pointTransactions[index];
                                      DateTime dt1 = DateTime.parse(
                                        "${data.transactionCreatedDatetime}",
                                      );
                                      var outputFormat =
                                          DateFormat('dd MMM yyyy hh:mm a');
                                      var outputDate = outputFormat.format(dt1);
                                      print(outputDate);
                                      return cards(
                                          "${data.transactionType}",
                                          "$outputDate",
                                          "${data.transactionAmount ?? ""}");
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )),
      ),
    );
  }

  Widget cards(String transactionType, String transactionDate,
      String transactionAmount) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transactionType,
                  style: kTitleBoldTextStyle,
                ),
                Text(
                  transactionDate,
                  style: kLabelTextStyle,
                ),
              ],
            ),
            Text(
              transactionAmount ?? "",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Divider(
          // height: 10,
          thickness: 2,
        ),
      ],
    );
  }
}
