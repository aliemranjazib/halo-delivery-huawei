// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:haloapp/components/custom_flushbar.dart';
// import 'package:haloapp/models/address_model.dart';
// import 'package:haloapp/models/food_history_model.dart';
// import 'package:haloapp/models/food_order_model.dart';
// import 'package:haloapp/models/google_places_component_model.dart';
// import 'package:haloapp/models/shop_model.dart';
// import 'package:haloapp/models/user_model.dart';
// import 'package:haloapp/networkings/food_history_networking.dart';
// import 'package:haloapp/networkings/food_networking.dart';
// import 'package:haloapp/screens/food/food_delivery_address_page.dart';
// import 'package:haloapp/screens/food/food_rating_popup.dart';
// import 'package:haloapp/screens/food/shop_menu_page.dart';
// import 'package:haloapp/screens/general/confirmation_dialog.dart';
// import 'package:haloapp/screens/general/custom_alert_dialog.dart';
// import 'package:haloapp/screens/general/find_address_page.dart';
// import 'package:haloapp/utils/app_translations/app_translations.dart';
// import 'package:haloapp/utils/constants/api_urls.dart';
// import 'package:haloapp/utils/constants/custom_colors.dart';
// import 'package:haloapp/utils/constants/fonts.dart';
// import 'package:haloapp/utils/constants/styles.dart';
// import 'package:haloapp/utils/debouncer.dart';
// import 'package:haloapp/utils/services/google_map_places_service.dart';
// import 'package:haloapp/utils/services/location_service.dart';
// import 'package:haloapp/utils/services/pop_with_result_service.dart';
// import 'package:haloapp/components/model_progress_hud.dart';

// class FoodMainPage extends StatefulWidget {
//   static const String id = 'foodMainPage';

//   @override
//   _FoodMainPageState createState() => _FoodMainPageState();
// }

// class _FoodMainPageState extends State<FoodMainPage> {
//   bool _showSpinner = true;
//   AddressModel _currentAddress = FoodOrderModel().getDeliveryAddress();
//   List<ShopModel> _shops = [];
//   List<ShopModel> _allShops = [];
//   String _selectedCategory;
//   final _debouncer = Debouncer(delay: Duration(milliseconds: 500));

//   @override
//   void initState() {
//     super.initState();

//     if (_currentAddress?.lat == null)
//       return setState(() {
//         _showSpinner = false;
//       });

//     Future.wait([
//       // _getUserLocation(),
//       initAddress(),
//       checkCompletedOrderToRate()
//     ]).then((value) {
//       setState(() {
//         _showSpinner = false;
//       });
//     });
//   }

//   Future<void> _getUserLocation() async {
//     setState(() {
//       _showSpinner = true;
//     });
//     print('getting location');
//     Position position = await LocationService.getLastKnownLocation();

//     bool locationPermissionGranted = await LocationService().checkPermission();
//     if (!locationPermissionGranted) {
//       showSimpleFlushBar(
//           AppTranslations.of(context)
//               .text('please_enable_location_service_in_phone_settings'),
//           context);

//       setState(() {
//         _showSpinner = false;
//       });
//       return;
//     }

//     position = await LocationService.getLastKnownLocation();
//     print('got location');

//     if (position != null) {
//       GooglePlacesComponentModel component = GooglePlacesComponentModel();
//       component.lat = position.latitude;
//       component.lng = position.longitude;
//       storeAddressDetails(component, 'Current Location');
//       await getNearbyShopList();
//       setState(() {
//         _showSpinner = false;
//       });
//     }

//     return;
//   }

//   void storeAddressDetails(
//       GooglePlacesComponentModel component, String fullAddress) {
//     String street = '';
//     if (component.street != null && component.street != '') {
//       street = component.street;
//     }

//     if (component.route != null && component.route != '') {
//       if (street != null && street != '') {
//         street = street + ', ' + component.route;
//       } else {
//         street = component.route;
//       }
//     }

//     AddressModel address = AddressModel(
//       lat: component.lat.toString(),
//       lng: component.lng.toString(),
//       fullAddress: fullAddress,
//       zip: component.zip,
//       city: component.city,
//       state: component.state,
//       street: street,
//     );
//     _currentAddress = address;

