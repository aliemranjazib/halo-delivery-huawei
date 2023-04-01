import 'package:flutter/material.dart';

class SamplePage extends StatefulWidget {
  static const String id = 'SamplePage';

  @override
  _SamplePageState createState() => _SamplePageState();
}

class _SamplePageState extends State<SamplePage> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
          // backgroundColor: kLightBackground,
          body: SafeArea(
        child: Container(),
      )),
    );
  }
}
