import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/components/model_progress_hud.dart';
import 'package:haloapp/models/activity_model.dart';
import 'package:haloapp/models/activity_question_model.dart';
import 'package:haloapp/models/notification_model.dart';
import 'package:haloapp/models/user_model.dart';
import 'package:haloapp/networkings/auth_networking.dart';
import 'package:haloapp/networkings/booking_networking.dart';
import 'package:haloapp/networkings/user_networking.dart';
import 'package:haloapp/screens/main/activity_support_page.dart';
import 'package:haloapp/screens/main/activty_support_chat_page.dart';
import 'package:haloapp/screens/main/notification_details_page.dart';
import 'package:haloapp/screens/main/referral_details_page.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/api_urls.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/constants/styles.dart';
import 'package:haloapp/utils/services/datetime_formatter.dart';
import 'package:url_launcher/url_launcher.dart';

class ReferralsPage extends StatefulWidget {
  static const String id = 'ReferralsPage';

  @override
  _ReferralsPageState createState() => _ReferralsPageState();
}

class _ReferralsPageState extends State<ReferralsPage> {
  @override
  initState() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: SafeArea(
        child: Container(
          height: double.infinity,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                    AppTranslations.of(context).text('invite_friends') +
                        '\n' +
                        'Halo app!',
                    style: TextStyle(
                        fontFamily: poppinsRegular,
                        fontSize: 14,
                        color: Colors.white),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(top: 36, left: 16.0, right: 16),
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
                            padding: EdgeInsets.symmetric(
                                vertical: 16, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(3)),
                              boxShadow: [elevation],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  AppTranslations.of(context)
                                      .text('share_ref_code'),
                                  style: TextStyle(fontSize: 14),
                                ),
                                SizedBox(
                                  height: 16,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      User().getUserRefCode(),
                                      style: TextStyle(
                                          color: kColorRed,
                                          fontFamily: poppinsSemiBold,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 26),
                                    ),
                                    SizedBox(
                                      width: 16,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Clipboard.setData(ClipboardData(
                                            text: User().getUserRefCode()));
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text("Copied")));
                                      },
                                      child: Image.asset(
                                        'images/copy.png',
                                        width: 16,
                                        height: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 32,
                                ),
                                ActionButton(
                                  buttonText: AppTranslations.of(context)
                                      .text('invite_a_friend'),
                                  onPressed: () {
                                    share();
                                  },
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
                    AppTranslations.of(context).text('total_reward_earned'),
                    style: kTitleBoldTextStyle,
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: darkGrey),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, ReferralsDetailPage.id);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Text(
                              'RM ' + User().getRefTotalCommission(),
                              style: kTitleBoldTextStyle,
                            ),
                            Spacer(),
                            Text(
                              AppTranslations.of(context).text('view_all'),
                              style: TextStyle(color: darkGrey, fontSize: 14),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: darkGrey,
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppTranslations.of(context).text('how_it_works'),
                    style: kTitleBoldTextStyle,
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    children: [
                      Image.asset(
                        'images/share.png',
                        width: 25,
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      Flexible(
                        child: Text(
                          AppTranslations.of(context)
                              .text('how_it_works_step_one'),
                          style: kLabelTextStyle,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    children: [
                      Image.asset(
                        'images/download.png',
                        width: 25,
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      Flexible(
                        child: Text(
                          AppTranslations.of(context)
                              .text('how_it_works_step_two'),
                          style: kLabelTextStyle,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    children: [
                      Image.asset(
                        'images/gift.png',
                        width: 25,
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      Flexible(
                        child: Text(
                          AppTranslations.of(context)
                              .text('how_it_works_step_three'),
                          style: kLabelTextStyle,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )
          ]),
        ),
      ),
    );
  }
}