//     FoodOrderModel().setDeliverAddress(address);
//     print(FoodOrderModel().getDeliveryAddress().street);
//   }

//   Future<void> getNearbyShopList([keyword]) async {
//     print('### ' + FoodOrderModel().foodOption.shopType);
//     print('getSHOP at:');
//     print(_currentAddress.lat);
//     print(_currentAddress.lng);
//     Map<String, dynamic> params = {
//       "apiKey": APIUrls().getFoodApiKey(),
//       "data": {
//         "lat": _currentAddress.lat,
//         "lng": _currentAddress.lng,
//         "shopType": FoodOrderModel().foodOption.shopType
//       }
//     };
//     if (keyword != null) params['data']['keyword'] = keyword;
//     print(params);

//     // setState(() {
//     //   _showSpinner = true;
//     // });

//     try {
//       var data = await FoodNetworking().getNearbyShops(params);
//       print("pppp $data");
//       // if(data.length == 0) return;
//       // if(data.length <= 0) return;
//       setState(() {
//         _shops = data;
//         _allShops = data;
//         print("www  : ${_shops[0].shopDeliveryFee}");
//       });
//     } catch (e) {
//       print(e.toString());
//       showSimpleFlushBar(e.toString(), context);
//     } finally {
//       setState(() {
//         _showSpinner = false;
//       });
//     }
//   }

//   Future<void> listOnRefresh() async {
//     _selectedCategory = null;
//     getNearbyShopList();
//   }

//   Future<void> initAddress() async {
//     await getNearbyShopList();
//   }

