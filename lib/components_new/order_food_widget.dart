import 'package:flutter/material.dart';
import 'package:haloapp/models/food_order_model.dart';
import 'package:haloapp/models/food_variant_model.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/constants/styles.dart';

class OrderFoodListWidget extends StatelessWidget {
  const OrderFoodListWidget({
    Key key,
    @required this.order,
    this.editable = false,
    this.orderOnDelete,
  }) : super(key: key);

  final FoodOrderCart order;
  final bool editable;
  final Function orderOnDelete;

  @override
  Widget build(BuildContext context) {
    Widget _buildOrderList(FoodOrderCart order) {
      List<Widget> list = [];

      list.add(Text(
        order.name,
        style: TextStyle(fontFamily: poppinsMedium, fontSize: 15),
        // overflow: TextOverflow.ellipsis,
      ));

      if (order.options.length > 0) {
        for (FoodVariantItemModel item in order.options) {
          list.add(Text(
            item.name,
            style: kSmallLabelTextStyle,
          ));
        }
      }

      list.add(Text(
        '${AppTranslations.of(context).text('remarks')}: ${(order.remark == null || order.remark.isEmpty) ? "-" :order.remark}',
        style: kSmallLabelTextStyle,
        overflow: TextOverflow.ellipsis,
      ));

      list.add(SizedBox(height: 8.0));

      if (editable ?? false) {
        list.add(
          Row(
            children: [
              Image.asset("images/ic_edit_new.png",width: 15.0,height: 15.0),
              Container(
                margin: EdgeInsets.only(left: 8),
                child: Text(
                  AppTranslations.of(context).text('edit'),
                  style: kSmallLabelTextStyle.copyWith(color: kColorRed),
                ),
              ),
            ],
          ),
        );
      }

      return Container(
        child: Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: list,
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildOrderList(order),
        SizedBox(width: 10.0),
        Container(
          width: 24,
          height: 24,
          margin: EdgeInsets.only(right: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(width: 1, color: kColorRed),
          ),
          child: Text(
            '${order.quantity}',
            style: kTitleTextStyle.copyWith(fontSize: 14, color: kColorRed),
          ),
        ),
        Container(
          child: Text(
            '${order.finalPrice}',
            style: TextStyle(fontFamily: poppinsMedium, fontSize: 15),
          ),
        ),
        SizedBox(width: 10.0),
        (editable)
            ? GestureDetector(
                onTap: orderOnDelete,
                child: Container(
                    width: 20.0,
                    height: 20.0,
                    // padding: EdgeInsets.all(3.0),
                    child: Image.asset("images/ic_trash.png",)
                )
              )
            : Container()
      ],
    );
  }
}

class FoodPricingWidget extends StatelessWidget {
  const FoodPricingWidget({
    @required this.title,
    @required this.amount,
    this.onPressed,
    this.isDiscount = false,
    Key key,
  }) : super(key: key);

  final String title;
  final String amount;
  final bool isDiscount;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onPressed();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                AppTranslations.of(context).text(title),
                style: TextStyle(fontFamily: poppinsRegular, fontSize: 14),
              ),
              if (onPressed != null)
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Icon(
                    Icons.info_outline,
                    size: 15,
                  ),
                )
            ],
          ),
          Text(
            '${(isDiscount) ? '-' : ''}RM $amount',
            style: TextStyle(fontFamily: poppinsMedium, fontSize: 15),
          )
        ],
      ),
    );
  }
}
