import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/components/custom_flushbar.dart';
import 'package:haloapp/components/input_textfield.dart';
import 'package:haloapp/components/labeled_checkbox.dart';
import 'package:haloapp/models/food_model.dart';
import 'package:haloapp/models/food_order_model.dart';
import 'package:haloapp/models/food_variant_model.dart';
import 'package:haloapp/models/shop_model.dart';
import 'package:haloapp/networkings/food_networking.dart';
import 'package:haloapp/screens/general/confirmation_dialog.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/api_urls.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/constants/styles.dart';
import 'package:haloapp/components/model_progress_hud.dart';

class FoodVariantDetailsPopup extends StatefulWidget {
  FoodVariantDetailsPopup({
    @required this.food,
    @required this.shop,
    this.prevOrderedFoodVariants,
    this.editingIndex,
    this.remark,
  });

  final ShopModel shop;
  final FoodModel food;
  final List<FoodVariantItemModel> prevOrderedFoodVariants;
  final int editingIndex;
  final String remark;

  @override
  _FoodVariantDetailsPopupState createState() =>
      _FoodVariantDetailsPopupState();
}

class _FoodVariantDetailsPopupState extends State<FoodVariantDetailsPopup> {
  bool _showSpinner = false;
  List<FoodVariantModel> _selectedFoodVariants = [];
  bool _canAddToCart = true;
  int _quantity = 1;
  String _calculatedTotalPrice;
  String _remarkInput = '';

  @override
  void initState() {
    super.initState();

    _initiateFoodVariants();
    _checkSelectedVariants();
  }

  _initiateFoodVariants() {
    if (widget.food.variants.length > 0) {
      for (FoodVariantModel variant in widget.food.variants) {
        List<FoodVariantItemModel> items = [];

        if (variant.variantList.length > 0) {
          for (FoodVariantItemModel vItem in variant.variantList) {
            FoodVariantItemModel item = FoodVariantItemModel(
                variantId: vItem.variantId,
                name: vItem.name,
                extraPrice: vItem.extraPrice,
                status: vItem.status,
                selected: (widget.prevOrderedFoodVariants != null)
                    ? ((widget.prevOrderedFoodVariants
                                .where((v) => v.variantId == vItem.variantId))
                            .toList()
                            .length >
                        0)
                    : vItem.selected);

            items.add(item);
          }
        }

        FoodVariantModel foodVariant = FoodVariantModel(
          variantMin: variant.variantMin,
          variantMax: variant.variantMax,
          variantName: variant.variantName,
          variantList: items,
          variantListId: variant.variantListId,
          variantOption: variant.variantOption,
        );

        _selectedFoodVariants.add(foodVariant);
      }
    }
  }

  _checkSelectedVariants() {
    _canAddToCart = true;

    if (_selectedFoodVariants.length > 0) {
      for (FoodVariantModel variant in _selectedFoodVariants) {
        var selectedItemsCount = 0;

        if (variant.variantList.length > 0) {
          for (FoodVariantItemModel item in variant.variantList) {
            if (item.selected) {
              selectedItemsCount = selectedItemsCount + 1;
            }
          }
        }

//        print('selectedItemsCount $selectedItemsCount');
//        print('variant.variantMin ${variant.variantMin}');
        if ((selectedItemsCount < int.parse(variant.variantMin)) &&
            variant.variantOption == 'required') {
          setState(() {
            _canAddToCart = false;
          });
        }
      }
    }

    // set ordered qty
    if (widget.prevOrderedFoodVariants != null)
      _quantity = int.tryParse(
          FoodOrderModel().getOrderCart()[widget.editingIndex].quantity);

    print(_canAddToCart);
  }

  _showDiscardPreviousOrderDialog() {
    showDialog(
        context: context,
        builder: (context) => ConfirmationDialog(
              title: AppTranslations.of(context).text('make_new_order'),
              message: AppTranslations.of(context)
                  .text('you_have_order_food_from_different_restaurant'),
            )).then((value) {
      if (value != null && value == 'confirm') {
        setState(() {
          FoodOrderModel().clearFoodOrderData();
          addFoodToCart();
        });
      } else {
        Navigator.pop(context);
      }
    });
  }