//   void editAddressOld() {
//     print("_currentAddress ${_currentAddress}");
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => FoodDeliveryAddressPage(
//           address: _currentAddress,
//         ),
//       ),
//     ).then((value) {
//       if (value != null && value == 'refresh') {
//         print('refresh');
//         AddressModel orderAddress = FoodOrderModel().getDeliveryAddress();

//         setState(() {
//           _currentAddress = AddressModel(
//             lat: orderAddress.lat,
//             lng: orderAddress.lng,
//             fullAddress: orderAddress.fullAddress,
//             zip: orderAddress.zip,
//             city: orderAddress.city,
//             state: orderAddress.state,
//             street: orderAddress.street,
//             buildingName: orderAddress.buildingName,
//             unitNo: orderAddress.unitNo,
//           );

//           getNearbyShopList();
//         });
//       }
//     });
//   }

//   Future<void> checkCompletedOrderToRate() async {
//     if (User().getAuthToken() == null) return;
//     setState(() {
//       _showSpinner = true;
//     });

//     try {
//       var data = await FoodHistoryNetworking().getFoodOrderHistory({});

//       setState(() {
//         if (data is List<FoodHistoryModel>) {
//           for (FoodHistoryModel history in data) {
//             if (history.orderStatus == 'Delivered' &&
//                 history.orderRating == '0') {
//               showGoToRateDialog(history);
//               return;
//             }
//           }
//         }
//       });
//     } catch (e) {
//       print(e.toString());
//       if (mounted) showSimpleFlushBar(e.toString(), context);
//     } finally {
//       // if (mounted)
//       setState(() {
//         _showSpinner = false;
//       });
//     }

//     return;
//   }

//   void showGoToRateDialog(FoodHistoryModel history) {
//     showDialog(
//         context: context,
//         builder: (context) => ConfirmationDialog(
//               title: AppTranslations.of(context).text('rate_our_service'),
//               message: AppTranslations.of(context)
//                   .text('there_is_completed_booking_to_rate'),
//             )).then((value) {
//       if (value != null && value == 'confirm') {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => FoodRatingPage(
//               history: history,
//             ),
//           ),
//         );
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           titleSpacing: 0,

//           // leadingWidth: 35,
//           automaticallyImplyLeading: false,
//           leading: Container(
//             // width: 50,
//             child: IconButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               icon: arrowBack,
//             ),
//           ),
//           title: Text(AppTranslations.of(context)
//               .text(FoodOrderModel().foodOption.searchName)),
//           // title: GestureDetector(
//           //   onTap: () async {
//           //     await Navigator.pushNamed(context, FindAddressPage.id,
//           //         arguments: {'popMode': true});
//           //     FoodOrderModel().clearFoodOrderData();
//           //     initAddress();
//           //     // editAddress();
//           //   },
//           //   behavior: HitTestBehavior.translucent,
//           //   child: Container(
//           //     padding: EdgeInsets.only(right: 10),
//           //     decoration: BoxDecoration(
//           //         // border: Border.all(color: Colors.grey),

//           //         borderRadius: BorderRadius.circular(5.0)),
//           //     // padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
//           //     child: Row(
//           //       children: <Widget>[
//           //         Expanded(
//           //           child: Column(
//           //             crossAxisAlignment: CrossAxisAlignment.stretch,
//           //             children: <Widget>[
//           //               Text(
//           //                 AppTranslations.of(context).text('deliver_to'),
//           //                 style:
//           //                     TextStyle(fontFamily: poppinsBold, fontSize: 13),
//           //               ),
//           //               Text(
//           //                 (_currentAddress != null)
//           //                     ? _currentAddress.fullAddress
//           //                     : 'Please Enter PickUp Address',
//           //                 style: TextStyle(
//           //                     fontFamily: poppinsMedium, fontSize: 15),
//           //                 overflow: TextOverflow.ellipsis,
//           //               )
//           //             ],
//           //           ),
//           //         ),
//           //         SizedBox(width: 10.0),
//           //         Icon(Icons.arrow_drop_down)
//           //       ],
//           //     ),
//           //   ),
//           // ),
//         ),
//         body: ModalProgressHUD(
//           inAsyncCall: _showSpinner,
//           child: SafeArea(
//             child: Container(
//               padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
//               color: Colors.white,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: <Widget>[
//                   // SizedBox(height: 10.0),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 4.0),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           AppTranslations.of(context).text('all_restaurants'),
//                           style: kTitleTextStyle.copyWith(fontSize: 16),
//                         ),
//                         Container(
//                           width: 100,
//                           child: DropdownButton<String>(
//                             hint: Text(
//                               'Category',
//                               style: TextStyle(
//                                 fontSize: 15,
//                                 color: kColorRed,
//                               ),
//                             ),
//                             isExpanded: true,
//                             value: _selectedCategory,
//                             icon: Icon(
//                               Icons.expand_more,
//                               color: kColorRed,
//                             ),
//                             iconSize: 24,
//                             elevation: 16,
//                             style: TextStyle(
//                               fontSize: 16,
//                               color: kColorRed,
//                             ),
//                             underline: Container(
//                               height: 0,
//                               color: Colors.deepPurpleAccent,
//                             ),
//                             onChanged: (String newValue) {
//                               print(newValue);
//                               if (newValue == "All")
//                                 _shops = _allShops;
//                               else
//                                 _shops = _allShops
//                                     .where((e) => e.category.contains(newValue))
//                                     .toList();
//                               setState(() {
//                                 _shops = _shops;
//                                 _selectedCategory = newValue;
//                               });
//                             },
//                             items: ((_allShops
//                                     .fold<List<String>>(
//                                         ["All"],
//                                         (prev, element) =>
//                                             [...prev, ...element.category])
//                                     .toSet()
//                                     .toList())
//                                   ..sort())
//                                 .map<DropdownMenuItem<String>>((String value) {
//                               return DropdownMenuItem<String>(
//                                 value: value,
//                                 child: Text(value,
//                                     overflow: TextOverflow.ellipsis),
//                               );
//                             }).toList(),
//                           ),
//                         )
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: 3.0),
//                   TextField(
//                     onChanged: (key) {
//                       _debouncer.run(() => getNearbyShopList(key));
//                     },
//                     // obscureText: true,
//                     decoration: InputDecoration(
//                         isDense: true,
//                         contentPadding: EdgeInsets.zero,
//                         prefixIcon: Icon(Icons.search),
//                         filled: true,
//                         fillColor: Colors.grey[100],
//                         border: OutlineInputBorder(
//                             borderSide: BorderSide.none,
//                             borderRadius:
//                                 BorderRadius.all(Radius.circular(100.0))),
//                         hintText: 'Search Restaurant / Food',
//                         hintStyle: TextStyle(fontSize: 14)),
//                   ),
//                   SizedBox(height: 5.0),
//                   Expanded(
//                     child: (_shops.length == 0)
//                         ? Container(
//                             padding: EdgeInsets.symmetric(horizontal: 30.0),
//                             child: Center(
//                               child: Text(
//                                 AppTranslations.of(context).text(
//                                     'there_is_no_restaurant_nearby_please_try_another_address'),
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                     fontFamily: poppinsItalic, fontSize: 16),
//                               ),
//                             ),
//                           )
//                         : RefreshIndicator(
//                             onRefresh: listOnRefresh,
//                             child: ListView.separated(
//                               itemBuilder: (BuildContext context, int index) {
//                                 ShopModel shop = _shops[index];

