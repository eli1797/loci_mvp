import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mvp/models/user.dart';
import 'package:mvp/services/database.dart';
import 'package:mvp/services/location.dart';
import 'package:mvp/shared/loading.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'package:flame/game.dart';

class HomeTab extends StatefulWidget {

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    LangawGame game = LangawGame();
    return game.widget;
  }
}



class LangawGame extends Game {
  Size screenSize;

  void render(Canvas canvas) {}

  void update(double t) {}

  void resize(Size size) {}
}
