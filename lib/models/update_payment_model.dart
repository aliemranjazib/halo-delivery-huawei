/// finalPrice : "40.29"
/// orderUniqueKey : "1660670204sNv44tTsIgySsWMIkwKxaNApCcRvJ62dwiqqdWXnKbHqUAmD8ONeD3uXoR0YoUiu98LjlNsoY0xtLBJEvkS7WJyCg3"
/// paymentMethod : "fpx"
/// paymentUrl : "https://www.billplz.com/bills/z7fcc9te"

class UpdatePaymentModel {
  String _finalPrice;
  String _orderUniqueKey;
  String _paymentMethod;
  String _paymentUrl;

  String get finalPrice => _finalPrice;
  String get orderUniqueKey => _orderUniqueKey;
  String get paymentMethod => _paymentMethod;
  String get paymentUrl => _paymentUrl;

  UpdatePaymentModel({
      String finalPrice, 
      String orderUniqueKey, 
      String paymentMethod, 
      String paymentUrl}){
    _finalPrice = finalPrice;
    _orderUniqueKey = orderUniqueKey;
    _paymentMethod = paymentMethod;
    _paymentUrl = paymentUrl;
}

  UpdatePaymentModel.fromJson(dynamic json) {
    _finalPrice = json['finalPrice'];
    _orderUniqueKey = json['orderUniqueKey'];
    _paymentMethod = json['paymentMethod'];
    _paymentUrl = json['paymentUrl'];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['finalPrice'] = _finalPrice;
    map['orderUniqueKey'] = _orderUniqueKey;
    map['paymentMethod'] = _paymentMethod;
    map['paymentUrl'] = _paymentUrl;
    return map;
  }

}