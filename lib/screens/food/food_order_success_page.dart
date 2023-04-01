import 'package:flutter/material.dart';
import 'package:haloapp/models/food_order_model.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/constants/styles.dart';

class FoodOrderSuccessPage extends StatefulWidget {
  @override
  _FoodOrderSuccessPageState createState() => _FoodOrderSuccessPageState();
}

class _FoodOrderSuccessPageState extends State<FoodOrderSuccessPage> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            AppTranslations.of(context).text('your_order'),
            style: kAppBarTextStyle,
          ),
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 10.0, bottom: 15.0),
              child: GestureDetector(
                onTap: () {
                  FoodOrderModel().clearFoodOrderData();
                  Navigator.pop(context, 'close');
                },
                child: Container(
                  height: 30,
                  width: 30,
                  margin: EdgeInsets.only(right: 20.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: Colors.grey.withOpacity(0.7),
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          AppTranslations.of(context)
                              .text('order_made_exclamation'),
                          style: kTitleTextStyle,
                        ),
                        SizedBox(height: 20.0),
                        Image.asset('images/completed.png'),
                        SizedBox(height: 30.0),
                        // Text(
                        //   AppTranslations.of(context)
                        //       .text('estimated_delivery_time'),
                        //   style: kDetailsTextStyle,
                        // ),
                        // SizedBox(height: 10.0),
                        // Text(
                        //   '${FoodOrderModel().getEstDuration()} mins',
                        //   style: TextStyle(
                        //       fontFamily: poppinsSemiBold, fontSize: 22),
                        // )
                      ],
                    ),
                  ),
//                  SizedBox(height: 20.0),
//                  Container(
//                    padding:
//                        EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
//                    color: Colors.white,
//                    child: Column(
//                      crossAxisAlignment: CrossAxisAlignment.stretch,
//                      children: <Widget>[
//                        Text(
//                          AppTranslations.of(context).text('order_details'),
//                          style: kTitleTextStyle,
//                        ),
//                        SizedBox(height: 15.0),
//                        Row(
//                          children: <Widget>[
//                            Text(
//                              AppTranslations.of(context).text('order_number'),
//                              style: TextStyle(
//                                  fontFamily: poppinsRegular, fontSize: 14),
//                            ),
//                            SizedBox(width: 8.0),
//                            Text(
//                              '#',
//                              style: TextStyle(
//                                  fontFamily: poppinsMedium, fontSize: 14),
//                            )
//                          ],
//                        ),
//                        SizedBox(height: 8.0),
//                        Row(
//                          children: <Widget>[
//                            Text(
//                              AppTranslations.of(context).text('order_from') +
//                                  ':',
//                              style: TextStyle(
//                                  fontFamily: poppinsRegular, fontSize: 14),
//                            ),
//                            SizedBox(width: 8.0),
//                            Text(
//                              'shop name',
//                              style: TextStyle(
//                                  fontFamily: poppinsMedium, fontSize: 14),
//                            )
//                          ],
//                        ),
//                        SizedBox(height: 8.0),
//                        Row(
//                          children: <Widget>[
//                            Text(
//                              AppTranslations.of(context).text('deliver_to') +
//                                  ':',
//                              style: TextStyle(
//                                  fontFamily: poppinsRegular, fontSize: 14),
//                            ),
//                            SizedBox(width: 8.0),
//                            Text(
//                              'address',
//                              style: TextStyle(
//                                  fontFamily: poppinsMedium, fontSize: 14),
//                            )
//                          ],
//                        ),
//                        SizedBox(
//                          height: 30.0,
//                          child: Divider(
//                            color: Colors.black,
//                          ),
//                        ),
//                      ],
//                    ),
//                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
