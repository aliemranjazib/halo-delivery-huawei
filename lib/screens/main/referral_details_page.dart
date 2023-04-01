import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/components/custom_flushbar.dart';
import 'package:haloapp/components/model_progress_hud.dart';
import 'package:haloapp/models/activity_model.dart';
import 'package:haloapp/models/activity_question_model.dart';
import 'package:haloapp/models/notification_model.dart';
import 'package:haloapp/models/referral_details_model.dart';
import 'package:haloapp/models/user_model.dart';
import 'package:haloapp/networkings/auth_networking.dart';
import 'package:haloapp/networkings/booking_networking.dart';
import 'package:haloapp/networkings/user_networking.dart';
import 'package:haloapp/screens/main/activity_support_page.dart';
import 'package:haloapp/screens/main/activty_support_chat_page.dart';
import 'package:haloapp/screens/main/notification_details_page.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/api_urls.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/constants/styles.dart';
import 'package:haloapp/utils/services/datetime_formatter.dart';
import 'package:url_launcher/url_launcher.dart';

class ReferralsDetailPage extends StatefulWidget {
  static const String id = 'ReferralsDetailPage';

  @override
  _ReferralsDetailPageState createState() => _ReferralsDetailPageState();
}

class _ReferralsDetailPageState extends State<ReferralsDetailPage> {
  bool _showSpinner = false;
  ReferralDetailsModel referralDetailsModel = new ReferralDetailsModel();

  @override
  initState() {
    referralDetailsModel.refSummary = [];
    loadReferralDetails();
    super.initState();
  }

  Future<void> share() async {
    await FlutterShare.share(
        title: 'Invite a friend',
        text:
            'Have you tried the Halo app yet? They have something for everybody, you can check it out here:',
        linkUrl: User().getUserRefLink(),
        chooserTitle: 'Invite a friend');
  }

  void loadReferralDetails() async {
    Map<String, dynamic> params = {
      "apiKey": APIUrls().getApiKey(),
      "data": {},
    };

    setState(() {
      _showSpinner = true;
    });

    try {
      var data = await UserNetworking().getUserReferralDetails(params);

      setState(() {
        referralDetailsModel = data;
        User().setRefTotalCommission(referralDetailsModel.refTotalCommission);
      });
    } catch (e) {
      if (mounted) showSimpleFlushBar(e.toString(), context);
    } finally {
      if (mounted)
        setState(() {
          _showSpinner = false;
        });
    }
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
            AppTranslations.of(context).text('referrals'),
            style: kAppBarTextStyle,
          ),
        ),
        body: RefreshIndicator(
          onRefresh:()async {loadReferralDetails();},
          child: SafeArea(
            child: Container(
              height: double.infinity,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                      child: Text(
                        AppTranslations.of(context).text('total_reward_earned'),
                        style:
                            TextStyle(fontFamily: poppinsRegular, fontSize: 14, color: Colors.white),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 36, left: 16.0, right: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 50,
                          ),
                          Column(
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(Radius.circular(3)),
                                  boxShadow: [elevation],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 16,
                                        ),
                                        Image.asset(
                                          "images/halo_logo.png",
                                          width: 60.0,
                                          height: 60.0,
                                        ),
                                        SizedBox(
                                          width: 32,
                                        ),
                                        Text(
                                          'RM',
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontFamily: poppinsSemiBold,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12),
                                        ),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        Text(
                                          User().getRefTotalCommission(),
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontFamily: poppinsSemiBold,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 26),
                                        ),
                                      ],
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
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppTranslations.of(context).text('referrals'),
                        style: kTitleBoldTextStyle,
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      ListView.separated(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        separatorBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Divider(
                              color: lightGrey,
                            ),
                          );
                        },
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: referralDetailsModel.refSummary.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    referralDetailsModel.refSummary[index].userPhone,
                                    style: kTitleBoldTextStyle,
                                  ),
                                  Text(
                                    '${DatetimeFormatter().dateAmPm(referralDetailsModel.refSummary[index].refCreatedDatetime)}',
                                    style: TextStyle(
                                        color: darkGrey,
                                        fontFamily: poppinsRegular),
                                  ),
                                ],
                              ),
                              Spacer(),
                              Text(
                                '+ RM ' + referralDetailsModel.refSummary[index].referrerCommission,
                                style: TextStyle(
                                    color: plusGreen,
                                    fontFamily: poppinsSemiBold,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              )
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
