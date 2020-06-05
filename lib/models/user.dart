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
  GeoPoint gp;
  final List<String> closeFriendsUIdList;

//  UserData({ this.uid, this.firstName, this.latitude, this.longitude, this.closeFriends });
//  UserData({ this.uid, this.firstName, this.latitude, this.longitude });
  UserData({ this.uid, this.firstName, this.gp, this.closeFriendsUIdList });


}

