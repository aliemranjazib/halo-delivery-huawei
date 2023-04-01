import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hms_gms_availability/flutter_hms_gms_availability.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/components/custom_drawer.dart';
import 'package:haloapp/components/custom_flushbar.dart';
import 'package:haloapp/components/huawei_map_widget.dart';
import 'package:haloapp/models/address_model.dart';
import 'package:haloapp/models/booking_model.dart';
import 'package:haloapp/models/history_model.dart';
import 'package:haloapp/models/user_model.dart';
import 'package:haloapp/models/vehicle_model.dart';
import 'package:haloapp/networkings/booking_networking.dart';
import 'package:haloapp/networkings/history_networking.dart';
import 'package:haloapp/screens/boarding/login_page.dart';
import 'package:haloapp/screens/history/delivery_history_details_page.dart';
import 'package:haloapp/screens/history/delivery_history_page.dart';
import 'package:haloapp/screens/delivery/vehicles_bottom_sheet_popup.dart';
import 'package:haloapp/screens/general/confirmation_dialog.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/services/google_map_places_service.dart';
import 'package:haloapp/screens/delivery/add_address_page.dart';
import 'package:haloapp/screens/delivery/addresses_list_page.dart';
import 'package:haloapp/screens/delivery/delivery_details_page.dart';
import 'package:haloapp/utils/constants/api_urls.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/constants/styles.dart';
import 'package:haloapp/utils/constants/vehicles.dart';
import 'package:haloapp/utils/services/huawei_map_places_service.dart';
import 'package:haloapp/utils/services/location_service.dart';
import 'package:haloapp/utils/services/pop_with_result_service.dart';
import 'package:haloapp/components/model_progress_hud.dart';
import 'package:huawei_location/huawei_location.dart';

import '../../components/address_view.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import '../../components/google_map_widget.dart';

import 'package:huawei_map/components/latLng.dart' as huaweiLatLng;
import 'package:huawei_map/components/marker.dart' as huaweiMarker;
import 'package:huawei_map/components/polyline.dart' as huaweiPolyLine;
import 'package:huawei_map/components/polylineId.dart' as huaweiPolyLineId;
import 'package:huawei_map/map.dart' as huaweiMap;

class DeliveryMainPage extends StatefulWidget {
  static const String id = 'deliveryMainPage';

  @override
  _DeliveryMainPageState createState() => _DeliveryMainPageState();
}

class _DeliveryMainPageState extends State<DeliveryMainPage> {
  bool _showSpinner = false;
  List<VehicleModel> vehicles = Vehicles().getVehicles();

  // static GoogleMapController _mapController;
//  Completer<GoogleMapController> _mapController = Completer();
//  LatLng _initialPosition = LatLng(37.422153, -122.084047);
//  BitmapDescriptor initialIcon;
//  BitmapDescriptor pickupIcon;
//  BitmapDescriptor dropoffIcon;
//  Map<String, Marker> _markers = {};
//  PolylinePoints polylinePoints;
//  List<LatLng> polylineCoordinates = [];
//  Map<PolylineId, Polyline> _polylines = {};

  //Huawei Map
  Completer<huaweiMap.HuaweiMapController> _huaweiMapController = Completer();
  huaweiMap.LatLng _huaweiInitialPosition =
      huaweiMap.LatLng(37.422153, -122.084047);
  huaweiMap.BitmapDescriptor huaweiInitialIcon;
  huaweiMap.BitmapDescriptor huaweiPickupIcon;
  huaweiMap.BitmapDescriptor huaweiDropoffIcon;
  Map<String, huaweiMarker.Marker> _huaweiMarkers = {};
  List<huaweiMap.LatLng> huaweiPolylineCoordinates = [];
  Map<huaweiPolyLineId.PolylineId, huaweiPolyLine.Polyline> _huaweiPolylines =
      {};

  double _distance;
  VehicleModel _selectedVehicle = Vehicles().getVehicles()[0];
  String _calculatedPrice = '-';

  @override
  void initState() {
    super.initState();
    BookingModel().clearBookingData();
    setupIcons();

    _getUserLocation();
    if (BookingModel().getAllAddresses().length > 0) {
      refreshMap();
    }

    if (User().getAuthToken() != null) checkCompletedBookingToRate();
  }

