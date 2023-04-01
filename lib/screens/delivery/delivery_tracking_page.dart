import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hms_gms_availability/flutter_hms_gms_availability.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:haloapp/components/custom_flushbar.dart';
import 'package:haloapp/models/history_model.dart';
import 'package:haloapp/networkings/history_networking.dart';
import 'package:haloapp/screens/auth/login_page.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/api_urls.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/constants/styles.dart';
import 'package:haloapp/utils/services/google_map_places_service.dart';
import 'package:haloapp/utils/services/location_service.dart';
import 'package:haloapp/utils/services/shared_pref_service.dart';
import 'package:haloapp/components/model_progress_hud.dart';
import 'package:huawei_location/location/location.dart';
import 'package:huawei_map/map.dart' as huaweiMap;

class DeliveryTrackingPage extends StatefulWidget {
  DeliveryTrackingPage({@required this.history});

  final HistoryModel history;

  @override
  _DeliveryTrackingPageState createState() => _DeliveryTrackingPageState();
}

class _DeliveryTrackingPageState extends State<DeliveryTrackingPage> {
  bool _showSpinner = false;
//  GoogleMapController mapController;
//  LatLng _initialPosition = LatLng(37.422153, -122.084047);
//  BitmapDescriptor riderIcon;
//  Map<String, Marker> _markers = {};
//
//  PolylinePoints polylinePoints;
//  List<LatLng> polylineCoordinates = [];
//  Map<PolylineId, Polyline> _polylines = {};
//  LatLng _riderLocation;

  double _distance;

  Timer _timer;

  //Huawei Map
  huaweiMap.HuaweiMapController huaweiMapController;
  huaweiMap.LatLng _huaweiInitialPosition =
      huaweiMap.LatLng(37.422153, -122.084047);
  huaweiMap.BitmapDescriptor huaweiRiderIcon;
  Map<String, huaweiMap.Marker> _huaweiMarkers = {};
  List<huaweiMap.LatLng> huaweiPolylineCoordinates = [];
//  Map<PolylineId, Polyline> _huaweiPolylines = {};
  huaweiMap.LatLng _huaweiRiderLocation;

  @override
  void initState() {
    super.initState();

    setupIcons();
    initiateMap();

    getTrackingInfo();
    startGetRiderLocation();
  }

  @override
  void dispose() {
    super.dispose();

    stopGetRiderLocation();
  }

  void initiateMap() async {
    Location position = await LocationService().getCurrentLocation();

    setState(() {
//      _initialPosition = LatLng(position.latitude, position.longitude);
      _huaweiInitialPosition =
          huaweiMap.LatLng(position.latitude, position.longitude);
    });
  }

//  void _onMapCreated(GoogleMapController controller) {
//    mapController = controller;
//  }

  void _onHuaweiMapCreated(huaweiMap.HuaweiMapController controller) {
    huaweiMapController = controller;
  }

  void setupIcons() {
    ImageConfiguration imageConfig = ImageConfiguration(size: Size(25, 25));

//    BitmapDescriptor.fromAssetImage(imageConfig, 'images/motorcyclex32.png')
//        .then((value) => riderIcon = value);

    huaweiMap.BitmapDescriptor.fromAssetImage(
            imageConfig, 'images/motorcyclex32.png')
        .then((value) => huaweiRiderIcon = value);
  }

  void getTrackingInfo() async {
    Map<String, dynamic> params = {
      "apiKey": APIUrls().getApiKey(),
      "data": {
        "bookingUniqueKey": widget.history.bookingUniqueKey,
      },
    };

    setState(() {
      _showSpinner = true;
    });

    try {
      var data = await HistoryNetworking().getTrackingInfo(params);

      if (data is Map<String, dynamic>) {
        Map<String, dynamic> locationData = data['location'];

        if (locationData != null &&
            locationData['lat'] != null &&
            locationData['lng'] != null) {
          _huaweiRiderLocation = huaweiMap.LatLng(
              double.parse(locationData['lat']),
              double.parse(locationData['lng']));
          addMarker();

          huaweiMapController.animateCamera(
              huaweiMap.CameraUpdate.newCameraPosition(huaweiMap.CameraPosition(
                  target: _huaweiRiderLocation, zoom: 17)));
//          if (await FlutterHmsGmsAvailability.isHmsAvailable) {
//            _huaweiRiderLocation = huaweiMap.LatLng(double.parse(locationData['lat']),
//                double.parse(locationData['lng']));
//            addMarker();
//
//            huaweiMapController.animateCamera(huaweiMap.CameraUpdate.newCameraPosition(
//                huaweiMap.CameraPosition(target: _huaweiRiderLocation, zoom: 17))
//            );
//
//          }else{
//            _riderLocation = LatLng(double.parse(locationData['lat']),
//                double.parse(locationData['lng']));
//            addMarker();
//
//            mapController.animateCamera(CameraUpdate.newCameraPosition(
//                CameraPosition(target: _riderLocation, zoom: 17)));
//          }

          setState(() {});
        }
      }
    } catch (e) {
      print(e.toString());
      if (e is Map<String, dynamic>) {
        if (e['status_code'] == 514) {
          SharedPrefService().removeLoginInfo();
          Navigator.popUntil(context, ModalRoute.withName(LoginPage.id));
        }
      } else if (e is String) {
        showSimpleFlushBar(e, context);
      }
    } finally {
      setState(() {
        _showSpinner = false;
      });
    }
  }

