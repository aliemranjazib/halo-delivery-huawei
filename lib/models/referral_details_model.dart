/// ref_summary : [{"user_phone":"+601156****39","referrer_commission":"0.00"},{"user_phone":"+601275*****91","referrer_commission":"0.00"}]
/// ref_total_commission : "0.00"

class ReferralDetailsModel {
  List<Ref_summary> _refSummary;
  String _refTotalCommission;

  List<Ref_summary> get refSummary => _refSummary;
  String get refTotalCommission => _refTotalCommission;

  set refSummary(List<Ref_summary> value) {
    _refSummary = value;
  }

  ReferralDetailsModel({
      List<Ref_summary> refSummary, 
      String refTotalCommission}){
    _refSummary = refSummary;
    _refTotalCommission = refTotalCommission;
}

  ReferralDetailsModel.fromJson(dynamic json) {
    if (json['ref_summary'] != null) {
      _refSummary = [];
      json['ref_summary'].forEach((v) {
        _refSummary.add(Ref_summary.fromJson(v));
      });
    }
    _refTotalCommission = json['ref_total_commission'];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    if (_refSummary != null) {
      map['ref_summary'] = _refSummary.map((v) => v.toJson()).toList();
    }
    map['ref_total_commission'] = _refTotalCommission;
    return map;
  }

}

/// user_phone : "+601156****39"
/// referrer_commission : "0.00"
/// ref_created_datetime : "2022-04-18 11:40:57"

class Ref_summary {
  String _userPhone;
  String _referrerCommission;
  String _refCreatedDatetime;

  String get userPhone => _userPhone;
  String get referrerCommission => _referrerCommission;
  String get refCreatedDatetime => _refCreatedDatetime;

  Ref_summary({
    String userPhone,
    String referrerCommission,
    String refCreatedDatetime}){
    _userPhone = userPhone;
    _referrerCommission = referrerCommission;
    _refCreatedDatetime = refCreatedDatetime;
  }

  Ref_summary.fromJson(dynamic json) {
    _userPhone = json['user_phone'];
    _referrerCommission = json['referrer_commission'];
    _refCreatedDatetime = json['ref_created_datetime'];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['user_phone'] = _userPhone;
    map['referrer_commission'] = _referrerCommission;
    map['ref_created_datetime'] = _refCreatedDatetime;
    return map;
  }

}