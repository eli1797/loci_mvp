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

class MapTab extends StatefulWidget {
  @override
  _MapTabState createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {

  GoogleMapController _mapsController;

  final LocationService _locationService = LocationService();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    return StreamBuilder<UserData>(
        stream: DatabaseService(uid: user.uid).userData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            UserData userData = snapshot.data;
            print(userData.firstName);
            print(userData.gp);
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
                initialCameraPosition: _createCameraPositionFromGP(userData.gp),
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
}
