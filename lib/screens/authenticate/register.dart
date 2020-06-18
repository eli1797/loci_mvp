import 'package:flutter/material.dart';
import 'package:mvp/models/user.dart';
import 'package:mvp/services/auth.dart';
import 'package:mvp/shared/loading.dart';
import 'package:provider/provider.dart';

class Register extends StatefulWidget {

  final Function toggleView;
  Register({ this.toggleView });

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  /// Service providing connection to Firebase Auth
  final AuthService _authService = AuthService();

  /// Key for email and password form
  final _formKey = GlobalKey<FormState>();

  /// State holder for whether or not to show the loading widget
  bool _loading = false;

  /// Text field states
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
        title: Text('Register'),
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
                  hintText: "Email",
                ),
                validator: (val) {
                  if (val.isEmpty) {
                    return 'Enter a email';
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
                    return 'Enter a password';
                  } else if (val.length < 6) {
                    return 'Enter an password longer than 6 characters';
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
                child: Text('Register'),
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    setState(() => _loading = true);
                    dynamic result = await _authService.registerEmailPass(_email.trim(), _password.trim());
                    if (result == null) {
                      setState(() {
                        _error = 'Please supply a valid email';
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
                child: Text('Already have an account? Sign in'),
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
