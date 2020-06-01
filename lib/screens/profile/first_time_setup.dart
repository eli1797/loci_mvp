import 'package:flutter/material.dart';

class FirstTimeSetup extends StatefulWidget {
  @override
  _FirstTimeSetupState createState() => _FirstTimeSetupState();
}

class _FirstTimeSetupState extends State<FirstTimeSetup> {

  final _formKey = GlobalKey<FormState>();

  //show the loading screen when true
  bool _loading = false;

  // form values
  String _currentFirstName;
  String _error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Loci'),
        backgroundColor: Colors.blue,
        elevation: 0.0,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 50.0),
        child: Form(
          key: _formKey,
          child: Column(children: <Widget>[
            Text(
              'What\'s your first name?',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 20.0),
            TextFormField(
              decoration: const InputDecoration(
                hintText: "Enter your first name.",
              ),
              validator: (val) =>
                  val.isEmpty ? 'Please enter your first name' : null,
              onChanged: (val) => setState(() => _currentFirstName = val),
            ),
            SizedBox(height: 20.0),
            Align(
              alignment: Alignment.centerRight,
              child: RaisedButton(
                  color:  Colors.blue,
                  child: Text('Next'),
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
//                    setState(() => _loading = true);
//                    dynamic result = await _authService.signInEmailPass(_email, _password);
//                    if (result == null) {
//                      setState(() {
//                        error = 'Failed login. Incorrect credentials';
//                        _loading = false;
//                      });
//                    }
                      print("Hi $_currentFirstName!");
                    }
                  }),
            ),
//            Text(
//              _error,
//              style: TextStyle(color:  Colors.red, fontSize: 12.0),
//            ),
          ]),
        ),
      ),
    );
  }
}
