import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/components/addresses_details.dart';
import 'package:haloapp/components/custom_flushbar.dart';
import 'package:haloapp/components_new/address_detail.dart';
import 'package:haloapp/components_new/driver_card.dart';
import 'package:haloapp/components_new/vehicle_card.dart';
import 'package:haloapp/models/activity_model.dart';
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
import 'package:haloapp/screens/main/activity_support_details_page.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/api_urls.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/constants/job_status.dart';
import 'package:haloapp/utils/constants/payment_method.dart';
import 'package:haloapp/utils/constants/styles.dart';
import 'package:haloapp/utils/constants/vehicles.dart';
import 'package:haloapp/utils/services/datetime_formatter.dart';
import 'package:haloapp/utils/services/pop_with_result_service.dart';
import 'package:haloapp/utils/services/shared_pref_service.dart';
import 'package:haloapp/components/model_progress_hud.dart';
import 'package:url_launcher/url_launcher.dart';

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
        centerTitle: true,
        title: Text(
          AppTranslations.of(context).text('history_details'),
          style: kAppBarTextStyle,
        ),
        leading: IconButton(
            icon: arrowBack,
            onPressed: () {
              Navigator.pop(context, _needRefreshList);
            }
            ),
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
                    color: Colors.grey[100],
                    child: Column(
                      children: <Widget>[
                        (details.orderStatus != 'pending' &&
                                details.orderStatus != 'new' &&
                                details.orderStatus != 'canceled')
                            ? DriverCard(
                                driverName: details.driverName,
                                driverPhoneNumber: details.driverPhone,
                                plateNumber: details.driverPlateNumber,
                                rating: details.customerRating,
                              )
                            : SizedBox.shrink(),
                        (details.orderStatus == 'completed')
                            ? SizedBox(height: 20)
                            : SizedBox.shrink(),
                        Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    AppTranslations.of(context)
                                        .text('delivery_details'),
                                    style:
                                        TextStyle(fontFamily: poppinsSemiBold),
                                  ),
                                  Text(
                                    '${DatetimeFormatter().getFormattedDateStr(format: 'dd MMM yyyy hh:mm a', datetime: details.pickupDatetime)}',
                                    style: TextStyle(
                                      fontFamily: poppinsRegular,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    JobStatus().getJobStatusDescription(
                                        details.orderStatus),
                                    style: TextStyle(
                                      fontFamily: poppinsRegular,
                                      color: Colors.green,
                                    ),
                                  ),
                                  Text(
                                    details.bookingNumber,
                                    style: TextStyle(
                                      fontFamily: poppinsRegular,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Image.asset('images/ic_timer.png', width: 36),
                                  Text(
                                    '${DatetimeFormatter().getFormattedDateStr(format: 'dd MMM yyyy - hh:mm a', datetime: details.pickupDatetime)}',
                                    style: TextStyle(
                                        fontFamily: poppinsSemiBold,
                                        fontSize: 15),
                                  ),
                                ],
                              ),
                              Divider(),
                              AddressDetail(addresses: details.addresses),
                              Divider(),
                              VehicleCard(
                                vehcileImage: Vehicles()
                                    .getVehicleImage(details.vehicleTypeId),
                                vehicleTitle: Vehicles()
                                    .getVehicleName(details.vehicleTypeId),
                                vehicleDesc: Vehicles()
                                    .getVehicle(details.vehicleTypeId)
                                    .description,
                                vehicleMeasure: Vehicles()
                                    .getVehicle(details.vehicleTypeId)
                                    .description2,
                                isSelected: true,
                                onSelected: () {},
                              ),
                              SizedBox(height: 5),
                              Text(
                                AppTranslations.of(context)
                                    .text('delivery_item_details'),
                                style: TextStyle(fontFamily: poppinsSemiBold),
                              ),
                              SizedBox(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    AppTranslations.of(context)
                                        .text('delivery_item_type'),
                                    textAlign: TextAlign.center,
                                    style: kTitleTextStyle.copyWith(
                                      fontFamily: poppinsRegular,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '${AppTranslations.of(context).text(details.itemType)} ${((details.itemTypeDesc != null && details.itemTypeDesc != '') ? ' - ${details.itemTypeDesc}' : '')}',
                                    textAlign: TextAlign.center,
                                    style: kDetailsTextStyle.copyWith(
                                      fontFamily: poppinsSemiBold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    AppTranslations.of(context).text('remarks'),
                                    textAlign: TextAlign.center,
                                    style: kTitleTextStyle.copyWith(
                                      fontFamily: poppinsRegular,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    (details.remarks != '')
                                        ? details.remarks
                                        : AppTranslations.of(context)
                                            .text('no_remarks'),
                                    textAlign: TextAlign.center,
                                    style: kDetailsTextStyle.copyWith(
                                      fontFamily: poppinsSemiBold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
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
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          color: Colors.white,
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Text(
                                AppTranslations.of(context)
                                    .text('payment_details'),
                                style: kTitleTextStyle.copyWith(fontSize: 14),
                              ),
                              SizedBox(height: 10.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Image.asset(
                                    PaymentMethod()
                                        .getPaymentMethod(details.paymentMethod)
                                        .image,
                                    width: 24,
                                    height: 24,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    '${AppTranslations.of(context).text(details.paymentMethod)}',
                                    style: kDetailsTextStyle,
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.0),
                              _bookingPricing(),
                            ],
                          ),
                        ),
                        (details.orderStatus == 'completed')
                        ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Container(
                          color: Colors.white,
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                AppTranslations.of(context)
                                    .text('your_reviews'),
                                textAlign: TextAlign.center,
                                style: kTitleTextStyle.copyWith(fontSize: 14),
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
                              SizedBox(height: 15.0),
                              (details.customerRating == '0')
                                  ? Container(
                                width: double.infinity,
                                child: ActionButton(
                                  onPressed: () {
                                    showRatingDialog();
                                  },
                                  buttonText: AppTranslations.of(context).text('review'),
                                ),
                              )
                                  : Container(),
                            ],
                          ),
                        ),
                      ],
                    )
                        : Container(),
                        Container(
                          margin: EdgeInsets.only(left: 16,right: 16),
                          width: double.infinity,
                          child: MaterialButton(
                            onPressed: () {
                              BookingDetail bookingDetail = new BookingDetail();
                              List<BookingAddress> bookingAddressList = [];
                              BookingAddress bookingAddress = new BookingAddress();
                              bookingAddress.recipientName = '';
                              bookingAddressList.add(bookingAddress);
                              bookingDetail.bookingNumber = details.bookingNumber;
                              bookingDetail.orderStatus = details.orderStatus;
                              bookingDetail.totalPrice = details.totalPrice;
                              bookingDetail.bookingAddress = bookingAddressList;
                              bookingDetail.itemType = 'Express';
                              bookingDetail.bookingDate = details.pickupDatetime;
                              Navigator.pushNamed(context, ActivitySupportDetailsPage.id, arguments: bookingDetail);
                            },
                            color: kColorRed,
                            textColor: Colors.white,
                            child: Text(
                              AppTranslations.of(context).text('contact_us'),
                              style: TextStyle(
                                  fontFamily: poppinsMedium,
                                  fontSize: 15
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              (details.orderStatus == 'completed' ||
                      details.orderStatus == 'canceled')
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
                        buttonText:
                            AppTranslations.of(context).text('repeat_order'),
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
      if(details.paymentMethod == "haloWalletCod")
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(AppTranslations.of(context).text('haloWallet'),
              style: kDetailsTextStyle),
          SizedBox(width: 10.0),
          Text(
              '${AppTranslations.of(context).text('currency_my')} ${(details.bookingHaloWalletAmount != '' ? details.bookingHaloWalletAmount : '0.00')}',
              style: kDetailsTextStyle),
        ],
      ),
      if(details.paymentMethod == "haloWalletCod")
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(AppTranslations.of(context).text('cod'),
              style: kDetailsTextStyle),
          SizedBox(width: 10.0),
          Text(
              '${AppTranslations.of(context).text('currency_my')} ${(details.bookingCodAmount != '' ? details.bookingCodAmount : '0.00')}',
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

    return Container(
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
