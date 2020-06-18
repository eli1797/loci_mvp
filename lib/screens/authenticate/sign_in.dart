import 'package:flutter/material.dart';
import 'package:mvp/services/auth.dart';
import 'package:mvp/shared/loading.dart';

class SignIn extends StatefulWidget {

  final Function toggleView;
  SignIn({ this.toggleView });

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  /// Service providing connection to Firebase Auth
  final AuthService _authService = AuthService();

  /// Key for email and password form
  final _formKey = GlobalKey<FormState>();

  /// State holder for whether or not to show the loading widget
  bool _loading = false;

  /// text field states
  String _email = '';
  String _password = '';
  String _error = '';

  @override
  Widget build(BuildContext context) {

    // Show loading widget or Sign-in depending on state
    return _loading ? Loading() : Scaffold(
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
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Email',
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
                  hintText: 'Password',
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
                    setState(() => _loading = true);

                    // Try Sign-in, display error if it fails
                    dynamic result = await _authService.signInEmailPass(_email.trim(), _password.trim());
                    if (result == null) {
                      setState(() {
                        _error = 'Failed login. Incorrect credentials';
                        _loading = false;
                      });
                    }
                  }
                }),
              Text(
                _error,
                style: TextStyle(color:  Colors.red, fontSize: 12.0),
              ),
              SizedBox(height: 5.0),
              FlatButton(
                child: Text('Need an account? Register'),
                onPressed: () {
                  widget.toggleView();
                }
              ),
            ],
          ),
        ),
      ),
    );
  }
}
