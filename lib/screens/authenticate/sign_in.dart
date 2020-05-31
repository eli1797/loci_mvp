import 'package:flutter/material.dart';
import 'package:mvp/screens/authenticate/register.dart';
import 'package:mvp/services/auth.dart';

class SignIn extends StatefulWidget {

  final Function toggleView;
  SignIn({ this.toggleView });

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  final AuthService _authService = AuthService();

  // text field states
  String _email = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0.0,
        title: Text('Sign in'),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: Form(
          child: Column(
            children: <Widget>[
              SizedBox(height: 20.0),
              TextFormField(
                  decoration: const InputDecoration(
                    hintText: "Email",
                  ),
                onChanged: (val) {
                  setState(() {
                    _email = val;
                  });
                }
              ),
              SizedBox(height: 20.0),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: "Password",
                ),
                obscureText: true,
                onChanged: (val) {
                  setState(() {
                    _password = val;
                  });
                }
              ),
              SizedBox(height: 20.0),
              RaisedButton(
                  color:  Colors.blue,
                  child: Text('Sign In'),
                  onPressed: () async {
                    print(_email);
                    print(_password);
                  }),
              SizedBox(height: 10.0),
              FlatButton(
                  child: Text('Need an account? Register'),
                  onPressed: () {
                    widget.toggleView();
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
