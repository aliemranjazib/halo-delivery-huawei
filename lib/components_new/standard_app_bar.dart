import 'package:flutter/material.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/constants/styles.dart';

class StandardAppBar extends StatelessWidget {
  StandardAppBar({this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(
          Icons.chevron_left,
          color: Colors.black,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      actions: <Widget>[
        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.chevron_left,
            color: Colors.white,
          ),
        ),
      ],
      title: Center(
        child: Text(
          title,
          style: kAppBarTextStyle.copyWith(
            fontFamily: poppinsBold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
