import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mvp/models/user.dart';
import 'package:mvp/services/auth.dart';
import 'package:mvp/services/database.dart';
import 'package:mvp/services/location.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {

  final AuthService _authService = AuthService();
  final LocationService _locationService = LocationService();

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User>(context);
    print(user);

    _locationService.checkPermission();

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
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: Column(
          children: <Widget>[
            SizedBox(height: 20.0),
            RaisedButton(
              color:  Colors.blue,
              child: Text('Get Location'),
              onPressed: () async {
                Position pos =  await _locationService.getPosition();
                print(pos);
                await DatabaseService(uid: user.uid).updateLocationFromPosition(pos);
                await DatabaseService(uid: user.uid).updateLocationWithGeo(pos);
                DatabaseService(uid: user.uid).queryWithinRange(pos, 50);
              },
            )
          ],
        ),
      )

    );
  }
}
