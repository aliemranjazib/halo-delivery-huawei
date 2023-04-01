import 'package:flutter/material.dart';
import '../constants/fonts.dart';
import '../constants/custom_colors.dart';

// Text Style
const kAppBarTextStyle =
    TextStyle(color: Colors.black, fontFamily: poppinsSemiBold, fontSize: 18);

const kInputTextStyle = TextStyle(fontFamily: poppinsRegular, fontSize: 14);
const kAddressPlaceholderTextStyle =
    TextStyle(color: Colors.grey, fontFamily: poppinsRegular, fontSize: 16);

const kAddressTextStyle =
    TextStyle(color: Colors.black, fontFamily: poppinsMedium, fontSize: 16);
const kTitleTextStyle = TextStyle(fontFamily: poppinsMedium, fontSize: 20);
const kDetailsTextStyle = TextStyle(fontFamily: poppinsRegular, fontSize: 16);
const kDetailsSemiBoldTextStyle = TextStyle(fontFamily: poppinsSemiBold, fontSize: 16);

const kSmallLabelTextStyle =
    TextStyle(fontFamily: poppinsRegular, fontSize: 12);

const kLabelSemiBoldTextStyle =
    TextStyle(fontFamily: poppinsSemiBold, fontSize: 14);

const kLabelTextStyle = TextStyle(fontFamily: poppinsRegular, fontSize: 14);
const kTitleSemiBoldTextStyle = TextStyle(fontFamily: poppinsSemiBold, fontSize: 18);

const kTitleLargeBoldTextStyle = TextStyle(fontFamily:poppinsBold,fontWeight: FontWeight.bold,fontSize: 16);
const kTitleBoldTextStyle = TextStyle(fontFamily:poppinsBold,fontWeight: FontWeight.bold,fontSize: 14);
const kSmallTitleBoldTextStyle = TextStyle(fontFamily:poppinsBold,fontWeight: FontWeight.bold,fontSize: 12);
const kLargeTitleBoldTextStyle = TextStyle(fontFamily:poppinsBold,fontWeight: FontWeight.bold,fontSize: 22);
const kLargeTitleSemiBoldTextStyle = TextStyle(fontFamily:poppinsSemiBold,fontWeight: FontWeight.w500,fontSize: 22);


// Input Border
const kOutlineInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(5)),
  borderSide: BorderSide(
    color: Colors.grey,
    width: 1,
    style: BorderStyle.solid,
  ),
);

const kOutlineInputTLTRBorder = OutlineInputBorder(
  borderRadius: BorderRadius.only(
    topLeft: Radius.circular(5),
    topRight: Radius.circular(5),
  ),
  borderSide: BorderSide(
    color: Colors.grey,
    width: 1,
    style: BorderStyle.solid,
  ),
);

const kOutlineInputBLBRBorder = OutlineInputBorder(
  borderRadius: BorderRadius.only(
    bottomLeft: Radius.circular(5),
    bottomRight: Radius.circular(5),
  ),
  borderSide: BorderSide(
    color: Colors.grey,
    width: 1,
    style: BorderStyle.solid,
  ),
);

const kOutlineInputBorderActive = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(5)),
  borderSide: BorderSide(
    width: 1,
    style: BorderStyle.solid,
  ),
);

const kTextFieldInputDecoration = InputDecoration(
  hintStyle:
      TextStyle(fontFamily: poppinsRegular, fontSize: 14, color: Colors.grey),
  contentPadding: EdgeInsets.symmetric(vertical: 1, horizontal: 15),
  filled: true,
  fillColor: Colors.white,
  border: kOutlineInputBorder,
  enabledBorder: kOutlineInputBorder,
  focusedBorder: kOutlineInputBorderActive,
);

InputDecoration kTextFieldTLTRBorderInputDecoration = InputDecoration(
  hintStyle:
      TextStyle(fontFamily: poppinsRegular, fontSize: 14, color: Colors.grey),
  contentPadding: EdgeInsets.symmetric(vertical: 1, horizontal: 15),
  filled: true,
  fillColor: Colors.white,
  border: kOutlineInputTLTRBorder,
  enabledBorder: kOutlineInputTLTRBorder,
  focusedBorder: kOutlineInputBorderActive.copyWith(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(5),
      topRight: Radius.circular(5),
    ),
  ),
);

InputDecoration kTextFieldBLBRBorderInputDecoration = InputDecoration(
  hintStyle:
      TextStyle(fontFamily: poppinsRegular, fontSize: 14, color: Colors.grey),
  contentPadding: EdgeInsets.symmetric(vertical: 1, horizontal: 15),
  filled: true,
  fillColor: Colors.white,
  border: kOutlineInputBLBRBorder,
  enabledBorder: kOutlineInputBLBRBorder,
  focusedBorder: kOutlineInputBorderActive.copyWith(
    borderRadius: BorderRadius.only(
      bottomLeft: Radius.circular(5),
      bottomRight: Radius.circular(5),
    ),
  ),
);

BoxDecoration kAppBarGradient = BoxDecoration(
  gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomLeft,
      colors: <Color>[
        kColorRed,
        kColorRed,
      ]),
);

const double marginBot = 8.0;
