import 'dart:ffi';

import 'package:haloapp/utils/constants/fonts.dart';
import 'package:flutter/material.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';

class ActionButton extends StatelessWidget {
  final String buttonText;
  final Widget icon;
  final Function onPressed;

  ActionButton({@required this.buttonText, this.onPressed, this.icon});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      highlightColor: Colors.white.withOpacity(.1),
      splashColor: Colors.white.withOpacity(.2),
      onPressed: onPressed,
      color: kColorRed,
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        // side: BorderSide(color: Colors.grey[400], width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null)
            Padding(
              padding: EdgeInsets.only(right: 5),
              child: icon,
            ),
          Text(
            buttonText,
            style: TextStyle(
              fontFamily: poppinsMedium,
              color: Colors.white,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class ActionButtonGreen extends StatelessWidget {
  final String buttonText;
  final Widget icon;
  final Function onPressed;

  ActionButtonGreen({@required this.buttonText, this.onPressed, this.icon});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      highlightColor: Colors.white.withOpacity(.1),
      splashColor: Colors.white.withOpacity(.2),
      onPressed: onPressed,
      color: Colors.green,
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        // side: BorderSide(color: Colors.grey[400], width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null)
            Padding(
              padding: EdgeInsets.only(right: 5),
              child: icon,
            ),
          Text(
            buttonText,
            style: TextStyle(
              fontFamily: poppinsMedium,
              color: Colors.white,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class ActionRightIconButton extends StatelessWidget {
  final String buttonText;
  final Widget icon;
  final Function onPressed;

  ActionRightIconButton({@required this.buttonText, this.onPressed, this.icon});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      highlightColor: Colors.white.withOpacity(.1),
      splashColor: Colors.white.withOpacity(.2),
      onPressed: onPressed,
      color: kColorRed,
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        // side: BorderSide(color: Colors.grey[400], width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            buttonText,
            style: TextStyle(
              fontFamily: poppinsMedium,
              color: Colors.white,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
          if (icon != null)
            Padding(
              padding: EdgeInsets.only(left: 6.0),
              child: icon,
            ),
        ],
      ),
    );
  }
}

class ActionButtonLight extends StatelessWidget {
  ActionButtonLight({@required this.buttonText, this.onPressed});

  final String buttonText;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      disabledColor: kColorRed.withOpacity(.05),
      disabledTextColor: kColorRed.withOpacity(.3),
      textColor: kColorRed,
      highlightColor: Colors.white.withOpacity(.2),
      splashColor: kColorRed.withOpacity(.2),
      elevation: 0,
      onPressed: onPressed,
      color: Color(0xFFFFE9E9),
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        // side: BorderSide(color: kColorRed.withOpacity(.1), width: 1),
      ),
      child: Text(
        buttonText,
        style: TextStyle(
          fontFamily: poppinsMedium,
          // color: kColorRed,
          fontSize: 14,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class ActionButtonOutline extends StatelessWidget {
  ActionButtonOutline({
    @required this.buttonText,
    this.textStyle,
    this.onPressed,
  });

  final String buttonText;
  final Function onPressed;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      elevation: 0,
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Colors.black,
          width: 1,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 8),
            child: Text(
              buttonText,
              style: textStyle != null
                  ? textStyle
                  : TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                    ),
            ),
          )
        ],
      ),
      color: Colors.white,
      textColor: Colors.white,
    );
  }
}

class ActionIconButtonOutline extends StatelessWidget {
  ActionIconButtonOutline({
    @required this.icon,
    @required this.buttonText,
    this.onPressed,
  });

  final Widget icon;
  final String buttonText;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      elevation: 0,
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Colors.black,
          width: 1,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
      onPressed: onPressed,
      child: Stack(
        // mainAxisAlignment: MainAxisAlignment.center,
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(margin: EdgeInsets.only(left: 6, right: 6), child: icon),
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Container(
                margin: EdgeInsets.only(left: 35, right: 35),
                padding: EdgeInsets.only(left: 8),
                child: Text(
                  buttonText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      color: Colors.white,
      textColor: Colors.white,
    );
  }
}

class ActionIconButton extends StatelessWidget {
  ActionIconButton(
      {@required this.buttonText, @required this.icon, this.onPressed});

  final Widget icon;
  final String buttonText;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
        disabledColor: kColorRed.withOpacity(.05),
        disabledTextColor: kColorRed.withOpacity(.3),
        textColor: kColorRed,
        highlightColor: Colors.white.withOpacity(.2),
        splashColor: kColorRed.withOpacity(.2),
        elevation: 2.0,
        onPressed: onPressed,
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          // side: BorderSide(color: kColorRed.withOpacity(.1), width: 1),
        ),
        child: Container(
          padding: EdgeInsets.all(6),
          child: Column(
            children: [
              icon,
              SizedBox(
                height: 10,
              ),
              Text(
                buttonText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: poppinsMedium,
                  // color: kColorRed,
                  fontSize: 14,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ));
  }
}

class ActionWithColorButton extends StatelessWidget {
  final String buttonText;
  final Widget icon;
  final Function onPressed;
  final Color butColor;

  ActionWithColorButton(
      {@required this.buttonText, this.onPressed, this.icon, this.butColor});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      highlightColor: Colors.white.withOpacity(.1),
      splashColor: Colors.white.withOpacity(.2),
      onPressed: onPressed,
      color: butColor != null ? butColor : kColorRed,
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        // side: BorderSide(color: Colors.grey[400], width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null)
            Padding(
              padding: EdgeInsets.only(right: 5),
              child: icon,
            ),
          Text(
            buttonText,
            style: TextStyle(
              fontFamily: poppinsMedium,
              color: Colors.white,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class ActionSmallButton extends StatelessWidget {
  final String buttonText;
  final Widget icon;
  final Function onPressed;
  final Color butColor;

  ActionSmallButton(
      {@required this.buttonText, this.onPressed, this.icon, this.butColor});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      highlightColor: Colors.white.withOpacity(.1),
      splashColor: Colors.white.withOpacity(.2),
      onPressed: onPressed,
      color: butColor != null ? butColor : kColorRed,
      padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 3.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        // side: BorderSide(color: Colors.grey[400], width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null)
            Padding(
              padding: EdgeInsets.only(right: 5),
              child: icon,
            ),
          Text(
            buttonText,
            style: TextStyle(
              fontFamily: poppinsMedium,
              color: Colors.white,
              fontSize: 10.0,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
