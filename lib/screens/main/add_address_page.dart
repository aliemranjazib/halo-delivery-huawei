import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hms_gms_availability/flutter_hms_gms_availability.dart';
import 'package:haloapp/components/input_textfield.dart';
import 'package:haloapp/models/address_model.dart';
import 'package:haloapp/models/booking_model.dart';
import 'package:haloapp/models/google_places_component_model.dart';
import 'package:haloapp/models/user_model.dart';
import 'package:haloapp/networkings/booking_networking.dart';
import 'package:haloapp/screens/delivery/past_booking_addresses_popup.dart';
import 'package:haloapp/screens/general/find_address_page.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/api_urls.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/constants/styles.dart';
import 'package:haloapp/utils/services/google_map_places_service.dart';
import 'package:haloapp/components/model_progress_hud.dart';
import 'package:haloapp/utils/utils.dart';
import '../../components/action_button.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import '../../components/custom_flushbar.dart';
import '../../components/remarks_textbox.dart';
import '../../utils/services/location_service.dart';
import 'package:huawei_map/map.dart' as huaweiMap;
import 'package:huawei_location/huawei_location.dart' as huaweiLocation;

class AddAddressPage extends StatefulWidget {
  static const String id = 'addAddressPage';

  AddAddressPage({this.addressIndex});

  final int addressIndex;

  @override
  _AddAddressPageState createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  bool _showSpinner = false;
  GoogleMapsPlaces _places =
      GoogleMapsPlaces(apiKey: APIUrls().getGoogleAPIKey());
  // GoogleMapController mapController;
  // LatLng _initialPosition = LatLng(37.422153, -122.084047);
  // BitmapDescriptor pickupIcon;
  // BitmapDescriptor dropoffIcon;
  // Map<String, Marker> _markers = {};

  bool _shouldInitiate = true;
  int _editingAddressIndex;
  // LatLng _selectedLocation;
  AddressModel address = AddressModel();

  ///Huawei Map
  huaweiMap.HuaweiMapController huaweiMapController;
  huaweiMap.LatLng _huaweiInitialPosition =
      huaweiMap.LatLng(37.422153, -122.084047);
  huaweiMap.LatLng _huaweiSelectedLocation;
  huaweiMap.BitmapDescriptor huaweiPickupIcon;
  huaweiMap.BitmapDescriptor huaweiDropoffIcon;
  Map<String, huaweiMap.Marker> _huaweiMarkers = {};

  TextEditingController _unitNoController;
  TextEditingController _buildingNameController;
  TextEditingController _picNameController;
  TextEditingController _picPhoneController;

  @override
  void initState() {
    super.initState();
    _editingAddressIndex = widget.addressIndex;
    print(_editingAddressIndex);
    //setupIcons();
    //_initiateAddressData();
  }

  void _initiateAddressData() async {
    if (_editingAddressIndex != null && isAddressExist() && _shouldInitiate) {
      AddressModel previousSavedAddress =
          BookingModel().getAddressAtIndex(_editingAddressIndex);

      address = AddressModel(
        type: previousSavedAddress.type,
        fullAddress: previousSavedAddress.fullAddress,
        lat: previousSavedAddress.lat,
        lng: previousSavedAddress.lng,
        street: previousSavedAddress.street,
        city: previousSavedAddress.city,
        state: previousSavedAddress.state,
        zip: previousSavedAddress.zip,
        unitNo: previousSavedAddress.unitNo,
        buildingName: previousSavedAddress.buildingName,
        receiverName: previousSavedAddress.receiverName,
        receiverPhone: previousSavedAddress.receiverPhone,
        remarks: previousSavedAddress.remarks,
        addressId: '',
      );

      // _selectedLocation =
      //     LatLng(double.parse(address.lat), double.parse(address.lng));

      _huaweiSelectedLocation = huaweiMap.LatLng(
          double.parse(address.lat), double.parse(address.lng));

      _unitNoController = TextEditingController(text: address.unitNo);
      _buildingNameController =
          TextEditingController(text: address.buildingName);
      _picNameController = TextEditingController(text: address.receiverName);
      _picPhoneController = TextEditingController(text: address.receiverPhone);

      // Initiate marker
      addMarker();

      _shouldInitiate = false;
    } else {
      // Initiate Map
      huaweiLocation.Location position =
          await LocationService().getCurrentLocation();

      _huaweiSelectedLocation =
          huaweiMap.LatLng(position.latitude, position.longitude);
      huaweiMapController.animateCamera(
          huaweiMap.CameraUpdate.newCameraPosition(huaweiMap.CameraPosition(
              target: _huaweiSelectedLocation, zoom: 16)));

      // Position position = await LocationService().getCurrentLocation();
      //
      // _selectedLocation = LatLng(position.latitude, position.longitude);
      // mapController.animateCamera(CameraUpdate.newCameraPosition(
      //     CameraPosition(target: _selectedLocation, zoom: 16)));
    }
  }

