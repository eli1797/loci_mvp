import 'dart:async';
import 'package:geolocator/geolocator.dart';

class LocationService {

  /// GeoLocator instance
  final Geolocator _geolocator = Geolocator();

  void checkPermission() async {
    try {
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
    } catch(e) {
      print(e.toString());
    }
  }

  /// Get Future<Position> using best accuracy
  Future<Position> getPosition() async {
    try {
      return await _geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  /// Stream changes in Position
  ///
  /// Default best accuracy and updates every one meter
  Stream<Position> positionStream({accuracy = LocationAccuracy.bestForNavigation, distanceFilter = 1}) {
    LocationOptions locationOptions = LocationOptions(accuracy: accuracy, distanceFilter: distanceFilter);
    return _geolocator.getPositionStream(locationOptions);
  }
}