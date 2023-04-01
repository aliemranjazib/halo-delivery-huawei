/// availablePaymentMethod : ["fpx","card","ewallet"]

class AvailableOnlinePaymentModel {
  List<String> _availablePaymentMethod;

  List<String> get availablePaymentMethod => _availablePaymentMethod;

  AvailableOnlinePaymentModel({
      List<String> availablePaymentMethod}){
    _availablePaymentMethod = availablePaymentMethod;
}

  AvailableOnlinePaymentModel.fromJson(dynamic json) {
    _availablePaymentMethod = json['availablePaymentMethod'] != null ? json['availablePaymentMethod'].cast<String>() : [];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['availablePaymentMethod'] = _availablePaymentMethod;
    return map;
  }

}