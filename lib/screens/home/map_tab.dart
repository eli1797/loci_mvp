import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mvp/models/user.dart';
import 'package:mvp/services/database.dart';
import 'package:mvp/services/location.dart';
import 'package:mvp/shared/loading.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math.dart';

class MapTab extends StatefulWidget {
  @override
  _MapTabState createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {

  final double EARTHRADIUS = 6366198;

  GoogleMapController _mapsController;

  final LocationService _locationService = LocationService();
  DatabaseService _databaseService;

  CameraPosition _startPos;
  CameraTargetBounds _cameraTargetBounds;

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  Map<MarkerId, OpenUser> markerData = <MarkerId, OpenUser>{};

  StreamSubscription _openSub;

  @override
  void initState() {
    super.initState();
    _databaseService = DatabaseService();
    _openSub = _databaseService.streamOpenUsers().listen((event) {
      print(event.runtimeType);
      _drawOpenUsers(event);
    });
  }

  @override
  void dispose(){
    try {
      _openSub.cancel();
    } catch(e) {
      print(e.toString());
    }
    super.dispose();
  }

  void _setupCamera(UserLocation userLocation) {
    // set the camera start position to be on the user
    _startPos = _createCameraPositionFromGP(userLocation.geoPoint);

    // set the camera bounds
    //_cameraTargetBounds = _createMapBoundsFromGeoPoint(userData.gp, 50);
  }

  void _drawOpenUsers(List<OpenUser> openUserList) {
    try {
      print("Drawing");

      Map<MarkerId, Marker> updateMarkers = <MarkerId, Marker>{};
      Map<MarkerId, OpenUser> updateMarkerData = <MarkerId, OpenUser>{};

      openUserList.forEach((user) {
        print(user.firstName);

        //Read: https://infinum.com/the-capsized-eight/creating-custom-markers-on-google-maps-in-flutter-apps
        //@Todo: Make custom markers with ^ and on tapped bring up a sheet from the bottom with pic, name, status, etc

        final MarkerId markerId = MarkerId(user.uid);

        final Marker newMarker = Marker(
          markerId: markerId,
          position: LatLng(user.geoPoint.latitude, user.geoPoint.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(210.0),
          onTap: () {
            _onMarkerTapped(markerId);
          },
        );

        updateMarkerData[markerId] = user;
        updateMarkers[markerId] = newMarker;
      });

      setState(() {
        markers = updateMarkers;
        markerData = updateMarkerData;
      });

    } catch(e) {
      print(e.toString());
    }
  }

  void _onMarkerTapped(MarkerId markerId) {
    print("Marker Tapped");
    try {
      OpenUser openUser = markerData[markerId];
      showModalBottomSheet(context: context, builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 60.0),
          child: Column(
              children: <Widget>[
              SizedBox(height: 20.0),
              CircleAvatar(
//                backgroundColor: Colors.blue,
                radius: 50.0,
                child: Text(openUser.firstName),
              ),
              SizedBox(height: 20.0),
              Text(openUser.firstName),
              SizedBox(height: 20.0),
              Text(openUser.status),
            ]
          )
        );
      });
    } catch(e) {
      print(e.toString());
      showModalBottomSheet(context: context, builder: (context) {
        return Container(
            padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 60.0),
            child: Column(
              children: <Widget>[
                SizedBox(height: 20.0),
                Text("Whoops! Failed to get this person")
              ]
            )
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);



    final userLocation = Provider.of<UserLocation>(context);
    final userData = Provider.of<UserData>(context);

    if (userLocation != null || userData != null) {
      _setupCamera(userLocation);

      if (userData.openness == 2.0) {
        if (_openSub != null && _openSub.isPaused) {
          _openSub.resume();
        }
      } else {
        if (_openSub != null) {
          _openSub.pause();
        }
      }

      return Container(
        height: MediaQuery
            .of(context)
            .size
            .height,
        width: MediaQuery
            .of(context)
            .size
            .width,
        child: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: _startPos,
          myLocationEnabled: true,
          onMapCreated: (GoogleMapController controller) {
            setState(() {
              _mapsController = controller;
            });
          },
          scrollGesturesEnabled: true,
          mapToolbarEnabled: false,
          markers: Set<Marker>.of(markers.values),
        ),
      );
    } else {
      return Loading();
    }
  }

  CameraPosition _createCameraPositionFromGP(GeoPoint gp) {
    return CameraPosition(
      target: LatLng(gp.latitude, gp.longitude),
      zoom: 18.75
    );
  }

  CameraTargetBounds _createMapBoundsFromGeoPoint(GeoPoint gp, double boundsM) {
    LatLng center = LatLng(gp.latitude, gp.longitude);
    //calc Northeast point
    LatLng northEast = _move(center, boundsM, boundsM);
    //calc Southwest point
    LatLng southWest = _move(center, -boundsM, -boundsM);
    //make LatLngBounds and return CameraTargetBounds
    return CameraTargetBounds(LatLngBounds(northeast: northEast, southwest: southWest));
  }

  LatLng _move(LatLng startLL, double toNorth, double toEast) {
    double lonDiff = _meterToLongitude(toEast, startLL.latitude);
    double latDiff = _meterToLatitude(toNorth);
    return new LatLng(startLL.latitude + latDiff, startLL.longitude
        + lonDiff);
  }

  double _meterToLongitude(double meterToEast, double latitude) {
    double latArc = radians(latitude);
    double radius = cos(latArc) * EARTHRADIUS;
    double rad = meterToEast / radius;
    return degrees(rad);
  }


  double _meterToLatitude(double meterToNorth) {
    double rad = meterToNorth / EARTHRADIUS;
    return degrees(rad);
  }
}