  void setupIcons() {
    ImageConfiguration imageConfig = ImageConfiguration(size: Size(25, 25));

//    BitmapDescriptor.fromAssetImage(imageConfig, 'images/pin_blue.png')
//        .then((value) => pickupIcon = value);
//
//    BitmapDescriptor.fromAssetImage(imageConfig, 'images/pin_red.png')
//        .then((value) => dropoffIcon = value);

    huaweiMap.BitmapDescriptor.fromAssetImage(
            imageConfig, 'images/pin_blue.png')
        .then((value) => huaweiPickupIcon = value);

    huaweiMap.BitmapDescriptor.fromAssetImage(imageConfig, 'images/pin_red.png')
        .then((value) => huaweiDropoffIcon = value);
  }

  // Get distance price
  void getDistancePrice() async {
    if (BookingModel().getAllAddresses() == null ||
        BookingModel().getAllAddresses().length < 2 ||
        _distance == null) {
      return;
    }

    Map<String, dynamic> params = {
      "apiKey": APIUrls().getApiKey(),
      "data": {
        "distance": _distance,
        "transportType": _selectedVehicle.id,
        "addresses": BookingModel().getAddressesListData(),
      }
    };
    print(params);

    setState(() {
      _showSpinner = true;
    });

    try {
      var data = await BookingNetworking().getDistancePrice(params);

      setState(() {
        _calculatedPrice = data;
      });
    } catch (e) {
      showSimpleFlushBar(e, context);
    } finally {
      setState(() {
        _showSpinner = false;
      });
    }
  }

  // Navigate to address list or add address page
  void addAddress(int index) async {
    dynamic refresh;

    if (index == 0 || index == 1) {
      refresh = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AddAddressPage(addressIndex: index)));
//      await Navigator.pushNamed(context, AddAddressPage.id, arguments: index);
    } else {
      refresh = await Navigator.pushNamed(context, AddressesListPage.id);
    }

    if (refresh == 'refresh') {
      refreshMap();
    }
  }

  //Huawei Map
  void _onHuaweiMapCreated(huaweiMap.HuaweiMapController controller) {
    // _mapController = controller;
    _huaweiMapController.complete(controller);
  }

