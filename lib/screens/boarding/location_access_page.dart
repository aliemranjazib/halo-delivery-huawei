import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/screens/main/tab_bar_controller.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/components/model_progress_hud.dart';
import 'package:haloapp/utils/constants/styles.dart';
import 'package:haloapp/utils/services/location_service.dart';
import 'package:location_permissions/location_permissions.dart';

class LocationPage extends StatefulWidget {
  static const String id = 'LocationPage';

  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  bool _showSpinner = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(
      LifecycleEventHandler(
        resumeCallBack: () async {
          bool locationPermissionGranted =
              await LocationService().checkPermission();
          if (locationPermissionGranted) {
            if (mounted) {
              Navigator.pop(context);
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            centerTitle: true,
            leading: IconButton(
              icon: arrowBack,
              onPressed: () => {Navigator.pop(context)},
            ),
            title: Text(AppTranslations.of(context).text('location_title'),
                textAlign: TextAlign.center, style: appBarTitleStyle),
            actions: [
              // IconButton(
              //   icon: Icon(
              //     Icons.close,
              //     color: Colors.white,
              //   ),
              //   onPressed: () => {},
              // ),
            ],
          ),
          body: ModalProgressHUD(
            inAsyncCall: _showSpinner,
            child: SafeArea(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            AppTranslations.of(context)
                                .text('location_title_label'),
                            style: TextStyle(
                              fontFamily: poppinsRegular,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            AppTranslations.of(context)
                                .text('location_description'),
                            style: TextStyle(
                              fontFamily: poppinsRegular,
                              fontSize: 14,
                              color: light2Grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Container(
                          height: 250,
                          margin: EdgeInsets.zero,
                          padding: EdgeInsets.zero,
                          child: Image.asset(
                            'images/location_bg.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 30),
                          child: ActionButton(
                            onPressed: () {
                              LocationPermissions().openAppSettings();
                            },
                            buttonText: AppTranslations.of(context)
                                .text('location_btn'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LifecycleEventHandler extends WidgetsBindingObserver {
  final AsyncCallback resumeCallBack;
  final AsyncCallback suspendingCallBack;

  LifecycleEventHandler({
    this.resumeCallBack,
    this.suspendingCallBack,
  });

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        if (resumeCallBack != null) {
          await resumeCallBack();
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        if (suspendingCallBack != null) {
          await suspendingCallBack();
        }
        break;
    }
  }
}
