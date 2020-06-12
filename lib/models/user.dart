import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

class User {

  final String uid;

  User({ this.uid });
}

class UserData {

  final String uid;
  final String firstName;
  final String status;
  final double openness;
//  GeoPoint gp;
//  final List<String> closeFriendsUIdList;

//  UserData({ this.uid, this.firstName, this.latitude, this.longitude, this.closeFriends });
//  UserData({ this.uid, this.firstName, this.latitude, this.longitude });
//  UserData({ this.uid, this.firstName, this.gp, this.closeFriendsUIdList });
  UserData({ this.uid, this.firstName, this.status, this.openness});

}

class UserLocation {

  final String uid;
  final double altitude;
  final String geoHash;
  final GeoPoint geoPoint;
  final Timestamp lastUpdated;

  UserLocation({ this.uid, this.altitude, this.geoHash, this.geoPoint, this.lastUpdated });
}

