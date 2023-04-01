class FoodVariantModel {
  String variantMin;
  String variantMax;
  String variantName;
  List<FoodVariantItemModel> variantList;
  String variantListId;
  String variantOption;
  bool showAlert;

  FoodVariantModel({
    this.variantMin,
    this.variantMax,
    this.variantName,
    this.variantList,
    this.variantListId,
    this.variantOption,
    this.showAlert = false
  }
  );
}

class FoodVariantItemModel {
  String variantId;
  String name;
  String extraPrice;
  bool status;
  bool selected = false;

  FoodVariantItemModel(
      {this.variantId, this.name, this.extraPrice, this.status, this.selected});
}
