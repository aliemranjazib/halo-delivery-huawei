class CalculateUpdatePaymentModel {
  String _finalPrice;
  String _paymentFee;
  String _paymentMethod;

  String get finalPrice => _finalPrice;
  String get paymentFee => _paymentFee;
  String get paymentMethod => _paymentMethod;

  CalculateUpdatePaymentModel({
      String finalPrice, 
      String paymentFee, 
      String paymentMethod}){
    _finalPrice = finalPrice;
    _paymentFee = paymentFee;
    _paymentMethod = paymentMethod;
}

  CalculateUpdatePaymentModel.fromJson(dynamic json) {
    _finalPrice = json['finalPrice'];
    _paymentFee = json['paymentFee'];
    _paymentMethod = json['paymentMethod'];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['finalPrice'] = _finalPrice;
    map['paymentFee'] = _paymentFee;
    map['paymentMethod'] = _paymentMethod;
    return map;
  }

}