  void addFoodToCart() {
    List<FoodVariantItemModel> items = [];

    if (_selectedFoodVariants.length > 0) {
      for (FoodVariantModel variant in _selectedFoodVariants) {
        if (variant.variantList.length > 0) {
          for (FoodVariantItemModel item in variant.variantList) {
            if (item.selected) {
              items.add(item);
            }
          }
        }
      }
    }

    FoodOrderCart order = FoodOrderCart(
      foodId: widget.food.foodId,
      name: widget.food.name,
      quantity: _quantity.toString(),
      options: items,
      remark: _remarkInput,
    );
    if (widget.prevOrderedFoodVariants == null) {
      print('add food');
      FoodOrderModel().addFoodInCart(order);
    } else {
      print('update food');
      FoodOrderModel().updateOrderInCart(widget.editingIndex, order);
    }
    FoodOrderModel().setShop(widget.shop);

    calculateOrderPrice();
  }

  void _removeItemFromCart() {
    FoodOrderModel().removeFoodFromCart(widget.editingIndex);
    Navigator.pop(context, 'refresh');
  }

  void calculateOrderPrice() async {
    Map<String, dynamic> params = {
      "apiKey": APIUrls().getFoodApiKey(),
      "data": {
        "orderCart": FoodOrderModel().getOrderCartParam(),
        "shopUniqueCode": widget.shop.uniqueCode
      }
    };
    print(params);

    setState(() {
      _showSpinner = true;
    });

    try {
      var data = await FoodNetworking().calculateOrder(params);

      if (data) {
        Navigator.pop(context, 'refresh');
      }
    } catch (e) {
      print(e.toString());
      showSimpleFlushBar(e, context);
    } finally {
      setState(() {
        _showSpinner = false;
      });
    }
  }

  _resetSelectedVariantsItems(List<FoodVariantItemModel> foodVariantItems) {
    if (foodVariantItems.length > 0) {
      for (FoodVariantItemModel item in foodVariantItems) {
        item.selected = false;
      }
    }
  }

  int _countSelectedVariants(List<FoodVariantItemModel> foodVariantItems) {
    int count = 0;

    for (FoodVariantItemModel item in foodVariantItems) {
      if (item.selected) {
        count = count + 1;
      }
    }

    print('selected: $count');
    return count;
  }

