import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:haloapp/components_new/shop_info_card.dart';
import 'package:haloapp/components_new/shop_tag.dart';
import 'package:haloapp/models/shop_model.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';

class HorizontalMerchantCard2 extends StatelessWidget {
  HorizontalMerchantCard2({
    this.headerImgUrl,
    this.logoUrl,
    this.shopInfo,
    this.cardHeight,
    this.cardWidth,
    this.onClick,
    this.isHideShowFeatureTag = false
  });

  final String headerImgUrl;
  final String logoUrl;
  final ShopModel shopInfo;
  final double cardHeight;
  final double cardWidth;
  final Function onClick;
  final bool isHideShowFeatureTag;

  renderShopTags() {
    if (shopInfo.shopTag != null && shopInfo.shopTag.length > 1) {
      return Wrap(
        direction: Axis.horizontal,
        children: [
          Container(
            margin: EdgeInsets.only(right: 5, top: 5),
            child: ShopTag(tag: shopInfo.shopTag[0]),
          ),
          // Container(
          //   margin: EdgeInsets.only(right: 5, top: 5),
          //   child: ShopTag(tag: shopInfo.shopTag[1]),
          // ),
        ],
      );
    } else {
      return Wrap(
        direction: Axis.horizontal,
        children: [
          ...shopInfo.shopTag.map(
            (e) => Container(
              margin: EdgeInsets.only(right: 5, top: 5),
              child: ShopTag(tag: e),
            ),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: Container(
        width: cardWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: (headerImgUrl != '')
                      ? CachedNetworkImage(
                          width: cardWidth,
                          height: cardHeight,
                          imageUrl: headerImgUrl,
                          placeholder: (context, url) =>
                              Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                          fit: BoxFit.cover,
                        )
                      : CachedNetworkImage(
                          width: cardWidth,
                          height: cardHeight,
                          imageUrl: logoUrl,
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                          fit: BoxFit.cover,
                        ),
                ),
                if (shopInfo.featuresStatus && !isHideShowFeatureTag)
                  Positioned(
                    top: 8.0,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 3.0, horizontal: 8.0),
                      color: kColorLightRed,
                      child: Text(
                        AppTranslations.of(context)
                            .text('featured')
                            .toUpperCase(),
                        style: TextStyle(
                            fontFamily: poppinsMedium,
                            fontSize: 10.0,
                            color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 3.0,),
            Text(
              shopInfo.shopName+"\n",
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: TextStyle(fontSize: 10.0, fontFamily: poppinsBold,height: 1.1,),
            ),
            Row(
              children: [
                Text(
                  '${(shopInfo.distance).toStringAsFixed(1)} km |',
                  style: TextStyle(fontSize: 10.0,color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
                Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 10.0,
                ),
                Text(
                  shopInfo.rating,
                  style: TextStyle(fontSize: 10.0,color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            // if (shopInfo.shopTag != null && shopInfo.shopTag.length > 0)
            //   renderShopTags()
          ],
        ),
      ),
    );
  }
}
