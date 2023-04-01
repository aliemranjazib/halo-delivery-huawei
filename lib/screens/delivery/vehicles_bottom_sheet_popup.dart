import 'package:flutter/material.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/constants/styles.dart';
import 'package:haloapp/utils/constants/vehicles.dart';

class VehiclesBottomSheetPopup extends StatefulWidget {
  @override
  _VehiclesBottomSheetPopupState createState() =>
      _VehiclesBottomSheetPopupState();
}

class _VehiclesBottomSheetPopupState extends State<VehiclesBottomSheetPopup> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
            color: kColorRed.withOpacity(0.85),
            child: Text(
              AppTranslations.of(context).text('vehicle_types'),
              style: TextStyle(
                  fontFamily: poppinsSemiBold,
                  fontSize: 16,
                  color: Colors.white),
            ),
          ),
          Flexible(
            child: ListView.separated(
                separatorBuilder: (context, index) {
                  return Divider(
                    color: Colors.black,
                  );
                },
                scrollDirection: Axis.vertical,
                itemCount: Vehicles().getVehicles().length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: EdgeInsets.only(right: 15.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context, Vehicles().getVehicles()[index]);
                      },
                      behavior: HitTestBehavior.translucent,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Image.asset(
                                Vehicles().getVehicles()[index].image,
                                height: 60,
                              ),
                              SizedBox(width: 15.0),
                              Text(
                                '${Vehicles().getVehicles()[index].name}',
                                style: TextStyle(
                                    fontFamily: poppinsMedium, fontSize: 15),
                              ),
                            ],
                          ),
//                          GestureDetector(
//                              onTap: () {
//                                print('view info');
//                              },
//                              child: Icon(Icons.info_outline))
                        ],
                      ),
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }
}