//  void _onMapCreated(GoogleMapController controller) {
//    // _mapController = controller;
//    _mapController.complete(controller);
//  }

  void _getUserLocation() async {
    Location position = await LocationService().getCurrentLocation();
    _huaweiInitialPosition =
        huaweiMap.LatLng(position.latitude, position.longitude);
    final huaweiMap.HuaweiMapController controller =
        await _huaweiMapController.future;
    controller.animateCamera(huaweiMap.CameraUpdate.newCameraPosition(
        huaweiMap.CameraPosition(target: _huaweiInitialPosition, zoom: 16)));

//    if(await FlutterHmsGmsAvailability.isHmsAvailable){
//      _huaweiInitialPosition = huaweiMap.LatLng(position.latitude, position.longitude);
//      final huaweiMap.HuaweiMapController controller = await _huaweiMapController.future;
//      controller.animateCamera(huaweiMap.CameraUpdate.newCameraPosition(
//          huaweiMap.CameraPosition(target: _huaweiInitialPosition, zoom: 16)));
//    }else{
//      _initialPosition = LatLng(position.latitude, position.longitude);
//      final GoogleMapController controller = await _mapController.future;
//      controller.animateCamera(CameraUpdate.newCameraPosition(
//          CameraPosition(target: _initialPosition, zoom: 16)));
//    }
  }

  void refreshMap() async {
    print('refresh map');

    if (await FlutterHmsGmsAvailability.isHmsAvailable) {
      _huaweiMarkers.clear();
      huaweiPolylineCoordinates.clear();
      _huaweiPolylines.clear();

      List<AddressModel> addresses = BookingModel().getAllAddresses();

      if (addresses.length == 0) {
        setState(() {});
        return;
      }

      for (int i = 0; i <= addresses.length - 1; i++) {
        final marker = huaweiMap.Marker(
            markerId: huaweiMap.MarkerId("$i"),
            position: huaweiMap.LatLng(
                double.parse(addresses[i].lat), double.parse(addresses[i].lng)),
            icon: (i == 0) ? huaweiPickupIcon : huaweiDropoffIcon);

        _huaweiMarkers["$i"] = marker;
      }

      final huaweiMap.HuaweiMapController controller =
          await _huaweiMapController.future;
      if (addresses.length >= 2) {
        // draw polyline
        await _createPolylines(addresses);

        // animate camera to see all markers
        List<huaweiMap.Marker> markersList = List();

        _huaweiMarkers.forEach((k, v) => markersList.add(v));
        huaweiMap.LatLngBounds bound =
            HuaweiMapPlacesService().getBounds(markersList);

        huaweiMap.CameraUpdate u2 =
            huaweiMap.CameraUpdate.newLatLngBounds(bound, 70);
        controller.animateCamera(u2);
        print('###animating');
      } else {
        // final GoogleMapController controller = await _mapController.future;
        controller.animateCamera(huaweiMap.CameraUpdate.newCameraPosition(
            huaweiMap.CameraPosition(
                target: huaweiMap.LatLng(double.parse(addresses[0].lat),
                    double.parse(addresses[0].lng)),
                zoom: 16)));
        print('###animating2');
      }
    }
//    else{
//      _markers.clear();
//      polylinePoints = null;
//      polylineCoordinates.clear();
//      _polylines.clear();
//
//      List<AddressModel> addresses = BookingModel().getAllAddresses();
//
//      if (addresses.length == 0) {
//        setState(() {});
//        return;
//      }
//
//      for (int i = 0; i <= addresses.length - 1; i++) {
//        final marker = Marker(
//            markerId: MarkerId("$i"),
//            position: LatLng(
//                double.parse(addresses[i].lat), double.parse(addresses[i].lng)),
//            icon: (i == 0) ? pickupIcon : dropoffIcon);
//
//        _markers["$i"] = marker;
//      }
//
//      final GoogleMapController controller = await _mapController.future;
//      if (addresses.length >= 2) {
//        // draw polyline
//        await _createPolylines(addresses);
//
//        // animate camera to see all markers
//        List<Marker> markersList = List();
//
//        _markers.forEach((k, v) => markersList.add(v));
//        LatLngBounds bound = GoogleMapPlacesService().getBounds(markersList);
//
//        CameraUpdate u2 = CameraUpdate.newLatLngBounds(bound, 70);
//        controller.animateCamera(u2);
//        print('###animating');
//      } else {
//        // final GoogleMapController controller = await _mapController.future;
//        controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
//            target: LatLng(
//                double.parse(addresses[0].lat), double.parse(addresses[0].lng)),
//            zoom: 16)));
//        print('###animating2');
//      }
//
//    }

    setState(() {});
  }

  void _createPolylines(List<AddressModel> addresses) async {
//    if(await FlutterHmsGmsAvailability.isHmsAvailable){
//      try {
//        Map<String, dynamic> routeData = await GoogleMapPlacesService()
//            .getRoute(BookingModel().getAllAddresses(), true);
//        int distanceInMeter = routeData['distance'];
//        _distance = distanceInMeter / 1000;
//        getDistancePrice();
//
//        polylineCoordinates = routeData['latLngList'];
//
//        _addPolyline();
//      } catch (e) {
//        showSimpleFlushBar(e, context);
//      }
//
//    }else{
//      polylinePoints = PolylinePoints();
//
//      try {
//        Map<String, dynamic> routeData = await GoogleMapPlacesService()
//            .getRoute(BookingModel().getAllAddresses(), true);
//        int distanceInMeter = routeData['distance'];
//        _distance = distanceInMeter / 1000;
//        getDistancePrice();
//
//        polylineCoordinates = routeData['latLngList'];
//
//        _addPolyline();
//      } catch (e) {
//        showSimpleFlushBar(e, context);
//      }
//    }

    try {
      Map<String, dynamic> routeData = await GoogleMapPlacesService()
          .getRoute(BookingModel().getAllAddresses(), true);
      int distanceInMeter = routeData['distance'];
      _distance = distanceInMeter / 1000;
      getDistancePrice();

      huaweiPolylineCoordinates = routeData['latLngList'];

      _addPolyline();
    } catch (e) {
      showSimpleFlushBar(e, context);
    }
  }

  void _addPolyline() async {
    final huaweiMap.PolylineId polylineId = huaweiMap.PolylineId('poly');

    final huaweiMap.Polyline polyline = huaweiMap.Polyline(
      polylineId: polylineId,
      color: Colors.red,
      width: 3,
      points: huaweiPolylineCoordinates,
    );

    _huaweiPolylines[polylineId] = polyline;
//    if(await FlutterHmsGmsAvailability.isHmsAvailable){
//      final huaweiMap.PolylineId polylineId = huaweiMap.PolylineId('poly');
//
//      for(var i = 0; i < polylineCoordinates.length ; i++){
//        huaweiMap.LatLng latLng = huaweiMap.LatLng(
//            polylineCoordinates[i].latitude,
//            polylineCoordinates[i].longitude
//        );
//        huaweiPolylineCoordinates.add(latLng);
//      }
//
//      final huaweiMap.Polyline polyline = huaweiMap.Polyline(
//        polylineId: polylineId,
//        color: Colors.red,
//        width: 3,
//        points: huaweiPolylineCoordinates,
//      );
//
//      _huaweiPolylines[polylineId] = polyline;
//
//    }
//    else{
//      final PolylineId polylineId = PolylineId('poly');
//
//      final Polyline polyline = Polyline(
//        polylineId: polylineId,
//        color: Colors.red,
//        width: 3,
//        points: polylineCoordinates,
//      );
//
//      _polylines[polylineId] = polyline;
//    }
    setState(() {});
  }

  void proceedToDeliveryDetails() {
    if (_calculatedPrice == '-') return;
    if (BookingModel().getAllAddresses() == null ||
        BookingModel().getAllAddresses().length < 2 ||
        _distance == null) {
      showSimpleFlushBar(
          AppTranslations.of(context)
              .text('please_enter_delivery_address_to_proceed'),
          context);
      return;
    }

    if (User().getAuthToken() == null) {
      Navigator.pushNamed(context, LoginPage.id,
          arguments: LoginArguments(false));
      return;
    }

    BookingModel().setVehicle(_selectedVehicle);
    BookingModel().setDistanceAndPrice(_distance.toString(), _calculatedPrice);

    Navigator.pushNamed(context, DeliveryDetailsPage.id).then((results) {
      if (results is PopWithResults) {
        PopWithResults popResult = results;
        if (popResult.toPage == DeliveryMainPage.id) {
        } else {
          // pop to previous page
          Navigator.of(context).pop(results);
        }
      }
    });
  }

  void showConfirmMakeNewBookingDialog() {
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
          refreshMap();
          _selectedVehicle = Vehicles().getVehicles()[0];
          _calculatedPrice = '-';
        });
      }
    });
  }

  void checkCompletedBookingToRate() async {
    Map<String, dynamic> params = {
      "apiKey": APIUrls().getApiKey(),
      "data": {
        "userToken": User().getUserToken(),
      },
    };

    setState(() {
      _showSpinner = true;
    });

    try {
      var data = await HistoryNetworking().getBookingHistory(params);

      setState(() {
        if (data is List<HistoryModel>) {
          for (HistoryModel history in data) {
            if (history.orderStatus == 'completed' &&
                history.customerRating == '0') {
              showGoToRateDialog(history.bookingUniqueKey);
              return;
            }
          }
        }
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

  void showGoToRateDialog(String bookingKey) {
    showDialog(
        context: context,
        builder: (context) => ConfirmationDialog(
              title: AppTranslations.of(context).text('rate_our_service'),
              message: AppTranslations.of(context)
                  .text('there_is_completed_booking_to_rate'),
            )).then((value) {
      if (value != null && value == 'confirm') {
        getHistoryDetails(bookingKey);
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

      Navigator.pushNamed(context, DeliveryHistoryDetailsPage.id,
              arguments: data)
          .then((value) {
        if (value != null) {
          if (value == 'remakeBooking') {
            setState(() {
              refreshMap();
            });
          }
        }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppTranslations.of(context).text("delivery"),
          style: kAppBarTextStyle,
        ),
      ),
//        drawer: CustomDrawer(
//          callback: (String value) {
//            if (value == 'newBooking') {
//              showConfirmMakeNewBookingDialog();
//            } else if (value == 'remakeBooking') {
//              setState(() {
//                refreshMap();
//              });
//            }
//          },
//        ),
      body: ModalProgressHUD(
        inAsyncCall: _showSpinner,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: Stack(
                  children: <Widget>[
                    _huaweiInitialPosition == null
                        ? Container(
                            child: Center(
                              child: Text(
                                AppTranslations.of(context).text('loading_map'),
                                style: TextStyle(
                                    fontFamily: poppinsMedium,
                                    color: Colors.grey[400]),
                              ),
                            ),
                          )
                        : getMap(),
//                        : FutureBuilder(
//                            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot){
//
//                              if(snapshot.connectionState == ConnectionState.done){
//                                return snapshot.data;
//                              }
//
//                              return Container(
//                                child: Center(
//                                  child: Text(
//                                    AppTranslations.of(context).text('loading_map'),
//                                    style: TextStyle(
//                                        fontFamily: poppinsMedium,
//                                        color: Colors.grey[400]),
//                                  ),
//                                ),
//                              );
//                            },
//                            future: getMap(),
//                          ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
                        color: kColorRed.withOpacity(0.5),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              addAddress(0);
                            },
                            child:
                                AddressView(addressIndex: 0, textMaxLines: 1),
                          ),
                          Divider(height: 1),
                          GestureDetector(
                            onTap: () {
                              if (BookingModel().getAllAddresses() != null &&
                                  BookingModel().getAllAddresses().length > 0) {
                                addAddress(1);
                              } else {
                                showSimpleFlushBar(
                                    AppTranslations.of(context)
                                        .text('enter_pickup_details_first'),
                                    context);
                              }
                            },
                            child:
                                AddressView(addressIndex: 1, textMaxLines: 1),
                          ),
                          (BookingModel().getAllAddresses() != null &&
                                  BookingModel().getAllAddresses().length >= 2)
                              ? GestureDetector(
                                  onTap: () {
                                    addAddress(null);
                                  },
                                  child: Container(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 8.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          (BookingModel()
                                                      .getAllAddresses()
                                                      .length >
                                                  2)
                                              ? '${BookingModel().getAllAddresses().length - 2} ${AppTranslations.of(context).text('more_location_s')}'
                                              : AppTranslations.of(context).text(
                                                  'add_more_dropoff_address'),
                                          style: TextStyle(
                                              fontFamily: poppinsMedium,
                                              color: Colors.white),
                                        ),
                                        SizedBox(width: 5.0),
                                        Icon(
                                          Icons.add_circle,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Container()
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                          context: context,
                          builder: (context) => VehiclesBottomSheetPopup())
                      .then((value) {
                    setState(() {
                      if (value != null) {
                        _selectedVehicle = value;
                        getDistancePrice();
                      }
                    });
                  });
                },
                behavior: HitTestBehavior.translucent,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Image.asset(
                        'images/chevron_upx24.png',
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Image.asset(
                                  _selectedVehicle.image,
                                  height: 50,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        '${_selectedVehicle.name}',
                                        style: TextStyle(
                                            fontFamily: poppinsMedium,
                                            fontSize: 16),
                                      ),
                                      Text(
                                        '${AppTranslations.of(context).text('item_size_limit_lxwxh')}: ${Vehicles().getVehicleDeliveryItemSize(_selectedVehicle.id)}',
                                        maxLines: 2,
                                        overflow: TextOverflow.clip,
                                        style: TextStyle(
                                            fontFamily: poppinsLight,
                                            fontSize: 13,
                                            color: Colors.grey[700]),
                                      ),
                                      Text(
                                        '${AppTranslations.of(context).text('max_weight')}: ${Vehicles().getVehicleDeliveryMaxWeight(_selectedVehicle.id)}',
                                        style: TextStyle(
                                            fontFamily: poppinsLight,
                                            fontSize: 13,
                                            color: Colors.grey[700]),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: <Widget>[
                              Text(
                                '${(_distance != null) ? _distance : 0} KM',
                                style: TextStyle(
                                    fontFamily: poppinsRegular, fontSize: 15),
                              ),
                              Text(
                                '${AppTranslations.of(context).text('currency_my')} $_calculatedPrice',
                                style: TextStyle(
                                    fontFamily: poppinsSemiBold, fontSize: 16),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 6,
              ),
              Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                  child: ActionButton(
                    buttonText: AppTranslations.of(context).text('next'),
                    onPressed: () async {
                      proceedToDeliveryDetails();
                    },
                  ))
            ],
          ),
        ),
      ),
    );
  }

  Widget getMap() {
//    if (await FlutterHmsGmsAvailability.isHmsAvailable) {
    return HuaweiMapWidget(
      onMapCreated: _onHuaweiMapCreated,
      location: _huaweiInitialPosition,
      markers: _huaweiMarkers,
      polylines: _huaweiPolylines,
    );
//    }
//    else {
//      return GoogleMapWidget(
//        onMapCreated: _onMapCreated,
//        location: _initialPosition,
//        markers: _markers,
//        polylines: _polylines,
//      );
//    }
  }
}
