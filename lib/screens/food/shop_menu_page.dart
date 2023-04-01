// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:haloapp/components/action_button.dart';
// import 'package:haloapp/components/custom_flushbar.dart';
// import 'package:haloapp/models/address_model.dart';
// import 'package:haloapp/models/food_model.dart';
// import 'package:haloapp/models/food_order_model.dart';
// import 'package:haloapp/models/food_variant_model.dart';
// import 'package:haloapp/models/shop_menu_model.dart';
// import 'package:haloapp/models/shop_model.dart';
// import 'package:haloapp/models/user_model.dart';
// import 'package:haloapp/networkings/food_networking.dart';
// import 'package:haloapp/screens/auth/login_page.dart';
// import 'package:haloapp/screens/food/food_cart_page.dart';
// import 'package:haloapp/screens/food/food_variant_details_popup.dart';
// import 'package:haloapp/screens/food/shop_details_page.dart';
// import 'package:haloapp/utils/app_translations/app_translations.dart';
// import 'package:haloapp/utils/constants/api_urls.dart';
// import 'package:haloapp/utils/constants/custom_colors.dart';
// import 'package:haloapp/utils/constants/fonts.dart';
// import 'package:haloapp/utils/constants/styles.dart';
// import 'package:haloapp/utils/services/pop_with_result_service.dart';
// import 'package:haloapp/components/model_progress_hud.dart';
// import 'package:rect_getter/rect_getter.dart';
// import 'package:scroll_to_index/scroll_to_index.dart';

// class ShopMenuPage extends StatefulWidget {
//   ShopMenuPage({@required this.shopUniqueCode, this.shopInfo});

//   final String shopUniqueCode;
//   final ShopModel shopInfo;

//   @override
//   _ShopMenuPageState createState() => _ShopMenuPageState();
// }

// class _ShopMenuPageState extends State<ShopMenuPage>
//     with SingleTickerProviderStateMixin {
//   bool _showSpinner = true;
//   bool _allowOrderAfterShopClose = false;
//   bool _scrollDetection = false;
//   List<ShopMenuModel> _shopMenu = [];
//   TabController _tabController;
//   AutoScrollController _scrollController;
//   double _scrollOffset = 0;
//   int _currentScrollIndex = 0;

//   var _keys = {};
//   var listViewKey = RectGetter.createGlobalKey();

//   @override
//   void initState() {
//     super.initState();
//     _scrollController = AutoScrollController(
//       viewportBoundaryGetter: () =>
//           Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
//       axis: Axis.vertical,
//     )..addListener(() {
//         // if (!_scrollDetection) return;
//         //
//         // setState(() {
//         //   var index = _scrollController.currentTagIndexInViewport(
//         //       preferPosition: AutoScrollPosition.begin);
//         //   print("index ${index}");
//         //   print("_scrollController ${_scrollController.tagMap}");
//         //   //Temporary solve scrolling tab
//         //   bool isUseThreshold = _scrollController.tagMap.entries.length >= 2;
//         //   if (_currentScrollIndex != null && _currentScrollIndex != index) {
//         //     if(index!=null){
//         //       _currentScrollIndex = index;
//         //     }
//         //
//         //     if(isUseThreshold){
//         //       if (_currentScrollIndex - 2  >= 0)
//         //         _tabController.animateTo(_currentScrollIndex - 2,
//         //             duration: Duration(milliseconds: 400));
//         //     }else{
//         //       if (_currentScrollIndex >= 0)
//         //         _tabController.animateTo(_currentScrollIndex,
//         //             duration: Duration(milliseconds: 400));
//         //     }
//         //
//         //   }
//         //
//         //   _scrollOffset = _scrollController.offset;
//         // });
//       });
//     // _scrollController = ScrollController()..addListener(() {
//     //   setState(() {
//     //           _scrollOffset = _scrollController.offset;
//     //         });
//     //     // print("offset = ${_scrollController.offset}");
//     // });
//     // _tabController = TabController(vsync: this, length: data.shopMenu.length);
//     getShopDetails();
//   }

//   @override
//   void dispose() {
//     // TODO: implement dispose
//     _scrollController.dispose();
//     _tabController.dispose();
//     super.dispose();
//   }

