import 'package:flutter/material.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/screens/auth/login_page.dart';
import 'package:haloapp/screens/main/tab_bar_controller.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/page_route_animation.dart';
import 'package:haloapp/utils/services/shared_pref_service.dart';

import 'get_started_page.dart';

class StepPage extends StatefulWidget {
  StepPage({this.arguments});
  static const String id = 'StepPage';
  final StepPageArguments arguments;

  @override
  _StepPageState createState() => _StepPageState();
}

class _StepPageState extends State<StepPage> {
  final String btnSkipTxt = 'boarding_btn_skip';
  final String btnNextTxt = 'boarding_btn_next';
  final String btnStartTxt = 'boarding_btn_start';
  final String board1Txt = 'boarding_1_description';
  final String board2Txt = 'boarding_2_description';
  final String board3Txt = 'boarding_3_description';

  final String board1Img = 'images/boarding_1.png';
  final String board2Img = 'images/boarding_2.png';
  final String board3Img = 'images/boarding_3.png';

  String displayTxt;
  String displayImg;
  String displaybtn;
  String displayBoard = '1';

  @override
  void initState() {
    super.initState();
    if (widget.arguments != null) {
      setState(() {
        displayBoard = widget.arguments.boardingStep;
      });
    }

    checkDisplay();
  }

  checkDisplay() {
    switch (displayBoard) {
      case '1':
        setState(() {
          displayTxt = board1Txt;
          displayImg = board1Img;
          displaybtn = btnNextTxt;
        });
        break;

      case '2':
        setState(() {
          displayTxt = board2Txt;
          displayImg = board2Img;
          displaybtn = btnNextTxt;
        });
        break;
      case '3':
        setState(() {
          displayTxt = board3Txt;
          displayImg = board3Img;
          displaybtn = btnStartTxt;
        });
        break;
    }
  }

  navigatePage() {
    switch (displayBoard) {
      case '1':
        goNextPage("2");
        // Navigator.push(
        //   context,
        //   FadeInRoute(
        //     routeName: StepPage.id,
        //     page: StepPage(arguments: StepPageArguments(boardingStep: '2'),),
        //   )
        //   // MaterialPageRoute(
        //   //   builder: (context) => StepPage(
        //   //     arguments: StepPageArguments(boardingStep: '2'),
        //   //   ),
        //   // ),
        // );
        break;

      case '2':
        goNextPage("3");
        // Navigator.push(
        //   context,
        //   FadeInRoute(
        //     routeName: StepPage.id,
        //     page: StepPage(arguments: StepPageArguments(boardingStep: '3'),),
        //   )
        //   // MaterialPageRoute(
        //   //   builder: (context) => StepPage(
        //   //     arguments: StepPageArguments(boardingStep: '3'),
        //   //   ),
        //   // ),
        // );
        break;
      case '3':
        SharedPrefService().setFirstTime(false);
        Navigator.pushNamedAndRemoveUntil(
          context,
          TabBarPage.id,
          (Route<dynamic> route) => false,
        );
        break;
    }
  }

  navigateBackPage() {
    switch (displayBoard) {
      case '2':
        goNextPage("1");
        // Navigator.push(
        //   context,
        //   FadeInRoute(
        //     routeName: StepPage.id,
        //     page: StepPage(arguments: StepPageArguments(boardingStep: '2'),),
        //   )
        //   // MaterialPageRoute(
        //   //   builder: (context) => StepPage(
        //   //     arguments: StepPageArguments(boardingStep: '2'),
        //   //   ),
        //   // ),
        // );
        break;

      case '3':
        goNextPage("2");
        // Navigator.push(
        //   context,
        //   FadeInRoute(
        //     routeName: StepPage.id,
        //     page: StepPage(arguments: StepPageArguments(boardingStep: '3'),),
        //   )
        //   // MaterialPageRoute(
        //   //   builder: (context) => StepPage(
        //   //     arguments: StepPageArguments(boardingStep: '3'),
        //   //   ),
        //   // ),
        // );
        break;

      default:
        break;
    }
  }

  void goNextPage(String page) {
    Navigator.push(
        context,
        FadeInRoute(
          routeName: StepPage.id,
          page: StepPage(
            arguments: StepPageArguments(boardingStep: page),
          ),
        )
        // MaterialPageRoute(
        //   builder: (context) => StepPage(
        //     arguments: StepPageArguments(boardingStep: '3'),
        //   ),
        // ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                Column(
                  children: [
                    Container(
                      height: (MediaQuery.of(context).size.height / 1.7),
                      margin: EdgeInsets.zero,
                      padding: EdgeInsets.zero,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(displayImg),
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                      child: null /* add child content here */,
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: Container(
                        margin: EdgeInsets.only(top: 8, left: 48, right: 48),
                        child: Text(
                          AppTranslations.of(context).text(displayTxt),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: poppinsRegular,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    Spacer(),
                    Container(
                      margin: EdgeInsets.all(16),
                      child: ActionButton(
                        buttonText:
                            AppTranslations.of(context).text(displaybtn),
                        onPressed: navigatePage,
                      ),
                    ),
                  ],
                ),
                displayBoard != '3'
                    ? Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          alignment: Alignment.topRight,
                          child: TextButton(
                            onPressed: () {
                              SharedPrefService().setFirstTime(false);
                              Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  TabBarPage.id,
                                  (Route<dynamic> route) => false);
                            },
                            child: Text(
                              AppTranslations.of(context).text(btnSkipTxt),
                              style: TextStyle(
                                color: kColorRed,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      )
                    : SizedBox.shrink(),
                if (displayBoard != '1')
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: TextButton(
                        onPressed: () {
                          navigateBackPage();
                        },
                        child: Text(
                          AppTranslations.of(context).text("btn_back"),
                          style: TextStyle(
                            color: kColorRed,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StepPageArguments {
  final String boardingStep;

  StepPageArguments({
    this.boardingStep = '1',
  });
}
