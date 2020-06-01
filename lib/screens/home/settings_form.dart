//import 'package:flutter/material.dart';
//import 'package:mvp/models/user.dart';
//import 'package:mvp/services/database.dart';
//import 'package:mvp/shared/loading.dart';
//import 'package:provider/provider.dart';
//
//class SettingsForm extends StatefulWidget {
//  @override
//  _SettingsFormState createState() => _SettingsFormState();
//}
//
//class _SettingsFormState extends State<SettingsForm> {
//
//  final _formKey = GlobalKey<FormState>();
//  final List<String> sugars = ['0', '1', '2', '3', '4'];
//
//  // form values
//  String _currentName;
//  String _currentSugars;
//  int _currentStrength;
//
//  @override
//  Widget build(BuildContext context) {
//
//    final user = Provider.of<User>(context);
//
//    return StreamBuilder<UserData>(
////      stream: DatabaseService(uid: user.uid).userData,
////      builder: (context, snapshot) {
//
//        if(snapshot.hasData) {
//
//          UserData userData = snapshot.data;
//
//          return Form(
//            key: _formKey,
//            child: Column(
//              children: <Widget>[
//                Text(
//                  'Update your brew settings',
//                  style: TextStyle(fontSize: 18.0),
//                ),
//                SizedBox(height: 20.0),
//                TextFormField(
//                  initialValue: userData.name,
//                  validator: (val) => val.isEmpty ? 'Please enter your name' : null,
//                  onChanged: (val) => setState(() => _currentName = val),
//                ),
//                SizedBox(height: 20.0),
//                //dropdown
//                DropdownButtonFormField(
//                  value: _currentSugars ?? userData.sugars,
//                  items: sugars.map((sugar) {
//                    return DropdownMenuItem(
//                        value: sugar,
//                        child: Text('$sugar sugars')
//                    );
//                  }).toList(),
//                  onChanged: (val) => setState(() => _currentSugars = val),
//                ),
//                Slider(
//                  value: (_currentStrength ?? userData.strength).toDouble(),
//                  activeColor: Colors.blue[_currentStrength ?? userData.strength],
//                  inactiveColor: Colors.blue[_currentStrength ?? userData.strength],
//                  min: 100,
//                  max: 900,
//                  divisions: 8,
//                  onChanged: (val) => setState(() => _currentStrength = val.round()),
//                ),
//                SizedBox(height: 20.0),
//
//                RaisedButton(
//                  color: Colors.blue,
//                  child: Text('Update'),
//                  onPressed: () async {
//                    if (_formKey.currentState.validate()) {
//                      await DatabaseService(uid: user.uid).updateUserData(
//                          _currentSugars ?? userData.sugars,
//                          _currentName ?? userData.name,
//                          _currentStrength ?? userData.strength
//                      );
//
//                      Navigator.pop(context);
//                    } else {
//                      print("Form invalid");
//                    }
//
//                  },
//                )
//              ],
//            )
//          );
//        } else {
//          return Loading();
//        }
//      }
//    );
//  }
//}
