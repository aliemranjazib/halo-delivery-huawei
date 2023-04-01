import 'package:flutter/material.dart';
import 'package:haloapp/components/custom_flushbar.dart';
import 'package:haloapp/components_new/address_detail.dart';
import 'package:haloapp/models/address_model.dart';
import 'package:haloapp/models/food_history_model.dart';
import 'package:haloapp/models/history_model.dart';
import 'package:haloapp/models/user_model.dart';
import 'package:haloapp/networkings/food_history_networking.dart';
import 'package:haloapp/networkings/history_networking.dart';
import 'package:haloapp/screens/auth/login_page.dart';
import 'package:haloapp/screens/history/delivery_history_details_page.dart';
import 'package:haloapp/screens/delivery/delivery_main_page.dart';
import 'package:haloapp/screens/main/food_history_details_page.dart';
import 'package:haloapp/screens/main/rating_and_comment_booking.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/api_urls.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/constants/job_status.dart';
import 'package:haloapp/utils/constants/styles.dart';
import 'package:haloapp/utils/constants/vehicles.dart';
import 'package:haloapp/utils/services/datetime_formatter.dart';
import 'package:haloapp/components/model_progress_hud.dart';
import 'package:haloapp/utils/services/shared_pref_service.dart';

class DeliveryHistoryPage extends StatefulWidget {
  static const String id = 'deliveryHistoryPage';
  String redirectToBooking = '';

  DeliveryHistoryPage({this.redirectToBooking});

  @override
  _DeliveryHistoryPageState createState() => _DeliveryHistoryPageState();
}

