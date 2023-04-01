class AddressModel {
  String name;
  String note;
  String type;
  String fullAddress;
  String lat;
  String lng;
  String street;
  String zip;
  String city;
  String state;
  String unitNo;
  String buildingName;
  String receiverName;
  String receiverPhone;
  String remarks;
  String addressId;
  bool paymentCollect;

  AddressModel({
    this.name,
    this.note,
    this.type,
    this.fullAddress,
    this.lat,
    this.lng,
    this.street,
    this.zip,
    this.city,
    this.state,
    this.unitNo,
    this.buildingName,
    this.receiverName,
    this.receiverPhone,
    this.remarks,
    this.addressId,
    this.paymentCollect,
  });
}
