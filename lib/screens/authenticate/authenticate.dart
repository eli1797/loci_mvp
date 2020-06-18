import 'package:flutter/material.dart';
import 'package:mvp/screens/authenticate/register.dart';
import 'package:mvp/screens/authenticate/sign_in.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {

  /// state holder determining whether to show sign-in or registration screen
  bool _showSignIn = true;

  void toggleView() {
    setState(() => _showSignIn = !_showSignIn);
  }

  @override
  Widget build(BuildContext context) {
    // toggle between screen based on _showSignIn
    if (_showSignIn) {
      return SignIn(toggleView: toggleView);
    } else {
      return Register(toggleView: toggleView);
    }
  }
}
