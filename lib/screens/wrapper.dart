import 'package:flutter/material.dart';
import 'package:mvp/models/user.dart';
import 'package:mvp/screens/authenticate/authenticate.dart';
import 'package:mvp/screens/home/home_wrapper.dart';
import 'package:provider/provider.dart';

/*
Wrapper listens for auth changes and chooses what to show accordingly
 */
class Wrapper extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    /// User model from Provider in main.dart
    final user = Provider.of<User>(context);

    // Show different screens based on authentication status
    if (user == null) {
      return Authenticate();
    } else {
      return HomeWrapper();
    }
  }
}
