import 'package:flutter/material.dart';
import 'package:haloapp/components/custom_flushbar.dart';
import 'package:haloapp/models/app_config_model.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/styles.dart';
import 'package:haloapp/utils/services/datetime_formatter.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsContainer extends StatelessWidget {
  NewsContainer({this.news});

  final List<New> news;

  void checkIsActive() {
    var list = List<New>();
    news.forEach((element) {
      if (element.promoStatus == "active") {
        list.add(element);
      }
    });
    news.clear();
    news.addAll(list);
  }

  @override
  Widget build(BuildContext context) {
    checkIsActive();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        news.length > 0
            ? Container(
                padding: EdgeInsets.only(left: 16),
                child: Text(
                  AppTranslations.of(context).text('my_news'),
                  style: kTitleBoldTextStyle,
                ),
              )
            : SizedBox.shrink(),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: ListView.separated(
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () async {
                    if (news[index].promoActionUrl != null &&
                        news[index].promoActionUrl != '') {
                      if (await canLaunch(news[index].promoActionUrl)) {
                        await launch(news[index].promoActionUrl);
                      } else {
                        showSimpleFlushBar(
                            AppTranslations.of(context).text('failed_to_load'),
                            context);
                      }
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.only(bottom: 8),
                    height: (MediaQuery.of(context).size.width - 20.0)/3,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                            child: Container(
                              child: Image.network(
                                news[index].promoImageUrl,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 6.0,
                        ),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  news[index].promoName,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: kDetailsTextStyle.copyWith(
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "images/ic_calendar_news.png",
                                    width: 15,
                                    height: 15,
                                  ),
                                  SizedBox(
                                    width: 6,
                                  ),
                                  Text(
                                    DatetimeFormatter().getFormattedDateStr(
                                        format: 'dd MMM yyyy',
                                        datetime:
                                            '${news[index].promoCreatedDatetime.toString()} 00:00:00'),
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return Container(
                  height: 10,
                );
              },
              itemCount: news.length),
        ),
      ],
    );
  }
}
