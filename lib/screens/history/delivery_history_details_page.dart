import 'package:flutter/material.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/components/addresses_details.dart';
import 'package:haloapp/components/custom_flushbar.dart';
import 'package:haloapp/models/address_model.dart';
import 'package:haloapp/models/booking_model.dart';
import 'package:haloapp/models/history_model.dart';
import 'package:haloapp/networkings/history_networking.dart';
import 'package:haloapp/screens/auth/login_page.dart';
import 'package:haloapp/screens/history/delivery_cancel_booking_dialog.dart';
import 'package:haloapp/screens/delivery/delivery_tracking_page.dart';
import 'package:haloapp/screens/delivery/rating_and_comment_booking.dart';
import 'package:haloapp/screens/delivery/remake_booking_dialog.dart';
import 'package:haloapp/screens/general/confirmation_dialog.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/api_urls.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/constants/job_status.dart';
import 'package:haloapp/utils/constants/styles.dart';
import 'package:haloapp/utils/constants/vehicles.dart';
import 'package:haloapp/utils/services/pop_with_result_service.dart';
import 'package:haloapp/utils/services/shared_pref_service.dart';
import 'package:haloapp/components/model_progress_hud.dart';

class DeliveryHistoryDetailsPage extends StatefulWidget {
  static const String id = 'deliveryHistoryDetailsPage';

  @override
  _DeliveryHistoryDetailsPageState createState() =>
      _DeliveryHistoryDetailsPageState();
}

