import 'package:flutter/material.dart';
import 'package:haloapp/components/custom_flushbar.dart';
import 'package:haloapp/components_new/custom_sliver_app_bar_ewallet.dart';
import 'package:haloapp/components_new/ewallet_container.dart';
import 'package:haloapp/components_new/ewallet_transaction_container.dart';

import 'package:haloapp/components_new/top_up_transaction_container.dart';
import 'package:haloapp/models/app_config_model.dart';

import 'package:haloapp/models/user_model.dart';
import 'package:haloapp/networkings/ewallet_networking.dart';
import 'package:haloapp/screens/boarding/login_page.dart';

import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/constants/styles.dart';

import 'package:haloapp/components/model_progress_hud.dart';
import 'package:haloapp/utils/services/shared_pref_service.dart';

class EwalletPage extends StatefulWidget {
  static const String id = 'ewalletPage';

  @override
  _EwalletPageState createState() => _EwalletPageState();
}

class _EwalletPageState extends State<EwalletPage> {
  bool _showSpinner = true;
  int type = 0;

  @override
  void initState() {
    super.initState();

    Future.wait([getTopUpHistoryApis(), getEwalletApis()]).then((value) {
      setState(() {
        _showSpinner = false;
      });
    });
  }

  Future<void> getEwalletApis() async {
    Map<String, dynamic> params = {
      "data": {
        "userToken": User().getUserToken(),
      }
    };
    print(params);

    // setState(() {
    //   _showSpinner = true;
    // });

    try {
      var data = await EwalletNetworking().getEwalletTransaction(params);
      // if(data.response.walletTransactions.length == 0) return;
      // if(data.length <= 0) return;
      setState(() {
        User().setEwalletTransaction(data);
      });
    } catch (e) {
      print(e.toString());
      if (e is Map<String, dynamic>) {
        if (e['status_code'] == 514) {
          SharedPrefService().removeLoginInfo();
          Navigator.popUntil(context, ModalRoute.withName(LoginPage.id));
        }
      } else {
        showSimpleFlushBar(e.toString(), context);
      }
    } finally {
      setState(() {
        _showSpinner = false;
      });
    }
  }

  Future<void> getTopUpHistoryApis() async {
    Map<String, dynamic> params = {};
    print(params);

    // setState(() {
    //   _showSpinner = true;
    // });

    try {
      var data = await EwalletNetworking().getTopUpTransaction(params);
      // if(data.response.walletTransactions.length == 0) return;
      // if(data.length <= 0) return;
      setState(() {
        User().setTopUpTransaction(data);
      });
    } catch (e) {
      print(e.toString());
      if (e is Map<String, dynamic>) {
        if (e['status_code'] == 514) {
          SharedPrefService().removeLoginInfo();
          Navigator.popUntil(context, ModalRoute.withName(LoginPage.id));
        }
      } else {
        showSimpleFlushBar(e.toString(), context);
      }
    } finally {
      setState(() {
        _showSpinner = false;
      });
    }
  }

