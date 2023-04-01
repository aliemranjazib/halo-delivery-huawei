import 'package:haloapp/models/address_model.dart';
import 'package:haloapp/models/item_type_model.dart';
import 'package:haloapp/models/user_model.dart';
import 'package:haloapp/models/vehicle_model.dart';
import 'dart:io';

class BookingModel {
  BookingModel._privateConstructor();
  static final BookingModel _instance = BookingModel._privateConstructor();

  factory BookingModel() {
    return _instance;
  }

  List<AddressModel> _addresses = [];
  VehicleModel _vehicle;
  String _distance;
  String _distancePrice;
  String _pickupDate;
  String _pickupTime;
  String _attachedImage;
  String _imageUrl;
  String _imageDescp;
  String _remarks = '';
  String _couponCode = '';
  String _bookingUniqueKey = '';
  String _paymentMethod = '';
  String _totalPrice = '';
  String _paymentAtAddressId = '';
  ItemTypeModel _itemType;
  String _itemTypeDesc = '';
  String _priorityFee = '';
  List<dynamic> _validPaymentMethods = [];

  void clearBookingData() {
    this._addresses.clear();
    this._vehicle = null;
    this._distance = null;
    this._distancePrice = null;
    this._pickupDate = null;
    this._pickupTime = null;
    this._attachedImage = null;
    this._imageUrl = null;
    this._imageDescp = null;
    this._remarks = '';
    this._couponCode = '';
    this._bookingUniqueKey = '';
    this._paymentMethod = '';
    this._totalPrice = '';
    this._paymentAtAddressId = '';
    this._itemType = null;
    this._itemTypeDesc = '';
    this._priorityFee = '';
  }

  AddressModel getAddressAtIndex(int index) => _addresses[index];
  List<AddressModel> getAllAddresses() => _addresses;

  void addAddress(AddressModel address) {
    this._addresses.add(address);
  }

  void replaceAddressAtIndex(int index, AddressModel address) {
    this._addresses[index] = address;
  }

  void removeAddressAtIndex(int index) {
    this._addresses.removeAt(index);
  }

  void removeAllDropoffAddresses() {
    this._addresses.removeRange(1, _addresses.length);
  }

  void setVehicle(VehicleModel vehicle) {
    this._vehicle = vehicle;
  }

  void setDistanceAndPrice(String distance, String price) {
    this._distance = distance;
    this._distancePrice = price;
  }

  void setPickupDateAndTime(String date, String time) {
    this._pickupDate = date;
    this._pickupTime = time;
  }

  void setPhotoAndDescription(
      String photo, String photoUrl, String description) {
    this._attachedImage = photo;
    this._imageUrl = photoUrl;
    this._imageDescp = description;
  }

  void setRemarks(String remarks) {
    this._remarks = remarks;
  }

  void setDeliveryItemDetails(ItemTypeModel itemType, String itemTypeDesc) {
    this._itemType = itemType;
    this._itemTypeDesc = itemTypeDesc;
  }

  void setCouponCode(String code) {
    this._couponCode = code;
  }

  void setPriorityFee(String amount) {
    this._priorityFee = amount;
  }

  void setPaymentCollectionAddressId(String id) {
    this._paymentAtAddressId = id;
  }

  void setPaymentMethod(String method) {
    this._paymentMethod = method;
  }

  void setCreatedBookingData(
      {String key, String totalPrice, List<AddressModel> addresses}) {
    this._bookingUniqueKey = key;
    this._totalPrice = totalPrice;
    this._addresses = addresses;
    this._paymentAtAddressId = '';
  }

  void setPaymentMethods(List<dynamic> validPaymentMethods) {
    this._validPaymentMethods = validPaymentMethods;
  }

  VehicleModel getVehicle() => _vehicle;
  String getPickupDate() => _pickupDate;
  String getPickupTime() => _pickupTime;
  String getAttachedImage() => _attachedImage;
  String getImageDescription() => _imageDescp;
  String getBookingRemarks() => _remarks;
  String getDeliveryDistance() => _distance;
  String getDistancePrice() => _distancePrice;
  String getTotalPrice() => _totalPrice;
  String getBookingUniqueKey() => _bookingUniqueKey;
  String getSelectedAddressIdToCollectPayment() => _paymentAtAddressId;
  String getCouponCode() => _couponCode;
  String getPaymentMethod() => _paymentMethod;
  ItemTypeModel getDeliveryItemType() => _itemType;
  String getDeliveryItemDesc() => _itemTypeDesc;
  String getPriorityFee() => _priorityFee;

  List<Map<String, dynamic>> getAddressesListData() {
    List<Map<String, dynamic>> addressDataList = [];

    if (this._addresses.length > 0) {
      for (int i = 0; i < this._addresses.length; i++) {
        AddressModel address = this._addresses[i];

        Map<String, dynamic> addressData = {
          "type": (i == 0) ? 'pickup' : 'dropoff',
          "fullAddress": address.fullAddress ?? '',
          "buildingName": address.buildingName ?? '',
          "buildingUnit": address.unitNo ?? '',
          "street": address.street ?? '',
          "zip": address.zip ?? '',
          "city": address.city ?? '',
          "state": address.state ?? '',
          "lat": address.lat,
          "lng": address.lng,
          "distance": '',
          "recipientName": address.receiverName,
          "recipientPhone": address.receiverPhone
        };

        addressDataList.add(addressData);
      }
    }

    return addressDataList;
  }

  Map<String, dynamic> getBookingData() {
    List<Map<String, dynamic>> addressDataList = getAddressesListData();

    return {
      "bookingUniqueKey": this._bookingUniqueKey,
      "userToken": User().getUserToken(),
      "userName": User().getUsername(),
      "userPhoneCountry": User().getUserPhoneCountryCode(),
      "userPhone": User().getUserPhone(),
      "userEmail": User().getUserEmail(),
      "vehicleType": this._vehicle.id,
      "pickupDate": this._pickupDate,
      "pickupTime": this._pickupTime,
      "distance": this._distance,
      "distancePrice": this._distancePrice,
      "remarks": this._remarks ?? '',
      "itemType": this._itemType.name,
      "itemTypeDesc": this._itemTypeDesc ?? '',
      "priorityFee": this._priorityFee ?? '',
      "addresses": addressDataList,
      "platform": (Platform.isIOS) ? 'ios' : 'android',
    };
  }

  Map<String, dynamic> getConfirmedBookingData() {
    List<Map<String, dynamic>> addressDataList = getAddressesListData();

    return {
      "bookingUniqueKey": this._bookingUniqueKey,
      "userToken": User().getUserToken(),
      "userName": User().getUsername(),
      "userPhoneCountry": User().getUserPhoneCountryCode(),
      "userPhone": User().getUserPhone(),
      "userEmail": User().getUserEmail(),
      "vehicleType": this._vehicle.id,
      "pickupDate": this._pickupDate,
      "pickupTime": this._pickupTime,
      "distance": this._distance,
      "distancePrice": this._distancePrice,
      "remarks": this._remarks ?? '',
      "itemType": this._itemType.name,
      "itemTypeDesc": this._itemTypeDesc ?? '',
      "priorityFee": this._priorityFee ?? '',
      "addresses": addressDataList,
      "platform": (Platform.isIOS) ? 'ios' : 'android',
      "paymentMethod": _paymentMethod,
      "imageUrl": this._imageUrl,
      "imageDescription": this._imageDescp ?? '',
      "couponName": this._couponCode ?? '',
      "addressId": this._paymentAtAddressId,
    };
  }

  List<dynamic> getPaymentMethods() => this._validPaymentMethods;
}
