// import 'package:flutter/material.dart';
// // import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:haloapp/models/shop_model.dart';
// import 'package:flutter_google_places/flutter_google_places.dart';
// import 'package:google_maps_webservice/places.dart';
// import 'package:haloapp/utils/app_translations/app_translations.dart';
// import 'package:haloapp/utils/constants/api_urls.dart';
// import 'package:haloapp/utils/constants/custom_colors.dart';
// import 'package:haloapp/utils/constants/fonts.dart';
// import 'package:haloapp/utils/constants/styles.dart';
// import 'package:haloapp/utils/services/datetime_formatter.dart';
// import 'package:huawei_map/map.dart' as huaweiMap;

// class ShopDetailsPage extends StatefulWidget {
//   ShopDetailsPage({@required this.shop});

//   final ShopModel shop;

//   @override
//   _ShopDetailsPageState createState() => _ShopDetailsPageState();
// }

// class _ShopDetailsPageState extends State<ShopDetailsPage> {
//   GoogleMapsPlaces _places =
//       GoogleMapsPlaces(apiKey: APIUrls().getGoogleAPIKey());
//   // GoogleMapController mapController;
//   // LatLng _initialPosition = LatLng(0, 0);
//   // BitmapDescriptor markerIcon;
//   // Set<Marker> _markers = {};

//   //Huawei Map
//   huaweiMap.HuaweiMapController huaweiMapController;
//   huaweiMap.LatLng _huaweiInitialPosition = huaweiMap.LatLng(0, 0);
//   huaweiMap.BitmapDescriptor huaweiMarkerIcon;
//   Set<huaweiMap.Marker> _huaweiMarkers = {};

//   List<String> _days = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];

//   @override
//   void initState() {
//     super.initState();

//     print("GGG: " + widget.shop.lat + " " + widget.shop.lng);
//     // _initialPosition =
//     //     LatLng(double.parse(widget.shop.lat), double.parse(widget.shop.lng));

//     // _huaweiInitialPosition = huaweiMap.LatLng(double.parse(widget.shop.lat), double.parse(widget.shop.lng));
//     addMarker();
//   }

//   // void _onMapCreated(GoogleMapController controller) {
//   //   mapController = controller;
//   // }

//   void _onHuaweiMapCreated(huaweiMap.HuaweiMapController controller) {
//     huaweiMapController = controller;
//   }

//   void setupIcons() {
//     ImageConfiguration imageConfig = ImageConfiguration(size: Size(25, 25));

//     // BitmapDescriptor.fromAssetImage(imageConfig, 'images/pin_red.png')
//     //     .then((value) => markerIcon = value);

//     huaweiMap.BitmapDescriptor.fromAssetImage(imageConfig, 'images/pin_red.png')
//         .then((value) => huaweiMarkerIcon = value);
//   }

//   void addMarker() async {
//     _huaweiMarkers.clear();

//     final marker = huaweiMap.Marker(
//         markerId: huaweiMap.MarkerId('marker'),
//         position: _huaweiInitialPosition);

