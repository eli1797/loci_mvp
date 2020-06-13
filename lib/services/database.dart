import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mvp/models/user.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

class DatabaseService {

  // collection references
  final CollectionReference _userCollection = Firestore.instance.collection('users');
  final CollectionReference _friendCollection = Firestore.instance.collection('friends');
  final CollectionReference _locationCollection = Firestore.instance.collection('locations');

  //GeoFlutterFire
  Geoflutterfire geo = Geoflutterfire();

  // id unique to user
  final String uid;

  // constructor
  DatabaseService({ this.uid });

  ///   User Collection   ///

  // Write

  // Write to update user collection
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

  // Update a user's firstName
  Future updateFirstName(String firstName) async {
    //@Todo: validation here? Probably some in the ui elements that call this
    try {
      return await _userCollection.document(this.uid).setData({
        'firstName': firstName
      }, merge: true);
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  // Update a user's status
  Future updateStatus(String status) async {
    //@Todo: validation here? Probably in the UI elements that make this call
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

  // Update a user's status
  Future updateOpenness(double openness) async {
    //@Todo: validation here? Probably in the UI elements that make this call
    try {
      return await _userCollection.document(this.uid).setData({
        'openness': openness,
      }, merge: true);
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  // Stream the users name and status
  Stream<UserData> streamThisUserData() {
    try {
      return _userCollection.document(this.uid).snapshots()
          .map(_createUserDataFromSnapshot);
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  // Helper
  // userData object from DocumentSnapshot
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

  ///   Friends Collection   ///

  // Write

  // Add a friend
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

  // Remove a friend
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

  Stream<UserFriends> streamThisUserFriends() {
    return _friendCollection.document(this.uid).snapshots()
        .map(_createFriendsUIdListFromSnapshot);
  }

  // Helper that creates a UserFriends object from DocumentSnapshot
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
  
  Stream<List<UserData>> streamFriends() {
    print("A");
    streamThisUserFriends().listen((event) {
      print("B");
      return streamUserDataByUIdList(event.friendUIds);
    });

  }

  // Stream a user by UId
  Stream<List<UserData>> streamUserDataByUIdList(List userUids) {
    print("C");
    print(userUids);
    _userCollection.where(FieldPath.documentId, whereIn: userUids).snapshots().listen((event) {
      List<UserData> userDataList = event.documents.map(_createUserDataFromSnapshot).toList();
      print(userDataList.runtimeType);
      userDataList.forEach((element) {
        print(element.firstName);
        print(element.openness);
      });
    });

    _userCollection.where(FieldPath.documentId, whereIn: userUids).snapshots().listen((event) {
      return event.documents.map(_createUserDataFromSnapshot).toList();
    });


  }

  // Helper that creates a UserFriends object from DocumentSnapshot
  List<UserData> _createUserDataListFromQuerySnapshot(QuerySnapshot querySnapshot) {
    print("hi");
    List toReturn = [];
    List docs = querySnapshot.documents;

    for (var docSnap in docs) {
      try {
         UserData newUserData = UserData(
            uid: docSnap.documentID,
            firstName: docSnap['firstName'] ?? "unnamed_member",
            status: docSnap['status'] ?? null,
            openness: (docSnap['openness'] ?? 0.0).toDouble()
        );
         toReturn.add(newUserData);
      } catch (e) {
        print(e.toString());
      }
    }
    print(toReturn);
    return toReturn;
  }


  ///   Location Collection   ///

  // Write

  // one off update user's geohash, geopoint(lat, long), and altitude
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

  // Stream the users name and status
  Stream<UserLocation> streamThisUserLocation() {
    try {
      return _locationCollection.document(this.uid).snapshots()
          .map(_createUserLocationFromSnapshot);
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

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

  // Helper
  GeoFirePoint _createGeoFirePointFromPosition (Position position) {
    return geo.point(latitude: position.latitude, longitude: position.longitude);
  }

  // Watch position (Geolocator?) and on changed stream to firestore
  //@TODO: Watch position ^


}