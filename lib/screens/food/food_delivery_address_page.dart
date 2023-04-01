import 'dart:collection';
// import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_hms_gms_availability/flutter_hms_gms_availability.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/components/custom_flushbar.dart';
import 'package:haloapp/components/input_textfield.dart';
import 'package:haloapp/models/address_model.dart';
import 'package:haloapp/models/food_order_model.dart';
import 'package:haloapp/models/google_places_component_model.dart';
import 'package:haloapp/networkings/food_networking.dart';
import 'package:haloapp/screens/general/find_address_page.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/api_urls.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/constants/styles.dart';
import 'package:haloapp/utils/services/google_map_places_service.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:haloapp/utils/services/location_service.dart';
import 'package:haloapp/components/model_progress_hud.dart';
import 'package:haloapp/utils/utils.dart';
import 'package:huawei_map/map.dart' as huaweiMap;
import 'package:huawei_location/location/location.dart' as huaweiLocation;

class FoodDeliveryAddressPage extends StatefulWidget {
  FoodDeliveryAddressPage({this.address});

  final AddressModel address;

  @override
  _FoodDeliveryAddressPageState createState() =>
      _FoodDeliveryAddressPageState();
}

class _FoodDeliveryAddressPageState extends State<FoodDeliveryAddressPage> {
  bool _showSpinner = false;
  GoogleMapsPlaces _places =
      GoogleMapsPlaces(apiKey: APIUrls().getGoogleAPIKey());

//  GoogleMapController mapController;
//  LatLng _initialPosition = LatLng(37.422153, -122.084047);
//  BitmapDescriptor pickupIcon;
//  Map<String, Marker> _markers = {};
//  LatLng _selectedLocation;

  //Huawei Map
  huaweiMap.HuaweiMapController huaweiMapController;
  huaweiMap.LatLng _huaweiInitialPosition =
      huaweiMap.LatLng(37.422153, -122.084047);
  huaweiMap.BitmapDescriptor huaweiPickupIcon;
  Map<String, huaweiMap.Marker> _huaweiMarkers = {};
  huaweiMap.LatLng _huaweiSelectedLocation;

  bool _shouldUpdateAddr = true;
  AddressModel _currentAddress;

  TextEditingController _unitNoController;
  TextEditingController _buildingNameController;

  @override
  void initState() {
    super.initState();

    initiateMap();
    setupIcons();
    _initiateAddressData();
    getZone();
  }

  void initiateMap() async {
    setState(() {
      _showSpinner = true;
    });

    bool locationPermissionGranted = await LocationService().checkPermission();
    if (!locationPermissionGranted) {
      showSimpleFlushBar(
          AppTranslations.of(context)
              .text('please_enable_location_service_in_phone_settings'),
          context);

      setState(() {
        _showSpinner = false;
      });
      return;
    }

    huaweiLocation.Location position =
        await LocationService().getCurrentLocation();
    _huaweiInitialPosition =
        huaweiMap.LatLng(position.latitude, position.longitude);

//    if(await FlutterHmsGmsAvailability.isHmsAvailable) {
//      _huaweiInitialPosition = huaweiMap.LatLng(position.latitude, position.longitude);
//    }else{
//      _initialPosition = LatLng(position.latitude, position.longitude);
//    }

    setState(() {
      _showSpinner = false;
    });
  }

//  void _onMapCreated(GoogleMapController controller) {
//    mapController = controller;
//  }

  void _onHuaweiMapCreated(huaweiMap.HuaweiMapController controller) {
    huaweiMapController = controller;
  }

  void setupIcons() async {
    ImageConfiguration imageConfig = ImageConfiguration(size: Size(25, 25));

//    BitmapDescriptor.fromAssetImage(imageConfig, 'images/pin_blue.png')
//        .then((value) => pickupIcon = value);

    huaweiMap.BitmapDescriptor.fromAssetImage(
            imageConfig, 'images/pin_blue.png')
        .then((value) => huaweiPickupIcon = value);
  }

  void _initiateAddressData() {
    if (widget.address != null) {
      _currentAddress = AddressModel(
        lat: widget.address.lat,
        lng: widget.address.lng,
        fullAddress: widget.address.fullAddress,
        zip: widget.address.zip,
        city: widget.address.city,
        state: widget.address.state,
        street: widget.address.street,
        buildingName: widget.address.buildingName,
        unitNo: widget.address.unitNo,
      );
//      _selectedLocation = LatLng(
//          double.parse(_currentAddress.lat), double.parse(_currentAddress.lng)
//      );

      _huaweiSelectedLocation = huaweiMap.LatLng(
          double.parse(_currentAddress.lat), double.parse(_currentAddress.lng));

      _unitNoController = TextEditingController(text: _currentAddress.unitNo);
      _buildingNameController =
          TextEditingController(text: _currentAddress.buildingName);

      // Initiate marker
      addMarker();
    }
  }

