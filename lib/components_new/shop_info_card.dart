import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:haloapp/components_new/shadow_card.dart';
import 'package:haloapp/components_new/shop_tag.dart';
import 'package:haloapp/models/shop_model.dart';
import 'package:haloapp/screens/main/shop_details_page.dart';
import 'package:haloapp/screens/main/shop_tag_list_page.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/fonts.dart';

class ShopInfoCard extends StatelessWidget {
  ShopInfoCard({
    this.shop,
    this.isShopInfo,
    this.shopUniqueCode,
    this.shopType,
    this.isHomePage = false,
  });

  // final List<int> cravings;
  final ShopModel shop;
  final bool isShopInfo;
  final bool isHomePage;
  final String shopType;

  final String shopUniqueCode;

  renderRatingBar(String value) {
    return RatingBar.builder(
      itemSize: 16,
      ignoreGestures: true,
      initialRating: double.parse(value),
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: true,
      itemCount: 5,
      itemBuilder: (context, _) => Icon(
        Icons.star,
        color: Colors.amber,
      ),
      onRatingUpdate: (rating) {
        print(rating);
      },
    );
  }

  Widget renderShopTags(BuildContext context) {
    if (shop.shopTag.length > 2) {
      return Wrap(
        direction: Axis.horizontal,
        children: [
          renderShopTag(shop.shopTag[0]),
          renderShopTag(shop.shopTag[1]),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ShopTagListPage(
                    tags: shop.shopTag,
                  ),
                ),
              );
            },
            child: Container(
              margin: EdgeInsets.only(left: 8, top: 12),
              child: Text(
                '& ${shop.shopTag.length - 2}more',
                style: TextStyle(
                  color: Colors.grey,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return Wrap(
        direction: Axis.horizontal,
        children: [...shop.shopTag.map((e) => renderShopTag(e)).toList()],
      );
    }
  }

  renderShopTag(String tag) {
    return Container(
      margin: EdgeInsets.only(top: 8, right: 8),
      child: ShopTag(tag: tag),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ShadowCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  shop.shopName,
                  style: TextStyle(
                    fontFamily: poppinsSemiBold,
                    fontSize: 18,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!isShopInfo)
                Visibility(
                  visible: shopType == 'donation' ? false : true,
                  child: Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ShopDetailsPage(
                              shop: shop,
                              shopUniqueCode: shopUniqueCode,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        AppTranslations.of(context).text('view_info'),
                        style: TextStyle(
                          fontFamily: poppinsSemiBold,
                          decoration: TextDecoration.underline,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                )
            ],
          ),
          if (shop.totalOrder != "0")
            Row(
              children: [
                renderRatingBar(shop.rating),
                // Text(
                //   '${shop.totalOrder} Orders',
                //   style: TextStyle(color: Colors.grey),
                //   overflow: TextOverflow.ellipsis,
                // ),
                Text(
                  '(${shop.totalOrder})',
                  style: TextStyle(color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          Visibility(
            visible: shopType == 'donation' ? true : false,
            child: Text(
              '${AppTranslations.of(context).text('Location')}: ${shop.city}',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          // Text(
          //   '${shop.category.join(',')} | ${(shop.distance).toStringAsFixed(1)} km',
          //   style: TextStyle(color: Colors.grey),
          //   overflow: TextOverflow.ellipsis,
          // ),
          Visibility(
            visible: shopType == 'donation' ? false : true,
            child: Text(
              '${AppTranslations.of(context).text('min_order')}: RM ${shop.shopMinAmount}',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          Visibility(
              visible: shopType == 'donation' ? false : true,
              child: renderShopTags(context)),
        ],
      ),
    );
  }
}
