import 'package:haloapp/models/address_model.dart';

class HistoryModel {
  final String bookingId;
  final String bookingUniqueKey;
  final String bookingNumber;
  final String orderStatus;
  final String bookingDate;
  final String pickupDatetime;
  final String pickupDate;
  final String pickupTime;
  final String driverName;
  final String driverPhone;
  final String driverPlateNumber;
  final String vehicleTypeId;
  final String distance;
  final String distancePrice;
  final String totalPrice;
  final String totalPriceOri;
  final String discountedPrice;
  final String remarks;
  final String paymentMethod;
  final String customerComment;
  final String customerRating;
  final String couponName;
  final String couponType;
  final String couponDiscount;
  final String itemType;
  final String itemTypeDesc;
  final String priorityFee;
  final String buildingName;
  final String buildingUnitNumber;
  final List<AddressModel> addresses;
  final String bookingHaloWalletAmount;
  final String bookingCodAmount;

  HistoryModel(
      {this.bookingId,
      this.bookingUniqueKey,
      this.bookingNumber,
      this.orderStatus,
      this.bookingDate,
      this.pickupDatetime,
      this.pickupDate,
      this.pickupTime,
      this.driverName,
      this.driverPhone,
      this.driverPlateNumber,
      this.vehicleTypeId,
      this.distance,
      this.distancePrice,
      this.totalPrice,
      this.totalPriceOri,
      this.discountedPrice,
      this.remarks,
      this.paymentMethod,
      this.customerComment,
      this.customerRating,
      this.couponName,
      this.couponType,
      this.couponDiscount,
      this.itemType,
      this.itemTypeDesc,
      this.priorityFee,
      this.buildingName,
      this.buildingUnitNumber,
      this.addresses,
      this.bookingHaloWalletAmount,
      this.bookingCodAmount
  });
}
