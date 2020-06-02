import 'package:flutter/material.dart';
import 'package:mvp/screens/wrapper.dart';
import 'package:mvp/services/auth.dart';
import 'package:provider/provider.dart';
import 'package:mvp/models/user.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User>(
      create: (_) => AuthService().user,
      child: MaterialApp(
//        initialRoute: '/',
//        routes: {
//          '/': (context) => Wrapper(),
//        },
      home: Wrapper(),
      ),
    );
  }
}