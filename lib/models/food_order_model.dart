import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:haloapp/models/address_model.dart';
import 'package:haloapp/models/food_variant_model.dart';
import 'package:haloapp/models/shop_model.dart';

import 'app_config_model.dart';

class FoodOrderModel {
  FoodOrderModel._privateConstructor();
  static final FoodOrderModel _instance = FoodOrderModel._privateConstructor();
  static ValueNotifier<List<FoodOrderCart>> orderCartNotifier =
      ValueNotifier([]);
  static ValueNotifier<AddressModel> deliverAddressNotifier =
      ValueNotifier(null);

  factory FoodOrderModel() {
    return _instance;
  }

  FoodOption foodOption;

  Map _offlineAddress = Map();
  AddressModel _deliverAddress;
  ShopModel _shop;
  List<FoodOrderCart> _orderCart = [];
  List<dynamic> _validPaymentMethods = [];

  // for after calculation
  String _foodFinalPrice;
//  List<FoodOrderCart> _orderDetails = [];

  String _finalPrice;
  String _estDuration;
  String _deliveryFee;
  String _packingFee;
  String _orderFoodSST;
  String _minFee;
  String _paymentFee;
  String _autoDiscount;
  String _paymentMethod;
  String _orderUniqueKey;
  List<dynamic> _availableDates = [];
  int _deliveryInterval;
  String _overtimeStatus;
  String _paymentMethodSelected;

  void clearFoodOrderData() {
    this._shop = null;
    this._orderCart.clear();
    orderCartNotifier.value.clear();
    this._foodFinalPrice = null;
    this._finalPrice = null;
    this._deliveryFee = null;
    this._packingFee = null;
    this._orderUniqueKey = null;
    this._estDuration = null;
    this._orderFoodSST = null;
    this._minFee = null;
    this._paymentFee = null;
    this._paymentMethod = null;
    this._availableDates = [];
    this._deliveryInterval = null;
    this._overtimeStatus = null;
    this._paymentMethodSelected = null;
  }

  int isSameFood(FoodOrderCart order) {
    for (var i = 0; i < _orderCart.length; i++) {
      bool isSame = order.getCreateOrderParam().toString() ==
          _orderCart[i].getCreateOrderParam().toString();

      // print('new item ');
      print(order.getCreateOrderParam().toString());

      // print('old item at index $i');
      print(_orderCart[i].getCreateOrderParam().toString());

      // print('is same: $isSame');

      if (isSame) {
        return i;
      }

      // print(_orderCart[i].getCreateOrderParam());
      // var isSame = order.getCreateOrderParam().toString() ==
      //     _orderCart[i].getCreateOrderParam().toString();
      // print("$i -- ${isSame}");
      // // if(isSame){
      // //   return i;
      // // }
      // var itemOrder = _orderCart[i];
      // if (itemOrder.foodId == order.foodId) {
      //   var isSame = true;
      //   // print("itemOrder == ${itemOrder.remark}");
      //   // print("order == ${order.remark}");

      //   isSame = isSame && (itemOrder.remark == order.remark);
      //   // print("isSame == $isSame");
      //   // print("dddd");
      //   FoodVariantItemModel orderOptions;
      //   try {
      //     itemOrder.options.forEach((element) {
      //       try {
      //         orderOptions = order.options.firstWhere((innerElement) =>
      //             (element.variantId == innerElement.variantId) &&
      //             (element.selected && innerElement.selected));
      //       } catch (e) {
      //         print(e);
      //       }
      //     });
      //   } catch (e) {
      //     print(e);
      //   }

      //   print("orderOptions ${orderOptions == null}");

      //   if (orderOptions != null) {
      //     return i;
      //   }
      // }
    }

    return null;
  }

  void addFoodInCart(FoodOrderCart order) {
    var index = isSameFood(order);
    if (index != null) {
      _orderCart.elementAt(index).quantity =
          (int.parse(_orderCart.elementAt(index).quantity) +
                  int.parse(order.quantity))
              .toString();
    } else {
      _orderCart.add(order);
    }

    if (index != null) {
    } else {
      orderCartNotifier.value = List.from(orderCartNotifier.value)..add(order);
    }
  }

  void removeFoodFromCart(int index) {
    _orderCart.removeAt(index);
    orderCartNotifier.value = List.from(orderCartNotifier.value)
      ..removeAt(index);
  }

  void setDeliverAddress(AddressModel address) {
    this._deliverAddress = address;
    deliverAddressNotifier.value = address;
  }

  void setDeliveryInterval(int v) {
    this._deliveryInterval = v;
  }

  void setOfflineAddress(Map address) {
    this._offlineAddress = address;
  }

  Map getOfflineAddress() {
    return this._offlineAddress;
  }

  void setShop(ShopModel shop) {
    this._shop = shop;
  }

  void clearOrderDetails() {
    this._orderCart.clear();
    orderCartNotifier.value = List.from(orderCartNotifier.value)..clear();
  }

  void setCalculatedFoodFinalPrice(String price) {
    this._foodFinalPrice = price;
  }

  void setCreatedOrderPrice(
      {String finalPrice,
      String foodFinalPrice,
      String estDuration,
      String deliveryFee,
      String packingFee,
      String orderFoodSST,
      String minFee,
      String paymentFee,
      String autoDiscount}) {
    this._finalPrice = finalPrice;
    this._foodFinalPrice = foodFinalPrice;
    this._estDuration = estDuration;
    this._deliveryFee = deliveryFee;
    this._packingFee = packingFee;
    this._orderFoodSST = orderFoodSST;
    this._minFee = minFee;
    this._paymentFee = paymentFee;
    this._autoDiscount = autoDiscount;
  }

