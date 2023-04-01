import 'package:flutter/material.dart';
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
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/api_urls.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/constants/styles.dart';
import 'package:haloapp/utils/services/datetime_formatter.dart';
import 'package:haloapp/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class ActivitySupportDetailsPage extends StatefulWidget {
  static const String id = 'ActivitySupportDetailPage';

  final BookingDetail activity;

  ActivitySupportDetailsPage(this.activity);

  @override
  _ActivitySupportDetailsPageState createState() => _ActivitySupportDetailsPageState();
}

class _ActivitySupportDetailsPageState extends State<ActivitySupportDetailsPage> {
  bool _showSpinner = true;
  ActivityQuestionModel _activityQuestion = ActivityQuestionModel();

  @override
  initState() {
    _activityQuestion.questions = [];
    _getQuestion();
    super.initState();
  }

  Future _getQuestion() async {
    Map<String, dynamic> params = {
      "apiKey": APIUrls().getApiKey(),
      "data": {
        "userToken": User().getUserToken(),
      }
    };

    print(params);

    setState(() {
      _showSpinner = true;
    });

    try {
      _activityQuestion = await UserNetworking().getUserSupportQuestion(params);
    } catch (e) {
      print('gg wtf');
      // print(e.toString());
    } finally {
      setState(() {
        _showSpinner = false;
      });
    }
  }

  void openChatPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActivitySupportChatPage(
          bookingNumber: widget.activity.bookingNumber,
          messageProblem: '',
        ),
      ),
    );
  }

  void openChatPageWithQuestion(String problemToSend) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActivitySupportChatPage(
          bookingNumber: widget.activity.bookingNumber,
          messageProblem: problemToSend,
        ),
      ),
    );
  }

  List<Widget> getQuestionSelections() {
    List<Widget> widgets = [];

    for (Questions question in _activityQuestion.questions) {
      // Create selections
      Text selectionText = Text(
        question.problem,
        style: kDetailsTextStyle,
      );

      Row selectedOptionRow = Row(
        children: <Widget>[Image.asset('images/ic_selected_green.png'), selectionText],
      );

      Widget selectionView = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Utils.showChatConfirmationDialog(context, () => openChatPageWithQuestion(question.problemToSend
              ));
              // vaccineReqModel.vaccineType = question.vaccineName!;
              // setState(() {
              //   if (_selectedConditions.contains(ques)) {
              //     _selectedConditions.remove(ques);
              //   } else {
              //     if (!_selectedConditions
              //         .contains(question.questionAnswerOption![0])) {
              //       if (ques == question.questionAnswerOption![0]) {
              //         _selectedConditions.clear();
              //         _selectedConditions.add(ques);
              //       } else {
              //         _selectedConditions.add(ques);
              //       }
              //
              //       // Generate server acceptable answer
              //       String answersStr = '';
              //       for (String ans in _selectedConditions) {
              //         if (answersStr == '') {
              //           answersStr = answersStr + '\"$ans\"';
              //         } else {
              //           answersStr = answersStr + ', \"$ans\"';
              //         }
              //       }
              //       String answer = '[$answersStr]';
              //       question.setUserAnswer(answer);
              //     }
              //   }
              // });
            },
            child: Container(
              padding: EdgeInsets.zero,
              color: Colors.white,
              child: selectionText,
            ),
          ),
          Divider(
            thickness: 1,
            color: lightGrey,
          )
        ],
      );

      widgets.add(selectionView); // End of for loop
    }

    return widgets;
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
          AppTranslations.of(context).text('support'),
          style: kAppBarTextStyle,
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _showSpinner,
        child: SafeArea(
          child: Container(
            height: double.infinity,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Stack(
                children: [
                  Container(
                    height: 100,
                    color: kColorRed,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0, right: 15),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(3)),
                            boxShadow: [elevation],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(children: [
                                Text(widget.activity.orderStatus, style: kLabelSemiBoldTextStyle),
                                Spacer(),
                                Text(
                                  DatetimeFormatter().getFormattedDateStr(
                                      format: 'dd MMM yyyy hh:mm a',
                                      datetime: widget.activity.bookingDate.toString()),
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ]),
                              Divider(
                                thickness: 1,
                                color: lightGrey,
                              ),
                              Row(
                                children: [
                                  Text(
                                    widget.activity.itemType,
                                    style: kLabelSemiBoldTextStyle,
                                  ),
                                  Spacer(),
                                  Row(
                                    children: [
                                      Text(
                                        'RM ',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      Text(widget.activity.totalPrice,
                                          style: kLabelSemiBoldTextStyle),
                                    ],
                                  ),
                                ],
                              ),
                              Text(widget.activity.bookingAddress[0].recipientName,
                                  style: kDetailsTextStyle),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            AppTranslations.of(context).text('related_transaction'),
                            style: kTitleBoldTextStyle,
                          ),
                        ),
                        Column(
                          children: getQuestionSelections(),
                        ),
                        SizedBox(
                          height: 64,
                        ),
                        ActionButton(
                          buttonText: AppTranslations.of(context).text('contact_us'),
                          onPressed: () {
                            Utils.showChatConfirmationDialog(context, () => openChatPage());
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
