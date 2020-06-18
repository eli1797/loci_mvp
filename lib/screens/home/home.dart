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
    _locationService.checkPermission();
//    _locationSub = _locationService.positionStream().listen((Position position) {
//      print("Location changed");
//      _databaseService.updateLocationWithGeo(position);
//    });
  }

  @override
  void dispose(){
    _locationSub.cancel();
    if (_locationSub != null) {
      _locationSub.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    //provider of the user model
    final user = Provider.of<User>(context);
    if (user == null) {
      return Authenticate();
    }

    _databaseService = DatabaseService(uid: user.uid);

    final userData = Provider.of<UserData>(context);

    if (userData != null) {

      if (userData.openness == 2.0) {
        if (_locationSub != null && _locationSub.isPaused) {
          _locationSub.resume();
        }

        _locationSub = _locationService.positionStream(distanceFilter: 2).listen((Position position) {
            print("Location changed");
//              _databaseService.updateLocationWithGeo(position);
            _databaseService.goOpen(
                firstName: userData.firstName,
                status: userData.status,
                position: position
            );
          });
      } else {
        if (_locationSub != null) {
          _locationSub.pause();
        }
      }

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
            body: StreamProvider<UserLocation> (
              create: (_) => DatabaseService(uid: user.uid).streamThisUserLocation(),
              child: StreamProvider<UserData> (
                create: (_) => DatabaseService(uid: user.uid).streamThisUserData(),
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
}
