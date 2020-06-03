import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mvp/models/user.dart';
import 'package:mvp/screens/authenticate/authenticate.dart';
import 'package:mvp/screens/profile/profile.dart';
import 'package:mvp/services/auth.dart';
import 'package:mvp/services/database.dart';
import 'package:mvp/services/location.dart';
import 'package:provider/provider.dart';

//@Todo: might need to make Home stateful for updating -> unless it contains other widgts how are stateful??
class Home extends StatelessWidget {

  final AuthService _authService = AuthService();
  final LocationService _locationService = LocationService();

  @override
  Widget build(BuildContext context) {

    //provider of the user model
    final user = Provider.of<User>(context);
    if (user == null) {
      return Authenticate();
    }

    final DatabaseService _databaseService = DatabaseService(uid: user.uid);

    _locationService.checkPermission();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Loci'),
        backgroundColor: Colors.blue,
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.account_circle, color: Colors.black,),
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Profile())
              );
            })
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
                await _databaseService.updateLocationFromPosition(pos);
                await _databaseService.updateLocationWithGeo(pos);
                _databaseService.queryWithinRange(pos, 50);
              },
            )
          ],
        ),
      )

    );
  }
}
