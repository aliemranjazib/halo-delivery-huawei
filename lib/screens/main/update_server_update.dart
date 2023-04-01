import 'package:flutter/material.dart';
import 'package:haloapp/components_new/profile_option.dart';
import 'package:haloapp/models/app_config_model.dart';
import 'package:haloapp/screens/auth/change_password_page.dart';
import 'package:haloapp/screens/main/language_selector_page.dart';

import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/styles.dart';

class UpdateServerPage extends StatefulWidget {
  static const String id = 'updateServerPage';

  @override
  UpdateServerPageState createState() =>UpdateServerPageState();
}

class UpdateServerPageState extends State<UpdateServerPage> {

  @override
  void initState() {
    super.initState();
    AppConfig.isUnderMaintenance.addListener(() {
      if(!AppConfig.isUnderMaintenance.value){
        AppConfig.isShowMaintenancePage = false;
        if(mounted){
          Navigator.pop(context);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          automaticallyImplyLeading:false,
          // leading: IconButton(
          //   icon: arrowBack,
          //   onPressed: () => {Navigator.pop(context)},
          // ),
          title: Text(
            "Server Maintenance",
            style: kAppBarTextStyle,
          ),
        ),
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: 20.0,
              horizontal: 25.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("images/halo_logo.png",width: 150.0, height: 150.0,),
                SizedBox(height: 50.0,),
                Text(
                  "Server under maintenance. Please wait while we will server you shortly.",
                  textAlign: TextAlign.center,
                  style: kTitleLargeBoldTextStyle,
                )

              ],
            ),
          ),
        ),
      ),
    );
  }
}
