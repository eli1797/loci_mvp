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
  final _formKey = GlobalKey<FormState>();

  // text field states
  String _email = '';
  String _password = '';
  String error = '';

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
          key: _formKey,
          child: Column(
            children: <Widget>[
              SizedBox(height: 20.0),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: "Email",
                ),
                validator: (val) {
                  if (val.isEmpty) {
                    return 'Enter your email';
                  } else {
                    return null;
                  }
                },
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
                validator: (val) {
                  if (val.isEmpty) {
                    return 'Enter your password';
                  } else {
                    return null;
                  }
                },
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
                    if (_formKey.currentState.validate()) {
                      dynamic result = await _authService.signInEmailPass(_email, _password);
                      if (result == null) {
                        setState(() => error = 'Failed login. Incorrect credentials');
                      }
                    }
                  }),
              Text(
                error,
                style: TextStyle(color:  Colors.red, fontSize: 12.0),
              ),
              SizedBox(height: 5.0),
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
