import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:haloapp/components/custom_flushbar.dart';
import 'package:haloapp/models/app_config_model.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:url_launcher/url_launcher.dart';

class BannerSlider extends StatefulWidget {
  final List<PromoBanner> promoBanner;

  BannerSlider({
    @required this.promoBanner,
  });

  @override
  State<StatefulWidget> createState() {
    return _BannerSliderState();
  }
}

class _BannerSliderState extends State<BannerSlider> {
  int _current = 0;
  final CarouselController _controller = CarouselController();
  // final List<String> imgList = [
  //   'https://halorider.oss-ap-southeast-3.aliyuncs.com/1682976680banner-test.png',
  //   'https://halorider.oss-ap-southeast-3.aliyuncs.com/1711431940banner-test.png',
  // ];

  @override
  Widget build(BuildContext context) {
    final List<Widget> imageSliders = widget.promoBanner
        .map((item) => Container(
              margin: EdgeInsets.all(5.0),
              child: GestureDetector(
                onTap: () async {
                  if(item.promoActionUrl != null && item.promoActionUrl != ''){
                    if (await canLaunch(item.promoActionUrl)) {
                      await launch(item.promoActionUrl);
                    } else {
                      showSimpleFlushBar(AppTranslations.of(context).text('failed_to_load'), context);
                    }
                  }
                },
                child: Column(
                  children: <Widget>[Image.network(item.promoImageUrl)],
                ),
              ),
            ))
        .toList();
    return Column(children: [
      CarouselSlider(
        items: imageSliders,
        carouselController: _controller,
        options: CarouselOptions(
            height: 195,
            autoPlay: true,
            aspectRatio: 2.0,
            viewportFraction: 1,
            onPageChanged: (index, reason) {
              setState(() {
                _current = index;
              });
            }),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: widget.promoBanner.map((i) {
          int index = widget.promoBanner.indexOf(i);
          return GestureDetector(
            onTap: () => _controller.animateToPage(index),
            child: Container(
              width: 6.0,
              height: 6.0,
              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _current == index
                    ? Colors.black.withOpacity(0.9)
                    : Colors.black.withOpacity(0.4),
              ),
            ),
          );
        }).toList(),
      ),
    ]);
  }
}
