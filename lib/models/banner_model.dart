/// reviewBanner : {"en":{"redirectUrl":"","imageUrl":"https://halorider.oss-ap-southeast-3.aliyuncs.com/payment_banner/covid_en.jpeg"},"bm":{"redirectUrl":"","imageUrl":"https://halorider.oss-ap-southeast-3.aliyuncs.com/payment_banner/covid_bm.jpeg"},"cn":{"redirectUrl":"","imageUrl":"https://halorider.oss-ap-southeast-3.aliyuncs.com/payment_banner/covid_cn.jpeg"}}

class BannerModel {
  ReviewBanner _reviewBanner;

  ReviewBanner get reviewBanner => _reviewBanner;

  BannerModel({
      ReviewBanner reviewBanner}){
    _reviewBanner = reviewBanner;
}

  BannerModel.fromJson(dynamic json) {
    _reviewBanner = json['reviewBanner'] != null ? ReviewBanner.fromJson(json['reviewBanner']) : null;
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    if (_reviewBanner != null) {
      map['reviewBanner'] = _reviewBanner.toJson();
    }
    return map;
  }

}

/// en : {"redirectUrl":"","imageUrl":"https://halorider.oss-ap-southeast-3.aliyuncs.com/payment_banner/covid_en.jpeg"}
/// bm : {"redirectUrl":"","imageUrl":"https://halorider.oss-ap-southeast-3.aliyuncs.com/payment_banner/covid_bm.jpeg"}
/// cn : {"redirectUrl":"","imageUrl":"https://halorider.oss-ap-southeast-3.aliyuncs.com/payment_banner/covid_cn.jpeg"}

class ReviewBanner {
  En _en;
  Bm _bm;
  Cn _cn;

  En get en => _en;
  Bm get bm => _bm;
  Cn get cn => _cn;

  ReviewBanner({
      En en, 
      Bm bm, 
      Cn cn}){
    _en = en;
    _bm = bm;
    _cn = cn;
}

  ReviewBanner.fromJson(dynamic json) {
    _en = json['en'] != null ? En.fromJson(json['en']) : null;
    _bm = json['bm'] != null ? Bm.fromJson(json['bm']) : null;
    _cn = json['cn'] != null ? Cn.fromJson(json['cn']) : null;
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    if (_en != null) {
      map['en'] = _en.toJson();
    }
    if (_bm != null) {
      map['bm'] = _bm.toJson();
    }
    if (_cn != null) {
      map['cn'] = _cn.toJson();
    }
    return map;
  }

}

/// redirectUrl : ""
/// imageUrl : "https://halorider.oss-ap-southeast-3.aliyuncs.com/payment_banner/covid_cn.jpeg"

class Cn {
  String _redirectUrl;
  String _imageUrl;

  String get redirectUrl => _redirectUrl;
  String get imageUrl => _imageUrl;

  Cn({
      String redirectUrl, 
      String imageUrl}){
    _redirectUrl = redirectUrl;
    _imageUrl = imageUrl;
}

  Cn.fromJson(dynamic json) {
    _redirectUrl = json['redirectUrl'];
    _imageUrl = json['imageUrl'];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['redirectUrl'] = _redirectUrl;
    map['imageUrl'] = _imageUrl;
    return map;
  }

}

/// redirectUrl : ""
/// imageUrl : "https://halorider.oss-ap-southeast-3.aliyuncs.com/payment_banner/covid_bm.jpeg"

class Bm {
  String _redirectUrl;
  String _imageUrl;

  String get redirectUrl => _redirectUrl;
  String get imageUrl => _imageUrl;

  Bm({
      String redirectUrl, 
      String imageUrl}){
    _redirectUrl = redirectUrl;
    _imageUrl = imageUrl;
}

  Bm.fromJson(dynamic json) {
    _redirectUrl = json['redirectUrl'];
    _imageUrl = json['imageUrl'];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['redirectUrl'] = _redirectUrl;
    map['imageUrl'] = _imageUrl;
    return map;
  }

}

/// redirectUrl : ""
/// imageUrl : "https://halorider.oss-ap-southeast-3.aliyuncs.com/payment_banner/covid_en.jpeg"

class En {
  String _redirectUrl;
  String _imageUrl;

  String get redirectUrl => _redirectUrl;
  String get imageUrl => _imageUrl;

  En({
      String redirectUrl, 
      String imageUrl}){
    _redirectUrl = redirectUrl;
    _imageUrl = imageUrl;
}

  En.fromJson(dynamic json) {
    _redirectUrl = json['redirectUrl'];
    _imageUrl = json['imageUrl'];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['redirectUrl'] = _redirectUrl;
    map['imageUrl'] = _imageUrl;
    return map;
  }

}