  void addMarker() async {
    _huaweiMarkers.clear();

    final marker = huaweiMap.Marker(
      markerId: huaweiMap.MarkerId('marker'),
      position:
          huaweiMap.LatLng(_huaweiRiderLocation.lat, _huaweiRiderLocation.lng),
      icon: huaweiRiderIcon,
    );

    _huaweiMarkers['selected_location'] = marker;
//    if (await FlutterHmsGmsAvailability.isHmsAvailable) {
//      _huaweiMarkers.clear();
//
//      final marker = huaweiMap.Marker(
//        markerId: huaweiMap.MarkerId('marker'),
//        position: huaweiMap.LatLng(_huaweiRiderLocation.lat, _huaweiRiderLocation.lng),
//        icon: huaweiRiderIcon,
//      );
//
//      _huaweiMarkers['selected_location'] = marker;
//    }else{
//      _markers.clear();
//
//      final marker = Marker(
//        markerId: MarkerId('marker'),
//        position: LatLng(_riderLocation.latitude, _riderLocation.longitude),
//        icon: riderIcon,
//      );
//
//      _markers['selected_location'] = marker;
//    }
  }

//  void _createPolylines() async {
//    polylinePoints = PolylinePoints();
//
//    try {
//      Map<String, dynamic> routeData =
//          await GoogleMapPlacesService().getRoute();
//      int distanceInMeter = routeData['distance'];
//      _distance = distanceInMeter / 1000;
//
//      polylineCoordinates = routeData['latLngList'];
//
//      _addPolyline();
//    } catch (e) {
//      showSimpleFlushBar(e, context);
//    }
//  }

  void _addPolyline() {
//    final PolylineId polylineId = PolylineId('poly');
//
//    final Polyline polyline = Polyline(
//      polylineId: polylineId,
//      color: Colors.red,
//      width: 3,
//      points: polylineCoordinates,
//    );
//
//    _polylines[polylineId] = polyline;
    setState(() {});
  }

  void startGetRiderLocation() {
    if (_timer != null) {
      _timer.cancel();
    }

    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      getTrackingInfo();
    });
  }

  void stopGetRiderLocation() {
    if (_timer != null) {
      _timer.cancel();
    }
  }

  String riderStatus() {
    String status = widget.history.orderStatus;

    if (status == 'ontheway') {
      return AppTranslations.of(context).text('rider_is_on_the_way_pick_up');
    } else if (status == 'started') {
      return AppTranslations.of(context)
          .text('item_picked_up_and_rider_ontheway_deliver');
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppTranslations.of(context).text('tracking'),
          style: kAppBarTextStyle,
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _showSpinner,
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                    child: _huaweiInitialPosition == null
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
                        : FutureBuilder(
                            builder: (BuildContext context,
                                AsyncSnapshot<dynamic> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                return snapshot.data;
                              }

                              return Container(
                                child: Center(
                                  child: Text(
                                    AppTranslations.of(context)
                                        .text('loading_map'),
                                    style: TextStyle(
                                        fontFamily: poppinsMedium,
                                        color: Colors.grey[400]),
                                  ),
                                ),
                              );
                            },
                            future: getMap(),
                          )),
              ),
              Container(
                padding: EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      (riderStatus() != '')
                          ? riderStatus()
                          : AppTranslations.of(context)
                              .text('rider_information'),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: poppinsMedium, fontSize: 18),
                    ),
                    SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          AppTranslations.of(context).text('driver_name'),
                          style: kDetailsTextStyle,
                        ),
                        SizedBox(width: 10.0),
                        Flexible(
                          child: Text(
                            '${(widget.history.driverName != null && widget.history.driverName != '') ? widget.history.driverName : '-'}',
                            style: kDetailsTextStyle,
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 10.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          AppTranslations.of(context).text('plate_no'),
                          style: kDetailsTextStyle,
                        ),
                        SizedBox(width: 10.0),
                        Text(
                          '${(widget.history.driverPlateNumber != null && widget.history.driverPlateNumber != '') ? widget.history.driverPlateNumber : '-'}',
                          style: kDetailsTextStyle,
                        )
                      ],
                    ),
                    SizedBox(height: 10.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          AppTranslations.of(context).text('driver_mobile_no'),
                          style: kDetailsTextStyle,
                        ),
                        SizedBox(width: 10.0),
                        Text(
                          '${(widget.history.driverPhone != null && widget.history.driverPhone != '') ? widget.history.driverPhone : '-'}',
                          style: kDetailsTextStyle,
                        )
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<Widget> getMap() async {
    return huaweiMap.HuaweiMap(
      onMapCreated: _onHuaweiMapCreated,
      initialCameraPosition: huaweiMap.CameraPosition(
        target: (_huaweiRiderLocation != null)
            ? _huaweiRiderLocation
            : _huaweiInitialPosition,
        zoom: 17,
      ),
      markers: _huaweiMarkers.values.toSet(),
      myLocationEnabled: true,
    );
//    if (await FlutterHmsGmsAvailability.isHmsAvailable) {
//      return huaweiMap.HuaweiMap(
//        onMapCreated: _onHuaweiMapCreated,
//        initialCameraPosition: huaweiMap.CameraPosition(
//          target: (_huaweiRiderLocation != null)
//              ? _huaweiRiderLocation
//              : _huaweiInitialPosition,
//          zoom: 17,
//        ),
//        markers: _huaweiMarkers.values.toSet(),
//        myLocationEnabled: true,
//      );
//    }else{
//
//      return GoogleMap(
//        onMapCreated: _onMapCreated,
//        initialCameraPosition: CameraPosition(
//          target: (_riderLocation != null)
//              ? _riderLocation
//              : _initialPosition,
//          zoom: 17,
//        ),
//        markers: _markers.values.toSet(),
//        myLocationEnabled: true,
//      );
//    }
  }
}
