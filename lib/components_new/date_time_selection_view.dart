import 'package:flutter/material.dart';
import 'package:haloapp/components_new/date_check_box.dart';
import 'package:haloapp/components_new/selection_check_box.dart';
import 'package:haloapp/models/food_order_model.dart';

import 'package:haloapp/utils/constants/styles.dart';
import 'package:haloapp/utils/services/datetime_formatter.dart';

class DateTimeSelectionView extends StatefulWidget {
  DateTimeSelectionView({
    @required this.dateTitle,
    @required this.timeTitle,
    @required this.dateSelections,
    @required this.timeSelections,
    @required this.onDateSelected,
    @required this.onTimeSelected,
    @required this.selectedDate,
    @required this.selectedTime,
    this.interval,
  });

  final String dateTitle;
  final String timeTitle;
  final List<dynamic> dateSelections;
  final List<dynamic> timeSelections;
  final Function(String) onDateSelected;
  final Function(String) onTimeSelected;
  final String selectedDate;
  final String selectedTime;
  final int interval;

  @override
  _DateTimeSelectionViewState createState() => _DateTimeSelectionViewState();
}

class _DateTimeSelectionViewState extends State<DateTimeSelectionView> {
  showTimeBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) => Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.timeTitle,
                      style: kTitleTextStyle,
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.close,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.separated(
                    itemBuilder: (BuildContext context, int index) {
                      List<dynamic> times = widget.timeSelections;

                      return SelectionCheckBox(
                        onPressed: () {
                          widget.onTimeSelected(times[index]);
                          setState(() {});
                          Navigator.pop(context);
                        },
                        isSelected: (widget.selectedTime == times[index]),
                        label: widget.interval != null
                            ? '${times[index]} - ${DatetimeFormatter().getStrTimeAfterMinute(time: times[index], interval: widget.interval)}'
                            : '${times[index]}',
                      );
                    },
                    separatorBuilder: (context, index) {
                      return Divider();
                    },
                    itemCount: widget.timeSelections.length,
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          widget.dateTitle,
          style: kAddressTextStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          height: 40,
          child: ListView.separated(
            itemBuilder: (BuildContext context, int index) {
              Map<String, dynamic> dateData = widget.dateSelections[index];
              String date = dateData.keys.first;
              return DateCheckBox(
                onPressed: () {
                  widget.onDateSelected(date);
                },
                isSelected: (widget.selectedDate == date),
                date: date,
              );
            },
            separatorBuilder: (context, index) {
              return SizedBox(width: 10.0);
            },
            itemCount: widget.dateSelections.length,
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
          ),
        ),
        SizedBox(height: 20.0),
        Text(
          widget.timeTitle,
          style: kAddressTextStyle,
        ),
        GestureDetector(
            onTap: () {
              showTimeBottomSheet();
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 1, color: Colors.grey),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.interval != null
                        ? '${widget.selectedTime} - ${DatetimeFormatter().getStrTimeAfterMinute(time: widget.selectedTime, interval: widget.interval)}'
                        : '${widget.selectedTime}',
                    style: kDetailsTextStyle,
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      showTimeBottomSheet();
                    },
                    child: Container(
                        width: 35.0,
                        height: 35.0,
                        padding: EdgeInsets.all(6.0),
                        child: Image.asset(
                          "images/ic_calendar.png",
                        )),
                  )
                  // IconButton(
                  //   icon: Icon(
                  //     Icons.calendar_today,
                  //     color: Colors.grey,
                  //   ),
                  //   onPressed: () {
                  //     showTimeBottomSheet();
                  //   },
                  // )
                ],
              ),
            )),
      ],
    );
  }
}
