import 'package:flutter/material.dart';
import 'package:haloapp/components/model_progress_hud.dart';
import 'package:haloapp/models/notification_model.dart';
import 'package:haloapp/networkings/auth_networking.dart';
import 'package:haloapp/screens/main/notification_details_page.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/api_urls.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/constants/styles.dart';
import 'package:haloapp/utils/services/datetime_formatter.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationListPage extends StatefulWidget {
  static const String id = 'NotificationListPage';

  @override
  _NotificationListPageState createState() => _NotificationListPageState();
}

class _NotificationListPageState extends State<NotificationListPage> {
  bool _showSpinner = true;
  NotificationModel _notification = NotificationModel();

  @override
  initState() {
    _notification.notification = [];
    _getNotification();
    super.initState();
  }

  Future _getNotification() async {
    Map<String, dynamic> params = {
      "apiKey": APIUrls().getApiKey(),
    };

    print(params);

    setState(() {
      _showSpinner = true;
    });

    try {
      _notification = await AuthNetworking().getNotificationList(params);
    } catch (e) {
      print('gg');
      // print(e.toString());
    } finally {
      setState(() {
        _showSpinner = false;
      });
    }
  }

  // List<String> _announcements = [];

  void viewAnnouncementDetails(NotificationSingleModel notificationModel) {
   Navigator.pushNamed(context, NotificationDetailsPage.id, arguments: notificationModel);
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
          AppTranslations.of(context).text('notification'),
          style: kAppBarTextStyle,
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _showSpinner,
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.all(15.0),
            child: (_notification.notification.length == 0)
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        AppTranslations.of(context).text('no_notification'),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: poppinsLight, fontSize: 16),
                      )
                    ],
                  )
                : ListView.separated(
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          viewAnnouncementDetails(_notification.notification[index]);
                        },
                        behavior: HitTestBehavior.translucent,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              DatetimeFormatter().getFormattedDateStr(
                                  format: 'dd MMM yyyy hh:mm a',
                                  datetime: _notification.notification[index].blastCreatedDatetime
                                      .toString()),
                            ),
                            Text(
                              _notification.notification[index].consumerBlastTitle,
                              style: TextStyle(fontFamily: poppinsMedium, fontSize: 16),
                            ),
                            Text(
                              _notification.notification[index].consumerBlastContent,
                              style: TextStyle(fontFamily: poppinsRegular, fontSize: 16),
                            ),
//                                Text(
//                                  _announcements[index].announcementContentHtml,
//                                  style: TextStyle(
//                                      fontFamily: poppinsRegular,
//                                      fontSize: 16),
//                                ),
//                         Container(
//                           width: MediaQuery.of(context).size.width - 30,
//                           child: Html(
//                             data: _notification[index].announcementContentHtml,
//                             shrinkWrap: false,
//                             onAnchorTap: (String url, RenderContext context,
//                                 Map<String, String> attributes, _) async {
//                               try {
//                                 if (await canLaunch(url)) {
//                                   launch(url);
//                                 }
//                               } catch (e) {}
//                               print("Opening $url...");
//                             },
//                             onImageTap: (src, _, __, ___) {
//                               print(src);
//                             },
//                             onImageError: (exception, stackTrace) {
//                               print(exception);
//                             },
//                             onCssParseError: (css, messages) {
//                               print("css that errored: $css");
//                               print("error messages:");
//                               messages.forEach((element) {
//                                 print(element);
//                               });
//                             },
//                           ),
//                         ),
//                                Flexible(
//                                  child: Text(
//                                    _announcements[index].announcementTitle,
//                                    style: TextStyle(
//                                        fontFamily: poppinsMedium,
//                                        fontSize: 16),
//                                  ),
//                                ),
//                                Flexible(
//                                  child: Text(
//                                    _announcements[index].announcementContent,
//                                    style: TextStyle(
//                                        fontFamily: poppinsRegular,
//                                        fontSize: 16),
//                                  ),
//                                ),
                          ],
                        ),
//                        Row(
//                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                          children: <Widget>[
//                            Column(
//                              crossAxisAlignment: CrossAxisAlignment.start,
//                              children: <Widget>[
//                                Text(DatetimeFormatter().getFormattedDateStr(
//                                    format: 'dd MMM yyyy hh:mm a',
//                                    datetime: _announcements[index]
//                                        .publishedDatetime
//                                        .toString()
//                                    )
//                                ),
//                                Text(
//                                  _announcements[index].announcementTitle,
//                                  style: TextStyle(
//                                      fontFamily: poppinsMedium,
//                                      fontSize: 16),
//                                ),
////                                Text(
////                                  _announcements[index].announcementContentHtml,
////                                  style: TextStyle(
////                                      fontFamily: poppinsRegular,
////                                      fontSize: 16),
////                                ),
//                                SingleChildScrollView(
//                                  scrollDirection: Axis.horizontal,
//                                  child: Html(
//                                    data: _announcements[index].announcementContentHtml,
//                                    shrinkWrap: false,
//                                  ),
//                                )
////                                Flexible(
////                                  child: Text(
////                                    _announcements[index].announcementTitle,
////                                    style: TextStyle(
////                                        fontFamily: poppinsMedium,
////                                        fontSize: 16),
////                                  ),
////                                ),
////                                Flexible(
////                                  child: Text(
////                                    _announcements[index].announcementContent,
////                                    style: TextStyle(
////                                        fontFamily: poppinsRegular,
////                                        fontSize: 16),
////                                  ),
////                                ),
//                              ],
//                            ),
////                            SizedBox(width: 10.0),
//                            // Icon(Icons.navigate_next)
//                          ],
//                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        child: Divider(
                          color: Colors.black,
                        ),
                      );
                    },
                    itemCount: _notification.notification.length),
          ),
        ),
      ),
    );
  }
}
