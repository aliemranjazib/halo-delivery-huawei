import 'package:haloapp/models/payment_method_model.dart';

class PaymentMethod {
  // since the payment method is now dynamic , it's not longer considered as constants

  // List<PaymentMethodModel> _paymentMethods = <PaymentMethodModel>[];

  // void addAll(List<PaymentMethodModel> paymentMethods) {
  //   this._paymentMethods = paymentMethods;
  // }

  // List<PaymentMethodModel> getPaymentMethods() {}

  List<PaymentMethodModel> getPaymentMethods() {
    return [
      PaymentMethodModel(
        id: '1',
        name: 'cod',
        image: 'images/ic_cash_on_delivery.png',
      ),
      PaymentMethodModel(
        id: '2',
        name: 'card',
        image: 'images/ic_visa.png',
      ),
      PaymentMethodModel(
        id: '3',
        name: 'fpx',
        image: 'images/ic_fpx.png',
      ),
      PaymentMethodModel(
        id: '4',
        name: 'haloWallet',
        image: 'images/haloje_logo_small.png',
      ),
      PaymentMethodModel(
        id: '6',
        name: 'haloWalletCod',
        image: 'images/haloje_logo_small.png',
      ),
      PaymentMethodModel(
        id: '5',
        name: 'ewallet',
        image: 'images/ic_e_wallet.png',
      ),
    ];
  }

  PaymentMethodModel getPaymentMethod(String name) {
    return getPaymentMethods().firstWhere((e) => e.name == name);
  }
}
