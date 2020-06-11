import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mvp/models/user.dart';
import 'package:mvp/services/database.dart';
import 'package:mvp/services/location.dart';
import 'package:mvp/shared/loading.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'package:vector_math/vector_math.dart';

class MapTab extends StatefulWidget {
  @override
  _MapTabState createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {

  final double EARTHRADIUS = 6366198;

  GoogleMapController _mapsController;

  final LocationService _locationService = LocationService();

  CameraPosition _startPos;
  CameraTargetBounds _cameraTargetBounds;

  @override
  void initState() {
    super.initState();
//    _locationService.checkPermission();
  }

  void _setupCamera(UserLocation userLocation) {
    // set the camera start position to be on the user
    _startPos = _createCameraPositionFromGP(userLocation.geoPoint);

    // set the camera bounds
    //_cameraTargetBounds = _createMapBoundsFromGeoPoint(userData.gp, 50);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    return StreamBuilder<UserLocation>(
        stream: DatabaseService(uid: user.uid).streamthisUserLocation(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            UserLocation userLocation = snapshot.data;

            _setupCamera(userLocation);

            print(userLocation.uid);

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
                //cameraTargetBounds: _cameraTargetBounds,
                myLocationEnabled: true,
                onMapCreated: (GoogleMapController controller) {
                  setState(() {
                    _mapsController = controller;
                  });
                },
                scrollGesturesEnabled: true,
              ),
            );
          } else {
            return Loading();
          }
        });
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
