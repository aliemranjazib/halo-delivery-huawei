class VehicleModel {
  final String id;
  final String name;
  final String image;
  final String description;
  final String description2;
  String price;

  VehicleModel({
    this.id,
    this.name,
    this.image,
    this.description,
    this.description2,
    this.price = '',
  });
}
