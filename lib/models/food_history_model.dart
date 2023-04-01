import 'package:haloapp/models/food_order_model.dart';

class FoodHistoryModel {
  String id;
  String orderNum;
  String orderUniqueKey;
  String orderPrice;
  String orderPriceOri;
  String orderPriceDiscount;
  String orderAutoDiscount;
  String orderFoodSST;
  String orderStatus;
  String shopId;
  String orderPickupDatetime;
  String orderPackingFee;
  String orderDeliveryFee;
  String minimumCharges;
  String paymentCharges;
  String totalDistance;
  String orderDeliveryAddress;
  String paymentMethod;
  String orderRemarks;
  String orderRating;
  String orderComments;
  String orderCodAmount;
  String orderHaloWalletAmount;
  String shopName;
  String shopPhone;
  String shopBuildingName;
  String shopFullAddress;
  String buildingName;
  String buildingUnitNumber;
  String shopLogoUrl;
  String shopLat;
  String shopLng;
  bool shopPartner;
  int shopDeliveryInterval;
  String customerLat;
  String customerLng;
  List<FoodOrderCart> orderItems = [];
  String street;
  String userName;
  String userPhone;
  String refundAvailableStatus;
  String payAgainStatus;
  String bookingRefundStatus;
  String showRefundDetailStatus;
  String bookingRefundRemark;
  String bookingRefundCreatedDatetime;
  String bookingRefundUpdateDatetime;
  String bookingRefundReceiptUrl;
  String customerPayRiderCash;
  String orderMerchantRemark;
  FoodHistoryModel(
      {this.id,
      this.orderNum,
      this.orderUniqueKey,
      this.orderPrice,
      this.orderPriceOri,
      this.orderPriceDiscount,
      this.orderFoodSST,
      this.orderAutoDiscount,
      this.orderStatus,
      this.shopId,
      this.orderPickupDatetime,
      this.orderPackingFee,
      this.orderDeliveryFee,
      this.minimumCharges,
      this.paymentCharges,
      this.totalDistance,
      this.orderDeliveryAddress,
      this.paymentMethod,
      this.orderRemarks,
      this.orderRating,
      this.orderComments,
      this.orderCodAmount,
      this.orderHaloWalletAmount,
      this.shopName,
      this.shopPhone,
      this.shopBuildingName,
      this.shopFullAddress,
      this.buildingName,
      this.buildingUnitNumber,
      this.shopLogoUrl,
      this.shopLat,
      this.shopLng,
      this.shopDeliveryInterval,
        this.shopPartner,
        this.customerLat,
      this.customerLng,
      this.orderItems,
      this.street,
      this.userName,
      this.userPhone,
      this.refundAvailableStatus,
      this.payAgainStatus,
      this.bookingRefundCreatedDatetime,
      this.bookingRefundRemark,
      this.bookingRefundStatus,
      this.bookingRefundUpdateDatetime,
      this.showRefundDetailStatus,
      this.customerPayRiderCash,
      this.bookingRefundReceiptUrl,
      this.orderMerchantRemark});

  factory FoodHistoryModel.fromJson(Map order) {
    return FoodHistoryModel(
        id: order['order_id'] ?? '',
        orderNum: order['order_number'] ?? '',
        orderUniqueKey: order['order_unique_key'] ?? '',
        orderPrice: order['order_price'] ?? '',
        orderPriceOri: order['order_price_ori'] ?? '',
        orderPriceDiscount: order['order_price_discount'] ?? '',
        orderFoodSST: order['order_food_sst'] ?? '0',
        orderAutoDiscount: order['auto_discount'] ?? '0.0',
        orderStatus: order['orderStatus'] ?? '',
        shopId: order['shop_id'] ?? '',
        orderPickupDatetime: order['order_pickup_datetime'] ?? '',
        orderDeliveryFee: order['order_delivery_fee'] ?? '',
        orderPackingFee: order['order_packing_fee'] ?? '0',
        minimumCharges: order['minimum_chargers'] ?? '0',
        paymentCharges: order['payment_chargers'] ?? '0',
        totalDistance: order['order_total_distance'] ?? '',
        orderDeliveryAddress: order['full_address'] ?? '',
        paymentMethod: order['payment_method'] ?? '',
        orderRemarks: order['order_remarks'] ?? '',
        orderRating: order['customer_rating'] ?? '',
        orderComments: order['customer_comment'] ?? '',
        orderCodAmount: order['order_cod_amount'] ?? '',
        orderHaloWalletAmount: order['order_halowallet_amount'] ?? '',
        shopName: order['shop_name'] ?? '',
        shopPhone: order['shop_phone'] ?? '',
        shopBuildingName: order['shop_building_name'] ?? '',
        shopFullAddress: order['shop_fulladdress'] ?? '',
        buildingName: order['building_name'] ?? '',
        buildingUnitNumber: order['building_unit_number'] ?? '',
        shopLogoUrl: order['shop_logo_url'] ?? '',
        shopLat: order['shop_lat'] ?? '',
        shopLng: order['shop_lng'] ?? '',
        shopDeliveryInterval:
            int.tryParse(order['shop_delivery_interval']) ?? 0,
        shopPartner: order['shop_partner'] == "true",
        customerLat: order['lat'] ?? '',
        customerLng: order['lng'] ?? '',
        orderItems: order['order_items'],
        street: order['street'] ?? '',
        userName: order['user_name'] ?? '',
        userPhone: order['user_phone'] ?? '',
        refundAvailableStatus: order['refundAvailableStatus'] ?? '',
        showRefundDetailStatus: order['showRefundDetailStatus'] == null
            ? ''
            : order['showRefundDetailStatus'],
        payAgainStatus: order['payAgainStatus'] ?? '',
        bookingRefundUpdateDatetime:
            order['booking_refund_update_datetime'] == null
                ? ''
                : order['booking_refund_update_datetime'],
        bookingRefundStatus: order['booking_refund_status'] == null
            ? ''
            : order['booking_refund_status'],
        bookingRefundRemark: order['booking_refund_remark'] == null
            ? ''
            : order['booking_refund_remark'],
        bookingRefundCreatedDatetime:
            order['booking_refund_created_datetime'] == null
                ? ''
                : order['booking_refund_created_datetime'],
        bookingRefundReceiptUrl: order['booking_refund_receipt_url'] == null
            ? ''
            : order['booking_refund_receipt_url'],
        customerPayRiderCash: order['customerPayRiderCash'] ?? '',
        orderMerchantRemark : order['order_merchant_remarks'] == null
            ? ''
            : order['order_merchant_remarks']);
  }
}
