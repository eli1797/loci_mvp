import 'package:flutter/material.dart';
import 'package:mvp/services/auth.dart';
import 'package:mvp/shared/loading.dart';

class Register extends StatefulWidget {

  final Function toggleView;
  Register({ this.toggleView });

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  // text field states
  String _email = '';
  String _password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
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
                  decoration: const InputDecoration(
                    hintText: "Email",
//                    enabledBorder: OutlineInputBorder(
//                      borderSide: BorderSide(color: Colors.blue, width: 2.0)
//                    ),
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
                          error = 'Please supply a valid email';
                          _loading = false;
                        });
                      }
                    }
                  }),
              Text(
                error,
                style: TextStyle(color:  Colors.red, fontSize: 12.0),
              ),
              SizedBox(height: 5.0),
              FlatButton(
                 child: Text('Already have an account? Sign in'),
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
