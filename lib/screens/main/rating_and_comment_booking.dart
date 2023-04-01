import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/components/custom_flushbar.dart';
import 'package:haloapp/components/remarks_textbox.dart';
import 'package:haloapp/components_new/driver_card.dart';
import 'package:haloapp/networkings/history_networking.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/api_urls.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/constants/styles.dart';
import 'package:haloapp/utils/services/pop_with_result_service.dart';

class RatingAndCommentsPage extends StatefulWidget {
  final String bookingUniqueKey;
  static const String id = 'ratingandcomment';

  RatingAndCommentsPage({this.bookingUniqueKey});

  @override
  _RatingAndCommentsPageState createState() => _RatingAndCommentsPageState();
}

class _RatingAndCommentsPageState extends State<RatingAndCommentsPage> {
  bool _showSpinner = false;
  double _rating = 5;
  String _commentTFValue;

  void rateBooking() async {
    Map<String, dynamic> params = {
      "apiKey": APIUrls().getApiKey(),
      "data": {
        "bookingUniqueKey": widget.bookingUniqueKey,
        "customerRating": _rating,
        "customerComment": _commentTFValue
      },
    };
    print(params);

    setState(() {
      _showSpinner = true;
    });

    try {
      var data = await HistoryNetworking().rateBooking(params);

      Navigator.pop(context, data);
    } catch (e) {
      if (e is Map<String, dynamic>) {
        if (e['status_code'] == 514) {
          Navigator.pop(
            context,
            PopWithResults(
              fromPage: 'rating',
              toPage: 'login',
              results: {
                'logout': true,
                'msg': e,
              },
            ),
          );
        }
      } else {
        print(e.toString());
        showSimpleFlushBar(e, context);
      }
    } finally {
      setState(() {
        _showSpinner = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.close_rounded),
                  ),
                ),
                Image.asset(
                  'images/success.png',
                  height: 200,
                ),
                Text(
                  AppTranslations.of(context).text('delivery_success'),
                  textAlign: TextAlign.center,
                  style: kTitleTextStyle.copyWith(fontSize: 16),
                ),
                Text(
                  AppTranslations.of(context).text('rate_driver_service'),
                  textAlign: TextAlign.center,
                  style: kTitleTextStyle.copyWith(fontSize: 16),
                ),
                DriverCard(
                  driverName: 'abcd',
                  driverPhoneNumber: '',
                  plateNumber: 'def',
                  vehicleModel: 'aaaa',
                ),
                SizedBox(height: 10),
                Text(
                  AppTranslations.of(context).text('rating_and_comment'),
                  style: TextStyle(fontFamily: poppinsRegular, fontSize: 16),
                ),
                SizedBox(height: 10.0),
                RatingBar.builder(
                  initialRating: _rating,
                  minRating: 1,
                  maxRating: 5,
                  glowColor: Colors.amberAccent,
                  itemBuilder: (context, _) {
                    return Icon(
                      Icons.star,
                      color: Colors.amber,
                    );
                  },
                  onRatingUpdate: (rating) {
                    _rating = rating;
                  },
                ),
                SizedBox(height: 20.0),
                Text(
                  AppTranslations.of(context).text('comment'),
                  style: TextStyle(fontFamily: poppinsRegular, fontSize: 16),
                ),
                SizedBox(height: 10.0),
                RemarksTextBox(
                  hintText: AppTranslations.of(context)
                      .text('write_your_comments_here'),
                  onChanged: (value) {
                    _commentTFValue = value;
                  },
                ),
                SizedBox(height: 40.0),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: ActionButton(
                        buttonText: AppTranslations.of(context).text('submit'),
                        onPressed: () {
                          rateBooking();
                        },
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
