import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hms_gms_availability/flutter_hms_gms_availability.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/components/custom_flushbar.dart';
import 'package:haloapp/components/input_textfield.dart';
import 'package:haloapp/components/model_progress_hud.dart';
import 'package:haloapp/models/address_model.dart';
import 'package:haloapp/models/food_model.dart';
import 'package:haloapp/models/food_order_model.dart';
import 'package:haloapp/models/user_model.dart';
import 'package:haloapp/networkings/food_networking.dart';
import 'package:haloapp/networkings/user_networking.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/api_urls.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/constants/styles.dart';
import 'package:huawei_map/map.dart' as huaweiMap;

class SaveAddressPage extends StatefulWidget {
  final AddressModel am;
  String adderssId;
  bool currentLocationMode;
  SaveAddressPage(this.am, {this.currentLocationMode = false, this.adderssId});

  @override
  _SaveAddressPageState createState() => _SaveAddressPageState();
}

class _SaveAddressPageState extends State<SaveAddressPage> {
  String _name = '';
  String _detail = '';
  String _note = '';
  String _zip = '';
  bool _preventDrag = true;
  TextEditingController _namec = new TextEditingController();
  TextEditingController _detailc = new TextEditingController();
  TextEditingController _notec = new TextEditingController();
  TextEditingController _zipc = new TextEditingController();
//  GoogleMapController mapController;
//  LatLng _droppin;
  bool _showSpinner = false;

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

//  Set<Polygon> _polygons = Set<Polygon>();

  //Huawei Map
  Set<huaweiMap.Polygon> _huaweiPolygons = Set<huaweiMap.Polygon>();
  huaweiMap.LatLng _huaweiDroppin;

  void _setPolygon(List<dynamic> data) async{
     print("data123 : $data");
     if (data != null && data.length > 0) {
       for (int i = 0; i < data.length; i++) {

         List<huaweiMap.LatLng> polygonLatLngs = [];

         for(int j = 0 ; j<data[i].length ; j++){
           polygonLatLngs.add(huaweiMap.LatLng(
               data[i][j].lat,data[i][j].lng
           ));
         }

         final String polygonIdVal = '';
         _huaweiPolygons.add(huaweiMap.Polygon(
           polygonId: huaweiMap.PolygonId('polygon$i'),
           points: polygonLatLngs,
           strokeWidth: 3,
           strokeColor: kColorRed.withOpacity(.2),
           fillColor: Colors.red.withOpacity(0.1),
         ));
       }
     }
//    if (await FlutterHmsGmsAvailability.isHmsAvailable) {
//
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
//            strokeWidth: 3,
//            strokeColor: kColorRed.withOpacity(.2),
//            fillColor: Colors.red.withOpacity(0.1),
//          ));
//        }
//      }
//    }

  }

