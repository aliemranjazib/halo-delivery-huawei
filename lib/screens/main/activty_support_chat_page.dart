import 'package:crisp/crisp.dart';
import 'package:flutter/material.dart';
import 'package:haloapp/models/user_model.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/styles.dart';
import 'package:haloapp/utils/services/package_info_service.dart';

class ActivitySupportChatPage extends StatefulWidget {
  static const String id = 'ActivitySupportChatPage';

  final String bookingNumber;
  final String messageProblem;

  ActivitySupportChatPage({this.bookingNumber, this.messageProblem});

  @override
  _ActivitySupportChatPageState createState() => _ActivitySupportChatPageState();
}

class _ActivitySupportChatPageState extends State<ActivitySupportChatPage> {
  CrispMain crispMain;
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    getAppVersion();
  }

  Future getAppVersion() async {
    _appVersion = (await PackageInfoService().getAppVersion()) +
        " @ " +
        (await PackageInfoService().getAppBuildNumber());
    setState(() {});

    if (User().getUserChatId() != null) {
      crispMain = CrispMain(
        websiteId: '93b1c86d-65fb-4ee8-83dd-5792092e3126',
        userToken: User().getUserChatId(),
      );
    } else {
      crispMain = CrispMain(
        websiteId: '93b1c86d-65fb-4ee8-83dd-5792092e3126',
      );
    }

    crispMain.register(
      user: CrispUser(
        email: User().getUserEmail() != null ? User().getUserEmail() : '',
        nickname: User().getUsername() != null ? User().getUsername() : '',
        phone: User().getUserPhone() != null ? User().getUserPhone() : '',
      ),
    );

    String messageQuestion = 'Question: ' + widget.messageProblem;
    String messageBookingNo = 'Booking Number: ' + widget.bookingNumber;

    if (widget.messageProblem != '') {
      crispMain.appendScript('\$crisp.push(["do", "message:send", ["text", "$messageQuestion"]]);');
    }

    if (widget.bookingNumber != '') {
      crispMain
          .appendScript('\$crisp.push(["do", "message:send", ["text", "$messageBookingNo"]]);');
    }

    //crispMain.setMessage();

    crispMain.setSessionData({
      "booking_number": widget.bookingNumber,
      "question_type": widget.messageProblem,
      "app_version": _appVersion,
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          leading: IconButton(
            icon: arrowBack,
            onPressed: () => {Navigator.pop(context)},
          ),
          title: Text(
            AppTranslations.of(context).text('support'),
            style: kAppBarTextStyle,
          ),
        ),
        body: CrispView(
          crispMain: crispMain,
          //clearCache: false,
          clearCache: User().getUserChatId() == null ? true : false,

        ),
      ),
    );
  }
}
