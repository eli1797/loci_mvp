import 'package:flutter/material.dart';
import 'package:mvp/services/auth.dart';

class Profile extends StatelessWidget {

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.settings, color: Colors.black,),
              onPressed: ()  {
                print("Settings");
              })
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: Column(
          children: <Widget>[
            RaisedButton(
                color:  Colors.blue,
                child: Text('Log out'),
                onPressed: () async {
                  Future result = await _authService.signOut();
                  Navigator.pop(context);
                }
            ),
          ],
        )
      )
    );
  }
}