//     _huaweiMarkers.add(marker);
// //    if (await FlutterHmsGmsAvailability.isHmsAvailable) {
// //      _huaweiMarkers.clear();
// //
// //      final marker =
// //      huaweiMap.Marker(markerId: huaweiMap.MarkerId('marker'), position: _huaweiInitialPosition);
// //
// //      _huaweiMarkers.add(marker);
// //    }else{
// //      _markers.clear();
// //
// //      final marker =
// //      Marker(markerId: MarkerId('marker'), position: _initialPosition);
// //
// //      _markers.add(marker);
// //    }
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     Widget _openingDayTime() {
//       if (widget.shop.shopOpenType == 'allDay') {
//         return Row(
//           children: <Widget>[
//             Text(
//               AppTranslations.of(context).text('all_days'),
//               style: TextStyle(fontFamily: poppinsRegular, fontSize: 15),
//             ),
//             SizedBox(width: 20.0),
//             Text(
//               '${DatetimeFormatter().getFormattedTimeStr(format: 'hh:mm a', time: widget.shop.shopOpenTimeRange['From'])} - ${DatetimeFormatter().getFormattedTimeStr(format: 'hh:mm a', time: widget.shop.shopOpenTimeRange['To'])}',
//               style: TextStyle(fontFamily: poppinsRegular, fontSize: 15),
//             )
//           ],
//         );
//       } else if (widget.shop.shopOpenType == 'specificDay') {
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: List.generate(_days.length, (index) {
//             String day = _days[index];

//             return (widget.shop.shopOpenTimeRange[day] != null)
//                 ? OpeningHrsWidget(
//                     day: day,
//                     fromTime: widget.shop.shopOpenTimeRange[day]['From'],
//                     toTime: widget.shop.shopOpenTimeRange[day]['To'])
//                 : Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: <Widget>[
//                       Text(
//                         AppTranslations.of(context).text('$day'),
//                         style:
//                             TextStyle(fontFamily: poppinsRegular, fontSize: 15),
//                       ),
//                       SizedBox(width: 20.0),
//                       Text(
//                         'Rest',
//                         style:
//                             TextStyle(fontFamily: poppinsRegular, fontSize: 15),
//                       )
//                     ],
//                   );
//           }),
//         );
//       } else if (widget.shop.shopOpenType == 'allDayWithRest' &&
//           widget.shop.shopOpenTimeRange is List<dynamic>) {
//         return Row(
//           children: <Widget>[
//             Text(
//               AppTranslations.of(context).text('all_days'),
//               style: TextStyle(fontFamily: poppinsRegular, fontSize: 15),
//             ),
//             SizedBox(width: 20.0),
//             Column(
//               children:
//                   List.generate(widget.shop.shopOpenTimeRange.length, (index) {
//                 Map<String, dynamic> openTimes =
//                     widget.shop.shopOpenTimeRange[index];
//                 return Text(
//                   '${DatetimeFormatter().getFormattedTimeStr(format: 'hh:mm a', time: openTimes['From'])} - ${DatetimeFormatter().getFormattedTimeStr(format: 'hh:mm a', time: openTimes['To'])}',
//                   style: TextStyle(fontFamily: poppinsRegular, fontSize: 15),
//                 );
//               }),
//             )
//           ],
//         );
//       } else if (widget.shop.shopOpenType == 'specificDayWithRest') {
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: List.generate(_days.length, (index) {
//             String day = _days[index];
//             List<dynamic> dayOpenTimes = widget.shop.shopOpenTimeRange[day];

//             return (dayOpenTimes != null)
//                 ? Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: <Widget>[
//                       Text(
//                         AppTranslations.of(context).text('$day'),
//                         style:
//                             TextStyle(fontFamily: poppinsRegular, fontSize: 15),
//                       ),
//                       SizedBox(width: 20.0),
//                       Column(
//                         children: List.generate(dayOpenTimes.length, (index) {
//                           Map<String, dynamic> openTimes = dayOpenTimes[index];

//                           return Text(
//                             '${DatetimeFormatter().getFormattedTimeStr(format: 'hh:mm a', time: openTimes['From'])} - ${DatetimeFormatter().getFormattedTimeStr(format: 'hh:mm a', time: openTimes['To'])}',
//                             style: TextStyle(
//                                 fontFamily: poppinsRegular, fontSize: 15),
//                           );
//                         }),
//                       )
//                     ],
//                   )
//                 : Container();
//           }),
//         );
//       }
//     }

//     return Scaffold(
//       appBar: AppBar(),
//       body: SafeArea(
//         child: Container(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: <Widget>[
//               Container(height: 250, child: getMap()
// //                FutureBuilder(
// //                  builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot){
// //                    if(snapshot.connectionState == ConnectionState.done){
// //                      return snapshot.data;
// //                    }
// //
// //                    return Container();
// //                  },
// //                  future: getMap(),
// //                )
//                   ),
//               Container(
//                 padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: <Widget>[
//                     Text(
//                       widget.shop.shopName,
//                       style:
//                           TextStyle(fontFamily: poppinsSemiBold, fontSize: 18),
//                     ),
//                     Text(
//                       '${widget.shop.category.join(', ')}',
//                       style: kSmallLabelTextStyle.copyWith(color: Colors.grey),
//                     ),
//                     SizedBox(height: 5.0),
//                     Row(
//                       children: <Widget>[
//                         Icon(
//                           Icons.star,
//                           color: kColorRed,
//                           size: 15,
//                         ),
//                         SizedBox(width: 3.0),
//                         Text(
//                           '${widget.shop.rating}',
//                           style: kSmallLabelTextStyle,
//                         ),
//                       ],
//                     ),
//                     (widget.shop.shopPromo == "1")
//                         ? Wrap(
//                             children: [
//                               Container(
//                                 margin: EdgeInsets.only(top: 5),
//                                 color: kColorRed,
//                                 padding: EdgeInsets.symmetric(
//                                     vertical: 3.0, horizontal: 6.0),
//                                 child: Text(
//                                   "${AppTranslations.of(context).text("promo_label")}",
//                                   style: kSmallLabelTextStyle.copyWith(
//                                       color: Colors.white),
//                                 ),
//                               )
//                             ],
//                           )
//                         : SizedBox.shrink(),
//                     SizedBox(height: 15.0),
//                     Text(
//                       '${AppTranslations.of(context).text('address')}:  ${widget.shop.fullAddress}',
//                       style:
//                           TextStyle(fontFamily: poppinsRegular, fontSize: 14),
//                     ),
//                     SizedBox(height: 25.0),
//                     Text(
//                       AppTranslations.of(context).text('opening_hours'),
//                       style:
//                           TextStyle(fontFamily: poppinsRegular, fontSize: 14),
//                     ),
//                     SizedBox(height: 5.0),
//                     _openingDayTime(),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget getMap() {
// //    if (await FlutterHmsGmsAvailability.isHmsAvailable) {
// //      return huaweiMap.HuaweiMap(
// //        onMapCreated: _onHuaweiMapCreated,
// //        initialCameraPosition: huaweiMap.CameraPosition(
// //          target: _huaweiInitialPosition,
// //          zoom: 18,
// //        ),
// //        markers: _huaweiMarkers,
// //        myLocationEnabled: false,
// //        myLocationButtonEnabled: false,
// //      );
// //    }else{
// //
// //      return GoogleMap(
// //        onMapCreated: _onMapCreated,
// //        initialCameraPosition: CameraPosition(
// //          target: _initialPosition,
// //          zoom: 18,
// //        ),
// //        markers: _markers,
// //        myLocationEnabled: false,
// //        myLocationButtonEnabled: false,
// //      );
// //    }
//     return huaweiMap.HuaweiMap(
//       onMapCreated: _onHuaweiMapCreated,
//       initialCameraPosition: huaweiMap.CameraPosition(
//         target: _huaweiInitialPosition,
//         zoom: 18,
//       ),
//       markers: _huaweiMarkers,
//       myLocationEnabled: false,
//       myLocationButtonEnabled: false,
//     );
//   }
// }

// class OpeningHrsWidget extends StatelessWidget {
//   const OpeningHrsWidget({
//     Key key,
//     @required this.day,
//     @required this.fromTime,
//     @required this.toTime,
//   }) : super(key: key);

//   final String day;
//   final String fromTime;
//   final String toTime;

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: <Widget>[
//         Text(
//           AppTranslations.of(context).text('$day'),
//           style: TextStyle(fontFamily: poppinsRegular, fontSize: 15),
//         ),
//         SizedBox(width: 20.0),
//         Text(
//           '${DatetimeFormatter().getFormattedTimeStr(format: 'HH:mm', time: fromTime)} - ${DatetimeFormatter().getFormattedTimeStr(format: 'HH:mm', time: toTime)}',
//           style: TextStyle(fontFamily: poppinsRegular, fontSize: 15),
//         )
//       ],
//     );
//   }
// }