  Future<void> listOnRefresh() async {
    if (type == 0) {
      getEwalletApis();
    } else {
      getTopUpHistoryApis();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: _showSpinner,
        child: SafeArea(
          top: false,
          child: !AppConfig.consumerConfig.eWalletEnable
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        "images/ic_ewallet.png",
                        width: 60.0,
                        height: 60.0,
                      ),
                      Text(
                        AppTranslations.of(context).text('ewallet_coming_soon'),
                        style: kTitleTextStyle,
                      )
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: listOnRefresh,
                  child: NestedScrollView(
                      headerSliverBuilder:
                          (BuildContext context, bool innerBoxIsScrolled) {
                        return [
                          SliverPersistentHeader(
                            pinned: true,
                            delegate: CustomSliverAppBarEwalletDelegate(
                              expandedHeight:
                                  MediaQuery.of(context).padding.top + 200,
                              topSafeArea: MediaQuery.of(context).padding.top,
                              topChild: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    child: Text(
                                      "${AppTranslations.of(context).text("title_my_wallet")}",
                                      style: kTitleSemiBoldTextStyle.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                    alignment: Alignment.bottomLeft,
                                    padding: EdgeInsets.only(left: 10.0),
                                  ),
                                ],
                              ),
                              botChild: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [EwalletContainer()],
                              ),
                            ),
                          ),
                        ];
                      },
                      body: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 15.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Expanded(
                                  child: MaterialButton(
                                    onPressed: () {
                                      if (type == 0) {
                                        return;
                                      }

                                      type = 0;
                                      listOnRefresh();
                                    },
                                    padding: EdgeInsets.all(13.0),
                                    color: (isSelected(0))
                                        ? kColorRed
                                        : Colors.white,
                                    child: Container(
                                      child: Text(
                                        AppTranslations.of(context)
                                            .text('title_transaction_history'),
                                        style: TextStyle(
                                          fontFamily: (isSelected(0))
                                              ? poppinsSemiBold
                                              : poppinsRegular,
                                          fontSize: 14.0,
                                          color: (isSelected(0))
                                              ? Colors.white
                                              : Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10.0),
                                Expanded(
                                  child: MaterialButton(
                                    onPressed: () {
                                      if (type == 1) {
                                        return;
                                      }

                                      type = 1;
                                      listOnRefresh();
                                    },
                                    padding: EdgeInsets.all(13.0),
                                    color: (isSelected(1))
                                        ? kColorRed
                                        : Colors.white,
                                    child: Container(
                                      child: Text(
                                        AppTranslations.of(context)
                                            .text('title_topup_history'),
                                        style: TextStyle(
                                          fontFamily: isSelected(1)
                                              ? poppinsSemiBold
                                              : poppinsRegular,
                                          fontSize: 14.0,
                                          color: isSelected(1)
                                              ? Colors.white
                                              : Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child:
                                  // (User().getWalletTransactionsResponse() != null && User().getWalletTransactionsResponse().response.walletTransactions.isNotEmpty)?
                                  getListing(),
                              //   :Container(
                              //     child: Center(
                              //       child: Text(
                              //         "No Transactions",
                              //         style: kLabelTextStyle.copyWith(
                              //           color: darkGrey
                              //         ),
                              //       ),
                              //     ),
                              //   ),
                            ),
                          ),
                        ],
                      )),
                ),
        ),
      ),
    );
  }

  Widget getListing() {
    print("Type : $type");
    if (type == 0) {
      if ((User().getWalletTransactionsResponse() != null &&
          User()
              .getWalletTransactionsResponse()
              .response
              .walletTransactions
              .isNotEmpty)) {
        return RefreshIndicator(
          onRefresh: listOnRefresh,
          child: Column(
            children: [
              // Container(
              //   padding: EdgeInsets.only(left: 10.0,right: 10.0),
              //   child: Text(
              //     "${AppTranslations.of(context).text("title_topup_history")}",
              //     style: kTitleSemiBoldTextStyle.copyWith(
              //       color: Colors.black,
              //     ),
              //   ),
              // ),
              Expanded(
                child: ListView.separated(
                    padding: EdgeInsets.all(10.0),
                    // physics: AlwaysScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      return EwalletTransactionContainer(
                        walletTransaction: User()
                            .getWalletTransactionsResponse()
                            .response
                            .walletTransactions[index],
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return Container(
                        margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                        height: 1,
                        color: lightGrey,
                      );
                    },
                    itemCount: User()
                        .getWalletTransactionsResponse()
                        .response
                        .walletTransactions
                        .length),
              )
            ],
          ),
        );
      }
    } else {
      if ((User().getTopUpTransactionResponse() != null &&
          User()
              .getTopUpTransactionResponse()
              .response
              .topupTransactions
              .isNotEmpty)) {
        return RefreshIndicator(
          onRefresh: listOnRefresh,
          child: Column(
            children: [
              // Container(
              //   padding: EdgeInsets.only(left: 10.0,right: 10.0),
              //   child: Text(
              //     "${AppTranslations.of(context).text("title_topup_history")}",
              //     style: kTitleSemiBoldTextStyle.copyWith(
              //       color: Colors.black,
              //     ),
              //   ),
              // ),
              Expanded(
                child: ListView.separated(
                    padding: EdgeInsets.all(10.0),
                    // physics: AlwaysScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      return TopUpTransactionContainer(
                          topupTransaction: User()
                              .getTopUpTransactionResponse()
                              .response
                              .topupTransactions[index]);
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return Container(
                        margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                        height: 1,
                        color: lightGrey,
                      );
                    },
                    itemCount: User()
                        .getTopUpTransactionResponse()
                        .response
                        .topupTransactions
                        .length),
              )
            ],
          ),
        );
      }
    }

    return Container(
      child: Center(
        child: Text(
          "No Transactions",
          style: kLabelTextStyle.copyWith(color: darkGrey),
        ),
      ),
    );
  }

  bool isSelected(int type) {
    return this.type == type;
  }
}
