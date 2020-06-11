import 'dart:async';

import 'package:geolocator/geolocator.dart';

class LocationService {

  // GeoLocator
  final Geolocator _geolocator = Geolocator();

  void checkPermission() async {
    await _geolocator.checkGeolocationPermissionStatus().then((status) {
      print('status: $status');
    });
    await _geolocator
        .checkGeolocationPermissionStatus(
            locationPermission: GeolocationPermission.locationAlways)
        .then((status) {
      print('always status: $status');
    });
    await _geolocator
        .checkGeolocationPermissionStatus(
            locationPermission: GeolocationPermission.locationWhenInUse)
        .then((status) {
      print('whenInUse status: $status');
    });
  }

  Future<Position> getPosition() async {
    return await _geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
  }

  Future<double> distanceFromMe(Position myPos, double lat, double long) async {
    return _geolocator.distanceBetween(myPos.latitude, myPos.longitude, lat, long);
  }

  Stream<Position> positionStream({accuracy = LocationAccuracy.bestForNavigation, distanceFilter = 1}) {
    LocationOptions locationOptions = LocationOptions(accuracy: accuracy, distanceFilter: distanceFilter);
    return _geolocator.getPositionStream(locationOptions);
  }
}