//   void getShopDetails() async {
//     AddressModel orderAddress = FoodOrderModel().getDeliveryAddress();
//     Map<String, dynamic> params = {
//       "apiKey": APIUrls().getFoodApiKey(),
//       "data": {
//         "shopUniqueCode": widget.shopUniqueCode,
//         "lat": orderAddress.lat,
//         "lng": orderAddress.lng
//       }
//     };
//     print(params);

//     setState(() {
//       _showSpinner = true;
//     });

//     try {
//       var data = await FoodNetworking().getShopDetails(params);
//       _tabController = TabController(vsync: this, length: data.shopMenu.length);
//       _scrollDetection = true;
//       setState(() {
//         _shopMenu = data.shopMenu;
//         _allowOrderAfterShopClose = data.shopClosePreOrder;
//         _showSpinner = false;
//       });
//     } catch (e) {
//       print(e);
//       // print(e.toString());
//       // showSimpleFlushBar(e, context);
//     } finally {
//       setState(() {
//         _showSpinner = false;
//       });
//     }
//   }

//   _foodItemOnPressed(ShopMenuModel menu, FoodModel food) {
//     if (food.status &&
//         menu.categoryStatus &&
//         (widget.shopInfo.shopStatus == 'open' || _allowOrderAfterShopClose)) {
//       _proceedToFoodVariantsPage(food, null);
//     }

// //    if (food.status && widget.shopInfo.shopStatus == 'open') {
// //      if (FoodOrderModel().getOrderCart().where((order) => order.foodId == food.foodId).toList().length > 0) {
// //
// //      } else {
// //        _proceedToFoodVariantsPage(food, null);
// //      }
// //    }
//   }

//   _proceedToFoodVariantsPage(
//       FoodModel food, List<FoodVariantItemModel> orderVariants) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => FoodVariantDetailsPopup(
//           food: food,
//           shop: widget.shopInfo,
//           prevOrderedFoodVariants: orderVariants,
//         ),
//       ),
//     ).then((value) {
//       if (value != null && value == 'refresh') {
//         setState(() {});
//       }
//     });
//   }

//   void createOrder() async {
//     if (User().getAuthToken() == null) {
//       Navigator.pushNamed(context, LoginPage.id);
//       return;
//     }

//     Map<String, dynamic> params = {
//       "apiKey": APIUrls().getFoodApiKey(),
//       "data": FoodOrderModel().getCreateOrderParam()
//     };
//     print(params);

//     setState(() {
//       _showSpinner = true;
//     });

//     try {
//       var data = await FoodNetworking().createOrder(params);

//       if (data) {
//         _viewCartPopup();
//       }
//     } catch (e) {
//       print(e.toString());
//       showSimpleFlushBar(e, context);
//     } finally {
//       setState(() {
//         _showSpinner = false;
//       });
//     }
//   }

//   _viewCartPopup() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => FoodCartPage(),
//       ),
//     ).then((value) {
//       if (value != null) {
//         if (value is PopWithResults) {
//           PopWithResults popResult = value;
//           if (popResult.toPage == 'shopMenu') {
//           } else {
//             // pop to previous page
//             Navigator.of(context).pop(value);
//           }
//         } else if (value == 'refresh') {
//           setState(() {});
//         }
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // print("SPINNER: " + _showSpinner.toString());
//     Widget _buildMenuFoodListInCategory(ShopMenuModel menu) {
//       List<Widget> foodList = [];
//       List<FoodModel> foods = menu.foods;

//       for (int i = 0; i < foods.length; i++) {
//         FoodModel food = foods[i];