  // void _onMapCreated(GoogleMapController controller) {
  //   mapController = controller;
  // }

  void _onHuaweiMapCreated(huaweiMap.HuaweiMapController controller) {
    huaweiMapController = controller;
  }

  void setupIcons() {
    ImageConfiguration imageConfig = ImageConfiguration(size: Size(25, 25));

    // BitmapDescriptor.fromAssetImage(imageConfig, 'images/pin_blue.png')
    //     .then((value) => pickupIcon = value);
    //
    // BitmapDescriptor.fromAssetImage(imageConfig, 'images/pin_red.png')
    //     .then((value) => dropoffIcon = value);

    huaweiMap.BitmapDescriptor.fromAssetImage(
            imageConfig, 'images/pin_blue.png')
        .then((value) => huaweiPickupIcon = value);

    huaweiMap.BitmapDescriptor.fromAssetImage(imageConfig, 'images/pin_red.png')
        .then((value) => huaweiDropoffIcon = value);
  }

  void addAddress() {
    print('add address at: $_editingAddressIndex');
    if (address.lat == null ||
        address.lat.isEmpty ||
        address.lng == null ||
        address.lng.isEmpty) {
      showSimpleFlushBar(
          AppTranslations.of(context).text('please_select_a_address'), context);
      return;
    }

    if ((address.receiverName == null || address.receiverName.isEmpty)) {
      showSimpleFlushBar(
          AppTranslations.of(context).text('please_enter_recipient_name'),
          context);
      return;
    }

    if ((address.receiverPhone == null || address.receiverPhone.isEmpty)) {
      showSimpleFlushBar(
          AppTranslations.of(context)
              .text('please_enter_recipient_mobile_number'),
          context);
      return;
    }

    if (_editingAddressIndex != null) {
      if (isAddressExist()) {
        BookingModel().replaceAddressAtIndex(_editingAddressIndex, address);
      } else {
        BookingModel().addAddress(address);
      }
    } else {
      BookingModel().addAddress(address);
    }

    Navigator.pop(context, 'refresh');
  }

  bool isAddressExist() {
    if (BookingModel().getAllAddresses() != null &&
        BookingModel().getAllAddresses().length > _editingAddressIndex &&
        BookingModel().getAddressAtIndex(_editingAddressIndex) != null) {
      return true;
    } else {
      return false;
    }
  }

  Future displayGoogleAutocomplete() async {
    var ams = await Navigator.pushNamed(context, FindAddressPage.id,
        arguments: {"bookingMode": true});
    if (ams == null) return;
    AddressModel am = ams;
    setState(() {
      address.fullAddress = am.fullAddress;
      address.lat = am.lat;
      address.lng = am.lng;
      address.zip = am.zip;
      address.city = am.city;
      address.state = am.state;
      address.street = am.street;
      address.unitNo = am.unitNo;
    });
  }

  // Google autocomplete
  Future displayGoogleAutocompleteOld() async {
    return Navigator.pushNamed(context, FindAddressPage.id);

    Prediction prediction = await showDialog(
        context: context,
        builder: (_) => PlacesAutocompleteWidget(
              apiKey: APIUrls().getGoogleAPIKey(),
              components: [Component(Component.country, "my")],
              onError: onError,
              debounce: 1500,
              mode: Mode.overlay,
            ));

//     Prediction prediction = await PlacesAutocomplete.show(
//       context: context,
//       apiKey: APIUrls().getGoogleAPIKey(),
//       components: [Component(Component.country, "my")],
//       onError: onError,
//       mode: Mode.overlay,
// //        types: ["address"]
//     );

    displayPrediction(prediction);
  }

