import 'package:flutter/material.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/services/datetime_formatter.dart';

class DateCheckBox extends StatelessWidget {
  DateCheckBox({
    this.onPressed,
    this.isSelected,
    this.date,
  });
  final Function onPressed;
  final bool isSelected;
  final String date;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          border: Border.all(
            color: kColorRed,
            width: 1.0,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.all(Radius.circular(15)),
          color: isSelected ? kColorRed : Colors.white,
        ),
        child: Center(
          child: Text(
            '${checkDate(context)}',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: isSelected ? poppinsSemiBold : poppinsRegular,
                fontSize: 14,
                color: isSelected ? Colors.white : kColorRed),
          ),
        ),
      ),
    );
  }

  String checkDate(BuildContext context){
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    DateTime dateTime = DatetimeFormatter().getFormattedDateTime(datetime: "$date 00:00:00");
    final aDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if(aDate == today) {
      return AppTranslations.of(context).text("today");
    }else if(aDate == tomorrow) {
      return AppTranslations.of(context).text("tomorrow");
    }else{
      return "${DatetimeFormatter().getFormattedDateStr(format: 'dd MMM yyyy', datetime: '$date 00:00:00')}";
    }
  }
}