//         Widget itemView = GestureDetector(
//           onTap: () {
//             _foodItemOnPressed(menu, food);
//           },
//           behavior: HitTestBehavior.translucent,
//           child: Container(
//             padding: EdgeInsets.symmetric(vertical: 10.0),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: <Widget>[
//                 (food.imageUrl != '')
//                     ? Stack(
//                         children: <Widget>[
//                           Padding(
//                             padding: const EdgeInsets.only(right: 8.0),
//                             child: CachedNetworkImage(
//                               imageUrl: food.imageUrl,
//                               placeholder: (context, url) => Image.asset(
//                                 "images/haloje_placeholder.png",
//                                 width: 100,
//                                 height: 100,
//                               ),
// //                                CircularProgressIndicator(),
//                               errorWidget: (context, url, error) =>
//                                   Icon(Icons.error),
//                               width: 100,
//                               height: 100,
//                             ),
//                           ),
//                           (!food.status ||
//                                   !menu.categoryStatus ||
//                                   (widget.shopInfo.shopStatus != 'open' &&
//                                       !_allowOrderAfterShopClose))
//                               ? Container(
//                                   color: Colors.white.withOpacity(0.6),
//                                   width: 100,
//                                   height: 100,
//                                 )
//                               : Container()
//                         ],
//                       )
//                     : Container(),
//                 SizedBox(width: 0.0),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: <Widget>[
//                       Text(
//                         food.name,
//                         style: (!food.status ||
//                                 !menu.categoryStatus ||
//                                 (widget.shopInfo.shopStatus != 'open' &&
//                                     !_allowOrderAfterShopClose))
//                             ? kDetailsTextStyle.copyWith(
//                                 color: Colors.grey[400])
//                             : kDetailsTextStyle,
//                       ),
//                       SizedBox(height: 5.0),
//                       food.description != ""
//                           ? Text(
//                               food.description,
//                               // style: kDetailsTextStyle,
//                             )
//                           : Row(),
//                       (!food.status || !menu.categoryStatus)
//                           ? Text(
//                               AppTranslations.of(context).text('not_available'),
//                               style: kSmallLabelTextStyle.copyWith(
//                                   fontFamily: poppinsMedium,
//                                   color: Colors.grey[400]),
//                             )
//                           : Container()
//                     ],
//                   ),
//                 ),
//                 SizedBox(width: 10.0),
//                 Text(
//                   '${AppTranslations.of(context).text('currency_my')} ${food.price}',
//                   style: (!food.status ||
//                           !menu.categoryStatus ||
//                           (widget.shopInfo.shopStatus != 'open' &&
//                               !_allowOrderAfterShopClose))
//                       ? TextStyle(fontFamily: poppinsSemiBold, fontSize: 16)
//                           .copyWith(color: Colors.grey[400])
//                       : TextStyle(fontFamily: poppinsSemiBold, fontSize: 16),
//                 ),
//               ],
//             ),
//           ),
//         );

//         foodList.add(itemView);

//         if (i < foods.length - 1) {
//           foodList.add(Divider(
//             color: kColorRed.withOpacity(.5),
//           ));
//         }
//       }

//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: foodList,
//       );
//     }

//     return Stack(
//       children: [
//         Scaffold(
//           extendBodyBehindAppBar: true,
//           bottomNavigationBar: (FoodOrderModel().getOrderCart() != null &&
//                   FoodOrderModel().getOrderCart().length > 0)
//               ? Container(
//                   padding: EdgeInsets.only(top: 15.0, bottom: 25.0),
//                   decoration: BoxDecoration(
//                     borderRadius:
//                         BorderRadius.vertical(top: Radius.circular(10)),
//                     color: Colors.white,
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.5),
//                         spreadRadius: 5,
//                         blurRadius: 15,
//                         offset: Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: ElevatedButton(
//                     onPressed: () {
//                       if (!_showSpinner) {
//                         createOrder();
//                       }
//                     },
//                     child: Container(
//                       padding: EdgeInsets.symmetric(
//                           vertical: 12.0, horizontal: 10.0),
//                       decoration: BoxDecoration(
//                           color: kColorRed,
//                           borderRadius: BorderRadius.circular(12)),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: <Widget>[
//                           Row(
//                             children: <Widget>[
//                               ConstrainedBox(
//                                 constraints: BoxConstraints(
//                                   minWidth: 25,
//                                   minHeight: 25,
//                                 ),
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(100),
//                                     color: Colors.white,
//                                   ),
//                                   padding:
//                                       EdgeInsets.symmetric(horizontal: 5.0),
//                                   child: Text(
//                                     '${FoodOrderModel().getOrderCart().length}',
//                                     style: kDetailsTextStyle.copyWith(
//                                         color: kColorRed, fontSize: 15),
//                                     textAlign: TextAlign.center,
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(width: 8.0),
//                               Text(
//                                 AppTranslations.of(context)
//                                     .text('view_your_cart'),
//                                 style: TextStyle(
//                                     fontFamily: poppinsMedium,
//                                     fontSize: 15,
//                                     color: Colors.white),
//                               ),
//                             ],
//                           ),
//                           Text(
//                             '${AppTranslations.of(context).text('currency_my')} ${FoodOrderModel().getFoodFinalPrice() ?? '0'}',
//                             style: TextStyle(
//                                 fontFamily: poppinsMedium,
//                                 fontSize: 18,
//                                 color: Colors.white),
//                           )
//                         ],
//                       ),
//                     ),
//                   ))
//               : null,
//           body: ModalProgressHUD(
//             inAsyncCall: _showSpinner,
//             child: NotificationListener<ScrollUpdateNotification>(
//               onNotification: (notification) {
//                 if (!_scrollDetection) return true;

