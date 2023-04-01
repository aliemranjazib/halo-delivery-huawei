import 'package:flutter/material.dart';
import 'package:haloapp/components/model_progress_hud.dart';
import 'package:haloapp/models/activity_model.dart';
import 'package:haloapp/models/notification_model.dart';
import 'package:haloapp/models/user_model.dart';
import 'package:haloapp/networkings/auth_networking.dart';
import 'package:haloapp/networkings/booking_networking.dart';
import 'package:haloapp/screens/main/activity_support_details_page.dart';
import 'package:haloapp/screens/main/notification_details_page.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/api_urls.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/constants/styles.dart';
import 'package:haloapp/utils/services/datetime_formatter.dart';
import 'package:url_launcher/url_launcher.dart';

class ActivitySupportAllPage extends StatefulWidget {
  static const String id = 'ActivitySupportAllPage';

  @override
  _ActivitySupportAllPageState createState() => _ActivitySupportAllPageState();
}

class _ActivitySupportAllPageState extends State<ActivitySupportAllPage> {
  bool _showSpinner = true;
  ActivityModel _activity = ActivityModel();

  @override
  initState() {
    _activity.bookingDetail = [];
    _getActivity();
    super.initState();
  }

  Future _getActivity() async {
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
      _activity = await BookingNetworking().getAllRecentActivity(params);
    } catch (e) {
      print('gg wtf');
      // print(e.toString());
    } finally {
      setState(() {
        _showSpinner = false;
      });
    }
  }

  // List<String> _announcements = [];

  void viewActivityDetails(BookingDetail bookDetail) {
    Navigator.pushNamed(context, ActivitySupportDetailsPage.id,
        arguments: bookDetail);
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
              padding: EdgeInsets.all(15.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent activities',
                      style: kLargeTitleBoldTextStyle,
                    ),
                    (_activity.bookingDetail.length == 0)
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                AppTranslations.of(context).text('no_activity'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: poppinsLight, fontSize: 16),
                              )
                            ],
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                onTap: () {
                                  viewActivityDetails(
                                      _activity.bookingDetail[index]);
                                },
                                behavior: HitTestBehavior.translucent,
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 6),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 6, horizontal: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(3)),
                                    boxShadow: [elevation],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(children: [
                                        Text(
                                            _activity.bookingDetail[index]
                                                .orderStatus,
                                            style: kLabelSemiBoldTextStyle),
                                        Spacer(),
                                        Text(
                                          DatetimeFormatter()
                                              .getFormattedDateStr(
                                                  format: 'dd MMM yyyy hh:mm a',
                                                  datetime: _activity
                                                      .bookingDetail[index]
                                                      .bookingDate
                                                      .toString()),
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
                                            _activity
                                                .bookingDetail[index].itemType,
                                            style: kLabelSemiBoldTextStyle,
                                          ),
                                          Spacer(),
                                          Row(
                                            children: [
                                              Text(
                                                'RM ',
                                                style: TextStyle(fontSize: 12),
                                              ),
                                              Text(
                                                  _activity.bookingDetail[index]
                                                      .totalPrice,
                                                  style:
                                                      kLabelSemiBoldTextStyle),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Text(
                                          _activity.bookingDetail[index]
                                              .bookingAddress[0].recipientName,
                                          style: TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                                ),
                              );
                            },
                            // separatorBuilder: (context, index) {
                            //   return Padding(
                            //     padding: EdgeInsets.symmetric(vertical: 10.0),
                            //     child: Divider(
                            //       color: Colors.black,
                            //     ),
                            //   );
                            // },
                            itemCount: _activity.bookingDetail.length),
                  ],
                ),
              )),
        ),
      ),
    );
  }
}