  @override
  void initState() {
    print('current lcoationm mode' + widget.currentLocationMode.toString());
    Future.delayed(const Duration(milliseconds: 500), () {
      _preventDrag = false;
    });
    if(widget.am != null){
      print("zip --> ${widget.am.zip}");
      _zip = _zipc.text = widget.am.zip;
    }

    if (widget.adderssId != null) {
      _name = _namec.text = widget.am.name;
      _detail = _detailc.text = widget.am.unitNo;
      _note = _notec.text = widget.am.note;
      _zip = _zipc.text = widget.am.zip;
    }

    getZone();

    _huaweiDroppin = huaweiMap.LatLng(num.tryParse(widget.am.lat.toString()).toDouble(),
        num.tryParse(widget.am.lng.toString()).toDouble());

//    FlutterHmsGmsAvailability.isHmsAvailable.then((value){
//      if(value){
//        _huaweiDroppin = huaweiMap.LatLng(num.tryParse(widget.am.lat.toString()).toDouble(),
//            num.tryParse(widget.am.lng.toString()).toDouble());
//      }else{
//        _droppin = LatLng(num.tryParse(widget.am.lat.toString()).toDouble(),
//            num.tryParse(widget.am.lng.toString()).toDouble());
//      }
//
//      setState(() {
//
//      });
//    });


    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.am.fullAddress);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: arrowBack,
          onPressed: () => {Navigator.pop(context)},
        ),
        title: Text(AppTranslations.of(context).text('delivery_locations'),
          style: kAppBarTextStyle,
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _showSpinner,
        child: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              children: [
                Stack(
                  // overflow: Overflow.visible,
                  children: [
                    Container(
                      height: 260,
                      child: Stack(
                        children: [
                          getMap(),
//                          FutureBuilder(
//                            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot){
//                              if(snapshot.connectionState == ConnectionState.done){
//                                return snapshot.data;
//                              }
//
//                              return Container();
//                            },
//                            future: getMap(),
//                          ),
                          // Align(
                          //   alignment: Alignment.center,
                          //   child: Container(
                          //     height: 5,
                          //     width: 5,
                          //     color: Colors.black,
                          //   ),
                          // ),
                          Align(
                            alignment: Alignment.center,
                            child: Transform.translate(
                                offset: Offset(0, -15),
                                child: Image.asset(
                                  'images/pin_red.png',
                                  height: 30,
                                )),
                          )
                        ],
                      ),
                    ),
                    Positioned(
                      // top: 50,
                      bottom: -20,
                      left: 14,
                      right: 14,
                      child: Container(
                          // height: 100,
                          // margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: new BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            // border: Border.all(color: Colors.grey[300]),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.1),
                                blurRadius:
                                    10.0, // has the effect of softening the shadow

                                offset: Offset(
                                  0, // horizontal, move right 10
                                  5.0, // vertical, move down 10
                                ),
                              )
                            ],
                          ),
                          padding: EdgeInsets.fromLTRB(15, 12, 5, 12),
                          child: Row(
                            // crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Text(
                              //   'Address',
                              //   textAlign: TextAlign.left,
                              //   style: TextStyle(
                              //       fontFamily: poppinsMedium, height: 1.2),
                              // ),
                              Image.asset(
                                'images/pin_red.png',
                                width: 20,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Flexible(
                                child: Text(
                                  widget.am.fullAddress,
                                  style: TextStyle(
                                      height: 1.5,
                                      fontFamily: poppinsMedium,
                                      fontSize: 12),
                                ),
                              ),
                            ],
                          )),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 18,
                      ),
                      Container(
                        child: Text(
                          AppTranslations.of(context).text(
                                  'you_may_hold_n_drag_the_pin_to_locate_your_location') +
                              ' and makesure it matches the adderss you have provided.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: poppinsItalic,
                              fontSize: 10,
                              color: Colors.blueGrey),
                        ),
                      ),

                      // if ((User().getAuthToken() != null))
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            '  ' + AppTranslations.of(context).text('address_nickname'),
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontFamily: poppinsMedium, height: 2.5),
                          ),
                          InputTextField(
                            controller: _namec,
                            hintText: AppTranslations.of(context)
                                .text('label_for_your_own_ref'),
                            onChange: (value) {
                              _name = value;
                            },
                          ),
                        ],
                      ),
                      Text(
                        '  ' +
                            AppTranslations.of(context).text('address_details'),
                        textAlign: TextAlign.left,
                        style:
                            TextStyle(fontFamily: poppinsMedium, height: 2.5),
                      ),
                      InputTextField(
                        controller: _detailc,
                        hintText: AppTranslations.of(context)
                            .text('address_details_placeholder'),
                        onChange: (value) {
                          _detail = value;
                        },
                      ),
                      Text(
                        '  ' +
                            AppTranslations.of(context).text('postal_zip_code'),
                        textAlign: TextAlign.left,
                        style:
                            TextStyle(fontFamily: poppinsMedium, height: 2.5),
                      ),
                      InputTextField(
                        inputType: TextInputType.number,
                        controller: _zipc,
                        hintText: AppTranslations.of(context)
                            .text('postal_zip_code_placeholder'),
                        onChange: (value) {
                          _zip = value;
                        },
                      ),
                      // SizedBox(height: 8,),
                      Text(
                        '  ' +
                            AppTranslations.of(context).text('note_to_driver'),
                        textAlign: TextAlign.left,
                        style:
                            TextStyle(fontFamily: poppinsMedium, height: 2.5),
                      ),
                      InputTextField(
                        controller: _notec,
                        hintText: AppTranslations.of(context)
                            .text('note_to_driver_placeholder'),
                        onChange: (value) {
                          _note = value;
                        },
                      ),
                      SizedBox(
                        height: 18,
                      ),
                      Row(
                        children: <Widget>[
                          if (!widget.currentLocationMode &&
                              widget.adderssId != null)
                            Expanded(
                              child: ActionButtonLight(
                                buttonText:
                                    AppTranslations.of(context).text('remove'),
                                onPressed: widget.adderssId == null
                                    ? null
                                    : () async {
                                        FocusScope.of(context)
                                            .requestFocus(FocusNode());
                                        setState(() {
                                          _showSpinner = true;
                                        });
                                        await UserNetworking.removeAddress(
                                            widget.adderssId);
                                        Navigator.pop(context, 'removed');
                                      },
                              ),
                            ),
                          if (!widget.currentLocationMode &&
                              User().getAuthToken() != null)
                            SizedBox(width: 8.0),
                          Expanded(
                            child: ActionButton(
                              buttonText: AppTranslations.of(context)
                                  .text('save_and_continue'),
                              onPressed: () async {
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                                // print(_zip);
                                if (_zip.length < 5) {
                                  showSimpleFlushBar(
                                      AppTranslations.of(context)
                                          .text('invalid_zip_code'),
                                      context);
                                  return;
                                }
                                // if ((User().getAuthToken() != null) &&
                                //     _name.length <= 2) {
                                if (_name.length <= 2) {
                                  showSimpleFlushBar(
                                      AppTranslations.of(context)
                                          .text('provide_name_to_save_address'),
                                      context);
                                  return;
                                }

                                setState(() {
                                  _showSpinner = true;
                                });

                                widget.am.unitNo = _detail;
                                widget.am.note = _note;
                                widget.am.zip = _zip;

                                if (widget.currentLocationMode) {
                                  FoodOrderModel().setDeliverAddress(widget.am);
                                  Navigator.pop(context, 'selected');
                                  return;
                                }

                                var param = {
                                  "addressName": _name,
                                  "addressFull": widget.am.fullAddress,
                                  // "addressCustom": _detail,
                                  "addressUnit": _detail,
                                  "addressStreet": widget.am.street,
                                  "addressZip": widget.am.zip,
                                  "addressCity": widget.am.city,
                                  "addressState": widget.am.state,
                                  "addressLat": widget.am.lat,
                                  "addressLng": widget.am.lng,
                                  "addressNote": _note
                                };

                                if (User().getAuthToken() != null) {
                                  await UserNetworking.saveAddress(
                                      param, widget.adderssId);
                                } else {
                                  FoodOrderModel().setOfflineAddress(param);
                                  // param
                                }

                                FoodOrderModel().setDeliverAddress(widget.am);
                                Navigator.pop(context, 'saved');
                              },
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getMap() {
    return huaweiMap.HuaweiMap(
      gestureRecognizers: Set()
        ..add(Factory<PanGestureRecognizer>(
                () => PanGestureRecognizer()))
        ..add(Factory<ScaleGestureRecognizer>(
                () => ScaleGestureRecognizer()))
        ..add(Factory<TapGestureRecognizer>(
                () => TapGestureRecognizer()))
        ..add(Factory<VerticalDragGestureRecognizer>(
                () => VerticalDragGestureRecognizer())),
      zoomControlsEnabled: false,
      polygons: _huaweiPolygons,
      initialCameraPosition: huaweiMap.CameraPosition(
        target: _huaweiDroppin,
        zoom: 15,
      ),
      onCameraMove: ((_position) {
        if (_preventDrag) return;
        // widget.am.fullAddress = 'Pinned Location';
        widget.am.state = '';
        widget.am.street = '';
        widget.am.zip = '';
        widget.am.buildingName = '';
        widget.am.city = '';
        widget.am.unitNo = '';
        widget.am.lat =
            _position.target.lat.toString();
        widget.am.lng =
            _position.target.lng.toString();
        _huaweiDroppin = huaweiMap.LatLng(_position.target.lat,
            _position.target.lng);
        // setState(() {});
         print("widget.am.lat  ${widget.am.lat } ${_position.target.lng}");
      }),
      // markers: [
      //   Marker(
      //       markerId: MarkerId('SomeId'),
      //       position: _droppin,
      //       draggable: true,
      //       onDragEnd: (newPosition) {
      //         print(
      //             'new position ${newPosition.latitude}, ${newPosition.longitude}');
      //         // _markerLocationChanged(newPosition);
      //       })
      // ].toSet(),
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
    );
//    if (await FlutterHmsGmsAvailability.isHmsAvailable) {
//      return huaweiMap.HuaweiMap(
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
//        polygons: _huaweiPolygons,
//        initialCameraPosition: huaweiMap.CameraPosition(
//          target: _huaweiDroppin,
//          zoom: 15,
//        ),
//        onCameraMove: ((_position) {
//          if (_preventDrag) return;
//          // widget.am.fullAddress = 'Pinned Location';
//          widget.am.state = '';
//          widget.am.street = '';
//          widget.am.zip = '';
//          widget.am.buildingName = '';
//          widget.am.city = '';
//          widget.am.unitNo = '';
//          widget.am.lat =
//              _position.target.lat.toString();
//          widget.am.lng =
//              _position.target.lng.toString();
//          _droppin = LatLng(_position.target.lat,
//              _position.target.lng);
//          // setState(() {});
//          // print(widget.am.lat);
//        }),
//        // markers: [
//        //   Marker(
//        //       markerId: MarkerId('SomeId'),
//        //       position: _droppin,
//        //       draggable: true,
//        //       onDragEnd: (newPosition) {
//        //         print(
//        //             'new position ${newPosition.latitude}, ${newPosition.longitude}');
//        //         // _markerLocationChanged(newPosition);
//        //       })
//        // ].toSet(),
//        myLocationEnabled: false,
//        myLocationButtonEnabled: false,
//      );
//    } else {
//      return GoogleMap(
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
//        polygons: _polygons,
//        initialCameraPosition: CameraPosition(
//          target: _droppin,
//          zoom: 15,
//        ),
//        onCameraMove: ((_position) {
//          if (_preventDrag) return;
//          // widget.am.fullAddress = 'Pinned Location';
//          widget.am.state = '';
//          widget.am.street = '';
//          widget.am.zip = '';
//          widget.am.buildingName = '';
//          widget.am.city = '';
//          widget.am.unitNo = '';
//          widget.am.lat =
//              _position.target.latitude.toString();
//          widget.am.lng =
//              _position.target.longitude.toString();
//          _droppin = LatLng(_position.target.latitude,
//              _position.target.longitude);
//          // setState(() {});
//          // print(widget.am.lat);
//        }),
//        // markers: [
//        //   Marker(
//        //       markerId: MarkerId('SomeId'),
//        //       position: _droppin,
//        //       draggable: true,
//        //       onDragEnd: (newPosition) {
//        //         print(
//        //             'new position ${newPosition.latitude}, ${newPosition.longitude}');
//        //         // _markerLocationChanged(newPosition);
//        //       })
//        // ].toSet(),
//        myLocationEnabled: false,
//        myLocationButtonEnabled: false,
//      );
//    }
  }
}
