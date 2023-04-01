import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:haloapp/components_new/shop_info_card.dart';
import 'package:haloapp/models/shop_model.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:haloapp/models/shop_review_model.dart';
import 'package:haloapp/networkings/food_networking.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/api_urls.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/constants/styles.dart';
import 'package:haloapp/utils/services/datetime_formatter.dart';
import 'package:haloapp/widget/measure_size_widget.dart';
import 'package:huawei_map/map.dart' as huaweiMap;

class ShopDetailsPage extends StatefulWidget {
  ShopDetailsPage({@required this.shopUniqueCode, @required this.shop});

  final String shopUniqueCode;
  final ShopModel shop;

  @override
  _ShopDetailsPageState createState() => _ShopDetailsPageState();
}

class _ShopDetailsPageState extends State<ShopDetailsPage> {
  GoogleMapsPlaces _places =
      GoogleMapsPlaces(apiKey: APIUrls().getGoogleAPIKey());
  // GoogleMapController mapController;
  // LatLng _initialPosition = LatLng(0, 0);
  // BitmapDescriptor markerIcon;
  // Set<Marker> _markers = {};
  //Huawei Map
  huaweiMap.HuaweiMapController huaweiMapController;
  huaweiMap.LatLng _huaweiInitialPosition = huaweiMap.LatLng(0, 0);
  huaweiMap.BitmapDescriptor huaweiMarkerIcon;
  Set<huaweiMap.Marker> _huaweiMarkers = {};