  Future displayGoogleAutocomplete() async {
    _shouldUpdateAddr = false;
    var c1 = await Navigator.pushNamed(context, FindAddressPage.id);
    // print('###' + (c1 as GooglePlacesComponentModel).fullAddress);
    if (c1 == null) return;
    GooglePlacesComponentModel component = c1;
    // print('### ' + component.fullAddress);
//    _selectedLocation = LatLng(component.lat, component.lng);
    _huaweiSelectedLocation = huaweiMap.LatLng(component.lat, component.lng);

    addMarker();

    navigateMapController();

    storeAddressDetails(component, component.fullAddress);
    Future.delayed(const Duration(milliseconds: 1000), () {
      _shouldUpdateAddr = true;
    });

    if (mounted) setState(() {});
  }

  void navigateMapController() async {
    huaweiMapController.animateCamera(huaweiMap.CameraUpdate.newCameraPosition(
        huaweiMap.CameraPosition(target: _huaweiSelectedLocation, zoom: 16)));
//    if (await FlutterHmsGmsAvailability.isHmsAvailable) {
//      huaweiMapController.animateCamera(huaweiMap.CameraUpdate.newCameraPosition(
//          huaweiMap.CameraPosition(target: _huaweiSelectedLocation, zoom: 16))
//      );
//    }else{
//      mapController.animateCamera(CameraUpdate.newCameraPosition(
//          CameraPosition(target: _selectedLocation, zoom: 16))
//      );
//    }
  }

  // Google autocomplete
  Future displayGoogleAutocompleteOld() async {
    Prediction prediction = await showDialog(
        context: context,
        builder: (_) => PlacesAutocompleteWidget(
              apiKey: APIUrls().getGoogleAPIKey(),
              components: [Component(Component.country, "my")],
              onError: onError,
              debounce: 1000,
              mode: Mode.overlay,
            ));

    displayPrediction(prediction);
  }

  Future displayPrediction(Prediction prediction) async {
    if (prediction != null) {
      _shouldUpdateAddr = false;
      PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(
          prediction.placeId,
          region: "my",
          fields: Utils.fields);

      if (detail.result == null) {
        showSimpleFlushBar(
            AppTranslations.of(context)
                .text('unable_get_location_details_please_try_another_one'),
            context);
        return;
      }

      GooglePlacesComponentModel component =
          GoogleMapPlacesService().getDelegatedComponent(detail.result);

//      _selectedLocation = LatLng(component.lat, component.lng);
      _huaweiSelectedLocation = huaweiMap.LatLng(component.lat, component.lng);

      addMarker();

      navigateMapController();

      _shouldUpdateAddr = false;
      storeAddressDetails(component, prediction.description);
      Future.delayed(const Duration(milliseconds: 1000), () {
        _shouldUpdateAddr = true;
      });

      if (mounted) setState(() {});
    }
  }

  void storeAddressDetails(
      GooglePlacesComponentModel component, String fullAddress) {
    String street = '';
    if (component.street != null && component.street != '') {
      street = component.street;
    }

    if (component.route != null && component.route != '') {
      if (street != null && street != '') {
        street = street + ', ' + component.route;
      } else {
        street = component.route;
      }
    }

    AddressModel address = AddressModel(
      lat: component.lat.toString(),
      lng: component.lng.toString(),
      fullAddress: fullAddress,
      zip: component.zip,
      city: component.city,
      state: component.state,
      street: street,
    );

    _currentAddress = address;

    print(FoodOrderModel().getDeliveryAddress().street);
  }

  void setAddress() {
    FoodOrderModel().setDeliverAddress(AddressModel(
      lat: _currentAddress.lat,
      lng: _currentAddress.lng,
      fullAddress: _currentAddress.fullAddress,
      zip: _currentAddress.zip,
      city: _currentAddress.city,
      state: _currentAddress.state,
      street: _currentAddress.street,
      buildingName: _currentAddress.buildingName,
      unitNo: _currentAddress.unitNo,
    ));

    Navigator.pop(context, 'refresh');
  }

  void onError(PlacesAutocompleteResponse response) {
    showSimpleFlushBar(response.errorMessage, context);
  }

  void addMarker() async {
    _huaweiMarkers.clear();

    final marker = huaweiMap.Marker(
        markerId: huaweiMap.MarkerId('marker'),
        position: huaweiMap.LatLng(
            _huaweiSelectedLocation.lat, _huaweiSelectedLocation.lng),
        icon: huaweiPickupIcon,
        draggable: true,
        onDragEnd: (newPosition) {
          print('new position ${newPosition.lat}, ${newPosition.lng}');
//          var latLng = LatLng(newPosition.lat, newPosition.lng);
          _markerLocationChanged(newPosition);
        });

    _huaweiMarkers['selected_location'] = marker;
  }

