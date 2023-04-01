import 'package:flutter/material.dart';

class HaloLoading extends StatefulWidget {
  const HaloLoading({Key key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _HaloLoading();
}

class _HaloLoading extends State<HaloLoading> with TickerProviderStateMixin {
  AnimationController _controller;
  Tween<double> _tween = Tween(begin: 0.75, end: 2);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(duration: const Duration(milliseconds: 700), vsync: this);
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
      // TODO: implement dispose
      _controller.dispose();
      super.dispose();
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: <Widget>[
          Align(
            child: ScaleTransition(
              scale: _tween.animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut)),
              child: SizedBox(
                height: 150,
                width: 150,
                child: Image.asset(
                  'images/haloje_logo.png',
                  // height: 100.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}