import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mvp/models/user.dart';
import 'package:mvp/services/database.dart';
import 'package:mvp/shared/constants.dart';
import 'package:mvp/shared/loading.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math.dart';

class MapTab extends StatefulWidget {
  @override
  _MapTabState createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {

  /// GoogleMapsController
  GoogleMapController _mapsController;

  /// Service that enables interaction with Cloud Firestore
  DatabaseService _databaseService;

  /// Initial position of the camera; required by GoogleMaps Widget
  CameraPosition _startPos;

  /// Map MarkerId to marker or Open user data tied to that marker
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  Map<MarkerId, OpenUser> markerData = <MarkerId, OpenUser>{};

  /// Subscription to List<OpenUser> from Open Collection
  StreamSubscription _openSub;

  /// State holder, true if userLocation is null
  bool _hasNoLocation;

  @override
  void initState() {
    super.initState();

    // Create a DatabaseService instance and subscribe to the OpenUsers stream
    _databaseService = DatabaseService();
    _openSub = _databaseService.streamOpenUsers().listen((event) {
      _drawOpenUsers(event);
    });
  }

  @override
  void dispose(){
    try {
      // cancel the subscription to the OpenUsers stream
      _openSub.cancel();
    } catch(e) {
      print(e.toString());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // Get user information from Providers in home.dart
    final userLocation = Provider.of<UserLocation>(context);
    final userData = Provider.of<UserData>(context);

    // Check for userLocation, if not the map cannot be built
    if (userLocation != null) {
      _setupCamera(userLocation.geoPoint);
      _hasNoLocation = false;
    } else {
      _hasNoLocation = true;
    }

    // Only stream other open users if this users is open
    if (userData != null) {
      if (userData.openness == 2.0) {
        if (_openSub != null && _openSub.isPaused) {
          _openSub.resume();
        }
      } else {
        if (_openSub != null) {
          _openSub.pause();
        }
      }

      // If a user has a location build the map, otherwise show the loading screen
      return _hasNoLocation ? Loading() : Container(
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
          scrollGesturesEnabled: false,
          mapToolbarEnabled: false,
          markers: userData.openness == 2.0 ?  Set<Marker>.of(markers.values) : null,
        ),
      );
    } else {
      return Loading();
    }
  }


  /// Create the initial camera position
  bool _setupCamera(GeoPoint geoPoint) {
    try {
      // set the camera start position to be on the user
      _startPos = _createCameraPositionFromGP(geoPoint);
      return true;
    } catch(e) {
      print(e.toString());
      return false;
    }
  }

  /// Draws markers, updates both Marker Maps based on events in _openSub
  void _drawOpenUsers(List<OpenUser> openUserList) {
    try {
      print("Drawing");

      /// Create new temp maps to hold the new info
      Map<MarkerId, Marker> updateMarkers = <MarkerId, Marker>{};
      Map<MarkerId, OpenUser> updateMarkerData = <MarkerId, OpenUser>{};

      openUserList.forEach((user) {
        print(user.firstName);

        //Read: https://infinum.com/the-capsized-eight/creating-custom-markers-on-google-maps-in-flutter-apps
        //@Todo: Make custom markers with ^

        /// Create a marker ID
        final MarkerId markerId = MarkerId(user.uid);

        /// Create a new Marker
        final Marker newMarker = Marker(
          markerId: markerId,
          position: LatLng(user.geoPoint.latitude, user.geoPoint.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(210.0),
          onTap: () {
            _onMarkerTapped(markerId);
          },
        );

        // Fill in the Maps with this marker and associated OpenUser data.
        updateMarkerData[markerId] = user;
        updateMarkers[markerId] = newMarker;
      });

      // Update the state with the new maps, will redraw markers
      setState(() {
        markers = updateMarkers;
        markerData = updateMarkerData;
      });

    } catch(e) {
      print(e.toString());
    }
  }

  /// Shows bottom modal sheet with OpenUser data on tap
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
                    radius: 50.0,
                    child: Text(openUser.firstName),
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    openUser.firstName,
                    style: TextStyle(fontSize: 22.0),
                  ),
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
    double radius = cos(latArc) * Constants.EARTHRADIUS;
    double rad = meterToEast / radius;
    return degrees(rad);
  }


  double _meterToLatitude(double meterToNorth) {
    double rad = meterToNorth / Constants.EARTHRADIUS;
    return degrees(rad);
  }
}