  void _markerLocationChanged(huaweiMap.LatLng newPosition) async {
    setState(() {
      _showSpinner = true;
    });

    try {
      Map<String, dynamic> result = await GoogleMapPlacesService()
          .getPlaceComponentByLocation(newPosition);
      GooglePlacesComponentModel component = result['components'];
      String fullAddress = result['fullAddress'];
//      _selectedLocation = LatLng(component.lat, component.lng);
      _huaweiSelectedLocation = huaweiMap.LatLng(component.lat, component.lng);
      // print('ggwp ' + _shouldUpdateAddr.toString());
      if (_shouldUpdateAddr) {
        storeAddressDetails(component, fullAddress);
      }
      print("full address: ${_currentAddress.fullAddress}");
      setState(() {});
    } catch (e) {
      print(e.toString());
      // if(MonthInputElement.supported)
      //   showSimpleFlushBar(
      //       'Some address details is missing for this location. Please try again',
      //       context);

      // reset marker to old position
      print(
          'old location: ${_huaweiSelectedLocation.lat}, ${_huaweiSelectedLocation.lng}');
      addMarker();

      navigateMapController();

      if (mounted) setState(() {});
    } finally {
      if (mounted)
        setState(() {
          _showSpinner = false;
        });
    }
  }

  void getZone() async {
    Map<String, dynamic> params = {
      "apiKey": APIUrls().getApiKey(),
    };
    print(params);

    setState(() {
      _showSpinner = true;
    });

    try {
      var data = await FoodNetworking().getZone(params);

      setState(() {
        _setPolygon(data);
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

//  Set<Polygon> _polygons = HashSet<Polygon>();

  Set<huaweiMap.Polygon> _huaweiPolygons = HashSet<huaweiMap.Polygon>();

  void _setPolygon(List<dynamic> data) async {
//    print(data);

    if (data != null && data.length > 0) {
      for (int i = 0; i < data.length; i++) {
        List<huaweiMap.LatLng> polygonLatLngs = [];

        for (int j = 0; j < data[i].length; j++) {
          polygonLatLngs
              .add(huaweiMap.LatLng(data[i][j].latitude, data[i][j].longitude));
        }

        final String polygonIdVal = '';
        _huaweiPolygons.add(huaweiMap.Polygon(
          polygonId: huaweiMap.PolygonId('polygon$i'),
          points: polygonLatLngs,
          strokeWidth: 3,
          strokeColor: kColorRed,
          fillColor: Colors.red.withOpacity(0.15),
        ));
      }
    }
//    if (await FlutterHmsGmsAvailability.isHmsAvailable) {
//      if (data != null && data.length > 0) {
//        for (int i = 0; i < data.length; i++) {
//
//          List<huaweiMap.LatLng> polygonLatLngs = [];
//
//          for(int j = 0 ; j<data[i].length ; j++){
//            polygonLatLngs.add(huaweiMap.LatLng(
//                data[i][j].latitude,data[i][j].longitude
//            ));
//          }
//
//          final String polygonIdVal = '';
//          _huaweiPolygons.add(huaweiMap.Polygon(
//            polygonId: huaweiMap.PolygonId('polygon$i'),
//            points: polygonLatLngs,
//            strokeWidth: 3,
//            strokeColor: kColorRed,
//            fillColor: Colors.red.withOpacity(0.15),
//          ));
//        }
//      }
//
//    }else{
//      if (data != null && data.length > 0) {
//        for (int i = 0; i < data.length; i++) {
//          List<LatLng> polygonLatLngs = data[i];
//
//          final String polygonIdVal = '';
//          _polygons.add(Polygon(
//            polygonId: PolygonId('polygon$i'),
//            points: polygonLatLngs,
//            strokeWidth: 2,
//            strokeColor: kColorRed,
//            fillColor: Colors.red.withOpacity(0.15),
//          ));
//        }
//      }
//    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(),
        body: ModalProgressHUD(
          inAsyncCall: _showSpinner,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Container(
                          height: 350,
                          child: _huaweiInitialPosition == null
                              ? Container(
                                  child: Center(
                                    child: Text(
                                      AppTranslations.of(context)
                                          .text('loading_map'),
                                      style: TextStyle(
                                          fontFamily: poppinsMedium,
                                          color: Colors.grey[400]),
                                    ),
                                  ),
                                )
                              : Stack(
                                  children: <Widget>[
                                    getMap(),
//                                    FutureBuilder(
//                                      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot){
//                                        if(snapshot.connectionState == ConnectionState.done){
//                                          return snapshot.data;
//                                        }
//                                        return Container();
//                                      },
//                                      future: getMap(),
//                                    ),
                                    Align(
                                      alignment: Alignment.center,
                                      child: Transform.translate(
                                          offset: Offset(0, -10),
                                          child: Image.asset(
                                              'images/pin_blue.png')),
                                    )
                                  ],
                                )),
                      (_huaweiSelectedLocation != null)
                          ? Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 15.0),
                              child: Text(
                                AppTranslations.of(context).text(
                                    'you_may_hold_n_drag_the_pin_to_locate_your_location'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: poppinsItalic,
                                    fontSize: 12,
                                    color: Colors.blueGrey),
                              ),
                            )
                          : Container(),
                      Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                displayGoogleAutocomplete();
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 15.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      style: BorderStyle.solid,
                                      color: (_currentAddress != null &&
                                              _currentAddress.fullAddress !=
                                                  null &&
                                              _currentAddress
                                                  .fullAddress.isNotEmpty)
                                          ? Colors.black
                                          : Colors.grey),
                                ),
                                child: Text(
                                  (_currentAddress != null &&
                                          _currentAddress.fullAddress != null &&
                                          _currentAddress
                                              .fullAddress.isNotEmpty)
                                      ? _currentAddress.fullAddress
                                      : AppTranslations.of(context)
                                          .text('address'),
                                  style: (_currentAddress != null &&
                                          _currentAddress.fullAddress != null &&
                                          _currentAddress
                                              .fullAddress.isNotEmpty)
                                      ? kInputTextStyle
                                      : kAddressPlaceholderTextStyle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 15.0,
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Expanded(
                                  child: InputTextField(
                                    hintText: (_currentAddress != null &&
                                            _currentAddress.unitNo != null)
                                        ? _currentAddress.unitNo
                                        : AppTranslations.of(context)
                                            .text('unit_no'),
                                    controller: _unitNoController,
                                    onChange: (value) {
                                      _currentAddress.unitNo = value;
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                  flex: 2,
                                  child: InputTextField(
                                    hintText: (_currentAddress != null &&
                                            _currentAddress.buildingName !=
                                                null)
                                        ? _currentAddress.buildingName
                                        : AppTranslations.of(context)
                                            .text('address'),
                                    controller: _buildingNameController,
                                    onChange: (value) {
                                      _currentAddress.buildingName = value;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: ActionButton(
                    buttonText: AppTranslations.of(context).text('save'),
                    onPressed: () {
                      setAddress();
                    },
                  ))
            ],
          ),
        ),
      ),
    );
  }

  Widget getMap() {
    return huaweiMap.HuaweiMap(
      onMapCreated: _onHuaweiMapCreated,
      initialCameraPosition: huaweiMap.CameraPosition(
        target: (_huaweiSelectedLocation != null)
            ? _huaweiSelectedLocation
            : _huaweiInitialPosition,
        zoom: 15,
      ),
//                                markers: _markers.values.toSet(),
      myLocationEnabled: true,
      polygons: _huaweiPolygons,
      onCameraMove: (cameraPosition) {
        _huaweiSelectedLocation = cameraPosition.target;
      },
      onCameraIdle: () {
//        var latLng = LatLng(_huaweiSelectedLocation.lat, _huaweiSelectedLocation.lng);
        _markerLocationChanged(_huaweiSelectedLocation);
      },
    );
//    if (await FlutterHmsGmsAvailability.isHmsAvailable) {
//      return huaweiMap.HuaweiMap(
//        onMapCreated: _onHuaweiMapCreated,
//        initialCameraPosition: huaweiMap.CameraPosition(
//          target: (_huaweiSelectedLocation != null)
//              ? _huaweiSelectedLocation
//              : _huaweiInitialPosition,
//          zoom: 15,
//        ),
////                                markers: _markers.values.toSet(),
//        myLocationEnabled: true,
//        polygons: _huaweiPolygons,
//        onCameraMove: (cameraPosition) {
//          _huaweiSelectedLocation = cameraPosition.target;
//        },
//        onCameraIdle: () {
//          var latLng = LatLng(_huaweiSelectedLocation.lat, _huaweiSelectedLocation.lng);
//          _markerLocationChanged(latLng);
//        },
//      );
//    } else {
//      return GoogleMap(
//        onMapCreated: _onMapCreated,
//        initialCameraPosition: CameraPosition(
//          target: (_selectedLocation != null)
//              ? _selectedLocation
//              : _initialPosition,
//          zoom: 15,
//        ),
////                                markers: _markers.values.toSet(),
//        myLocationEnabled: true,
//        polygons: _polygons,
//        onCameraMove: (cameraPosition) {
//          _selectedLocation =
//              cameraPosition.target;
//        },
//        onCameraIdle: () {
//          _markerLocationChanged(
//              _selectedLocation);
//        },
//      );
//    }
  }
}
