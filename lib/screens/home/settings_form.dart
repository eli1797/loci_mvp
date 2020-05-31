import 'package:flutter/material.dart';

class SettingsForm extends StatefulWidget {
  @override
  _SettingsFormState createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {

  final _formKey = GlobalKey<FormState>();
  final List<String> sugars = ['0', '1', '2', '3', '4'];

  // form values
  String _currentName;
  String _currentSugars;
  int _currentStrength;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Text(
            'Update your brew settings',
            style: TextStyle(fontSize: 18.0),
          ),
          SizedBox(height: 20.0),
          TextFormField(
            decoration: const InputDecoration(
              hintText: "Name",
            ),
            validator: (val) => val.isEmpty ? 'Please enter your name' : null,
            onChanged: (val) => setState(() => _currentName = val),
          ),
          SizedBox(height: 20.0),
          //dropdown
          DropdownButtonFormField(
            value: _currentSugars ?? '0',
            items: sugars.map((sugar) {
              return DropdownMenuItem(
                value: sugar,
                child: Text('$sugar sugars')
              );
            }).toList(),
            onChanged: (val) => setState(() => _currentSugars = val),
          ),
          Slider(
            value: (_currentStrength ?? 100).toDouble(),
            min: 100,
            max: 900,
            divisions: 8,
            onChanged: (val) => setState(() => _currentStrength = val.round()),
          ),
          SizedBox(height: 20.0),

          RaisedButton(
            color: Colors.blue,
            child: Text('Update'),
            onPressed: () async {
              print(_currentName);
              print(_currentSugars);
              print(_currentStrength);
            },
          )
        ],
      )
    );
  }
}