  Future displayPrediction(Prediction prediction) async {
    if (prediction != null) {
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

//      if (await FlutterHmsGmsAvailability.isHmsAvailable) {
//        _huaweiSelectedLocation = huaweiMap.LatLng(component.lat, component.lng);
//        addMarker();
//
//        huaweiMapController.animateCamera(huaweiMap.CameraUpdate.newCameraPosition(
//            huaweiMap.CameraPosition(target: _huaweiSelectedLocation, zoom: 16)));
//
//        storeAddressDetails(component, prediction.description);
//      }else{
//        _selectedLocation = LatLng(component.lat, component.lng);
//        addMarker();
//
//        mapController.animateCamera(CameraUpdate.newCameraPosition(
//            CameraPosition(target: _selectedLocation, zoom: 16)));
//
//        storeAddressDetails(component, prediction.description);
//      }

      _huaweiSelectedLocation = huaweiMap.LatLng(component.lat, component.lng);
      addMarker();

      huaweiMapController.animateCamera(
          huaweiMap.CameraUpdate.newCameraPosition(huaweiMap.CameraPosition(
              target: _huaweiSelectedLocation, zoom: 16)));

      storeAddressDetails(component, prediction.description);

      print("full address: ${address.fullAddress}");
      print(address.street);
      setState(() {});
    }
  }

  void storeAddressDetails(
      GooglePlacesComponentModel component, String fullAddress) {
    address.fullAddress = fullAddress;
    address.lat = component.lat.toString();
    address.lng = component.lng.toString();
    address.zip = component.zip;
    address.city = component.city;
    address.state = component.state;

    if (component.street != null && component.street != '') {
      address.street = component.street;
    }

    if (component.route != null && component.route != '') {
      if (address.street != null) {
        address.street = address.street + ', ' + component.route;
      } else {
        address.street = component.route;
      }
    }
  }

  void onError(PlacesAutocompleteResponse response) {
    showSimpleFlushBar(response.errorMessage, context);
  }