  void setAvailableDates(List<dynamic> dates) {
    this._availableDates = dates;
  }

  void setPaymentMethod(String method) {
    this._paymentMethod = method;
  }

  void setPaymentMethodSelected(String selectMethod) {
    this._paymentMethodSelected = selectMethod;
  }

  void setOrderCart(List<FoodOrderCart> orders) {
    this._orderCart = orders;
    orderCartNotifier.value = List.from(orderCartNotifier.value)
      ..addAll(orders);
  }

  void setPaymentMethods(List<dynamic> validPaymentMethods) {
    this._validPaymentMethods = validPaymentMethods;
  }

  void setOvertimeStatus(String status) {
    this._overtimeStatus = status;
  }

  void updateOrderInCart(int index, FoodOrderCart updatedOrder) {
    FoodOrderCart order = FoodOrderCart(
      foodId: updatedOrder.foodId,
      name: updatedOrder.name,
      quantity: updatedOrder.quantity,
      options: updatedOrder.options,
      price: updatedOrder.price,
      finalPrice: updatedOrder.finalPrice,
      remark: updatedOrder.remark,
    );

    this._orderCart[index] = order;
    orderCartNotifier.value[index] = order;
  }

  void setOrderUniqueKey(String key) {
    this._orderUniqueKey = key;
  }

  AddressModel getDeliveryAddress() => this._deliverAddress;
  bool hasSelectedShop() => (this._shop == null) ? false : true;
  ShopModel getShop() => this._shop;
  String getShopUniqueCode() => this._shop.uniqueCode;
  String getShopName() => this._shop.shopName;
  String getFoodFinalPrice() => this._foodFinalPrice;
  String getFinalPrice() => this._finalPrice;
  String getEstDuration() => this._estDuration;
  String getDeliveryFee() => this._deliveryFee;
  String getOrderFoodSST() => this._orderFoodSST;
  String getAutoDiscount() => this._autoDiscount;
  String getMinFee() => this._minFee;
  String getPaymentFee() => this._paymentFee;
  String getPackingFee() => this._packingFee;
  String getOrderUniqueKey() => this._orderUniqueKey;
  List<FoodOrderCart> getOrderCart() => this._orderCart;
  List<dynamic> getAvailableDates() => this._availableDates;
  int getDeliveryInterval() => this._deliveryInterval;
  String getPaymentMethod() => this._paymentMethod;
  List<dynamic> getPaymentMethods() => this._validPaymentMethods;
  String getOverTimeStatus() => this._overtimeStatus;
  String getPaymentMethodSelected() => this._paymentMethodSelected;

  List<Map<String, dynamic>> getOrderCartParam() {
    List<Map<String, dynamic>> orderCartDataList = [];

    if (this._orderCart.length > 0) {
      for (FoodOrderCart order in this._orderCart) {
        List<Map<String, dynamic>> itemDataList = [];

        if (order.options.length > 0) {
          for (FoodVariantItemModel item in order.options) {
            itemDataList.add({"variantId": item.variantId});
          }
        }

        Map<String, dynamic> orderData = {
          "foodId": order.foodId,
          "quantity": order.quantity,
          "options": itemDataList,
          "remark": order.remark
        };

        orderCartDataList.add(orderData);
      }
    }

    return orderCartDataList;
  }

  Map<String, dynamic> getCreateOrderParam() {
    Map<String, dynamic> orderData = {
      "lat": this._deliverAddress.lat,
      "lng": this._deliverAddress.lng,
      "note": this._deliverAddress.note ?? '',
      "fullAddress": this._deliverAddress.fullAddress,
      "buildingName": this._deliverAddress.buildingName ?? '',
      "buildingUnit": this._deliverAddress.unitNo ?? '',
      "street": this._deliverAddress.street,
      "zip": this._deliverAddress.zip,
      "city": this._deliverAddress.city,
      "state": this._deliverAddress.state,
      "orderCart": getOrderCartParam(),
      "shopUniqueCode": this._shop.uniqueCode,
      "orderUniqueKey":
          (this._orderUniqueKey != null) ? this._orderUniqueKey : '',
      "paymentMethod": this._paymentMethod
    };

    return orderData;
  }
}

class FoodOrderCart {
  String foodId;
  String name = '';
  String quantity;
  List<FoodVariantItemModel> options = [];
  String price = '';
  String finalPrice = '';
  String remark = '';

  FoodOrderCart({
    this.foodId,
    this.name,
    this.quantity,
    this.options,
    this.price,
    this.finalPrice,
    this.remark,
  });

  Map<String, dynamic> getCreateOrderParam() {
    Map<String, dynamic> orderData = {
      "foodId": this.foodId,
      // "name": this.name,
      // "quantity": this.quantity,
      // "price": this.price,
      // "finalPrice": this.finalPrice,
      "remark": this.remark,
      "options": getOrderCartParam()
    };

    return orderData;
  }

  List<Map<String, dynamic>> getOrderCartParam() {
    List<Map<String, dynamic>> orderCartDataList = [];

    if (this.options.length > 0) {
      for (FoodVariantItemModel order in this.options) {
        Map<String, dynamic> orderData = {
          "variantId": order.variantId,
          // "name": order.name,
          // "extraPrice": order.extraPrice,
          // "status": order.status,
          "selected": order.selected
        };

        orderCartDataList.add(orderData);
      }
    }

    return orderCartDataList;
  }
}
