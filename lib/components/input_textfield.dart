import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import '../utils/constants/styles.dart';

class InputTextFormField extends StatelessWidget {
  InputTextFormField({
    this.hintText,
    this.initText,
    this.prefixText,
    this.obscureText,
    this.onChange,
    this.onTap,
    this.controller,
    this.prefix,
    this.enabled,
    this.inputType,
    this.textAlign,
    this.suffix,
    this.textInputFormatter
  });

  final String hintText;
  final String initText;
  final String prefixText;
  final bool obscureText;
  final Function onChange;
  final Function onTap;
  final TextInputType inputType;
  final TextAlign textAlign;
  final TextEditingController controller;
  final TextInputFormatter textInputFormatter;
  final bool enabled;
  final Widget prefix;
  final Widget suffix;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChange,
      onTap: onTap,
      controller: initText != null
          ? (TextEditingController()..text = initText)
          : controller,
      enabled: (enabled != null) ? enabled : true,
      obscureText: obscureText == null ? false : obscureText,
      keyboardType: inputType,
      textAlign: (textAlign != null) ? textAlign : TextAlign.start,
      style: kInputTextStyle,
      inputFormatters: textInputFormatter!=null?[textInputFormatter]:null,
      decoration: kTextFieldInputDecoration.copyWith(
        // isCollapsed: (prefix != null),
        // filled: false,
        // contentPadding: EdgeInsets.all(0),
        hintText: hintText,
        prefixIcon: prefix,
        suffix: suffix,
        prefixText: prefixText,
        prefixStyle: kInputTextStyle
      ),
    );
  }
}

class InputTextField extends StatelessWidget {
  InputTextField({
    this.hintText,
    this.initText,
    this.obscureText,
    this.onChange,
    this.onTap,
    this.controller,
    this.prefix,
    this.enabled,
    this.inputType,
    this.textAlign,
    this.suffix,
  });

  final String hintText;
  final String initText;
  final bool obscureText;
  final Function onChange;
  final Function onTap;
  final TextInputType inputType;
  final TextAlign textAlign;
  final TextEditingController controller;
  final bool enabled;
  final Widget prefix;
  final Widget suffix;
  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChange,
      onTap: onTap,
      controller: initText != null
          ? (getController())
          : controller,
      enabled: (enabled != null) ? enabled : true,
      obscureText: obscureText == null ? false : obscureText,
      keyboardType: inputType,
      textAlign: (textAlign != null) ? textAlign : TextAlign.start,
      style: kInputTextStyle,
      decoration: kTextFieldInputDecoration.copyWith(
        // isCollapsed: (prefix != null),
        // filled: false,
        // contentPadding: EdgeInsets.all(0),
        hintText: hintText,
        prefixIcon: prefix,
        suffix: suffix,
      ),
    );
  }

  TextEditingController getController(){
    var controller = TextEditingController();
    controller.text = initText;
    controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text?.length ?? 0));
    return controller;
  }
}

class InputTextTLTRBorderField extends StatelessWidget {
  InputTextTLTRBorderField({
    this.hintText,
    this.initText,
    this.obscureText,
    this.onChange,
    this.onTap,
    this.controller,
    this.prefix,
    this.enabled,
    this.inputType,
    this.textAlign,
    this.suffix,
  });

  final String hintText;
  final String initText;
  final bool obscureText;
  final Function onChange;
  final Function onTap;
  final TextInputType inputType;
  final TextAlign textAlign;
  final TextEditingController controller;
  final bool enabled;
  final Widget prefix;
  final Widget suffix;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChange,
      onTap: onTap,
      controller: initText != null
          ? (TextEditingController()..text = initText)
          : controller,
      enabled: (enabled != null) ? enabled : true,
      obscureText: obscureText == null ? false : obscureText,
      keyboardType: inputType,
      textAlign: (textAlign != null) ? textAlign : TextAlign.start,
      style: kInputTextStyle,
      decoration: kTextFieldTLTRBorderInputDecoration.copyWith(
        // isCollapsed: (prefix != null),
        // filled: false,
        // contentPadding: EdgeInsets.all(0),
        hintText: hintText,
        prefixIcon: prefix,
        suffix: suffix,
      ),
    );
  }
}

class InputTextBLBRBorderField extends StatelessWidget {
  InputTextBLBRBorderField({
    this.hintText,
    this.initText,
    this.obscureText,
    this.onChange,
    this.onTap,
    this.controller,
    this.prefix,
    this.enabled,
    this.inputType,
    this.textAlign,
    this.suffix,
  });

