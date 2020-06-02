import 'package:geolocator/geolocator.dart';

class LocationService {

  final Geolocator _geolocator = Geolocator();
  Position _currentPosition;

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
}