  Widget _buildFoodVariantsList(
      FoodVariantModel variant, List<FoodVariantItemModel> foodVariantItems) {
    List<Widget> foodList = [];

    if (foodVariantItems.length > 0) {
      for (int i = 0; i < foodVariantItems.length; i++) {
        FoodVariantItemModel variantItem = foodVariantItems[i];

        Widget itemView = CheckboxWithContents(
          onChanged: (value) {
            if (!variantItem.status) {
              return;
            }

            int maxNum = int.parse(variant.variantMax);

            if (maxNum != 0) {
              if (value) {
                if (maxNum == 1) {
                  _resetSelectedVariantsItems(foodVariantItems);
                }

                if (_countSelectedVariants(foodVariantItems) == maxNum) {
                  return;
                }
              }
            }

            setState(() {
              variantItem.selected = value;
            });

            _checkSelectedVariants();
          },
          value: variantItem.selected,
          padding: EdgeInsets.only(top: 0),
          content: Container(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        variantItem.name,
                        style: (variantItem.status)
                            ? kDetailsTextStyle
                            : kDetailsTextStyle.copyWith(
                                color: Colors.grey[400]),
                      ),
                      (!variantItem.status)
                          ? Text(
                              AppTranslations.of(context).text('not_available'),
                              style: kSmallLabelTextStyle.copyWith(
                                  fontFamily: poppinsMedium,
                                  color: Colors.grey[400]),
                            )
                          : Container()
                    ],
                  ),
                ),
                SizedBox(width: 10.0),
                (variantItem.extraPrice != '')
                    ? Container(
                        margin: EdgeInsets.only(right: 10.0),
                        child: Text(
                          '+ RM ${variantItem.extraPrice}',
                          style: (variantItem.status)
                              ? TextStyle(
                                  fontFamily: poppinsSemiBold, fontSize: 16)
                              : TextStyle(
                                  fontFamily: poppinsSemiBold,
                                  fontSize: 16,
                                  color: Colors.grey[400]),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        );

        foodList.add(itemView);

        if (i < foodVariantItems.length - 1) {
          foodList.add(Divider(
            color: Colors.grey,
          ));
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: foodList,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: (widget.food.imageUrl != '') ? true : false,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor:
            (widget.food.imageUrl != '') ? Colors.transparent : kColorRed,
        automaticallyImplyLeading: false,
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 10.0, bottom: 15.0),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                height: 30,
                width: 30,
                margin: EdgeInsets.only(right: 20.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  color: Colors.grey.withOpacity(0.7),
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: _showSpinner,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  color: Colors.grey[100],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      (widget.food.imageUrl != '')
                          ? CachedNetworkImage(
                              imageUrl: widget.food.imageUrl,
                              placeholder: (context, url) =>
                                  CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                              height: 250,
                              fit: BoxFit.cover,
                            )
                          : Container(),
                      Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 15.0),
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    widget.food.name,
                                    style: kTitleTextStyle,
                                  ),
                                ),
                                SizedBox(width: 10.0),
                                Text(
                                  '${AppTranslations.of(context).text('currency_my')} ${widget.food.price}',
                                  style: kTitleTextStyle.copyWith(
                                      fontFamily: poppinsSemiBold),
                                )
                              ],
                            ),
                            Text(
                              widget.food.description,
                              style: kDetailsTextStyle,
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Column(
                        children: List.generate(_selectedFoodVariants.length,
                            (index) {
                          FoodVariantModel variant =
                              _selectedFoodVariants[index];

                          return Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 15.0),
                            color: Colors.white,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  variant.variantName,
                                  style: kTitleTextStyle,
                                ),
                                SizedBox(height: 5.0),
                                Text(
                                  (variant.variantOption == 'required')
                                      ? '${AppTranslations.of(context).text('select')} ${(variant.variantMax == '0') ? '${AppTranslations.of(context).text('at_least')} ${variant.variantMin}' : variant.variantMin}'
                                      : '${AppTranslations.of(context).text('optional')}${(variant.variantMax != '0') ? ', max ${variant.variantMax}' : ''}',
                                  style: kSmallLabelTextStyle.copyWith(
                                      color: Colors.grey),
                                ),
                                SizedBox(height: 15.0),
                                _buildFoodVariantsList(
                                    variant, variant.variantList),
                                SizedBox(height: 20.0),
                              ],
                            ),
                          );
                        }),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 15.0),
                        color: Colors.white,
                        child: Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Text(
                                  AppTranslations.of(context)
                                      .text('special_instructions'),
                                  style: kTitleTextStyle,
                                ),
                                SizedBox(width: 10.0),
                                Text(
                                  AppTranslations.of(context).text('optional'),
                                  style: kSmallLabelTextStyle.copyWith(
                                      color: Colors.grey),
                                )
                              ],
                            ),
                            SizedBox(height: 12.0),
                            InputTextField(
                              inputType: TextInputType.text,
                              initText: widget.remark,
                              hintText: AppTranslations.of(context)
                                  .text('eg_less_ice'),
                              onChange: (value) {
                                _remarkInput = value;
                              },
                            ),
                            SizedBox(height: 35.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (_quantity > 0) {
                                        _quantity = _quantity - 1;
                                      }
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(3.0),
                                    decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(4)),
                                    child: Icon(
                                      Icons.remove,
                                      size: 25,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 25.0),
                                Text(
                                  '$_quantity',
                                  style: kTitleTextStyle,
                                ),
                                SizedBox(width: 25.0),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _quantity = _quantity + 1;
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(3.0),
                                    decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(4)),
                                    child: Icon(
                                      Icons.add,
                                      size: 25,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 120,
                        color: Colors.white,
                      )
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 25.0, horizontal: 15.0),
              child: ActionButton(
                buttonText: (_quantity > 0)
                    ? ((widget.prevOrderedFoodVariants == null)
                        ? 'Add to Cart'
                        : 'Update Cart')
                    : (widget.prevOrderedFoodVariants != null)
                        ? 'Remove from Cart'
                        : 'Back to Menu',
                onPressed: (_canAddToCart)
                    ? () {
                        if (_quantity == 0) {
                          if (widget.prevOrderedFoodVariants != null) {
                            _removeItemFromCart();
                          } else {
                            Navigator.pop(context);
                          }
                        } else {
                          if (FoodOrderModel().hasSelectedShop() &&
                              widget.shop.uniqueCode !=
                                  FoodOrderModel().getShopUniqueCode()) {
                            _showDiscardPreviousOrderDialog();
                          } else {
                            addFoodToCart();
                          }
                        }
                      }
                    : null,
              ),
            )
          ],
        ),
      ),
    );
  }
}
