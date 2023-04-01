import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverCard extends StatelessWidget {
  DriverCard({
    this.driverName,
    this.vehicleModel,
    this.plateNumber,
    this.rating,
    this.driverPhoneNumber,
  });

  final String driverName;
  final String vehicleModel;
  final String plateNumber;
  final String rating;
  final String driverPhoneNumber;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (driverName != null)
                  Text(
                    driverName,
                    style: TextStyle(
                      fontFamily: poppinsSemiBold,
                    ),
                  ),
                if (vehicleModel != null)
                  Text(
                    vehicleModel,
                    style: TextStyle(
                      fontFamily: poppinsSemiBold,
                    ),
                  ),
                if (plateNumber != null)
                  Text(
                    plateNumber,
                    style: TextStyle(
                      fontFamily: poppinsSemiBold,
                    ),
                  ),
                if (rating != null)
                  RatingBar.builder(
                    itemSize: 16,
                    ignoreGestures: true,
                    initialRating: double.parse(rating),
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
                  )
              ],
            ),
          ),
          SizedBox(width: 6.0,),
          InkWell(
            onTap: () {
              launch('tel:' + driverPhoneNumber);
            },
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kColorRed,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(Icons.phone, size: 25, color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}