class _DeliveryHistoryDetailsPageState
    extends State<DeliveryHistoryDetailsPage> {
  bool _showSpinner = false;
  HistoryModel details;
  bool _needRefreshList = false;

  void showCancelBookingDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => DeliveryCancelBookingDialog(
              bookingUniqueKey: details.bookingUniqueKey,
            )).then((value) {
      if (value != null) {
        if (value is PopWithResults) {
          PopWithResults popResult = value;

          if (popResult.toPage == 'login') {
            SharedPrefService().removeLoginInfo();
            Navigator.popUntil(context, ModalRoute.withName(LoginPage.id));
          }
        } else {
          _needRefreshList = true;
          showSimpleFlushBar(value, context, isError: false);
          getHistoryDetails(details.bookingUniqueKey);
        }
      }
    });
  }

  void getHistoryDetails(String key) async {
    Map<String, dynamic> params = {
      "apiKey": APIUrls().getApiKey(),
      "data": {
        "bookingUniqueKey": key,
      },
    };

    setState(() {
      _showSpinner = true;
    });

    try {
      var data = await HistoryNetworking().getHistoryDetails(params);

      setState(() {
        details = data;
      });
    } catch (e) {
      print(e.toString());
      showSimpleFlushBar(e, context);
    } finally {
      setState(() {
        _showSpinner = false;
      });
    }
  }

  void showRatingDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => RatingAndCommentsPage(
              bookingUniqueKey: details.bookingUniqueKey,
            )).then((value) {
      if (value != null) {
        if (value is PopWithResults) {
          PopWithResults popResult = value;

          if (popResult.toPage == 'login') {
            SharedPrefService().removeLoginInfo();
            Navigator.popUntil(context, ModalRoute.withName(LoginPage.id));
          }
        } else {
          _needRefreshList = true;
          showSimpleFlushBar(value, context, isError: false);
          getHistoryDetails(details.bookingUniqueKey);
        }
      }
    });
  }

  void showMakeNewBookingDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => RemakeSameBookingConfirmationDialog(
            addresses: details.addresses)).then((value) {
      if (value != null && value == 'confirm') {
        if (BookingModel().getAllAddresses().length > 0) {
          // Have booking data
          showDiscardCurrentBookingDialog();
        } else {
          copyHistoryBookingData();
        }
      }
    });
  }

  void showDiscardCurrentBookingDialog() {
    showDialog(
        context: context,
        builder: (context) => ConfirmationDialog(
              title: AppTranslations.of(context).text('make_new_booking'),
              message: AppTranslations.of(context).text(
                  'are_you_sure_make_new_booking_current_booking_will_discarded'),
            )).then((value) {
      if (value != null && value == 'confirm') {
        setState(() {
          BookingModel().clearBookingData();
          copyHistoryBookingData();
        });
      }
    });
  }

  void copyHistoryBookingData() {
    for (AddressModel address in details.addresses) {
      BookingModel().addAddress(AddressModel(
        type: address.type,
        fullAddress: address.fullAddress,
        lat: address.lat,
        lng: address.lng,
        street: address.street,
        city: address.city,
        zip: address.zip,
        state: address.state,
        unitNo: address.unitNo,
        buildingName: address.buildingName,
        receiverName: address.receiverName,
        receiverPhone: address.receiverPhone,
      ));
    }

    Navigator.pop(context, 'remakeBooking');
  }

  @override
  Widget build(BuildContext context) {
    if (_needRefreshList == false) {
      details = ModalRoute.of(context).settings.arguments;
    }

    return Scaffold(
      // backgroundColor: kLightBackground,
      appBar: AppBar(
        title: Text(
          AppTranslations.of(context).text('history_details'),
          style: kAppBarTextStyle,
        ),
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context, _needRefreshList);
            }),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _showSpinner,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    margin: EdgeInsets.all(15.0),
                    child: Column(
                      children: <Widget>[
                        (details.orderStatus == 'completed')
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  Container(
                                    color: Colors.white,
                                    padding: EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: <Widget>[
                                        Text(
                                          AppTranslations.of(context)
                                              .text('your_reviews'),
                                          textAlign: TextAlign.center,
                                          style: kTitleTextStyle,
                                        ),
                                        SizedBox(height: 10.0),
                                        TitleDetailsRow(
                                          titleText: AppTranslations.of(context)
                                              .text('comment'),
                                          detailText:
                                              (details.customerComment != '')
                                                  ? details.customerComment
                                                  : AppTranslations.of(context)
                                                      .text('no_comment'),
                                        ),
                                        SizedBox(height: 10.0),
                                        Row(
                                          children: <Widget>[
                                            Text(
                                                '${AppTranslations.of(context).text('rating')}: ',
                                                style: kDetailsTextStyle),
                                            (details.customerRating != '0')
                                                ? displayRating()
                                                : Text(
                                                    AppTranslations.of(context)
                                                        .text('no_rating'),
                                                    style: kDetailsTextStyle),
                                          ],
                                        ),
                                        SizedBox(height: 15.0),
                                        (details.customerRating == '0')
                                            ? MaterialButton(
                                                onPressed: () {
                                                  showRatingDialog();
                                                },
                                                color: kColorRed,
                                                textColor: Colors.white,
                                                child: Text(
                                                  AppTranslations.of(context)
                                                      .text('review'),
                                                  style: TextStyle(
                                                      fontFamily: poppinsMedium,
                                                      fontSize: 15),
                                                ),
                                              )
                                            : Container()
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : Container(),
                        SizedBox(height: 16.0),
                        Container(
                          color: Colors.white,
                          padding: EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Text(
                                AppTranslations.of(context)
                                    .text('booking_information'),
                                textAlign: TextAlign.center,
                                style: kTitleTextStyle,
                              ),
                              SizedBox(height: 10.0),
                              TitleDetailsRow(
                                titleText: AppTranslations.of(context)
                                    .text('booking_number'),
                                detailText: details.bookingNumber,
                              ),
                              SizedBox(height: 10.0),
                              TitleDetailsRow(
                                titleText: AppTranslations.of(context)
                                    .text('pickup_date'),
                                detailText: details.pickupDate,
                              ),
                              SizedBox(height: 10.0),
                              TitleDetailsRow(
                                titleText: AppTranslations.of(context)
                                    .text('pickup_time'),
                                detailText: details.pickupTime,
                              ),
                              SizedBox(height: 10.0),
                              TitleDetailsRow(
                                titleText:
                                    AppTranslations.of(context).text('status'),
                                detailText: AppTranslations.of(context).text(
                                    JobStatus().getJobStatusDescription(
                                        details.orderStatus)),
                                detailTextColor: Colors.green,
                              ),
                              SizedBox(height: 10.0),
                              TitleDetailsRow(
                                titleText: "Payment Method",
                                detailText: details.paymentMethod,
                              ),
                              SizedBox(height: 10.0),
                              TitleDetailsRow(
                                titleText: "Building Name",
                                detailText: details.buildingName,
                              ),
                              SizedBox(height: 10.0),
                              TitleDetailsRow(
                                titleText: "Building Unit Number",
                                detailText: details.buildingUnitNumber,
                              ),
                              SizedBox(height: 15.0),
                              (details.orderStatus == 'new' ||
                                      details.orderStatus == 'pending')
                                  ? MaterialButton(
                                      onPressed: () {
                                        showCancelBookingDialog();
                                      },
                                      color: kColorRed,
                                      textColor: Colors.white,
                                      child: Text(
                                        AppTranslations.of(context)
                                            .text('cancel_booking'),
                                        style: TextStyle(
                                            fontFamily: poppinsMedium,
                                            fontSize: 15),
                                      ),
                                    )
                                  : Container(),
                              (details.orderStatus != '' &&
                                      details.orderStatus != 'new' &&
                                      details.orderStatus != 'pending' &&
                                      details.orderStatus != 'completed' &&
                                      details.orderStatus != 'canceled')
                                  ? MaterialButton(
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    DeliveryTrackingPage(
                                                      history: details,
                                                    )));
                                      },
                                      color: kColorRed,
                                      textColor: Colors.white,
                                      child: Text(
                                        AppTranslations.of(context)
                                            .text('tracking'),
                                        style: TextStyle(
                                            fontFamily: poppinsMedium,
                                            fontSize: 15),
                                      ),
                                    )
                                  : Container(),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.0),
                        Container(
                          color: Colors.white,
                          padding: EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Text(
                                AppTranslations.of(context)
                                    .text('driver_information'),
                                textAlign: TextAlign.center,
                                style: kTitleTextStyle,
                              ),
                              SizedBox(height: 10.0),
                              TitleDetailsRow(
                                titleText: AppTranslations.of(context)
                                    .text('driver_name'),
                                detailText: details.driverName ?? '-',
                              ),
                              SizedBox(height: 10.0),
                              TitleDetailsRow(
                                titleText: AppTranslations.of(context)
                                    .text('driver_mobile_no'),
                                detailText: details.driverPhone ?? '-',
                              ),
                              SizedBox(height: 10.0),
                              TitleDetailsRow(
                                titleText: AppTranslations.of(context)
                                    .text('plate_no'),
                                detailText: details.driverPlateNumber ?? '-',
                              ),
                              SizedBox(height: 30.0),
                              Text(
                                AppTranslations.of(context)
                                    .text('vehicle_type'),
                                textAlign: TextAlign.center,
                                style: kTitleTextStyle,
                              ),
                              Image.asset(
                                  Vehicles()
                                      .getVehicleImage(details.vehicleTypeId),
                                  height: 80),
                              Text(
                                Vehicles()
                                    .getVehicleName(details.vehicleTypeId),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: poppinsMedium, fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.0),
                        Container(
                          color: Colors.white,
                          padding: EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Text(
                                AppTranslations.of(context).text('addresses'),
                                textAlign: TextAlign.center,
                                style: kTitleTextStyle,
                              ),
                              SizedBox(height: 10.0),
                              AddressesDetails(
                                addresses: details.addresses,
                                showPayment: true,
                                onlinePayment: (details.paymentMethod == 'cod')
                                    ? false
                                    : true,
                              ),
                            ],
                          ),
                        ),
