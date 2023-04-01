import 'package:flutter/material.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/job_status.dart';

class OrderProgressIndicator extends StatelessWidget {
  OrderProgressIndicator({this.status});

  final String status;

  statusColor() {
    switch (status) {
      case JobStatus.otw:
      case JobStatus.otwPickedUp:
        return kColorRed;

      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppTranslations.of(context).text('prepare'),
                style: TextStyle(fontSize: 12, color: kColorRed),
              ),
              Text(
                AppTranslations.of(context).text('out_of_delviery'),
                style: TextStyle(fontSize: 12, color: statusColor()),
              ),
              Text(
                AppTranslations.of(context).text('reached'),
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 4),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: kColorRed,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(bottom: 4),
                  height: 2,
                  decoration: BoxDecoration(
                    color: statusColor(),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 4),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: statusColor(),
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(bottom: 4),
                  height: 2,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 4),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
