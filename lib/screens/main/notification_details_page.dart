import 'package:flutter/material.dart';
import 'package:haloapp/models/notification_model.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/constants/styles.dart';
import 'package:haloapp/utils/services/datetime_formatter.dart';

class NotificationDetailsPage extends StatelessWidget {
  static const String id = 'NotificationDetailsPage';
  final NotificationSingleModel notification;

  NotificationDetailsPage(this.notification);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          notification.consumerBlastTitle,
          style: kAppBarTextStyle,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: arrowBack,
          onPressed: () => {Navigator.pop(context)},
        ),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(DatetimeFormatter().getFormattedDateStr(
                  format: 'dd MMM yyyy hh:mm a',
                  datetime: notification
                      .blastScheduledDatetime
                      .toString()
              ),
              ),
              Text(
                notification.consumerBlastTitle,
                style: TextStyle(
                    fontFamily: poppinsMedium,
                    fontSize: 16
                ),
              ),
                Text(
                  notification.consumerBlastContent,
                  style: TextStyle(
                      fontFamily: poppinsRegular,
                      fontSize: 16),
                ),
//              ),
//                                Text(
//                                  _announcements[index].announcementContentHtml,
//                                  style: TextStyle(
//                                      fontFamily: poppinsRegular,
//                                      fontSize: 16),
//                                ),
//               Expanded(
//                 child: ListView(
//                   children: [
//                     Container(
//                       width: MediaQuery.of(context).size.width - 30,
//                       child: Html(
//                         data: notification.announcementContentHtml,
//                         shrinkWrap: false,
//                         onAnchorTap: (String url,
//                             RenderContext context,
//                             Map<String, String> attributes,
//                             _)async{
//
//                           try{
//                             if(await canLaunch(url)){
//                               launch(url);
//                             }
//                           }catch(e){
//
//                           }
//                           print("Opening $url...");
//
//                         },
//                         onImageTap: (src, _, __, ___) {
//                           print(src);
//                         },
//                         onImageError: (exception, stackTrace) {
//                           print(exception);
//                         },
//                         onCssParseError: (css, messages) {
//                           print("css that errored: $css");
//                           print("error messages:");
//                           messages.forEach((element) {
//                             print(element);
//                           });
//                         },
//                       ),
//                     )
//                   ],
//                 ),
//               ),
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
        ),
      ),
    );
  }
}