//                SizedBox(height: 16.0),
//                Container(
//                  color: Colors.white,
//                  padding: EdgeInsets.all(10.0),
//                  child: Column(
//                    crossAxisAlignment: CrossAxisAlignment.stretch,
//                    children: <Widget>[
//                      Text(
//                        'Image',
//                        textAlign: TextAlign.center,
//                        style: kTitleTextStyle,
//                      ),
//                      SizedBox(height: 10.0),
//                    ],
//                  ),
//                ),
                        SizedBox(height: 16.0),
                        Container(
                          color: Colors.white,
                          padding: EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Text(
                                AppTranslations.of(context)
                                    .text('delivery_item_type'),
                                textAlign: TextAlign.center,
                                style: kTitleTextStyle,
                              ),
                              SizedBox(height: 10.0),
                              Text(
                                '${AppTranslations.of(context).text(details.itemType)} ${((details.itemTypeDesc != null && details.itemTypeDesc != '') ? ' - ${details.itemTypeDesc}' : '')}',
                                textAlign: TextAlign.center,
                                style: kDetailsTextStyle,
                              ),
                              SizedBox(height: 30.0),
                              Text(
                                AppTranslations.of(context).text('remarks'),
                                textAlign: TextAlign.center,
                                style: kTitleTextStyle,
                              ),
                              SizedBox(height: 10.0),
                              Text(
                                (details.remarks != '')
                                    ? details.remarks
                                    : AppTranslations.of(context)
                                        .text('no_remarks'),
                                textAlign: TextAlign.center,
                                style: kDetailsTextStyle,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.0),
                        Container(
                          color: Colors.white,
                          padding: EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Text(
                                AppTranslations.of(context)
                                    .text('payment_details'),
                                textAlign: TextAlign.center,
                                style: kTitleTextStyle,
                              ),
                              SizedBox(height: 10.0),
                              _bookingPricing(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              (details.orderStatus == 'completed')
                  ? Container(
                      padding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: Offset(0, -4), // changes position of shadow
                          ),
                        ],
                      ),
                      child: ActionButton(
                        onPressed: () {
                          showMakeNewBookingDialog();
                        },
                        buttonText: AppTranslations.of(context)
                            .text('make_new_booking_with_same_address'),
                      ),
                    )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }

  Widget _bookingPricing() {
    List<Widget> priceDetails = [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(AppTranslations.of(context).text('distance_price'),
              style: kDetailsTextStyle),
          SizedBox(width: 10.0),
          Text(
              '${AppTranslations.of(context).text('currency_my')} ${details.distancePrice}',
              style: kDetailsTextStyle),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(AppTranslations.of(context).text('priority_fee'),
              style: kDetailsTextStyle),
          SizedBox(width: 10.0),
          Text(
              '${AppTranslations.of(context).text('currency_my')} ${(details.priorityFee != '' ? details.priorityFee : '0.00')}',
              style: kDetailsTextStyle),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(AppTranslations.of(context).text('total_price'),
              style: kDetailsTextStyle),
          SizedBox(width: 10.0),
          Text(
              '${AppTranslations.of(context).text('currency_my')} ${details.totalPriceOri}',
              style: kDetailsTextStyle),
        ],
      )
    ];

    if (details.couponName != null && details.couponName != '') {
      priceDetails.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            child: Text(
              '${AppTranslations.of(context).text('promo_code')}: ${details.couponName}',
              style: kDetailsTextStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 10.0),
          Text('- RM ${details.discountedPrice}', style: kDetailsTextStyle)
        ],
      ));
    }

    priceDetails.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          AppTranslations.of(context).text('final_price'),
          style: kAddressTextStyle,
        ),
        SizedBox(width: 10.0),
        Text(
            '${AppTranslations.of(context).text('currency_my')} ${details.totalPrice}',
            style: kAddressTextStyle.copyWith(fontSize: 18, color: Colors.red))
      ],
    ));

    priceDetails.add(SizedBox(height: 10.0));
    priceDetails.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          '${AppTranslations.of(context).text('payment_method')}: ${details.paymentMethod.toUpperCase()}',
          style: kDetailsTextStyle,
        ),
      ],
    ));

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: priceDetails,
      ),
    );
  }

  Widget displayRating() {
    List<Widget> ratingStars = [];
    int rating = int.parse(details.customerRating);

    for (int i = 0; i < 5; i++) {
      if (i < rating) {
        ratingStars.add(Icon(Icons.star, color: Colors.amberAccent));
      } else {
        ratingStars.add(Icon(Icons.star, color: Colors.grey));
      }
    }

    return Row(
      children: ratingStars,
    );
  }
}

class TitleDetailsRow extends StatelessWidget {
  const TitleDetailsRow(
      {Key key,
      @required this.titleText,
      @required this.detailText,
      this.detailTextColor})
      : super(key: key);

  final String titleText;
  final String detailText;
  final Color detailTextColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('$titleText: ', style: kDetailsTextStyle),
        Flexible(
          child: Text('$detailText',
              style: kDetailsTextStyle.copyWith(
                  color: (detailTextColor != null)
                      ? detailTextColor
                      : Colors.black)),
        ),
      ],
    );
  }
}
