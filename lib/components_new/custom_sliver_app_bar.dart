import 'package:flutter/material.dart';
import 'package:haloapp/components/search_bar_input.dart';
import 'package:haloapp/models/app_config_model.dart';
import 'package:haloapp/models/food_order_model.dart';
import 'package:haloapp/screens/main/shop_list_page.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/styles.dart';

class CustomSliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final double topSafeArea;
  final Widget topChild;

  const CustomSliverAppBarDelegate({
    @required this.expandedHeight,
    @required this.topSafeArea,
    @required this.topChild,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          margin: EdgeInsets.only(bottom: 1.0),
          decoration: kAppBarGradient,
        ),
        Positioned(
          top: 180,
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
          ),
        ),
        buildAppBar(context, shrinkOffset),
        Positioned(
          top: 16 - shrinkOffset,
          left: 0,
          right: 0,
          bottom: 0,
          child: Opacity(
            opacity: disappear(shrinkOffset),
            child: topChild,
          ),
        ),
      ],
    );
  }

  double getTotalHeightToShinrk() {
    return expandedHeight - (kToolbarHeight + 30);
  }

  double appear(double shrinkOffset) => shrinkOffset / expandedHeight;

  double disappear(double shrinkOffset) {
    return (1 - shrinkOffset / expandedHeight);
  }

  Widget buildAppBar(context, double shrinkOffset) => Opacity(
        opacity: appear(shrinkOffset),
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          decoration: kAppBarGradient,
          child: Row(
            children: [
              Expanded(
                  flex: 2,
                  child: SearchBarInput(
                    onTap: () {
                      FoodOption foodOption = FoodOption(
                          searchName: AppTranslations.of(context).text("food"),
                          shopType: "food");
                      FoodOrderModel().foodOption = foodOption;
                      Navigator.pushNamed(context, ShopListPage.id);
                    },
                  )),
            ],
          ),
        ),
      );

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => kToolbarHeight + topSafeArea;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}