class _DeliveryHistoryPageState extends State<DeliveryHistoryPage>
    with SingleTickerProviderStateMixin {
  bool _showSpinner = false;
  List<String> _historyType = ['food', 'express'];
  String _selectedHistoryType = 'food';
  List<HistoryModel> _bookingHistories = [];
  List<FoodHistoryModel> _foodHistories = [];
  TabController tabController;

  @override
  void initState() {
    super.initState();

    if (User().getAuthToken() != null) _historyTypeBtnPressed(0);

    tabController = TabController(vsync: this, length: _historyType.length);
    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        _historyTypeBtnPressed(tabController.index);
      }
    });
  }

  _historyTypeBtnPressed(int index) {
    _selectedHistoryType = _historyType[index];

    switch (_selectedHistoryType) {
      case 'express':
        loadHistory();
        break;
      case 'food':
        loadFoodHistory();
        break;
      default:
        break;
    }
  }

  void loadHistory() async {
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
          _bookingHistories = data;

          if (widget.redirectToBooking != null &&
              widget.redirectToBooking != '') {
            getHistoryDetails(widget.redirectToBooking);
          }
        }
      });
    } catch (e) {
      if (mounted) showSimpleFlushBar(e.toString(), context);
    } finally {
      if (mounted)
        setState(() {
          _showSpinner = false;
        });
    }
  }

  void loadFoodHistory() async {
    setState(() {
      _showSpinner = true;
    });

    try {
      var data = await FoodHistoryNetworking().getFoodOrderHistory({});

      setState(() {
        if (data is List<FoodHistoryModel>) {
          print(_foodHistories.length);
          _foodHistories = data;
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

      widget.redirectToBooking = '';
      Navigator.pushNamed(context, DeliveryHistoryDetailsPage.id,
              arguments: data)
          .then((value) {
        if (value != null) {
          if (value == true) {
            loadHistory();
          } else if (value == 'remakeBooking') {
            Navigator.pushNamed(context, DeliveryMainPage.id);
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
    Widget _getHistoryListView() {
      print(_selectedHistoryType);
      if (_selectedHistoryType == 'express') {
        return ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          separatorBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.all(10.0),
              child: Divider(
                color: kColorRed.withOpacity(.4),
              ),
            );
          },
          scrollDirection: Axis.vertical,
          // Set max 5 addresses
          itemCount: _bookingHistories.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                getHistoryDetails(_bookingHistories[index].bookingUniqueKey);
              },
              behavior: HitTestBehavior.translucent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Image.asset(
                          Vehicles().getVehicleImage(
                              _bookingHistories[index].vehicleTypeId),
                          width: 80.0,
                          height: 60,
                          fit: BoxFit.contain,
                        ),

                        SizedBox(width: 15.0),
                        mainInfo(_bookingHistories[index]),
                        SizedBox(width: 6.0),
                        // SizedBox(width: 15.0),
                      ],
                    ),
                  ),
                  _bookingHistories[index].addresses != null
                      ? AddressDetail(
                          addresses: _bookingHistories[index].addresses,
                        )
                      : SizedBox.shrink(),
                ],
              ),
            );
          },
        );
      } else if (_selectedHistoryType == 'food') {
        return ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            separatorBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.all(10.0),
                child: Divider(
                  color: kColorRed.withOpacity(.5),
                ),
              );
            },
            scrollDirection: Axis.vertical,
            itemCount: _foodHistories.length,
            itemBuilder: (BuildContext context, int index) {
              FoodHistoryModel foodHistory = _foodHistories[index];
              double width = MediaQuery.of(context).size.width * 0.50;

              return Column(
                children: <Widget>[
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            children: [
                              Row(
                                children: <Widget>[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.network(
                                      foodHistory.shopLogoUrl,
                                      height: 50.0,
                                      width: 50.0,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          width: width,
                                          child: Text(
                                            '${foodHistory.shopName} ${(foodHistory.shopBuildingName != '') ? '- ${foodHistory.shopBuildingName}' : ''}',
                                            style: TextStyle(
                                              fontFamily: poppinsMedium,
                                              fontSize: 14,
                                            ),
                                            overflow: TextOverflow.visible,
                                          ),
                                        ),
                                        Text(
                                          foodHistory.street != ''
                                              ? foodHistory.street
                                              : foodHistory.shopBuildingName,
                                          style: kSmallLabelTextStyle,
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(height: 10.0),
                              Row(
                                children: [
                                  Container(
                                    child: Text(
                                      '${foodHistory.orderItems.length} ${AppTranslations.of(context).text('items')}',
                                      style: kSmallLabelTextStyle,
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(height: 10.0),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DatetimeFormatter().getFormattedDateStr(
                                        format: 'dd MMM yyyy hh:mm a',
                                        datetime:
                                            foodHistory.orderPickupDatetime),
                                    style: kSmallLabelTextStyle,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 3.0),
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${AppTranslations.of(context).text('currency_my')} ${foodHistory.orderPrice}',
                                style: TextStyle(
                                    fontFamily: poppinsMedium,
                                    fontSize: 16,
                                    color: kColorRed),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16.0),
                                    color: kColorRed.withOpacity(.1)),
                                child: Wrap(children: [
                                  Text(
                                    AppTranslations.of(context).text(
                                        'order_' + foodHistory.orderStatus),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 3,
                                    textAlign: TextAlign.center,
                                    style: kSmallLabelTextStyle.copyWith(
                                      color: kColorRed,
                                      fontFamily: poppinsMedium,
                                      // fontSize: 5,
                                    ),
                                  ),
                                ]),
                              ),
                            ],
                          ),
                        ),
                      ]),
                    ),
                    onTap: () async{
                      var isCancelBooking = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              FoodHistoryDetailsPage(history: foodHistory),
                        ),
                      );

                      if(isCancelBooking!= null && isCancelBooking is bool){
                        if(isCancelBooking){
                          _historyTypeBtnPressed(tabController.index);
                        }
                      }
                    },
                  )
                ],
              );
            });
      } else {
        return Container();
      }
    }

    return DefaultTabController(
      initialIndex: 1,
      length: _historyType.length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: kColorRed,
          title: Text(
            AppTranslations.of(context).text('history'),
            style: kAppBarTextStyle.copyWith(color: Colors.white),
          ),
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: kAppBarGradient,
          ),
          bottom: TabBar(
            controller: tabController,
            onTap: (index){
              _historyTypeBtnPressed(index);
            },
            tabs: <Widget>[
              Tab(
                child: Text(
                  AppTranslations.of(context).text("food"),
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Tab(
                child: Text(
                  AppTranslations.of(context).text("express"),
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        body: ModalProgressHUD(
          inAsyncCall: _showSpinner,
          child: TabBarView(
            controller: tabController,
            physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 10),
                child: RefreshIndicator(
                  onRefresh: ()async{
                    _historyTypeBtnPressed(tabController.index);
                    return Future.value(true);
                  },
                    child: _getHistoryListView()
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 10),
                child: RefreshIndicator(
                  onRefresh: ()async{
                    _historyTypeBtnPressed(tabController.index);
                    return Future.value(true);
                  },
                  child: _getHistoryListView()
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget mainInfo(HistoryModel history) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Vehicles().getVehicleName(history.vehicleTypeId),
                style: TextStyle(
                  fontFamily: poppinsSemiBold,
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
              Text(
                '${AppTranslations.of(context).text('currency_my')} ${history.totalPrice}',
                style: TextStyle(
                  fontFamily: poppinsSemiBold,
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#${history.bookingNumber}',
                style: TextStyle(
                  fontFamily: poppinsRegular,
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: kColorRed.withOpacity(.1)),
                child: Text(
                    '${AppTranslations.of(context).text(JobStatus().getJobStatusDescription(history.orderStatus))}',
                    style: TextStyle(
                        fontFamily: poppinsMedium,
                        fontSize: 12,
                        color: kColorRed)),
              ),
            ],
          ),
          SizedBox(height: 10.0),
          Text(
            '${DatetimeFormatter().dateAmPm(history.pickupDatetime)}',
            style: TextStyle(fontFamily: poppinsMedium, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
