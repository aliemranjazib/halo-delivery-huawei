import 'package:flutter/material.dart';
import 'package:haloapp/components/custom_flushbar.dart';
import 'package:haloapp/components/model_progress_hud.dart';
import 'package:haloapp/components/search_bar_input.dart';
import 'package:haloapp/components_new/shop_card.dart';
import 'package:haloapp/models/address_model.dart';
import 'package:haloapp/models/food_order_model.dart';
import 'package:haloapp/models/shop_model.dart';
import 'package:haloapp/networkings/food_networking.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/api_urls.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/styles.dart';
import 'package:haloapp/utils/debouncer.dart';
import 'package:haloapp/utils/utils.dart';

class ShopListPage extends StatefulWidget {
  static const String id = '/shopList';

  @override
  _ShopListPageState createState() => _ShopListPageState();
}

class _ShopListPageState extends State<ShopListPage> {
  bool _showSpinner = true;
  AddressModel _currentAddress = FoodOrderModel().getDeliveryAddress();
  List<ShopModel> _shops = [];
  List<ShopModel> _allShops = [];
  final _debouncer = Debouncer(delay: Duration(milliseconds: 500));

  FocusNode myFocusNode = FocusNode();

  Future<void> getNearbyShopList({keyword = ''}) async {
    // print('getSHOP at: ${FoodOrderModel().foodOption.shopType}');
    // print(_currentAddress.lat);
    // print(_currentAddress.lng);
    Map<String, dynamic> params = {
      "apiKey": APIUrls().getFoodApiKey(),
      "data": {
        "lat": _currentAddress == null ? 0.0 : _currentAddress.lat,
        "lng": _currentAddress == null ? 0.0 : _currentAddress.lng,
        "keyword": keyword.toString(),
        // keyword.toString().isNotEmpty
        //     ? keyword
        //     : FoodOrderModel().foodOption.searchName,
        "shopType": FoodOrderModel().foodOption.shopType,
        "shopCategory": FoodOrderModel().foodOption.searchName
      }
    };
    print(params);

    setState(() {
      _showSpinner = true;
    });

    try {
      var data = await FoodNetworking().getNearbyShops(params);
      setState(() {
        _shops = data;
        _allShops = data;
      });
    } catch (e) {
      print(e.toString());
      // showSimpleFlushBar(e.toString(), context);
    } finally {
      setState(() {
        _showSpinner = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getNearbyShopList();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _showSpinner,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: Container(
            child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: arrowBack),
          ),
          actions: [
            // IconButton(
            //   icon: Icon(
            //     Icons.close,
            //     color: Colors.white,
            //   ),
            //   onPressed: () => {},
            // ),
          ],
          title: Text('${FoodOrderModel().foodOption.searchName}',
              textAlign: TextAlign.center, style: kAppBarTextStyle),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: _shops != null && _shops.length > 0
                ? Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SearchBarInput(
                          onChange: (key) {
                            _debouncer
                                .run(() => getNearbyShopList(keyword: key));
                          },
                          defaultBorderColor: Colors.grey,
                          isAutoFocus: true,
                        ),
                        ListView.separated(
                          separatorBuilder: (context, index) => Divider(),
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _shops.length,
                          itemBuilder: (_, index) {
                            return ShopCard(
                              shop: _shops[index],
                            );
                          },
                        )
                      ],
                    ),
                  )
                : Container(
                    height: MediaQuery.of(context).size.height - 200,
                    child: Center(
                        child: Text(AppTranslations.of(context)
                            .text('no_shop_available'))),
                  ),
          ),
        ),
      ),
    );
  }
}
