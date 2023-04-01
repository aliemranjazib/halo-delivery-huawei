import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/screens/auth/signup_page.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/widget/social_sign_in.dart';
import 'package:huawei_hmsavailability/huawei_hmsavailability.dart';

SocialLoginInfoModel socialInfoModelFromJson(String str) => SocialLoginInfoModel.fromJson(json.decode(str));

String socialInfoModelToJson(SocialLoginInfoModel data) => json.encode(data.toJson());

class SocialLoginInfoModel{
  String userId;
  String email;
  String name;
  String image;
  String socialDataRaw;
  final String type;

  SocialLoginInfoModel({
    @required this.type,
    this.userId = "",
    this.email = "",
    this.name = "",
    this.image = "",
    this.socialDataRaw = "",
  });

  factory SocialLoginInfoModel.fromJson(Map<String, dynamic> json) => SocialLoginInfoModel(
    userId: json["userId"] == null ? null : json["userId"],
    email: json["email"] == null ? null : json["email"],
    name: json["name"] == null ? null : json["name"],
    image: json["image"] == null ? null : json["image"],
    socialDataRaw: json["socialDataRaw"] == null ? null : json["socialDataRaw"],
    type: json["type"] == null ? null : json["type"],
  );

  Map<String, dynamic> toJson() => {
    "userId": userId == null ? null : userId,
    "email": email == null ? null : email,
    "name": name == null ? null : name,
    "image": image == null ? null : image,
    "socialDataRaw": socialDataRaw == null ? null : socialDataRaw,
    "type": type == null ? null : type,
  };

  static const String FACEBOOK = "facebook";
  static const String INSTAGRAM = "instagram";
  static const String GOOGLE = "google";
  static const String APPLE = "apple";

}

typedef SocialListenerCallback = Future Function(bool isLoading,SocialLoginInfoModel socialLoginInfoModel);

enum SocialLoginContainerDirection{
  vertical,horizontal
}
class SocialLoginContainer extends StatefulWidget {

  final bool enable;
  final SocialLoginContainerDirection socialLoginContainerDirection;
  final SocialListenerCallback socialListenerCallback;

  SocialLoginContainer(
    {
      Key key,
      this.enable = true,
      this.socialLoginContainerDirection = SocialLoginContainerDirection.vertical,
      this.socialListenerCallback
    }
  );

  @override
  SocialLoginContainerState createState() => SocialLoginContainerState();

}

class SocialLoginContainerState extends State<SocialLoginContainer> with SingleTickerProviderStateMixin{

  int isHmsAvailable;
  HmsApiAvailability hmsApiAvailability;
  @override
  void initState() {
    super.initState();
    hmsApiAvailability = HmsApiAvailability();
    hmsApiAvailability.isHMSAvailable().then((value){
      // 0: HMS Core (APK) is available.
      // 1: No HMS Core (APK) is found on the device.
      isHmsAvailable = value;
      setState(() {

      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 12,bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if(Platform.isIOS)
              AppleSignInButton(socialLoginButtonType: SocialLoginButtonType.button,enable: widget.enable,socialListenerCallback: widget.socialListenerCallback,),
              SizedBox(height: 6,),
              FacebookSignInButton(socialLoginButtonType: SocialLoginButtonType.button,enable: widget.enable,socialListenerCallback: widget.socialListenerCallback,),
              SizedBox(height: 6,),
              if(isHmsAvailable == 1 || Platform.isIOS)
              GoogleSignInButton(socialLoginButtonType: SocialLoginButtonType.button,enable: widget.enable,socialListenerCallback: widget.socialListenerCallback,),
              SizedBox(height: 6,),
              ActionIconButtonOutline(
                icon: Container(
                  alignment: Alignment.centerLeft,
                  child: Image.asset(
                    'images/phone.png',
                    width: socialIconSize,
                    height: socialIconSize,
                    color: Colors.black,
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, SignUpPage.id);
                },
                buttonText: AppTranslations.of(context)
                    .text('login_btn_register'),
              )
            ],
          ),
        ],
      )
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
