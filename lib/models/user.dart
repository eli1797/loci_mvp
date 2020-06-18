import 'package:cloud_firestore/cloud_firestore.dart';

/// User
/// Root data model for authentication & providing uids
class User {

  final String uid;

  User({ this.uid });
}

/// UserData
/// Data Model for users collection
class UserData {

  final String uid;
  final String firstName;
  final String status;
  final double openness;

  UserData({ this.uid, this.firstName, this.status, this.openness});

}

/// UserLocation
/// Data model for locations collection
///
/// Not currently in use in app
class UserLocation {

  final String uid;
  final double altitude;
  final String geoHash;
  final GeoPoint geoPoint;
  final Timestamp lastUpdated;

  UserLocation({ this.uid, this.altitude, this.geoHash, this.geoPoint, this.lastUpdated });
}

/// UserFriends
/// Data model for friends collection
///
/// Semi implemented in Database Service, not used in app yet
class UserFriends {

  final String uid;
  List friendUIds;

  UserFriends({ this.uid, this.friendUIds});
}

/// OpenUser
/// Data model for open collection, contains all info needed for Map Tab
class OpenUser {

  final String uid;
  final String firstName;
  final String status;
  final double altitude;
  final String geoHash;
  final GeoPoint geoPoint;
  final Timestamp lastUpdated;

  OpenUser({ this.uid, this.firstName, this.status, this.altitude, this.geoHash, this.geoPoint, this.lastUpdated });
}

