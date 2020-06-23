import 'dart:ui';
import 'package:flame/gestures.dart';
import 'package:flutter/gestures.dart';
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


    /// Create a Flame Utility instance
    Util flameUtil = Util();
    // lock the orientation to portrait up
    flameUtil.setOrientation(DeviceOrientation.portraitUp);

    // create an instance of the game
    BoxGame game = BoxGame(screenSize: MediaQuery.of(context).size);

    // return the game as a widget
    return game.widget;
  }
}



class BoxGame extends Game with TapDetector {

  Size screenSize;
  bool hasWon = false;

  BoxGame({ this.screenSize });

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
    if (hasWon) {
      boxPaint.color = Color(0xff00ff00);
    } else {
      boxPaint.color = Color(0xffffffff);
    }
    canvas.drawRect(boxRect, boxPaint);
  }

  void onTapDown(TapDownDetails d) {
    print("Tapped");

    print(d.localPosition.dx);
    print(d.localPosition.dy);

    double screenCenterX = screenSize.width / 2;
    double screenCenterY = screenSize.height / 2;

    // if you tap inside the box you win
    if (d.localPosition.dx >= screenCenterX - 75
        && d.localPosition.dx <= screenCenterX + 75
        && d.localPosition.dy >= screenCenterY - 75
        && d.localPosition.dy <= screenCenterY + 75
    ) {
      print("set true");
      hasWon = true;
    } else {
      hasWon = false;
    }
  }

  void update(double t) {}

}
