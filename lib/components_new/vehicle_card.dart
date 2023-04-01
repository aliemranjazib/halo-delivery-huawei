import 'package:flutter/material.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';

class VehicleCard extends StatelessWidget {
  VehicleCard({
    this.vehcileImage,
    this.vehicleTitle,
    this.vehicleDesc,
    this.vehicleMeasure,
    this.onSelected,
    this.isSelected,
  });

  final String vehcileImage;
  final String vehicleTitle;
  final String vehicleDesc;
  final String vehicleMeasure;
  final Function onSelected;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          onSelected();
        },
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: Color(0xffF3F3F3),
            borderRadius: BorderRadius.circular(10),
            border: isSelected ? Border.all(color: kColorRed) : null,
          ),
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 20,
                ),
                child: Row(
                  children: [
                    Image.asset(
                      vehcileImage,
                      width: 70.0,
                      height: 70.0,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            vehicleTitle,
                            style: TextStyle(
                              fontFamily: poppinsSemiBold,
                            ),
                          ),
                          Text(
                            vehicleDesc,
                            style: TextStyle(
                              fontFamily: poppinsRegular,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            vehicleMeasure,
                            style: TextStyle(
                              fontFamily: poppinsRegular,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              if (isSelected)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Image.asset(
                    'images/ic_tick.png',
                    width: 24,
                  ),
                ),
            ],
          ),
        ));
  }
}