  final String hintText;
  final String initText;
  final bool obscureText;
  final Function onChange;
  final Function onTap;
  final TextInputType inputType;
  final TextAlign textAlign;
  final TextEditingController controller;
  final bool enabled;
  final Widget prefix;
  final Widget suffix;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChange,
      onTap: onTap,
      controller: initText != null
          ? (TextEditingController()..text = initText)
          : controller,
      enabled: (enabled != null) ? enabled : true,
      obscureText: obscureText == null ? false : obscureText,
      keyboardType: inputType,
      textAlign: (textAlign != null) ? textAlign : TextAlign.start,
      style: kInputTextStyle,
      decoration: kTextFieldBLBRBorderInputDecoration.copyWith(
        // isCollapsed: (prefix != null),
        // filled: false,
        // contentPadding: EdgeInsets.all(0),
        hintText: hintText,
        prefixIcon: prefix,
        suffix: suffix,
      ),
    );
  }
}

class PasswordInputTextField extends StatefulWidget {
  PasswordInputTextField({
    this.hintText,
    this.initText,
    this.onChange,
    this.onTap,
    this.controller,
    this.prefix,
    this.enabled,
    this.inputType,
    this.textAlign,
    this.suffix,
  });

  final String hintText;
  final String initText;
  final Function onChange;
  final Function onTap;
  final TextInputType inputType;
  final TextAlign textAlign;
  final TextEditingController controller;
  final bool enabled;
  final Widget prefix;
  final Widget suffix;
  @override
  _PasswordInputTextFieldState createState() => _PasswordInputTextFieldState();
}

class _PasswordInputTextFieldState extends State<PasswordInputTextField> {
  bool _showTxt = false;
  @override
  Widget build(BuildContext context) {
    return InputTextField(
      onChange: widget.onChange,
      onTap: widget.onTap,
      controller: widget.initText != null
          ? (TextEditingController().text = widget.initText)
          : widget.controller,
      enabled: (widget.enabled != null) ? widget.enabled : true,
      obscureText: !_showTxt,
      inputType: widget.inputType,
      textAlign:
          (widget.textAlign != null) ? widget.textAlign : TextAlign.start,
      hintText: widget.hintText,
      suffix: GestureDetector(
        onTap: () {
          setState(() => _showTxt = !_showTxt);
        },
        child: Text(
          _showTxt
              ? AppTranslations.of(context).text('input_sufix_btn_hide')
              : AppTranslations.of(context).text('input_sufix_btn_show'),
          style: TextStyle(
            color: Colors.black,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}

class PasswordInputBLBRBorderTextField extends StatefulWidget {
  PasswordInputBLBRBorderTextField({
    this.hintText,
    this.initText,
    this.onChange,
    this.onTap,
    this.controller,
    this.prefix,
    this.enabled,
    this.inputType,
    this.textAlign,
    this.suffix,
  });

  final String hintText;
  final String initText;
  final Function onChange;
  final Function onTap;
  final TextInputType inputType;
  final TextAlign textAlign;
  final TextEditingController controller;
  final bool enabled;
  final Widget prefix;
  final Widget suffix;
  @override
  _PasswordInputBLBRBorderTextFieldState createState() =>
      _PasswordInputBLBRBorderTextFieldState();
}

class _PasswordInputBLBRBorderTextFieldState
    extends State<PasswordInputBLBRBorderTextField> {
  bool _showTxt = false;
  @override
  Widget build(BuildContext context) {
    return InputTextBLBRBorderField(
      onChange: widget.onChange,
      onTap: widget.onTap,
      controller: widget.initText != null
          ? (TextEditingController().text = widget.initText)
          : widget.controller,
      enabled: (widget.enabled != null) ? widget.enabled : true,
      obscureText: !_showTxt,
      inputType: widget.inputType,
      textAlign:
          (widget.textAlign != null) ? widget.textAlign : TextAlign.start,
      hintText: widget.hintText,
      suffix: GestureDetector(
        onTap: () {
          setState(() => _showTxt = !_showTxt);
        },
        child: Text(
          _showTxt
              ? AppTranslations.of(context).text('input_sufix_btn_hide')
              : AppTranslations.of(context).text('input_sufix_btn_show'),
          style: TextStyle(
            color: Colors.black,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}

class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({this.decimalRange})
      : assert(decimalRange == null || decimalRange > 0);

  final int decimalRange;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, // unused.
      TextEditingValue newValue,
      ) {
    TextSelection newSelection = newValue.selection;
    String truncated = newValue.text;

    if (decimalRange != null) {
      String value = newValue.text;

      if (value.contains(".") &&
          value.substring(value.indexOf(".") + 1).length > decimalRange) {
        truncated = oldValue.text;
        newSelection = oldValue.selection;
      } else if (value == ".") {
        truncated = "0.";

        newSelection = newValue.selection.copyWith(
          baseOffset: min(truncated.length, truncated.length + 1),
          extentOffset: min(truncated.length, truncated.length + 1),
        );
      }

      return TextEditingValue(
        text: truncated,
        selection: newSelection,
        composing: TextRange.empty,
      );
    }
    return newValue;
  }
}