//                                 return GestureDetector(
//                                   onTap: () {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) => ShopMenuPage(
//                                           shopUniqueCode: shop.uniqueCode,
//                                           shopInfo: shop,
//                                         ),
//                                       ),
//                                     ).then((value) {
//                                       if (value is PopWithResults) {
//                                         PopWithResults popResult = value;
//                                         if (popResult.toPage == 'foodMain') {
//                                           // TODO: pop current order banner and refresh
//                                           print('pop banner');
//                                           getNearbyShopList();
//                                         } else {
//                                           // pop to previous page
//                                           Navigator.of(context).pop(value);
//                                         }
//                                       }
//                                     });
//                                   },
//                                   behavior: HitTestBehavior.translucent,
//                                   child: Container(
//                                     // color: Colors.black,
//                                     padding:
//                                         EdgeInsets.symmetric(vertical: 10.0),
//                                     child: Row(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: <Widget>[
//                                         Stack(
//                                           children: <Widget>[
//                                             CachedNetworkImage(
//                                               // fit: BoxFit.fitWidth,
//                                               imageUrl: shop.logoUrl,
//                                               placeholder: (context, url) =>
//                                                   Image.asset(
//                                                 "images/haloje_placeholder.png",
//                                                 width: 100,
//                                                 height: 100,
//                                               ),
//                                               errorWidget:
//                                                   (context, url, error) =>
//                                                       Icon(Icons.error),
//                                               width: 100,
//                                               height: 100,
//                                             ),
// //                                    Image.network(
// //                                      shop.logoUrl,
// //                                      width: 120,
// //                                      height: 120,
// //                                    ),
//                                             (shop.featuresStatus)
//                                                 ? Positioned(
//                                                     top: 8.0,
//                                                     child: Container(
//                                                       padding:
//                                                           EdgeInsets.symmetric(
//                                                               vertical: 3.0,
//                                                               horizontal: 8.0),
//                                                       color: kColorLightRed,
//                                                       child: Text(
//                                                         AppTranslations.of(
//                                                                 context)
//                                                             .text('featured')
//                                                             .toUpperCase(),
//                                                         style: TextStyle(
//                                                             fontFamily:
//                                                                 poppinsMedium,
//                                                             fontSize: 11,
//                                                             color:
//                                                                 Colors.white),
//                                                       ),
//                                                     ),
//                                                   )
//                                                 : Container(),
//                                             (shop.shopStatus == 'open')
//                                                 ? Container()
//                                                 : Positioned.fill(
//                                                     child: Container(
//                                                       color: Colors.white
//                                                           .withOpacity(0.6),
//                                                     ),
//                                                   )
//                                           ],
//                                         ),
//                                         SizedBox(width: 10.0),
//                                         Expanded(
//                                           child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.stretch,
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.start,
//                                             children: <Widget>[
//                                               Text(
//                                                 shop.shopName,
//                                                 overflow: TextOverflow.ellipsis,
//                                                 style: TextStyle(
//                                                     fontFamily: poppinsMedium,
//                                                     fontSize: 15),
//                                               ),
//                                               Text(
//                                                 '${shop.category.join(', ')}',
//                                                 style: kSmallLabelTextStyle
//                                                     .copyWith(
//                                                         color: Colors.grey),
//                                               ),
//                                               SizedBox(height: 5.0),
//                                               Row(
//                                                 children: <Widget>[
//                                                   Icon(
//                                                     Icons.star,
//                                                     color: kColorRed,
//                                                     size: 15,
//                                                   ),
//                                                   SizedBox(width: 3.0),
//                                                   Text(
//                                                     '${shop.rating} (${shop.totalOrder})',
//                                                     style: kSmallLabelTextStyle,
//                                                   ),
//                                                   SizedBox(width: 8.0),
//                                                   Text(
//                                                     '${(shop.distance).toStringAsFixed(1)} km',
//                                                     style: kSmallLabelTextStyle,
//                                                   ),
//                                                   SizedBox(width: 8.0),
//                                                   // Text(
//                                                   //   '${shop.duration} mins',
//                                                   //   style: kSmallLabelTextStyle,
//                                                   // ),
//                                                 ],
//                                               ),
//                                               SizedBox(
//                                                   width: 10.0, height: 5.0),
//                                               Row(
//                                                 children: [
//                                                   if (shop.shopStatus != 'open')
//                                                     Container(
//                                                       color: kColorRed,
//                                                       padding:
//                                                           EdgeInsets.symmetric(
//                                                               vertical: 3.0,
//                                                               horizontal: 6.0),
//                                                       child: Text(
//                                                         shop.shopClosePreOrder
//                                                             ? "Order for later"
//                                                             : AppTranslations
//                                                                     .of(context)
//                                                                 .text('closed'),
//                                                         style:
//                                                             kSmallLabelTextStyle
//                                                                 .copyWith(
//                                                                     color: Colors
//                                                                         .white),
//                                                       ),
//                                                     ),
//                                                   SizedBox(width: 5.0),
//                                                   Text(
//                                                     "Min Order: RM " +
//                                                         shop.shopMinAmount,
//                                                     style: kSmallLabelTextStyle,
//                                                   ),
//                                                 ],
//                                               ),
//                                               SizedBox(height: 5.0),
//                                               (shop.freeDeliveryStatus)
//                                                   ? Text(
//                                                       AppTranslations.of(
//                                                               context)
//                                                           .text(
//                                                               'free_delivery'),
//                                                       style: TextStyle(
//                                                         fontFamily:
//                                                             poppinsMedium,
//                                                         fontSize: 14,
//                                                       ),
//                                                     )
//                                                   : Container(),
//                                               (shop.shopStatus == 'open')
//                                                   ? Container()
//                                                   : Column(
//                                                       crossAxisAlignment:
//                                                           CrossAxisAlignment
//                                                               .start,
//                                                       children: <Widget>[
//                                                         SizedBox(height: 10.0),
//                                                         Row(
//                                                           children: <Widget>[
//                                                             (shop.closeShopText !=
//                                                                     '')
//                                                                 ? Text(
//                                                                     shop.closeShopText,
//                                                                     style:
//                                                                         kSmallLabelTextStyle,
//                                                                   )
//                                                                 : Container()
//                                                           ],
//                                                         ),
//                                                       ],
//                                                     ),
//                                               SizedBox(height: 5.0),
//                                               (shop.shopPromo == "1")
//                                                   ? Wrap(
//                                                       children: [
//                                                         Container(
//                                                           color: kColorRed,
//                                                           padding: EdgeInsets
//                                                               .symmetric(
//                                                                   vertical: 3.0,
//                                                                   horizontal:
//                                                                       6.0),
//                                                           child: Text(
//                                                             "${AppTranslations.of(context).text("promo_label")}",
//                                                             style: kSmallLabelTextStyle
//                                                                 .copyWith(
//                                                                     color: Colors
//                                                                         .white),
//                                                           ),
//                                                         )
//                                                       ],
//                                                     )
//                                                   : SizedBox.shrink(),
//                                             ],
//                                           ),
//                                         )
//                                       ],
//                                     ),
//                                   ),
//                                 );
//                               },
//                               separatorBuilder: (context, index) {
//                                 return Divider(
//                                   color: Colors.grey,
//                                 );
//                               },
//                               itemCount: _shops.length,
//                               scrollDirection: Axis.vertical,
//                               shrinkWrap: true,
//                             ),
//                           ),
//                   )
//                 ],
//               ),
//             ),
//           ),
//         ));
//   }
// }
