import 'package:flutter/material.dart';
import 'package:haloapp/components/custom_flushbar.dart';
import 'package:haloapp/models/app_config_model.dart';
import 'package:haloapp/screens/main/activty_support_chat_page.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/constants/styles.dart';
import 'package:haloapp/components/model_progress_hud.dart';
import 'package:haloapp/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportPage extends StatefulWidget {
  static const String id = 'supportPage';

  @override
  _SupportPageState createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  bool _showSpinner = false;

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _openMessenger() async {
    String url = AppConfig.consumerConfig.supportUrl;
    String webUrl = AppConfig.consumerConfig.supportUrlBackup;

    setState(() {
      _showSpinner = true;
    });

    if (await canLaunch(url)) {
      await launch(url);

      setState(() {
        _showSpinner = false;
      });
    } else if (await canLaunch(webUrl)) {
      await launch(webUrl);

      setState(() {
        _showSpinner = false;
      });
    } else {
      setState(() {
        _showSpinner = false;
      });
      print('Could not launch $url');
      showSimpleFlushBar(
          AppTranslations.of(context)
              .text('failed_please_make_sure_install_fb_messenger'),
          context);
    }
  }

  void openChatPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActivitySupportChatPage(
          bookingNumber: '',
          messageProblem: '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.red,
        title: Text(
          AppTranslations.of(context).text('title_message'),
          style: kAppBarTextStyle.copyWith(color: Colors.white),
        ),
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: kAppBarGradient,
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _showSpinner,
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SizedBox(height: 50.0),
                    Image.asset(
                      'images/ic_chat.png',
                      width: 80,
                      height: 200,
                    ),
                    SizedBox(height: 50.0),
                    MaterialButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 10),
                      onPressed: () {
                        _openMessenger();
                      },
                      color: kColorRed,
                      textColor: Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppTranslations.of(context).text('chat_now'),
                            style: TextStyle(
                              fontFamily: poppinsMedium,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    MaterialButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 10),
                      onPressed: () {
                        Utils.showChatConfirmationDialog(
                            context, () => openChatPage());
                      },
                      color: kColorRed,
                      textColor: Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppTranslations.of(context).text('contact_us'),
                            style: TextStyle(
                              fontFamily: poppinsMedium,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
