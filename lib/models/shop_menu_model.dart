import 'package:haloapp/models/food_model.dart';

class ShopMenuModel {
  String categoryId;
  String categoryName;
  bool categoryStatus;
  List<FoodModel> foods;

  ShopMenuModel(
      {this.categoryId, this.categoryName, this.categoryStatus, this.foods});
}
