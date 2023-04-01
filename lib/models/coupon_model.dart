class Coupon {
  Coupon({
    this.couponId,
    this.couponName,
    this.couponType,
    this.couponDiscount,
    this.couponStartedDatetime,
    this.couponExpiryDatetime,
    this.couponCreatedDatetime,
    this.couponStatus,
    this.couponCountry,
    this.couponPlatform,
    this.couponQuantity,
    this.couponMinPurchase,
    this.couponTimeFrom,
    this.couponTimeTo,
    this.couponUsageLimit,
    this.couponFirstTimeUser,
    this.couponOwner,
    this.couponCompany,
    this.couponDescription,
    this.couponHideStatus,
    this.couponActiveStatus,
    this.couponInactiveReason,
  });

  String couponId;
  String couponName;
  String couponType;
  String couponDiscount;
  dynamic couponStartedDatetime;
  dynamic couponExpiryDatetime;
  DateTime couponCreatedDatetime;
  String couponStatus;
  String couponCountry;
  String couponPlatform;
  String couponQuantity;
  String couponMinPurchase;
  dynamic couponTimeFrom;
  dynamic couponTimeTo;
  String couponUsageLimit;
  dynamic couponFirstTimeUser;
  String couponOwner;
  String couponCompany;
  String couponDescription;
  String couponHideStatus;
  String couponActiveStatus;
  dynamic couponInactiveReason;

  factory Coupon.fromJson(Map<String, dynamic> json) => Coupon(
        couponId: json["coupon_id"],
        couponName: json["coupon_name"],
        couponType: json["coupon_type"],
        couponDiscount: json["coupon_discount"],
        couponStartedDatetime: json["coupon_started_datetime"] ?? null,
        couponExpiryDatetime: json["coupon_expiry_datetime"] ?? null,
        couponCreatedDatetime: DateTime.parse(json["coupon_created_datetime"]),
        couponStatus: json["coupon_status"],
        couponCountry: json["coupon_country"],
        couponPlatform: json["coupon_platform"],
        couponQuantity: json["coupon_quantity"],
        couponMinPurchase: json["coupon_min_purchase"],
        couponTimeFrom: json["coupon_time_from"],
        couponTimeTo: json["coupon_time_to"],
        couponUsageLimit: json["coupon_usage_limit"],
        couponFirstTimeUser: json["coupon_first_time_user"],
        couponOwner: json["coupon_owner"],
        couponCompany: json["coupon_company"],
        couponDescription: json["coupon_description"],
        couponHideStatus: json["coupon_hide_status"],
        couponActiveStatus: json["couponActiveStatus"],
        couponInactiveReason: json["couponInactiveReason"],
      );

  Map<String, dynamic> toJson() => {
        "coupon_id": couponId,
        "coupon_name": couponName,
        "coupon_type": couponType,
        "coupon_discount": couponDiscount,
        "coupon_started_datetime": couponStartedDatetime,
        "coupon_expiry_datetime": couponExpiryDatetime,
        "coupon_created_datetime": couponCreatedDatetime.toIso8601String(),
        "coupon_status": couponStatus,
        "coupon_country": couponCountry,
        "coupon_platform": couponPlatform,
        "coupon_quantity": couponQuantity,
        "coupon_min_purchase": couponMinPurchase,
        "coupon_time_from": couponTimeFrom,
        "coupon_time_to": couponTimeTo,
        "coupon_usage_limit": couponUsageLimit,
        "coupon_first_time_user": couponFirstTimeUser,
        "coupon_owner": couponOwner,
        "coupon_company": couponCompany,
        "coupon_description": couponDescription,
        "coupon_hide_status": couponHideStatus,
        "couponActiveStatus": couponActiveStatus,
        "couponInactiveReason": couponInactiveReason,
      };
}
