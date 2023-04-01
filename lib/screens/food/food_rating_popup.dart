import 'package:flutter/material.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/components/custom_flushbar.dart';
import 'package:haloapp/components/remarks_textbox.dart';
import 'package:haloapp/models/food_history_model.dart';
import 'package:haloapp/networkings/food_history_networking.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/api_urls.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/constants/styles.dart';
import 'package:haloapp/utils/services/pop_with_result_service.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:haloapp/components/model_progress_hud.dart';

class FoodRatingPage extends StatefulWidget {
  FoodRatingPage({this.history});

  final FoodHistoryModel history;

  @override
  _FoodRatingPageState createState() => _FoodRatingPageState();
}

class _FoodRatingPageState extends State<FoodRatingPage> {
  bool _showSpinner = false;
  double _foodRating = 5;
  String _foodCommentTFValue;
  double _riderRating = 5;
  String _riderCommentTFValue;

  void rateBooking() async {
    Map<String, dynamic> params = {
      "apiKey": APIUrls().getFoodApiKey(),
      "data": {
        "orderUniqueKey": widget.history.orderUniqueKey,
        "foodCustomerRating": _foodRating,
        "foodCustomerComment": _foodCommentTFValue,
        "riderCustomerRating": _riderRating,
        "riderCustomerComment": _riderCommentTFValue
      },
    };
    print(params);

    setState(() {
      _showSpinner = true;
    });

    try {
      var data = await FoodHistoryNetworking().rateOrder(params);

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
      appBar: AppBar(
        title: Text(
          AppTranslations.of(context).text(
            'rating_and_comment',
          ),
          style: kAppBarTextStyle,
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _showSpinner,
        child: SafeArea(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 26.0, vertical: 20.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    AppTranslations.of(context).text(
                        'would_you_like_to_give_rating_for_your_previous_completed_order_ques'),
                    style: TextStyle(fontFamily: poppinsRegular, fontSize: 16),
                  ),
                  SizedBox(height: 25.0),
                  Container(
                    color: Colors.grey[200],
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(
                          widget.history.orderPickupDatetime,
                          style: kDetailsTextStyle,
                        ),
                        Text(
                          widget.history.shopName,
                          style: kDetailsTextStyle,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 25.0),
                  Text(
                    AppTranslations.of(context).text('food_rating'),
                    style: TextStyle(fontFamily: poppinsRegular, fontSize: 16),
                  ),
                  SizedBox(height: 10.0),
                  RatingBar.builder(
                    initialRating: _foodRating,
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
                      _foodRating = rating;
                    },
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    AppTranslations.of(context).text('food_comment'),
                    style: TextStyle(fontFamily: poppinsRegular, fontSize: 16),
                  ),
                  SizedBox(height: 10.0),
                  RemarksTextBox(
                    hintText: AppTranslations.of(context)
                        .text('write_your_comments_here'),
                    onChanged: (value) {
                      _foodCommentTFValue = value;
                    },
                  ),
                  SizedBox(height: 30.0),
                  Text(
                    AppTranslations.of(context).text('rider_rating'),
                    style: TextStyle(fontFamily: poppinsRegular, fontSize: 16),
                  ),
                  SizedBox(height: 10.0),
                  RatingBar.builder(
                    initialRating: _riderRating,
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
                      _riderRating = rating;
                    },
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    AppTranslations.of(context).text('rider_comment'),
                    style: TextStyle(fontFamily: poppinsRegular, fontSize: 16),
                  ),
                  SizedBox(height: 10.0),
                  RemarksTextBox(
                    hintText: AppTranslations.of(context)
                        .text('write_your_comments_here'),
                    onChanged: (value) {
                      _riderCommentTFValue = value;
                    },
                  ),
                  SizedBox(height: 40.0),
                  ActionButton(
                    buttonText: AppTranslations.of(context).text('submit'),
                    onPressed: () {
                      rateBooking();
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
