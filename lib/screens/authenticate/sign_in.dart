import 'package:flutter/material.dart';
import 'package:mvp/services/auth.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[100],
      appBar: AppBar(
        backgroundColor: Colors.brown[400],
        elevation: 0.0,
        title: Text('Sign in'),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: RaisedButton(
          child: Text('Sign in Anonymously'),
          onPressed: () async {
            //dynamic because it could be a FirebaseUser or null
            dynamic result = await _authService.signInAnon();
            if (result == null) {
              print('Error signing in');
            } else {
              print('Signed in');
              print(result);
            }
          },
        ),
      ),
    );
  }
}
