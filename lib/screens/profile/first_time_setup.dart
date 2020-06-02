import 'package:flutter/material.dart';
import 'package:mvp/models/user.dart';
import 'package:mvp/services/auth.dart';
import 'package:mvp/services/database.dart';
import 'package:mvp/shared/loading.dart';
import 'package:provider/provider.dart';

class FirstTimeSetup extends StatefulWidget {
  @override
  _FirstTimeSetupState createState() => _FirstTimeSetupState();
}

class _FirstTimeSetupState extends State<FirstTimeSetup> {

  final _formKey = GlobalKey<FormState>();

  final AuthService _authService = AuthService();

  //show the loading screen when true
  bool _loading = false;

  // form values
  String _currentFirstName;
  String error = '';

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Loci'),
        backgroundColor: Colors.blue,
        elevation: 0.0,
        actions: <Widget>[
          FlatButton.icon(
              onPressed: () async {
                await _authService.signOut();
              },
              icon: Icon(Icons.person),
              label: Text('logout')
          ),
        ],
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
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                hintText: "What do you go by?",
              ),
              validator: (val) {
                //@Todo: validate further, against non-text, injection? etc
                return val.isEmpty ? 'Please enter your first name' : null;
              },
              onChanged: (val) => setState(() => _currentFirstName = val),
            ),
            SizedBox(height: 20.0),
            Align(
              alignment: Alignment.centerRight,
              child: RaisedButton(
                  color: Colors.blue,
                  child: Text('Say Hi'),
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      error = '';
                      setState(() => _loading = true);
                      dynamic result = await DatabaseService(uid: user.uid)
                          .updateName(_currentFirstName);
                      if (result != null) {
                        setState(() {
                          error = 'Failed login. Incorrect credentials';
                          _loading = false;
                        });
                      }
                      print(user.toString());
                      print("Hi $_currentFirstName!");
                    }
                  }),
            ),
            Text(
              error,
              style: TextStyle(color: Colors.red, fontSize: 12.0),
            ),
          ]),
        ),
      ),
    );
  }
}
