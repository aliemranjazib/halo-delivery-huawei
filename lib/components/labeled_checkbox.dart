import 'package:flutter/material.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';

class CheckboxWithContents extends StatelessWidget {
  const CheckboxWithContents({
    this.content,
    this.padding,
    this.value,
    this.onChanged,
  });

  final Widget content;
  final EdgeInsets padding;
  final bool value;
  final Function onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onChanged(!value);
      },
      child: Padding(
        padding: padding,
        child: Row(
          children: <Widget>[
            Expanded(child: content),
            Container(
              width: 25.0,
              height: 25.0,
              decoration: BoxDecoration(
                border: Border.all(color: kColorRed),
                  borderRadius: BorderRadius.all(Radius.circular(20.0))
              ),
              child: Theme(
                data: ThemeData(unselectedWidgetColor: Colors.white),
                child: Checkbox(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  checkColor: kColorRed,
                  activeColor: kColorRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  value: value,
                  onChanged: (bool newValue) {
                    onChanged(newValue);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
