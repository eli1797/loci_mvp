import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mvp/models/user.dart';
import 'package:mvp/screens/authenticate/authenticate.dart';
import 'package:mvp/screens/bloop/bloop.dart';
import 'package:mvp/screens/home/home_tab.dart';
import 'package:mvp/screens/home/map_tab.dart';
import 'package:mvp/screens/profile/profile.dart';
import 'package:mvp/services/auth.dart';
import 'package:mvp/services/database.dart';
import 'package:mvp/services/location.dart';
import 'package:mvp/shared/constants.dart';
import 'package:mvp/shared/loading.dart';
import 'package:provider/provider.dart';

//@Todo: might need to make Home stateful for updating -> unless it contains other widgts how are stateful??
class Home extends StatefulWidget {

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  DatabaseService _databaseService;
  final LocationService _locationService = LocationService();

  StreamSubscription _locationSub;

  @override
  void initState() {
    super.initState();

    // check permissions
    _locationService.checkPermission();
  }

  @override
  void dispose(){
    try {
      _locationSub.cancel();
    } catch(e) {
      print(e.toString());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    /// Provider of the User model from main.dart
    final user = Provider.of<User>(context);

    // if no user, show the authentication screen
    if (user == null) {
      return Authenticate();
    }

    // set the database service instance
    _databaseService = DatabaseService(uid: user.uid);

    // one off write position to location collection
    // used for required initial camera position in map
    _updatePos();

    /// Provider of UserData model from home_wrapper.dart
    final userData = Provider.of<UserData>(context);

    // if we have user data
    if (_locationSub != null && _locationSub.isPaused) {
      _locationSub.resume();
    } else {
      _locationSub = _locationService.positionStream(distanceFilter: 5)
          .listen((Position position) {
        print("Location changed");

        // @TODO: Fewer writes here?
        _databaseService.updateLocationWithGeo(position);

        if (userData != null && userData.openness == 2.0) {
          _databaseService.goOpen(
              firstName: userData.firstName,
              status: userData.status,
              position: position
          );
        }
      });
    }

    // if UserData show tabs, else show Loading widget
    if (userData != null) {
      return DefaultTabController(
          length: 2,
          child: Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: Colors.white,
              appBar: AppBar(
                title: Text('Loci'),
                backgroundColor: Colors.blue,
                elevation: 0.0,
                actions: <Widget>[
                  Container(
                    height: 15.0,
                    width: 15.0,
                    decoration: BoxDecoration(
                      color: Constants.sliderColor[userData.openness ?? 0.0],
                      shape: BoxShape.circle,
                    ),
                  ),
                  IconButton(
                      icon: Icon(Icons.account_circle, color: Colors.black,),
                      onPressed: () async {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Profile())
                        );
                      })
                ],
                bottom: TabBar(
                  tabs: <Widget>[
                    Tab(icon: Icon(Icons.chat)),
                    Tab(icon: Icon(Icons.near_me)),
                  ],
                ),
              ),
              body: StreamProvider<UserLocation>(
                create: (_) =>
                    DatabaseService(uid: user.uid).streamThisUserLocation(),
                child: StreamProvider<UserData>(
                    create: (_) =>
                        DatabaseService(uid: user.uid).streamThisUserData(),
                    child: TabBarView(
                        children: [
                          HomeTab(),
                          MapTab()
                        ]
                    )
                ),
              )
          )
      );
    } else {
      return Loading();
    }
  }

  // one-off on init write to locations collection
  void _updatePos() async {
    try {
      Position pos = await _locationService.getPosition();
      _databaseService.updateLocationWithGeo(pos);
    } catch(e) {
      print(e.toString());
    }
  }

}