//                 setState(() {
//                   // if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
//                   //   print('User is going down');
//                   //
//                   // } else if(_scrollController.position.userScrollDirection == ScrollDirection.forward){
//                   //
//                   //   print('User is going up');
//                   //   setState(() {
//                   //     message = 'going up';
//                   //   });
//                   // }
//                   int index = getFirstItem();

//                   if (_currentScrollIndex != index) {
//                     if (index != null) {
//                       _currentScrollIndex = index;
//                     }
//                     _tabController.animateTo(_currentScrollIndex,
//                         duration: Duration(milliseconds: 400));
//                   }

//                   _scrollOffset = _scrollController.offset;
//                 });
//                 return true;
//               },
//               child: RectGetter(
//                 key: listViewKey,
//                 child: CustomScrollView(
//                   controller: _scrollController,
//                   slivers: <Widget>[
//                     SliverAppBar(
//                       stretch: true,
//                       // backgroundColor: Colors.white,
//                       leading: Padding(
//                         padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
//                         child: GestureDetector(
//                           onTap: () {
//                             Navigator.pop(context);
//                           },
//                           child: Container(
//                             height: 30,
//                             width: 30,
//                             margin: EdgeInsets.only(left: 20.0),
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(5.0),
//                               color: Colors.white.withOpacity(0.3),
//                             ),
//                             child: Icon(
//                               Icons.chevron_left,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                       ),
//                       title: Text(
//                         widget.shopInfo.shopName,
//                         style: TextStyle(
//                             fontFamily: poppinsSemiBold,
//                             fontSize: 18,
//                             color: Colors.white),
//                       ),
//                       floating: false,
//                       pinned: true,
//                       expandedHeight: 180,
//                       flexibleSpace: FlexibleSpaceBar(
//                         stretchModes: [StretchMode.zoomBackground],
//                         background: (widget.shopInfo.headerImgUrl != '')
//                             ? CachedNetworkImage(
//                                 height: double.infinity,
//                                 imageUrl: widget.shopInfo.headerImgUrl,
//                                 placeholder: (context, url) =>
//                                     Center(child: CircularProgressIndicator()),
//                                 errorWidget: (context, url, error) =>
//                                     Icon(Icons.error),
//                                 fit: BoxFit.cover,
//                               )
//                             : CachedNetworkImage(
//                                 height: double.infinity,
//                                 imageUrl: widget.shopInfo.logoUrl,
//                                 placeholder: (context, url) =>
//                                     CircularProgressIndicator(),
//                                 errorWidget: (context, url, error) =>
//                                     Icon(Icons.error),
//                                 fit: BoxFit.cover,
//                               ),
//                       ),
//                     ),

