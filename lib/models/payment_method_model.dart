class PaymentMethodModel {
  final String id;
  final String name;
  final String image;

  PaymentMethodModel({
    this.id,
    this.name,
    this.image,
  });
}

class DynamicPaymentMethodModel {
  final String name;
  final String title;
  final String image;

  DynamicPaymentMethodModel({
    this.name,
    this.title,
    this.image,
  });
}
