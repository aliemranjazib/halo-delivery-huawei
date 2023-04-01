import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class CupertinoDatetimePickerPopup {
  void showCupertinoPicker<T>(BuildContext context,
      {CupertinoDatePickerMode mode = CupertinoDatePickerMode.dateAndTime,
      List<T> options,
      T selectedValue,
      DateTime minDate,
      DateTime lastDate,
      DateTime initialDate,
      int minuteInterval = 1,
      @required Function(DateTime value) onChanged}) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => SizedBox(
        height: 240.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              alignment: Alignment.centerRight,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(249, 249, 247, 1.0),
                border: Border(
                  bottom: const BorderSide(width: 0.5, color: Colors.black38),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Text(
                      'Cancel',
                      style: CupertinoTheme.of(context)
                          .textTheme
                          .actionTextStyle
                          .copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                    ),
                    onPressed: () {
                      onChanged(null);
                      Navigator.of(context).pop();
                    },
                  ),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Text(
                      'Done',
                      style: CupertinoTheme.of(context)
                          .textTheme
                          .actionTextStyle
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
                child: CupertinoDatePicker(
              minimumDate: minDate,
              maximumDate: lastDate,
              initialDateTime: initialDate,
              mode: mode,
              minuteInterval: minuteInterval,
              backgroundColor: Colors.white,
              onDateTimeChanged: (DateTime value) {
                if (onChanged == null) return;
                if (mode == CupertinoDatePickerMode.time) {
                  onChanged(DateTime(0000, 01, 01, value.hour, value.minute));
                } else {
                  onChanged(value);
                }
              },
            )),
          ],
        ),
      ),
    );
  }
}