  void addMarker() async {
    print('add marker');
    _huaweiMarkers.clear();

    final marker = huaweiMap.Marker(
        markerId: huaweiMap.MarkerId('marker'),
        position: huaweiMap.LatLng(
            _huaweiSelectedLocation.lat, _huaweiSelectedLocation.lng),
        icon:
            (_editingAddressIndex == 0) ? huaweiPickupIcon : huaweiDropoffIcon,
        draggable: true,
        onDragEnd: (newPosition) {
          print('new position ${newPosition.lat}, ${newPosition.lng}');
//          LatLng newPositionLatLng = LatLng(newPosition.lat,newPosition.lng);
          _markerLocationChanged(newPosition);
        });

    _huaweiMarkers['selected_location'] = marker;

    // _markers.clear();
    //
    // final marker = Marker(
    //     markerId: MarkerId('marker'),
    //     position:
    //         LatLng(_selectedLocation.latitude, _selectedLocation.longitude),
    //     icon: (_editingAddressIndex == 0) ? pickupIcon : dropoffIcon,
    //     draggable: true,
    //     onDragEnd: (newPosition) {
    //       print(
    //           'new position ${newPosition.latitude}, ${newPosition.longitude}');
    //       _markerLocationChanged(newPosition);
    //     });
    //
    // _markers['selected_location'] = marker;
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

      storeAddressDetails(component, fullAddress);
      print("full address: ${address.fullAddress}");
      setState(() {});
    } catch (e) {
      print(e.toString());
      showSimpleFlushBar(
          'Some address details is missing for this location. Please try again',
          context);

      // reset marker to old position
//      print(
//          'old location: ${_selectedLocation.latitude}, ${_selectedLocation.longitude}');
      addMarker();

      if (await FlutterHmsGmsAvailability.isHmsAvailable) {
        huaweiMapController.animateCamera(
            huaweiMap.CameraUpdate.newCameraPosition(huaweiMap.CameraPosition(
                target: _huaweiSelectedLocation, zoom: 16)));
      } else {
//        mapController.animateCamera(CameraUpdate.newCameraPosition(
//            CameraPosition(target: _selectedLocation, zoom: 16)));
      }

      setState(() {});
    } finally {
      setState(() {
        _showSpinner = false;
      });
    }
  }

  void getPreviousBookingAddress() async {
    if (User().getAuthToken() == null) return displayGoogleAutocomplete();

    Map<String, dynamic> params = {
      "apiKey": APIUrls().getApiKey(),
      "data": {
        "addressType": (_editingAddressIndex == 0) ? "pickup" : "dropoff"
      }
    };

    setState(() {
      _showSpinner = true;
    });

    try {
      var data = await BookingNetworking().getRecentAddresses(params);

      if (data is List<AddressModel> && data.length > 0) {
        _showPastBookingsAddressesPopup(data);
      } else {
        displayGoogleAutocomplete();
      }
    } catch (e) {
      showSimpleFlushBar(e, context);
    } finally {
      setState(() {
        _showSpinner = false;
      });
    }
  }

  _showPastBookingsAddressesPopup(List<AddressModel> addresses) {
    showDialog(
        context: context,
        builder: (context) =>
            PastBookingAddressesDialog(addresses: addresses)).then((value) {
      if (value != null) {
        if (value == 'newAddress') {
          displayGoogleAutocomplete();
        } else if (value is AddressModel) {
          // Store address info
          FlutterHmsGmsAvailability.isHmsAvailable.then((isHms) {
            if (isHms) {
              _huaweiSelectedLocation = huaweiMap.LatLng(
                  double.parse(value.lat), double.parse(value.lng));
              addMarker();

              huaweiMapController.animateCamera(
                  huaweiMap.CameraUpdate.newCameraPosition(
                      huaweiMap.CameraPosition(
                          target: _huaweiSelectedLocation, zoom: 16)));
            } else {
//              _selectedLocation =
//                  LatLng(double.parse(value.lat), double.parse(value.lng));
//              addMarker();
//
//              mapController.animateCamera(CameraUpdate.newCameraPosition(
//                  CameraPosition(target: _selectedLocation, zoom: 16)));
            }

            setState(() {
              address.fullAddress = value.fullAddress;
              address.lat = value.lat;
              address.lng = value.lng;
              address.zip = value.zip;
              address.city = value.city;
              address.state = value.state;
              address.street = value.street;
            });
          });
        }
      }
    });
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
        appBar: AppBar(
          leading: IconButton(
            icon: arrowBack,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            widget.addressIndex == 0
                ? AppTranslations.of(context).text('pickup_location')
                : AppTranslations.of(context).text('delivery_target'),
            style: kAppBarTextStyle,
          ),
        ),
        body: SafeArea(
          child: ModalProgressHUD(
            inAsyncCall: _showSpinner,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Row() ??
                            Container(
                                height: 200,
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
                                          Align(
                                            alignment: Alignment.center,
                                            child: Transform.translate(
                                                offset: Offset(0, -10),
                                                child: (_editingAddressIndex ==
                                                        0)
                                                    ? Image.asset(
                                                        'images/pin_blue.png')
                                                    : Image.asset(
                                                        'images/pin_red.png')),
                                          )
                                        ],
                                      )),
                        Row() ??
//                            FutureBuilder(
//                              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot){
//                                if(snapshot.connectionState == ConnectionState.done){
//                                  return snapshot.data;
//                                }
//                                return Container();
//                              },
//                              future:getMarker()
//                            ),
                            getMarker(),
                        Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 15.0, horizontal: 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Row(
                                children: [
                                  Image.asset(
                                    (_editingAddressIndex != null &&
                                            _editingAddressIndex == 0)
                                        ? 'images/ic_sender.png'
                                        : 'images/ic_recipient.png',
                                    width: 24,
                                    height: 24,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    (_editingAddressIndex != null &&
                                            _editingAddressIndex == 0)
                                        ? AppTranslations.of(context)
                                            .text('sender_information')
                                        : AppTranslations.of(context)
                                            .text('recipient_information'),
                                    style: TextStyle(
                                      fontFamily: poppinsMedium,
                                      fontSize: 16,
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(height: 15),
                              GestureDetector(
                                onTap: () {
                                  displayGoogleAutocomplete();
                                  // getPreviousBookingAddress();
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 15.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                        style: BorderStyle.solid,
                                        color: (address != null &&
                                                address.fullAddress != null &&
                                                address.fullAddress.isNotEmpty)
                                            ? Colors.black
                                            : Colors.grey),
                                  ),
                                  child: Text(
                                    (address != null &&
                                            address.fullAddress != null &&
                                            address.fullAddress.isNotEmpty)
                                        ? address.fullAddress
                                        : AppTranslations.of(context)
                                            .text('address'),
                                    style: (address != null &&
                                            address.fullAddress != null &&
                                            address.fullAddress.isNotEmpty)
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
                              Row() ??
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      Expanded(
                                        child: InputTextField(
                                          hintText: (address != null &&
                                                  address.unitNo != null)
                                              ? address.unitNo
                                              : AppTranslations.of(context)
                                                  .text('unit_no'),
                                          controller: _unitNoController,
                                          onChange: (value) {
                                            address.unitNo = value;
                                          },
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: InputTextField(
                                          hintText: (address != null &&
                                                  address.buildingName != null)
                                              ? address.buildingName
                                              : AppTranslations.of(context)
                                                  .text('address'),
                                          controller: _buildingNameController,
                                          onChange: (value) {
                                            address.buildingName = value;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                              Row() ??
                                  SizedBox(
                                    height: 15.0,
                                  ),
                              InputTextField(
                                hintText: (_editingAddressIndex != null &&
                                        _editingAddressIndex == 0)
                                    ? AppTranslations.of(context)
                                        .text('sender_name')
                                    : AppTranslations.of(context)
                                        .text('recipient_name'),
                                controller: _picNameController,
                                enabled: true,
                                onChange: (value) {
                                  address.receiverName = value;
                                },
                              ),
                              SizedBox(
                                height: 15.0,
                              ),
                              InputTextField(
                                hintText: (_editingAddressIndex != null &&
                                        _editingAddressIndex == 0)
                                    ? AppTranslations.of(context)
                                        .text('sender_mobile_number')
                                    : AppTranslations.of(context)
                                        .text('recipient_mobile_number'),
                                inputType: TextInputType.number,
                                controller: _picPhoneController,
                                enabled: true,
                                onChange: (value) {
                                  address.receiverPhone = value;
                                },
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
                        addAddress();
                      },
                    ))
              ],
            ),
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
//                                    markers: _markers.values.toSet(),
      myLocationEnabled: true,
      onCameraMove: (cameraPosition) {
        print("onCameraMove");

        _huaweiSelectedLocation = cameraPosition.target;
      },
      onCameraIdle: () {
        print('onCameraIdle');
//        LatLng latLng = LatLng(_huaweiSelectedLocation.lat, _huaweiSelectedLocation.lng);
        _markerLocationChanged(_huaweiSelectedLocation);
      },
    );
  }

  Future<Widget> getMarker() async {
    return ((_huaweiSelectedLocation != null)
        ? Container(
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
            child: Text(
              AppTranslations.of(context)
                  .text('you_may_hold_n_drag_the_pin_to_locate_your_location'),
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: poppinsItalic,
                  fontSize: 12,
                  color: Colors.blueGrey),
            ),
          )
        : Container());
//    if (await FlutterHmsGmsAvailability.isHmsAvailable) {
//      return ((_huaweiSelectedLocation != null)
//          ? Container(
//        padding: EdgeInsets.symmetric(
//            vertical: 10.0, horizontal: 15.0),
//        child: Text(
//          AppTranslations.of(context).text(
//              'you_may_hold_n_drag_the_pin_to_locate_your_location'),
//          textAlign: TextAlign.center,
//          style: TextStyle(
//              fontFamily: poppinsItalic,
//              fontSize: 12,
//              color: Colors.blueGrey),
//        ),
//      )
//          : Container());
//    }else{
//      return ((_selectedLocation != null)
//          ? Container(
//        padding: EdgeInsets.symmetric(
//            vertical: 10.0, horizontal: 15.0),
//        child: Text(
//          AppTranslations.of(context).text(
//              'you_may_hold_n_drag_the_pin_to_locate_your_location'),
//          textAlign: TextAlign.center,
//          style: TextStyle(
//              fontFamily: poppinsItalic,
//              fontSize: 12,
//              color: Colors.blueGrey),
//        ),
//      )
//          : Container());
//    }
  }
}