// //          SliverPadding(
// //            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
// //            sliver: SliverList(
// //              delegate: SliverChildBuilderDelegate((context, index) {
// //                return Container(
// //                  child: ListView.separated(
// //                    itemBuilder: (context, index) {
// //                      ShopMenuModel menu = _shopMenu[index];
// //
// //                      return Container(
// //                        padding: EdgeInsets.symmetric(
// //                            vertical: 10.0, horizontal: 15.0),
// //                        color: Colors.white,
// //                        height: 20.0,
// //                        child: Column(
// //                          children: <Widget>[
// //                            Text(
// //                              menu.categoryName,
// //                              style: TextStyle(
// //                                  fontFamily: poppinsRegular, fontSize: 15),
// //                            )
// //                          ],
// //                        ),
// //                      );
// //                    },
// //                    separatorBuilder: (context, index) {
// //                      return SizedBox(width: 5.0);
// //                    },
// //                    scrollDirection: Axis.horizontal,
// //                    itemCount: _shopMenu.length,
// //                  ),
// //                );
// //              }, childCount: 1),
// //            ),
// //          ),
// //            SliverAppBar(
// //              automaticallyImplyLeading: false,
// //              pinned: true,
// //              floating: false,
// //              expandedHeight: 20,
// //              backgroundColor: Colors.white,
// //              bottom: PreferredSize(
// //                // Add this code
// //                preferredSize: Size.fromHeight(20.0), // Add this code
// //                child: Text(''), // Add this code
// //              ),
// //              flexibleSpace: ListView.separated(
// //                itemBuilder: (context, index) {
// //                  ShopMenuModel menu = _shopMenu[index];
// //
// //                  return Container(
// //                    padding:
// //                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
// //                    color: Colors.white,
// //                    height: 20.0,
// //                    child: Column(
// //                      children: <Widget>[
// //                        Text(
// //                          menu.categoryName,
// //                          style: TextStyle(
// //                              fontFamily: poppinsRegular, fontSize: 15),
// //                        )
// //                      ],
// //                    ),
// //                  );
// //                },
// //                separatorBuilder: (context, index) {
// //                  return SizedBox(width: 5.0);
// //                },
// //                scrollDirection: Axis.horizontal,
// //                itemCount: _shopMenu.length,
// //              ),
// //            ),
//                     SliverList(
//                         delegate: SliverChildListDelegate([
//                       Container(
//                         color: Colors.white,
//                         padding: EdgeInsets.symmetric(
//                             vertical: 10.0, horizontal: 15.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.stretch,
//                           children: <Widget>[
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: <Widget>[
//                                 Expanded(
//                                   child: Row(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.center,
//                                     children: <Widget>[
//                                       Flexible(
//                                         child: Text(
//                                           widget.shopInfo.shopName,
//                                           style: TextStyle(
//                                               fontFamily: poppinsSemiBold,
//                                               fontSize: 18),
//                                         ),
//                                       ),
//                                       (widget.shopInfo.shopStatus == 'open')
//                                           ? Container()
//                                           : Row(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: <Widget>[
//                                                 SizedBox(width: 10.0),
//                                                 Container(
//                                                   color: kColorRed,
//                                                   padding: EdgeInsets.symmetric(
//                                                       vertical: 3.0,
//                                                       horizontal: 6.0),
//                                                   child: Text(
//                                                     widget.shopInfo
//                                                             .shopClosePreOrder
//                                                         ? "Order for later"
//                                                         : AppTranslations.of(
//                                                                 context)
//                                                             .text('closed'),
//                                                     style: kSmallLabelTextStyle
//                                                         .copyWith(
//                                                             color:
//                                                                 Colors.white),
//                                                   ),
//                                                 ),
//                                               ],
//                                             )
//                                     ],
//                                   ),
//                                 ),
//                                 SizedBox(width: 10.0),
//                                 GestureDetector(
//                                   onTap: () {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                           builder: (context) => ShopDetailsPage(
//                                                 shop: widget.shopInfo,
//                                               )),
//                                     );
//                                   },
//                                   child: Icon(
//                                     Icons.info_outline,
//                                     size: 25.0,
//                                   ),
//                                 )
//                               ],
//                             ),
//                             Text(
//                               '${widget.shopInfo.category.join(', ')}',
//                               style: kSmallLabelTextStyle.copyWith(
//                                   color: Colors.grey),
//                             ),
//                             SizedBox(height: 5.0),
//                             Row(
//                               children: <Widget>[
//                                 Icon(
//                                   Icons.star,
//                                   color: kColorRed,
//                                   size: 15,
//                                 ),
//                                 SizedBox(width: 3.0),
//                                 Text(
//                                   '${widget.shopInfo.rating} (${widget.shopInfo.totalOrder})',
//                                   style: kSmallLabelTextStyle,
//                                 ),
//                                 SizedBox(width: 8.0),
//                                 Text(
//                                   '${(widget.shopInfo.distance).toStringAsFixed(1)} km',
//                                   style: kSmallLabelTextStyle,
//                                 ),
//                                 SizedBox(width: 8.0),
//                                 Text(
//                                   '${widget.shopInfo.duration} mins',
//                                   style: kSmallLabelTextStyle,
//                                 ),
//                               ],
//                             ),
//                             SizedBox(height: 5.0),
//                             Text(
//                               'Min Order: RM  ${widget.shopInfo.shopMinAmount}',
//                               style: kSmallLabelTextStyle.copyWith(
//                                   color: Colors.black),
//                             ),
//                             (widget.shopInfo.shopPromo == "1")
//                                 ? Wrap(
//                                     children: [
//                                       Container(
//                                         margin: EdgeInsets.only(top: 5),
//                                         color: kColorRed,
//                                         padding: EdgeInsets.symmetric(
//                                             vertical: 3.0, horizontal: 6.0),
//                                         child: Text(
//                                           "${AppTranslations.of(context).text("promo_label")}",
//                                           style: kSmallLabelTextStyle.copyWith(
//                                               color: Colors.white),
//                                         ),
//                                       )
//                                     ],
//                                   )
//                                 : SizedBox.shrink(),
//                             // Container(color: Colors.red, height: 5)
//                           ],
//                         ),
//                       ),
//                     ])),

//                     SliverList(
//                       delegate: SliverChildBuilderDelegate((context, index) {
//                         ShopMenuModel menu = _shopMenu[index];
//                         _keys[index] = RectGetter.createGlobalKey();

//                         return AutoScrollTag(
//                             key: ValueKey(index),
//                             controller: _scrollController,
//                             index: index,
//                             child: RectGetter(
//                               key: _keys[index],
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   border: Border(
//                                     bottom: BorderSide(
//                                         width: 5.0, color: Colors.grey[100]),
//                                   ),
//                                   color: Colors.white,
//                                 ),
//                                 padding: EdgeInsets.symmetric(
//                                     vertical: 10.0, horizontal: 15.0),
//                                 child: Column(
//                                   crossAxisAlignment:
//                                       CrossAxisAlignment.stretch,
//                                   children: <Widget>[
//                                     Text(
//                                       menu.categoryName,
//                                       style: kTitleTextStyle,
//                                     ),
//                                     SizedBox(height: 15.0),
//                                     _buildMenuFoodListInCategory(menu),
//                                   ],
//                                 ),
//                               ),
//                             ));
//                       }, childCount: _shopMenu.length),
//                     )
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//         if (!_showSpinner)
//           Positioned(
//               top: MediaQuery.of(context).padding.top + kToolbarHeight,
//               left: 0.0,
//               right: 0.0,
//               child: AnimatedOpacity(
//                 opacity: _scrollOffset < 180 ? 0.0 : 1.0,
//                 duration: Duration(milliseconds: 100),
//                 child: Container(
//                   // height: 130,
//                   child: Material(
//                     child: TabBar(
//                       controller: _tabController,
//                       isScrollable: true,
//                       indicatorColor: Theme.of(context).appBarTheme.color,
//                       // controller: _tabController,
//                       labelColor: Colors.black,
//                       unselectedLabelColor: Colors.black54,
//                       onTap: (index) {
//                         _scrollDetection = false;
//                         Future.delayed(const Duration(milliseconds: 500), () {
//                           // Here you can write your code

//                           _scrollDetection = true;
//                         });
//                         _scrollController.scrollToIndex(index,
//                             preferPosition: AutoScrollPosition.begin);
//                       },
//                       tabs: [
//                         ..._shopMenu
//                             .map((item) => Tab(text: item.categoryName)),
//                       ],
//                     ),
//                   ),
//                 ),
//               )),
//       ],
//     );
//   }

//   List<int> getVisible() {
//     /// First, get the rect of ListView, and then traver the _keys
//     /// get rect of each item by keys in _keys, and if this rect in the range of ListView's rect,
//     /// add the index into result list.
//     var rect = RectGetter.getRectFromKey(listViewKey);
//     var _items = <int>[];
//     _keys.forEach((index, key) {
//       var itemRect = RectGetter.getRectFromKey(key);
//       if (itemRect != null &&
//           !(itemRect.top > rect.bottom || itemRect.bottom < rect.top))
//         _items.add(index);
//     });

//     /// so all visible item's index are in this _items.
//     return _items;
//   }

//   int getFirstItem() {
//     var visibles = getVisible();
//     return visibles.first;
//   }

//   int getLastItem() {
//     var visibles = getVisible();
//     return visibles.last;
//   }
// }
