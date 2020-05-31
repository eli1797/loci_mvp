import 'package:flutter/material.dart';
import 'package:mvp/services/auth.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  final AuthService _authService = AuthService();

  // text field states
  String _email = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0.0,
        title: Text('Register'),
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
                  child: Text('Register'),
                  onPressed: () async {
                    print(_email);
                    print(_password);
                  })
            ],
          ),
        ),
      ),
    );
  }
}
