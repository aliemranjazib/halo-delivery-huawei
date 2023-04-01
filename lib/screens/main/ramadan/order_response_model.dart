// To parse this JSON data, do
//
//     final orderResponse = orderResponseFromJson(jsonString);

import 'dart:convert';

class OrderResponse {
  OrderResponse({
    this.msg,
    this.response,
  });

  String msg;
  Response response;

  factory OrderResponse.fromRawJson(String str) =>
      OrderResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory OrderResponse.fromJson(Map<String, dynamic> json) => OrderResponse(
        msg: json["msg"],
        response: Response.fromJson(json["response"]),
      );

  Map<String, dynamic> toJson() => {
        "msg": msg,
        "response": response.toJson(),
      };
}

class Response {
  Response({
    this.finalPrice,
    this.foodFinalPrice,
    this.estDuration,
    this.shopDeliveryInterval,
    this.overtimeStatus,
    this.deliveryFee,
    this.orderDetails,
    this.orderUniqueKey,
    this.minFee,
    this.packingFee,
    this.orderFoodSst,
    this.preOrder,
    this.paymentFee,
    this.userBalance,
    this.autoDiscount,
    this.paymentMethodSelected,
    this.paymentMethod,
    this.paymentMethodWithIcon,
    this.showPreOrderStatus,
  });

  String finalPrice;
  String foodFinalPrice;
  int estDuration;
  String shopDeliveryInterval;
  String overtimeStatus;
  String deliveryFee;
  List<OrderDetail> orderDetails;
  String orderUniqueKey;
  String minFee;
  String packingFee;
  String orderFoodSst;
  List<PreOrder> preOrder;
  String paymentFee;
  String userBalance;
  String autoDiscount;
  String paymentMethodSelected;
  List<String> paymentMethod;
  List<PaymentMethodWithIcon> paymentMethodWithIcon;
  String showPreOrderStatus;

  factory Response.fromRawJson(String str) =>
      Response.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Response.fromJson(Map<String, dynamic> json) => Response(
        finalPrice: json["finalPrice"],
        foodFinalPrice: json["foodFinalPrice"],
        estDuration: json["estDuration"],
        shopDeliveryInterval: json["shop_delivery_interval"],
        overtimeStatus: json["overtimeStatus"],
        deliveryFee: json["deliveryFee"],
        orderDetails: List<OrderDetail>.from(
            json["orderDetails"].map((x) => OrderDetail.fromJson(x))),
        orderUniqueKey: json["orderUniqueKey"],
        minFee: json["min_fee"],
        packingFee: json["packing_fee"],
        orderFoodSst: json["order_food_sst"],
        preOrder: List<PreOrder>.from(
            json["preOrder"].map((x) => PreOrder.fromJson(x))),
        paymentFee: json["paymentFee"],
        userBalance: json["userBalance"],
        autoDiscount: json["autoDiscount"],
        paymentMethodSelected: json["paymentMethodSelected"],
        paymentMethod: List<String>.from(json["paymentMethod"].map((x) => x)),
        paymentMethodWithIcon: List<PaymentMethodWithIcon>.from(
            json["paymentMethodWithIcon"]
                .map((x) => PaymentMethodWithIcon.fromJson(x))),
        showPreOrderStatus: json["showPreOrderStatus"],
      );

  Map<String, dynamic> toJson() => {
        "finalPrice": finalPrice,
        "foodFinalPrice": foodFinalPrice,
        "estDuration": estDuration,
        "shop_delivery_interval": shopDeliveryInterval,
        "overtimeStatus": overtimeStatus,
        "deliveryFee": deliveryFee,
        "orderDetails": List<dynamic>.from(orderDetails.map((x) => x.toJson())),
        "orderUniqueKey": orderUniqueKey,
        "min_fee": minFee,
        "packing_fee": packingFee,
        "order_food_sst": orderFoodSst,
        "preOrder": List<dynamic>.from(preOrder.map((x) => x.toJson())),
        "paymentFee": paymentFee,
        "userBalance": userBalance,
        "autoDiscount": autoDiscount,
        "paymentMethodSelected": paymentMethodSelected,
        "paymentMethod": List<dynamic>.from(paymentMethod.map((x) => x)),
        "paymentMethodWithIcon":
            List<dynamic>.from(paymentMethodWithIcon.map((x) => x.toJson())),
        "showPreOrderStatus": showPreOrderStatus,
      };
}

class OrderDetail {
  OrderDetail({
    this.name,
    this.foodId,
    this.quantity,
    this.price,
    this.costPrice,
    this.finalPrice,
    this.finalCostPrice,
    this.priceOri,
    this.finalPriceOri,
    this.costPriceOri,
    this.finalCostPriceOri,
    this.remark,
  });

  String name;
  String foodId;
  String quantity;
  String price;
  String costPrice;
  String finalPrice;
  String finalCostPrice;
  String priceOri;
  String finalPriceOri;
  String costPriceOri;
  String finalCostPriceOri;
  String remark;

  factory OrderDetail.fromRawJson(String str) =>
      OrderDetail.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory OrderDetail.fromJson(Map<String, dynamic> json) => OrderDetail(
        name: json["name"],
        foodId: json["foodId"],
        quantity: json["quantity"],
        price: json["price"],
        costPrice: json["costPrice"],
        finalPrice: json["finalPrice"],
        finalCostPrice: json["finalCostPrice"],
        priceOri: json["priceOri"],
        finalPriceOri: json["finalPriceOri"],
        costPriceOri: json["costPriceOri"],
        finalCostPriceOri: json["finalCostPriceOri"],
        remark: json["remark"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "foodId": foodId,
        "quantity": quantity,
        "price": price,
        "costPrice": costPrice,
        "finalPrice": finalPrice,
        "finalCostPrice": finalCostPrice,
        "priceOri": priceOri,
        "finalPriceOri": finalPriceOri,
        "costPriceOri": costPriceOri,
        "finalCostPriceOri": finalCostPriceOri,
        "remark": remark,
      };
}

class PaymentMethodWithIcon {
  PaymentMethodWithIcon({
    this.methodName,
    this.methodDisplayName,
    this.methodIconUrl,
  });

  String methodName;
  String methodDisplayName;
  String methodIconUrl;

  factory PaymentMethodWithIcon.fromRawJson(String str) =>
      PaymentMethodWithIcon.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PaymentMethodWithIcon.fromJson(Map<String, dynamic> json) =>
      PaymentMethodWithIcon(
        methodName: json["method_name"],
        methodDisplayName: json["method_display_name"],
        methodIconUrl: json["method_icon_url"],
      );

  Map<String, dynamic> toJson() => {
        "method_name": methodName,
        "method_display_name": methodDisplayName,
        "method_icon_url": methodIconUrl,
      };
}

class PreOrder {
  PreOrder({
    this.the20230316,
  });

  List<String> the20230316;

  factory PreOrder.fromRawJson(String str) =>
      PreOrder.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PreOrder.fromJson(Map<String, dynamic> json) => PreOrder(
        the20230316: List<String>.from(json["2023-03-16"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "2023-03-16": List<dynamic>.from(the20230316.map((x) => x)),
      };
}
