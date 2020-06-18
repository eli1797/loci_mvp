import 'package:flutter/material.dart';
import 'package:mvp/services/auth.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    /// Service to interact with Firebase Auth
    final AuthService _authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: Column(
          children: <Widget>[
            RaisedButton(
              color: Colors.blue,
              child: Text('Log out'),
              onPressed: () async {
                Future result = await _authService.signOut();
                Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
              }
            ),
          ],
        ),
      ),
    );
  }
}
