import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mvp/models/user.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

class DatabaseService {

  /// Firestore collection references
  final CollectionReference _userCollection = Firestore.instance.collection('users');
  final CollectionReference _friendCollection = Firestore.instance.collection('friends');
  final CollectionReference _locationCollection = Firestore.instance.collection('locations');
  final CollectionReference _openCollection = Firestore.instance.collection('open');

  /// GeoFlutterFire instance
  Geoflutterfire geo = Geoflutterfire();

  /// id unique to user, created by Firebase Auth and associated with User Model
  final String uid;

  /// Constructor
  DatabaseService({ this.uid });

  ///   User Collection   ///

  /// Write to add/update this User's doc in the user collection
  Future updateThisUserDocument ({String firstName, String status = '', double openness = 0.0}) async {
    try {
      return await _userCollection.document(this.uid).setData({
        'firstName': firstName,
        'status': status,
        'openness': openness,
        'lastUpdated': Timestamp.now()
      }, merge: true);
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  /// Update this user's firstName
  Future updateFirstName(String firstName) async {
    try {
      return await _userCollection.document(this.uid).setData({
        'firstName': firstName
      }, merge: true);
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  /// Update this user's status
  Future updateStatus(String status) async {
    try {
      return await _userCollection.document(this.uid).setData({
        'status': status,
        'lastUpdated': Timestamp.now()
      }, merge: true);
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  /// Update this user's openness
  Future updateOpenness(double openness) async {
    try {
      return await _userCollection.document(this.uid).setData({
        'openness': openness,
      }, merge: true);
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  /// Activate a tag in this user's tags
  Future activateTag(String tag) async {
    try {
      Map<String, bool> tagMap = {tag: true};
      return await _userCollection.document(this.uid).setData({
        'tags': tagMap,
      }, merge: true);
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  /// Deactivate a tag in this user's tags
  Future deactivateTag(String tag) async {
    try {
      Map<String, bool> tagMap = {tag: false};
      return await _userCollection.document(this.uid).setData({
        'tags': tagMap,
      }, merge: true);
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  /// Stream this users UserData
  Stream<UserData> streamThisUserData() {
    try {
      return _userCollection.document(this.uid).snapshots()
          .map(_createUserDataFromSnapshot);
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  /// Stream UserData by uid
  Stream<UserData> streamUserDataByUId(String userUId) {
    try {
      return _userCollection.document(userUId).snapshots()
          .map(_createUserDataFromSnapshot);
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  /// Helper creates UserData object from DocumentSnapshot
  UserData _createUserDataFromSnapshot(DocumentSnapshot documentSnapshot) {
    try {
      return UserData(
          uid: documentSnapshot.documentID,
          firstName: documentSnapshot['firstName'] ?? "unnamed_member",
          status: documentSnapshot['status'] ?? null,
          openness: (documentSnapshot['openness'] ?? 0.0).toDouble()
      );
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  /// Open Collection ///

  /// Go open
  ///
  /// Writes firstName, status, and location info to an open collection doc
  Future goOpen ({String firstName, String status = '', Position position}) async {
    try {
      GeoFirePoint gfp = _createGeoFirePointFromPosition(position);
      return await _openCollection.document(this.uid).setData({
        'firstName': firstName,
        'status': status,
        'geoPoint': gfp.geoPoint,
        'geoHash': gfp.hash,
        'altitude': position.altitude,
        'lastUpdated': Timestamp.now()
      }, merge: true);
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  /// Go hidden
  ///
  /// Removes this users document from the open collection
  Future goHidden() async {
    try {
      return await _openCollection.document(this.uid).delete();
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  /// Stream all OpenUsers in the open collection
  ///
  /// Returns a Stream of a List of OpenUsers (including oneself if open)
  Stream<List<OpenUser>> streamOpenUsers() {
    try {

      return _openCollection.snapshots().map((qSnap) {
        List<OpenUser> openUsers = new List();
        qSnap.documents.forEach((element) {
          // create OpenUsers from the streamed data
          OpenUser newOpenUser = OpenUser(
              uid: element.documentID,
              firstName: element.data['firstName'],
              status: element.data['status'],
              altitude: element.data['altitude'],
              geoHash: element.data['geoHash'],
              geoPoint: element.data['geoPoint'],
              lastUpdated: element.data['lastUpdated']
          );
          openUsers.add(newOpenUser);
        });
        print("Open users" + openUsers.toString());
        return openUsers;
      });
    } catch(e) {
      print(e.toString());
      return null;
    }
  }


  ///   Friends Collection   ///

  /// Add a friend
  Future addFriendByUID (String friendUId) async {
    try {
      return await _friendCollection.document(this.uid).setData({
        'closeFriendsUIdList': FieldValue.arrayUnion([friendUId])
      }, merge: true);
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  /// Remove a friend from this user by their uid
  Future _removeFriendByUID (String friendUId) async {
    try {
      return await _friendCollection.document(this.uid).setData({
        'closeFriendsUIdList': FieldValue.arrayRemove([friendUId])
      }, merge: true);
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  /// Stream this Users Friends
  Stream<UserFriends> streamThisUserFriends() {
    return _friendCollection.document(this.uid).snapshots()
        .map(_createFriendsUIdListFromSnapshot);
  }

  /// Helper that creates a UserFriends object from DocumentSnapshot
  UserFriends _createFriendsUIdListFromSnapshot(DocumentSnapshot documentSnapshot) {
    try {
      return UserFriends(
          uid: documentSnapshot.documentID,
          friendUIds: documentSnapshot['closeFriendsUIdList'] ?? []
      );
    } catch(e) {
      print(e.toString());
      return null;
    }
  }


  ///   Location Collection   ///

  // Write

  /// Write to update user's geohash, geopoint(lat, long), and altitude
  Future updateLocationWithGeo (Position position) async {
    try {
      GeoFirePoint gfp = _createGeoFirePointFromPosition(position);
      return await _locationCollection.document(this.uid).setData({
        'geoPoint': gfp.geoPoint,
        'geoHash': gfp.hash,
        'altitude': position.altitude,
        'lastUpdated': Timestamp.now()
      }, merge: true);
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  /// Stream this Users UserLocation
  Stream<UserLocation> streamThisUserLocation() {
    try {
      return _locationCollection.document(this.uid).snapshots()
          .map(_createUserLocationFromSnapshot);
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  /// Helper creates UserLocation from DocumentSnapshot
  UserLocation _createUserLocationFromSnapshot(DocumentSnapshot documentSnapshot) {
    try {
      return UserLocation(
        uid: documentSnapshot.documentID,
        altitude: documentSnapshot['altitude'],
        geoHash: documentSnapshot['geoHash'],
        geoPoint: documentSnapshot['geoPoint'],
        lastUpdated: documentSnapshot['lastUpdated']
      );
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  /// Helper creates GeoFirePoint from Position
  GeoFirePoint _createGeoFirePointFromPosition (Position position) {
    return geo.point(latitude: position.latitude, longitude: position.longitude);
  }

}