import 'package:haloapp/models/payment_method_model.dart';

class PaymentMethod {
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
