import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:haloapp/components/model_progress_hud.dart';
import 'package:haloapp/models/food_history_model.dart';
import 'package:haloapp/models/food_order_model.dart';
import 'package:haloapp/models/food_rider_tacking.dart';
import 'package:haloapp/networkings/food_networking.dart';
import 'package:haloapp/screens/food/food_cart_page.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/constants/styles.dart';
import 'package:haloapp/utils/services/datetime_formatter.dart';
import 'package:huawei_map/components/latLng.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui' as ui;
import 'package:huawei_map/map.dart' as huaweiMap;

class FoodHistoryDetailsPage extends StatefulWidget {
  FoodHistoryDetailsPage({@required this.history, this.success = false});

  final FoodHistoryModel history;
  final bool success;

  @override
  _FoodHistoryDetailsPageState createState() => _FoodHistoryDetailsPageState();
}

class _FoodHistoryDetailsPageState extends State<FoodHistoryDetailsPage>
    with TickerProviderStateMixin {
  // BitmapDescriptor pickupIcon;
  // BitmapDescriptor dropoffIcon;
  // BitmapDescriptor motorIcon;
  // LatLng customerCoordinates;
  // LatLng merchantCoordinates;

  //Huawei Map
  huaweiMap.BitmapDescriptor huaweiMapPickupIcon;
  huaweiMap.BitmapDescriptor huaweiMapDropoffIcon;
  huaweiMap.BitmapDescriptor huaweiMotorIcon;
  huaweiMap.LatLng huaweiMapCustomerCoordinates;
  huaweiMap.LatLng huaweiMapMerchantCoordinates;

  bool _showMap = false;
  bool isRiderTrackingAvailable = false;
  Duration riderTrackingInterval = const Duration(seconds: 5);
  FoodRiderTracking riderTracking = FoodRiderTracking();
  Timer _timer;
  final _controller = ScrollController();
  AnimationController _animController;

  @override
  void initState() {
    _animController = AnimationController(
        duration: const Duration(milliseconds: 1500), vsync: this)
      ..repeat(reverse: true);

    // customerCoordinates = LatLng(double.parse(widget.history.shopLat),
    //     double.parse(widget.history.shopLng));

    // merchantCoordinates = LatLng(double.parse(widget.history.customerLat),
    //     double.parse(widget.history.customerLng));

    huaweiMapCustomerCoordinates = huaweiMap.LatLng(
        double.parse(widget.history.shopLat),
        double.parse(widget.history.shopLng));

    huaweiMapMerchantCoordinates = huaweiMap.LatLng(
        double.parse(widget.history.customerLat),
        double.parse(widget.history.customerLng));

    initRiderTracking();
    setupIcons();
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void initRiderTracking() {
    trackRider();
    _timer = Timer.periodic(riderTrackingInterval, (Timer t) {
      trackRider();
    });
  }

  void trackRider() async {
    var _riderTracking = await FoodNetworking.getFoodRiderTracking(
        widget.history.orderUniqueKey);
    print('### RIP');

    widget.history.orderStatus = _riderTracking.orderStatus;
    setState(() {
      // isRiderTrackingAvailable = _riderTracking.isJobCompleted;
      riderTracking = _riderTracking;
    });
    if (_riderTracking.isJobCompleted) _timer.cancel();
    print(riderTracking.toJson());
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  Future<Uint8List> getBytesFromNetwork(String url, int width) async {
    Uint8List icon = (await NetworkAssetBundle(Uri.parse(url)).load(url))
        .buffer
        .asUint8List();
    ui.Codec codec = await ui.instantiateImageCodec(icon, targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  void setupIcons() async {
    final Uint8List pickupIconRaw =
        await getBytesFromNetwork(widget.history.shopLogoUrl, 120);

    final Uint8List motorIconRaw =
        await getBytesFromAsset('images/motorcycle.png', 100);
    // final Uint8List pickupIconRaw =
    //     await getBytesFromAsset('images/pin_blue.png', 100);
    final Uint8List dropoffIconRaw =
        await getBytesFromAsset('images/pin_red.png', 100);

    // motorIcon = BitmapDescriptor.fromBytes(motorIconRaw);
    // pickupIcon = BitmapDescriptor.fromBytes(pickupIconRaw);
    // dropoffIcon = BitmapDescriptor.fromBytes(dropoffIconRaw);

    huaweiMotorIcon = huaweiMap.BitmapDescriptor.fromBytes(motorIconRaw);
    huaweiMapPickupIcon = huaweiMap.BitmapDescriptor.fromBytes(pickupIconRaw);
    huaweiMapDropoffIcon = huaweiMap.BitmapDescriptor.fromBytes(dropoffIconRaw);
    ImageConfiguration imageConfig = ImageConfiguration(size: Size(35, 35));
    // motorIcon = await BitmapDescriptor.fromAssetImage(
    //     imageConfig, 'images/motorcyclex32.png');
    // pickupIcon = await BitmapDescriptor.fromAssetImage(
    //     imageConfig, 'images/pin_blue.png');
    // dropoffIcon = await BitmapDescriptor.fromAssetImage(
    //     imageConfig, 'images/pin_red.png');
    setState(() {
      _showMap = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    print(widget.history.orderUniqueKey);
    return Scaffold(
      appBar: AppBar(
        title: (!widget.success)
            ? Text(widget.history.orderNum)
            : Text(
                AppTranslations.of(context).text('your_order'),
                style: kAppBarTextStyle,
              ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _controller,
          child: Container(
            // padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (!riderTracking.isJobCompleted)
                  Container(
                    constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height -
                            AppBar().preferredSize.height),
                    child: Column(
                      children: [
                        if (!riderTracking.isJobCompleted)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              LinearProgressIndicator(
                                minHeight: 2,
                                backgroundColor: kColorRed,
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
                                // value: .5,
                              ),
                              Container(
                                padding: EdgeInsets.all(10),
                                color: kColorRed,
                                child: Text(
                                  riderTracking.orderStatus == 'pending'
                                      ? AppTranslations.of(context)
                                          .text('order_searching_rider')
                                      : AppTranslations.of(context)
                                              .text('order_status') +
                                          ' : ' +
                                          AppTranslations.of(context).text(
                                              'order_' +
                                                  riderTracking.orderStatus),
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        // if (widget.success)
                        //   Column(children: [
                        //     SizedBox(
                        //       height: 20,
                        //     ),
                        //     Text(
                        //       AppTranslations.of(context)
                        //           .text('order_made_exclamation'),
                        //       style: kTitleTextStyle,
                        //     ),
                        //     SizedBox(height: 20.0),
                        //     Image.asset(
                        //       'images/completed.png',
                        //       height: 100,
                        //     ),
                        //     SizedBox(height: 30.0),
                        //   ]),
                        if (_showMap)
                          Container(
                            height: MediaQuery.of(context).size.height -
                                AppBar().preferredSize.height -
                                350,
                            child: getMap(),
//                            FutureBuilder(
//                              future: getMap(),
//                              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot){
//                                if(snapshot.connectionState == ConnectionState.done){
//                                  return snapshot.data;
//                                }
//                                return ModalProgressHUD(
//                                  inAsyncCall: true,
//                                  child: Container()
//                                );
//                              },
//                            )
                          ),

                        if (!riderTracking.isJobCompleted)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                height: 85,
                                margin: EdgeInsets.all(20),
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: kColorLightRed,
                                    borderRadius: BorderRadius.circular(20)),
                                child: (riderTracking.orderStatus == 'pending')
                                    ? AnimatedBuilder(
                                        builder: (BuildContext context,
                                            Widget child) {
                                          return Opacity(
                                              // duration: Duration(milliseconds: 200),
                                              opacity: _animController.value,
                                              child: child);
                                        },
                                        animation: _animController,
                                        child: Container(
                                          alignment: Alignment.center,
                                          child: Text(
                                              AppTranslations.of(context).text(
                                                  'order_searching_rider'),
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14)),
                                        ),
                                      )
                                    : Row(
                                        children: [
                                          Stack(
                                            children: [
                                              Positioned.fill(
                                                child: Container(
                                                  margin: EdgeInsets.all(10),
                                                  color: Colors.white
                                                      .withOpacity(1),
                                                ),
                                              ),
                                              Container(
                                                // padding: EdgeInsets.all(15),
                                                decoration: BoxDecoration(
                                                    // color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5)),
                                                child: Icon(
                                                  Icons.account_box,
                                                  size: 40,
                                                  color: kColorLightRed,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(width: 5),
                                          Flexible(
                                            fit: FlexFit.tight,
                                            child: Text(
                                              riderTracking.riderName,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18),
                                            ),
                                          ),
                                          // Spacer(),
                                          InkWell(
                                            onTap: () {
                                              launch('tel:' +
                                                  riderTracking.riderPhone);
                                            },
                                            child: Container(
                                                padding: EdgeInsets.all(20),
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15)),
                                                child: Icon(
                                                  Icons.phone,
                                                  size: 25,
                                                  color: kColorRed,
                                                )),
                                          )
                                        ],
                                      ),
                              ),
                              // SizedBox(height: 20),
                              GestureDetector(
                                onTap: () => _controller.animateTo(
                                    MediaQuery.of(context).size.height -
                                        AppBar().preferredSize.height,
                                    duration: Duration(seconds: 2),
                                    curve: Curves.fastOutSlowIn),
                                child: Container(
                                    margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
                                    padding: EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                        color: kColorLightRed.withOpacity(.2),
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    child: Text(
                                      AppTranslations.of(context)
                                          .text('order_view_summary'),
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: kColorRed,
                                          fontFamily: poppinsMedium),
                                      textAlign: TextAlign.center,
                                    )),
                              )
                            ],
                          ),
                      ],
                    ),
                  ),
                Container(
                  constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height -
                          AppBar().preferredSize.height),
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(
                        blurRadius: 40, color: Colors.black.withOpacity(.1))
                  ]),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 15.0),
                        color: Colors.white,
                        child: Column(
                          // crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text(
                              '#${widget.history.orderNum}',
                              style: TextStyle(
                                  fontFamily: poppinsBold, fontSize: 13),
                            ),
                            Text(
                              '${DatetimeFormatter().getFormattedDateStr(format: 'dd MMM yyyy', datetime: widget.history.orderPickupDatetime)}  ${DatetimeFormatter().getFormattedDisplayTime(widget.history.orderPickupDatetime)} - ${DatetimeFormatter().getFormattedDisplayTime(DateTime.parse(widget.history.orderPickupDatetime).add(Duration(minutes: widget.history.shopDeliveryInterval)).toString())}',
                              style: TextStyle(
                                  fontFamily: poppinsRegular, fontSize: 13),
                            ),
                            Text(
                              '${AppTranslations.of(context).text(widget.history.paymentMethod)}',
                              style: TextStyle(
                                  fontFamily: poppinsRegular, fontSize: 13),
                            ),
                            // if (widget.history.buildingUnitNumber.length > 0)
                            //   Text(
                            //     '${widget.history.buildingUnitNumber}, ${widget.history.buildingName}',
                            //     style: TextStyle(
                            //         fontFamily: poppinsRegular, fontSize: 13),
                            //   ),
                            SizedBox(height: 5),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 2),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: kColorRed.withOpacity(.1)),
                              child: Text(
                                AppTranslations.of(context).text(
                                    'order_' + widget.history.orderStatus),
                                style: kSmallLabelTextStyle.copyWith(
                                    color: kColorRed,
                                    fontFamily: poppinsMedium),
                              ),
                            ),
                            SizedBox(height: 15.0),
                            Row(
                              children: <Widget>[
                                Image.network(
                                  widget.history.shopLogoUrl,
                                  width: 50,
                                ),
                                SizedBox(width: 10.0),
                                Flexible(
                                  child: Text(
                                    '${widget.history.shopName} ${(widget.history.shopBuildingName != '') ? '- ${widget.history.shopBuildingName}' : ''}',
                                    style: TextStyle(
                                        fontFamily: poppinsMedium,
                                        fontSize: 15),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 15.0),
                      Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 0.0, horizontal: 15.0),
                        color: Colors.white,
                        child: Column(
                          children: List.generate(
                              widget.history.orderItems.length, (index) {
                            FoodOrderCart order =
                                widget.history.orderItems[index];

                            return Container(
                              margin: EdgeInsets.only(bottom: 10.0),
                              child: OrderFoodListWidget(order: order),
                            );
                          }),
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 15.0),
                        color: Colors.white,
                        child: Column(
                          children: <Widget>[
                            FoodPricingWidget(
                              title: 'delivery_fee',
                              amount: widget.history.orderDeliveryFee ?? '0.00',
                            ),
                            (widget.history.orderPriceDiscount != '0' &&
                                    widget.history.orderPriceDiscount != '0.00')
                                ? FoodPricingWidget(
                                    title: 'discounted_price',
                                    amount: widget.history.orderPriceDiscount ??
                                        '0.00',
                                    isDiscount: true,
                                  )
                                : Container(),
                            (widget.history.orderAutoDiscount != '0' &&
                                    widget.history.orderAutoDiscount != '0.00')
                                ? FoodPricingWidget(
                                    title: 'special_promo_label',
                                    amount: widget.history.orderAutoDiscount ??
                                        '0.00',
                                    isDiscount: true,
                                  )
                                : Container(),
                            (widget.history.minimumCharges != '0' &&
                                    widget.history.minimumCharges != '0.00')
                                ? FoodPricingWidget(
                                    title: 'Minimum Fee',
                                    amount:
                                        widget.history.minimumCharges ?? '0.00',
                                  )
                                : Container(),
                            (widget.history.orderPackingFee != '0' &&
                                    widget.history.orderPackingFee != '0.00')
                                ? FoodPricingWidget(
                                    title: 'Packing Fee',
                                    amount: widget.history.orderPackingFee ??
                                        '0.00',
                                  )
                                : Container(),
                            (widget.history.paymentCharges != '0' &&
                                    widget.history.paymentCharges != '0.00')
                                ? FoodPricingWidget(
                                    title: 'Payment Fee',
                                    amount:
                                        widget.history.paymentCharges ?? '0.00',
                                  )
                                : Container(),
                            (widget.history.orderFoodSST != '0' &&
                                    widget.history.orderFoodSST != '0.00')
                                ? FoodPricingWidget(
                                    title: 'SST',
                                    amount:
                                        widget.history.orderFoodSST ?? '0.00',
                                  )
                                : Container(),
                            FoodPricingWidget(
                              title: 'total_price',
                              amount: widget.history.orderPrice ?? '0.00',
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 15.0),
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text(
                              AppTranslations.of(context).text('remarks'),
                              style: TextStyle(
                                  fontFamily: poppinsMedium, fontSize: 15),
                            ),
                            SizedBox(height: 10.0),
                            Text(
                                '${(widget.history.orderRemarks != '') ? widget.history.orderRemarks : AppTranslations.of(context).text('no_remarks')}')
                          ],
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              AppTranslations.of(context).text('locations'),
                              style: TextStyle(
                                  fontFamily: poppinsMedium, fontSize: 15),
                            ),
                            SizedBox(height: 10.0),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Image.asset(
                                  'images/pin_blue.png',
                                  height: 15.0,
                                ),
                                SizedBox(width: 10.0),
                                Flexible(
                                  child: Text(
                                    widget.history.shopFullAddress,
                                    style: TextStyle(
                                        fontFamily: poppinsRegular,
                                        fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.0),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Image.asset(
                                  'images/pin_red.png',
                                  height: 15.0,
                                ),
                                SizedBox(width: 10.0),
                                Flexible(
                                  child: Text(
                                    widget.history.orderDeliveryAddress,
                                    style: TextStyle(
                                        fontFamily: poppinsRegular,
                                        fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.0),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getMap() {
    return huaweiMap.HuaweiMap(
      onMapCreated: (huaweiMap.HuaweiMapController controller) {
        final huaweiMap.LatLng southwest = huaweiMap.LatLng(
          min(huaweiMapMerchantCoordinates.lat,
              huaweiMapCustomerCoordinates.lat),
          min(huaweiMapMerchantCoordinates.lng,
              huaweiMapCustomerCoordinates.lng),
        );

        final huaweiMap.LatLng northeast = huaweiMap.LatLng(
          max(huaweiMapMerchantCoordinates.lat,
              huaweiMapCustomerCoordinates.lat),
          max(huaweiMapMerchantCoordinates.lng,
              huaweiMapCustomerCoordinates.lng),
        );

        huaweiMap.LatLngBounds bounds = huaweiMap.LatLngBounds(
          southwest: southwest,
          northeast: northeast,
        );

        // huaweiMap.LatLngBounds bound = huaweiMap.LatLngBounds(
        //     southwest: huaweiMapMerchantCoordinates,
        //     northeast: huaweiMapCustomerCoordinates
        // );
        huaweiMap.CameraUpdate u2 =
            huaweiMap.CameraUpdate.newLatLngBounds(bounds, 100);
        controller.animateCamera(u2);
      },
      gestureRecognizers: Set()
        ..add(Factory<PanGestureRecognizer>(() => PanGestureRecognizer()))
        ..add(Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()))
        ..add(Factory<TapGestureRecognizer>(() => TapGestureRecognizer()))
        ..add(Factory<VerticalDragGestureRecognizer>(
            () => VerticalDragGestureRecognizer())),
      zoomControlsEnabled: false,
      initialCameraPosition: huaweiMap.CameraPosition(
        target: huaweiMapCustomerCoordinates,
        zoom: 15,
      ),
      markers: [
        if (riderTracking.lat != null)
          huaweiMap.Marker(
              icon: huaweiMotorIcon,
              markerId: huaweiMap.MarkerId('0'),
              position: huaweiMap.LatLng(riderTracking.lat, riderTracking.lng)),
        huaweiMap.Marker(
            // icon: dropoffIcon,
            markerId: huaweiMap.MarkerId('1'),
            infoWindow: huaweiMap.InfoWindow(
                title: 'Customer Address',
                snippet: widget.history.orderDeliveryAddress),
            position: huaweiMapMerchantCoordinates),
        huaweiMap.Marker(
            icon: huaweiMapPickupIcon,
            markerId: huaweiMap.MarkerId('2'),
            infoWindow: huaweiMap.InfoWindow(
                title: 'Shop Address', snippet: widget.history.shopFullAddress),
            position: huaweiMapCustomerCoordinates),
      ].toSet(),
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
    );
//    if (await FlutterHmsGmsAvailability.isHmsAvailable) {
//      return huaweiMap.HuaweiMap(
//        onMapCreated: (huaweiMap.HuaweiMapController controller) {
//          huaweiMap.LatLngBounds bound = huaweiMap.LatLngBounds(
//              southwest: huaweiMapMerchantCoordinates,
//              northeast: huaweiMapCustomerCoordinates);
//          huaweiMap.CameraUpdate u2 = huaweiMap.CameraUpdate.newLatLngBounds(bound, 100);
//          controller.animateCamera(u2);
//        },
//        gestureRecognizers: Set()
//          ..add(Factory<PanGestureRecognizer>(
//                  () => PanGestureRecognizer()))
//          ..add(Factory<ScaleGestureRecognizer>(
//                  () => ScaleGestureRecognizer()))
//          ..add(Factory<TapGestureRecognizer>(
//                  () => TapGestureRecognizer()))
//          ..add(Factory<VerticalDragGestureRecognizer>(
//                  () => VerticalDragGestureRecognizer())),
//        zoomControlsEnabled: false,
//        initialCameraPosition: huaweiMap.CameraPosition(
//          target: huaweiMapCustomerCoordinates,
//          zoom: 15,
//        ),
//        markers: [
//          if (riderTracking.lat != null)
//            huaweiMap.Marker(
//                icon: huaweiMotorIcon,
//                markerId: huaweiMap.MarkerId('0'),
//                position: huaweiMap.LatLng(riderTracking.lat,
//                    riderTracking.lng)),
//          huaweiMap.Marker(
//            // icon: dropoffIcon,
//              markerId: huaweiMap.MarkerId('1'),
//              infoWindow: huaweiMap.InfoWindow(
//                  title: 'Customer Address',
//                  snippet: widget
//                      .history.orderDeliveryAddress),
//              position: huaweiMapMerchantCoordinates),
//          huaweiMap.Marker(
//              icon: huaweiMapPickupIcon,
//              markerId: huaweiMap.MarkerId('2'),
//              infoWindow: huaweiMap.InfoWindow(
//                  title: 'Shop Address',
//                  snippet:
//                  widget.history.shopFullAddress),
//              position: huaweiMapCustomerCoordinates),
//        ].toSet(),
//        myLocationEnabled: false,
//        myLocationButtonEnabled: false,
//      );
//    }else{
//      return GoogleMap(
//        onMapCreated: (GoogleMapController controller) {
//          LatLngBounds bound = LatLngBounds(
//              southwest: merchantCoordinates,
//              northeast: customerCoordinates);
//          CameraUpdate u2 =
//          CameraUpdate.newLatLngBounds(bound, 100);
//          controller.animateCamera(u2);
//        },
//        gestureRecognizers: Set()
//          ..add(Factory<PanGestureRecognizer>(
//                  () => PanGestureRecognizer()))
//          ..add(Factory<ScaleGestureRecognizer>(
//                  () => ScaleGestureRecognizer()))
//          ..add(Factory<TapGestureRecognizer>(
//                  () => TapGestureRecognizer()))
//          ..add(Factory<VerticalDragGestureRecognizer>(
//                  () => VerticalDragGestureRecognizer())),
//        zoomControlsEnabled: false,
//        initialCameraPosition: CameraPosition(
//          target: customerCoordinates,
//          zoom: 15,
//        ),
//        markers: [
//          if (riderTracking.lat != null)
//            Marker(
//                icon: motorIcon,
//                markerId: MarkerId('0'),
//                position: LatLng(riderTracking.lat,
//                    riderTracking.lng)),
//          Marker(
//            // icon: dropoffIcon,
//              markerId: MarkerId('1'),
//              infoWindow: InfoWindow(
//                  title: 'Customer Address',
//                  snippet: widget
//                      .history.orderDeliveryAddress),
//              position: merchantCoordinates),
//          Marker(
//              icon: pickupIcon,
//              markerId: MarkerId('2'),
//              infoWindow: InfoWindow(
//                  title: 'Shop Address',
//                  snippet:
//                  widget.history.shopFullAddress),
//              position: customerCoordinates),
//        ].toSet(),
//        myLocationEnabled: false,
//        myLocationButtonEnabled: false,
//      );
//    }
  }
}
