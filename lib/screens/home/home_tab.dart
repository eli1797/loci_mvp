import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mvp/models/user.dart';
import 'package:provider/provider.dart';
import 'package:flame/game.dart';
import 'package:flame/util.dart';

class HomeTab extends StatefulWidget {

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    Util flameUtil = Util();
    flameUtil.setOrientation(DeviceOrientation.portraitUp);

    BoxGame game = BoxGame();
    return game.widget;
  }
}



class BoxGame extends Game {
  Size screenSize;

  void render(Canvas canvas) {
    // draw a rectangle for the background
    Rect bgRect = Rect.fromLTWH(0, 0, screenSize.width, screenSize.height);
    // make a paint object to fill in the rectangle
    Paint bgPaint = Paint();
    bgPaint.color = Color(0xff000000);
    // fill in the background rectangle
    canvas.drawRect(bgRect, bgPaint);

    // draw a box
    double screenCenterX = screenSize.width / 2;
    double screenCenterY = screenSize.height / 2;
    Rect boxRect = Rect.fromLTWH(
        screenCenterX - 75,
        screenCenterY - 75,
        150,
        150
    );
    Paint boxPaint = Paint();
    boxPaint.color = Color(0xffffffff);
    canvas.drawRect(boxRect, boxPaint);






  }

  void update(double t) {}

  void resize(Size size) {
    screenSize = size;
    super.resize(size);
  }
}