  List<String> _days = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];

  List<String> _tabs = ['Shop Information', 'Reviews'];
  String _selectedTab = 'Shop Information';
  List<ShopReview> _shopReviews = [];
  Size shopWidget = Size(400.0, 140.0);

  @override
  void initState() {
    super.initState();
    getShopReviews();
    print("GGG: " + widget.shop.lat + " " + widget.shop.lng);
    // _initialPosition =
    //     LatLng(double.parse(widget.shop.lat), double.parse(widget.shop.lng));

    _huaweiInitialPosition = huaweiMap.LatLng(
        double.parse(widget.shop.lat), double.parse(widget.shop.lng));
    addMarker();
  }

  void getShopReviews() async {
    Map<String, dynamic> params = {
      "data": {
        "shopUniqueCode": widget.shopUniqueCode,
      }
    };
    var data = await FoodNetworking().getShopReview(params);
    setState(() {
      _shopReviews = data;
    });
  }

  // void _onMapCreated(GoogleMapController controller) {
  //   mapController = controller;
  // }

  void _onHuaweiMapCreated(huaweiMap.HuaweiMapController controller) {
    huaweiMapController = controller;
  }

  void setupIcons() {
    ImageConfiguration imageConfig = ImageConfiguration(size: Size(25, 25));

    // BitmapDescriptor.fromAssetImage(imageConfig, 'images/pin_red.png')
    //     .then((value) => markerIcon = value);

    huaweiMap.BitmapDescriptor.fromAssetImage(imageConfig, 'images/pin_red.png')
        .then((value) => huaweiMarkerIcon = value);
  }

  void addMarker() async {
    // _markers.clear();
    //
    // final marker =
    //     Marker(markerId: MarkerId('marker'), position: _initialPosition);
    //
    // _markers.add(marker);

    _huaweiMarkers.clear();

    final marker = huaweiMap.Marker(
        markerId: huaweiMap.MarkerId('marker'),
        position: _huaweiInitialPosition);

    _huaweiMarkers.add(marker);

    setState(() {});
  }

  renderTab(String tab) {
    // if (tab == _tabs[1] && _shopReviews.length == 0) {
    //   return SizedBox.shrink();
    // }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = tab;
        });
      },
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.only(right: 8),
        padding: EdgeInsets.symmetric(
          vertical: 3,
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          color: _selectedTab == tab ? Colors.black : lightGrey,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          tab,
          style: TextStyle(
            color: _selectedTab == tab ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _openingDayTime() {
    if (widget.shop.shopOpenType == 'allDay') {
      return Row(
        children: <Widget>[
          Text(
            AppTranslations.of(context).text('all_days'),
            style: TextStyle(fontFamily: poppinsRegular, fontSize: 15),
          ),
          SizedBox(width: 20.0),
          Text(
            '${DatetimeFormatter().getFormattedTimeStr(format: 'hh:mm a', time: widget.shop.shopOpenTimeRange['From'])} - ${DatetimeFormatter().getFormattedTimeStr(format: 'hh:mm a', time: widget.shop.shopOpenTimeRange['To'])}',
            style: kLabelTextStyle,
          )
        ],
      );
    } else if (widget.shop.shopOpenType == 'specificDay') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(_days.length, (index) {
          String day = _days[index];

          return (widget.shop.shopOpenTimeRange[day] != null)
              ? OpeningHrsWidget(
                  day: day,
                  fromTime: widget.shop.shopOpenTimeRange[day]['From'],
                  toTime: widget.shop.shopOpenTimeRange[day]['To'])
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      AppTranslations.of(context).text('$day'),
                      style: kLabelTextStyle,
                    ),
                    SizedBox(width: 20.0),
                    Text(
                      AppTranslations.of(context).text('rest'),
                      style: kLabelTextStyle,
                    )
                  ],
                );
        }),
      );
    } else if (widget.shop.shopOpenType == 'allDayWithRest' &&
        widget.shop.shopOpenTimeRange is List<dynamic>) {
      return Row(
        children: <Widget>[
          Text(
            AppTranslations.of(context).text('all_days'),
            style: kLabelTextStyle,
          ),
          SizedBox(width: 20.0),
          Column(
            children:
                List.generate(widget.shop.shopOpenTimeRange.length, (index) {
              Map<String, dynamic> openTimes =
                  widget.shop.shopOpenTimeRange[index];
              return Text(
                '${DatetimeFormatter().getFormattedTimeStr(format: 'hh:mm a', time: openTimes['From'])} - ${DatetimeFormatter().getFormattedTimeStr(format: 'hh:mm a', time: openTimes['To'])}',
                style: kLabelTextStyle,
              );
            }),
          )
        ],
      );
    } else if (widget.shop.shopOpenType == 'specificDayWithRest') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(_days.length, (index) {
          String day = _days[index];
          List<dynamic> dayOpenTimes = widget.shop.shopOpenTimeRange[day];

          return (dayOpenTimes != null)
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      AppTranslations.of(context).text('$day'),
                      style: kLabelTextStyle,
                    ),
                    SizedBox(width: 20.0),
                    Column(
                      children: List.generate(dayOpenTimes.length, (index) {
                        Map<String, dynamic> openTimes = dayOpenTimes[index];

                        return Text(
                          '${DatetimeFormatter().getFormattedTimeStr(format: 'hh:mm a', time: openTimes['From'])} - ${DatetimeFormatter().getFormattedTimeStr(format: 'hh:mm a', time: openTimes['To'])}',
                          style: kLabelTextStyle,
                        );
                      }),
                    )
                  ],
                )
              : Container();
        }),
      );
    }
  }

  renderShopAddressInformation() {
    return Column(
      children: [
        Container(height: 250, child: getMap()),
        Container(
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              (widget.shop.shopPromo == "1")
                  ? Wrap(
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 5),
                          color: kColorRed,
                          padding: EdgeInsets.symmetric(
                              vertical: 3.0, horizontal: 6.0),
                          child: Text(
                            "${AppTranslations.of(context).text("promo_label")}",
                            style: kSmallLabelTextStyle.copyWith(
                                color: Colors.white),
                          ),
                        )
                      ],
                    )
                  : SizedBox.shrink(),
              SizedBox(height: 15.0),
              Text(
                '${AppTranslations.of(context).text('address')}',
                style: kTitleBoldTextStyle,
              ),
              Text(
                '${widget.shop.fullAddress}',
                style: kLabelTextStyle,
              ),
              SizedBox(height: 25.0),
              Text(
                AppTranslations.of(context).text('opening_hours'),
                style: kTitleBoldTextStyle,
              ),
              SizedBox(height: 5.0),
              _openingDayTime(),
            ],
          ),
        )
      ],
    );
  }

  renderReviews() {
    if (_shopReviews.isEmpty) {
      return Container(
        height: 200.0,
        padding: EdgeInsets.all(10.0),
        child: Center(
          child: Text(
            AppTranslations.of(context).text("no_reviews"),
            style: kDetailsTextStyle.copyWith(color: Colors.grey),
          ),
        ),
      );
    }
    return ListView.separated(
      separatorBuilder: (context, index) => Divider(),
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _shopReviews.length,
      itemBuilder: (_, index) {
        return Container(
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text(
                    //   'Crystal',
                    //   style: TextStyle(fontFamily: poppinsSemiBold),
                    // ),
                    Text(
                      DatetimeFormatter().getFormattedDateStr(
                        format: 'dd MMM yyyy',
                        datetime:
                            '${_shopReviews[index].orderRatingDatetime} 00:00:00',
                      ),
                      style: TextStyle(
                        fontFamily: poppinsRegular,
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    // Text(
                    //   _shopReviews[index].customerComment,
                    //   style: TextStyle(fontFamily: poppinsRegular),
                    // )
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    RatingBar.builder(
                      itemSize: 16,
                      ignoreGestures: true,
                      initialRating:
                          double.parse(_shopReviews[index].customerRating),
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        print(rating);
                      },
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  switchRender() {
    switch (_selectedTab) {
      case 'Shop Information':
        return renderShopAddressInformation();

      case 'Reviews':
        return renderReviews();
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 170.0 + shopWidget.height,
                child: Stack(
                  children: [
                    Container(
                      height: 230,
                      child: (widget.shop.headerImgUrl != '')
                          ? CachedNetworkImage(
                              width: MediaQuery.of(context).size.width,
                              imageUrl: widget.shop.headerImgUrl,
                              placeholder: (context, url) =>
                                  Center(child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                              fit: BoxFit.cover,
                            )
                          : CachedNetworkImage(
                              width: MediaQuery.of(context).size.width,
                              imageUrl: widget.shop.logoUrl,
                              placeholder: (context, url) =>
                                  CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                              fit: BoxFit.cover,
                            ),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top),
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios,
                          size: 20,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Positioned(
                      top: 170.0,
                      left: 0,
                      right: 0,
                      // bottom: 0,
                      child: MeasureSize(
                        onChange: (size) {
                          print(size);
                          setState(() {
                            shopWidget = size;
                          });
                        },
                        child: ShopInfoCard(
                          shop: widget.shop,
                          isShopInfo: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 10.0,
                      ),
                      child: Row(
                        children: [..._tabs.map((e) => renderTab(e)).toList()],
                      ),
                    ),
                    switchRender(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getMap() {
    // return GoogleMap(
    //   onMapCreated: _onMapCreated,
    //   initialCameraPosition: CameraPosition(
    //     target: _initialPosition,
    //     zoom: 18,
    //   ),
    //   markers: _markers,
    //   myLocationEnabled: false,
    //   myLocationButtonEnabled: false,
    // );

    return huaweiMap.HuaweiMap(
      onMapCreated: _onHuaweiMapCreated,
      initialCameraPosition: huaweiMap.CameraPosition(
        target: _huaweiInitialPosition,
        zoom: 18,
      ),
      markers: _huaweiMarkers,
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
    );
  }
}

class OpeningHrsWidget extends StatelessWidget {
  const OpeningHrsWidget({
    Key key,
    @required this.day,
    @required this.fromTime,
    @required this.toTime,
  }) : super(key: key);

  final String day;
  final String fromTime;
  final String toTime;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          AppTranslations.of(context).text('$day'),
          style: TextStyle(fontFamily: poppinsRegular, fontSize: 15),
        ),
        SizedBox(width: 20.0),
        Text(
          '${DatetimeFormatter().getFormattedTimeStr(format: 'HH:mm', time: fromTime)} - ${DatetimeFormatter().getFormattedTimeStr(format: 'HH:mm', time: toTime)}',
          style: TextStyle(fontFamily: poppinsRegular, fontSize: 15),
        )
      ],
    );
  }
}
