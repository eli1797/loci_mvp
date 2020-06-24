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
    BoxGame game = BoxGame(MediaQuery.of(context).size);

    // return the game as a widget
    return game.widget;
  }
}



class BoxGame extends Game with TapDetector {

  Size screenSize;
  bool hasWon = false;

  double newX = 0;
  double newY = 0;

  Rect boxRect;

  BoxGame(this.screenSize) {
    // draw a box
    this.boxRect = Rect.fromLTWH(
        0,
        0,
        50,
        50
    );
  }



  Paint boxPaint = Paint();


  void render(Canvas canvas) {
    // draw a rectangle for the background
    Rect bgRect = Rect.fromLTWH(0, 0, screenSize.width, screenSize.height);
    // make a paint object to fill in the rectangle
    Paint bgPaint = Paint();
    bgPaint.color = Color(0xff000000);
    // fill in the background rectangle
    canvas.drawRect(bgRect, bgPaint);

    //draw the box
    boxPaint.color = Colors.orange;
    canvas.drawRect(boxRect, boxPaint);
  }

  void onTapDown(TapDownDetails d) {
    print("Tapped");

    print(d.localPosition.dx);
    print(d.localPosition.dy);

//    Offset offset = Offset(d.localPosition.dx, d.localPosition.dy);
////    boxRect.translate(d.localPosition.dx, d.localPosition.dy);
    this.newX = d.localPosition.dx.toDouble();
    this.newY = d.localPosition.dy.toDouble();

  }

  void update(double t) {
    if (this.newX != 0.0 && this.newY != 0.0) {
      print("Hi");
      this.boxRect = boxRect.translate(newX, newY);
    }

    this.newX = 0.0;
    this.newY = 0.0;


    print(this.boxRect.toString());
  }

}

class RectObj {

  Rect rectObj;
  Paint rectPaint;
  double x;
  double y;
  BoxGame boxGame;

  RectObj(this.boxGame, double x, double y) {
    rectObj = Rect.fromLTWH(x, y, 30, 30);
    rectPaint = Paint();
    rectPaint.color = Color(0xff6ab04c);
  }

  void render(Canvas c) {
    c.drawRect(rectObj, rectPaint);
  }

  void update(double t) {

  }
}
