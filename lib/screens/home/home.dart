import 'package:flutter/material.dart';
import 'package:mvp/services/auth.dart';

class Home extends StatelessWidget {

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
              label: Text('logout')),
//            FlatButton.icon(
//                onPressed: () => _showSettingsPanel(),
//                icon: Icon(Icons.settings),
//                label: Text('settings'))
        ],
      ),
      body: Text('Hello world'),
    );
  }
}
