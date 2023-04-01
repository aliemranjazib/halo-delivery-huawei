import 'package:flutter/material.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/components/custom_flushbar.dart';
import 'package:haloapp/models/address_model.dart';
import 'package:haloapp/models/food_history_model.dart';
import 'package:haloapp/models/history_model.dart';
import 'package:haloapp/models/user_model.dart';
import 'package:haloapp/networkings/food_history_networking.dart';
import 'package:haloapp/networkings/history_networking.dart';
import 'package:haloapp/screens/history/delivery_history_details_page.dart';
import 'package:haloapp/screens/delivery/delivery_main_page.dart';
import 'package:haloapp/screens/history/food_history_details_page.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/api_urls.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/constants/job_status.dart';
import 'package:haloapp/utils/constants/styles.dart';
import 'package:haloapp/utils/constants/vehicles.dart';
import 'package:haloapp/utils/services/datetime_formatter.dart';
import 'package:haloapp/components/model_progress_hud.dart';

class DeliveryHistoryPage extends StatefulWidget {
  static const String id = 'deliveryHistoryPage';
  String redirectToBooking = '';

  DeliveryHistoryPage({this.redirectToBooking});

  @override
  _DeliveryHistoryPageState createState() => _DeliveryHistoryPageState();
}

class _DeliveryHistoryPageState extends State<DeliveryHistoryPage> {
  bool _showSpinner = false;
  List<String> _historyType = ['food', 'express'];
  String _selectedHistoryType = 'food';
  List<HistoryModel> _bookingHistories = [];
  List<FoodHistoryModel> _foodHistories = [];

  @override
  void initState() {
    super.initState();

    if (User().getAuthToken() != null) _historyTypeBtnPressed(0);
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
      print(e.toString());
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
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: kColorRed.withOpacity(.04)),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Image.asset(
                                    Vehicles().getVehicleImage(
                                        _bookingHistories[index].vehicleTypeId),
                                    height: 60,
                                  ),
                                  Text(
                                      '${AppTranslations.of(context).text('currency_my')} ${_bookingHistories[index].totalPrice}',
                                      style: TextStyle(
                                          fontFamily: poppinsSemiBold,
                                          fontSize: 15,
                                          color: kColorRed)),
                                  SizedBox(height: 10.0),
                                ],
                              ),
                            ),
                            SizedBox(width: 15.0),
                            mainInfo(_bookingHistories[index]),
                            SizedBox(width: 6.0),
                            // SizedBox(width: 15.0),
                          ],
                        ),
                      ),
                      onTap: () {
                        getHistoryDetails(
                            _bookingHistories[index].bookingUniqueKey);
                      },
                    )
                  ]);
            });
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
              double width = MediaQuery.of(context).size.width * 0.60;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 2),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: kColorRed.withOpacity(.1)),
                                child: Text(
                                  AppTranslations.of(context)
                                      .text('order_' + foodHistory.orderStatus),
                                  style: kSmallLabelTextStyle.copyWith(
                                      color: kColorRed,
                                      fontFamily: poppinsMedium),
                                ),
                              ),
                              Text(
                                DatetimeFormatter().getFormattedDateStr(
                                    format: 'dd MMM yyyy',
                                    datetime: foodHistory.orderPickupDatetime),
                                style: kSmallLabelTextStyle,
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                    '${foodHistory.orderItems.length} ${AppTranslations.of(context).text('items')}',
                                    style: kSmallLabelTextStyle,
                                  ),
                                ],
                              ),
                              Flexible(
                                child: Text(
                                  '${AppTranslations.of(context).text('currency_my')} ${foodHistory.orderPrice}',
                                  style: TextStyle(
                                      fontFamily: poppinsMedium,
                                      fontSize: 16,
                                      color: kColorRed),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FoodHistoryDetailsPage(
                                  history: foodHistory)));
                    },
                  )
                ],
              );
            });
      } else {
        return Container();
      }
    }

    return Scaffold(
      // backgroundColor: kLightBackground,
      appBar: AppBar(
        title: Text(
          AppTranslations.of(context).text('history'),
          style: kAppBarTextStyle,
        ),
        automaticallyImplyLeading: false,
      ),
      body: ModalProgressHUD(
        inAsyncCall: _showSpinner,
        child: SafeArea(
          child: Container(
            color: Colors.white,
            // margin: EdgeInsets.all(15.0),
            // padding: EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(_historyType.length, (index) {
                      List<Widget> a = [];
                      if (index % 2 != 0)
                        a.add(SizedBox(
                          width: 2,
                        ));
                      if (_selectedHistoryType == _historyType[index]) {
                        a.add(Expanded(
                          child: ActionButton(
                            buttonText: AppTranslations.of(context)
                                .text(_historyType[index]),
                            onPressed: () {
                              if (User().getAuthToken() != null)
                                _historyTypeBtnPressed(index);
                            },
                          ),
                        ));
                      } else {
                        a.add(Expanded(
                          child: ActionButtonLight(
                            buttonText: AppTranslations.of(context)
                                .text(_historyType[index]),
                            onPressed: () {
                              if (User().getAuthToken() != null)
                                _historyTypeBtnPressed(index);
                            },
                          ),
                        ));
                      }
                      if (index % 2 == 0)
                        a.add(SizedBox(
                          width: 2,
                        ));

                      return Expanded(child: Row(children: a));
                    }),
                  ),
                ),
                // SizedBox(
                //   height: 5.0,
                //   // child: Divider(
                //   //   color: kColorRed.withOpacity(.4),
                //   // ),
                // ),
                ((_selectedHistoryType == 'express' &&
                            _bookingHistories.length == 0) ||
                        (_selectedHistoryType == 'food' &&
                            _foodHistories.length == 0))
                    ? Center(
                        child: Text(
                          AppTranslations.of(context)
                              .text('no_history_booking'),
                          style: TextStyle(
                              fontFamily: poppinsLight,
                              fontSize: 14,
                              color: Colors.grey),
                        ),
                      )
                    : Container(
                        child: Expanded(child: _getHistoryListView()),
                      ),
              ],
            ),
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
                '#${history.bookingNumber}',
                style: TextStyle(
                    fontFamily: poppinsRegular, fontSize: 14, color: kColorRed),
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

  // No use for now
  Widget addresses(List<AddressModel> addresses) {
    List<Widget> addressesView = [];
    // TODO: loop addresses and show 'and more' if more than 2

    Widget addressView = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Image.asset(
          'images/pin_blue.png',
          height: 20,
        ),
        SizedBox(width: 8.0),
        Flexible(
          child: Text(
            '123, Taman Puteri, Bandar Puteri Puchong, Puchong, Selangor.',
            style: TextStyle(fontFamily: poppinsRegular, fontSize: 14),
          ),
        ),
      ],
    );

    addressesView.add(addressView);
    addressesView.add(SizedBox(height: 8.0));
    addressesView.add(addressView);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: addressesView,
    );
  }
}
