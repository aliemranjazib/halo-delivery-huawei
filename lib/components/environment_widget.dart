
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:haloapp/utils/constants/api_urls.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';

class BlinkingTextAnimation extends StatefulWidget {

  @override
  _BlinkingAnimationState createState() => _BlinkingAnimationState();
}

class _BlinkingAnimationState extends State<BlinkingTextAnimation>
    with SingleTickerProviderStateMixin {
  Animation<Color> animation;
  AnimationController controller;

  String environment = "";

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);

    getEnvironment();

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget child) {
          return Container(
            padding: EdgeInsets.only(left: 6,right: 6),
            child: Text(environment,
                style: TextStyle(color: animation.value, fontSize: 14, fontWeight: FontWeight.bold)),
          );
        });
  }

  Widget getEnvironment(){
    Color colorSelected;
    if(APIUrls.ENVIRONMENT == APIUrls.STAGING_ENVIRONMENT) {
      colorSelected = darkGrey;
      environment = "Stg";
    }else{
      colorSelected = green;
      environment = "Prod";
    }

    final CurvedAnimation curve = CurvedAnimation(parent: controller, curve: Curves.ease);

    animation =
        ColorTween(begin: Colors.white, end: colorSelected).animate(curve);

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        controller.forward();
      }
      setState(() {});
    });

//      Text(
//      environment,
//      style: TextStyle(
//          fontSize: Dimens.fontNormal, color: colorSelected, fontWeight: FontWeight.bold),
//    );
  }

  dispose() {
    controller.dispose();
    super.dispose();
  }
}