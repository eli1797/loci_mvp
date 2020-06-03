import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mvp/models/user.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {

  // collection reference
  final CollectionReference _userCollection = Firestore.instance.collection('users');

  //GeoFlutterFire
  Geoflutterfire geo = Geoflutterfire();

  // id unique to user
  final String uid;

  // constructor
  DatabaseService({ this.uid });

  //   Writes   //

  //update all user data
  Future updateUserData (String firstName, Position position, List<User> closeFriends) async {
    GeoFirePoint gfp = createGeoFirePointFromPosition(position);
    return await _userCollection.document(uid).setData({
      'firstName': firstName,
      'position': gfp.data,
      'closeFriends': closeFriends
    }, merge: true);
  }

  //update a user's firstName
  Future updateName (String firstName) async {
    //@Todo: validation here?
    return await _userCollection.document(uid).setData({
      'firstName': firstName
    }, merge: true);
  }

  // create a geo fire point (lat, long) from a geolocator position
  GeoFirePoint createGeoFirePointFromPosition (Position position) {
    return geo.point(latitude: position.latitude, longitude: position.longitude);
  }

  // update the users position (geohash and geopoint (lat, long)) and altitude
  Future updateLocationWithGeo (Position position) async {
    GeoFirePoint gfp = createGeoFirePointFromPosition(position);
    return await _userCollection.document(uid).setData({
      'position': gfp.data,
    }, merge: true);
  }

  //update add a random friend
  Future randomFriend () async {
    // need to get a random uid from the server
    UserData userData = await queryOnFirstName("Bob");
    // add that uid to my close friends subcollection
    return await _userCollection.document(uid).collection('closeFriends').document(userData.uid).setData({
      'friend': userData.uid
    });
  }

  //   QUERIES   //

  // get UserData from first name
  Future<UserData> queryOnFirstName(String firstName) async {
    QuerySnapshot qSnap = await _userCollection.where("firstName", isEqualTo: firstName).limit(1)
        .getDocuments();

    return qSnap.documents.map(_userDataFromSnapshot).toList().first;
  }

  // Query all users within range
  Stream<List<DocumentSnapshot>> queryWithinRange(Position position, double rangeInKM) {
    return queryCollectionWithinRange(_userCollection, position, rangeInKM);
  }

  // Query a collection for Document Snapshots within range of a position
  Stream<List<DocumentSnapshot>> queryCollectionWithinRange(CollectionReference collectionReference, Position position, double rangeInKM) {
    try {
      GeoFirePoint gfpQueryPoint = createGeoFirePointFromPosition(position);
      var geoRef = geo.collection(collectionRef: collectionReference);
      Stream<List<DocumentSnapshot>> result = geoRef.within(center: gfpQueryPoint,
          radius: rangeInKM,
          field: 'position',
          strictMode: true);
      result.listen((List<DocumentSnapshot> documentList) {
        documentList.forEach((DocumentSnapshot document) {
          print(document.documentID);
          String name = document.data['firstName'];
          print(name);
          GeoPoint point = document.data['position']['geopoint'];
          print(point);
        });
      });
      return result;
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  //   STREAMS   //

  // Stream UserData
  Stream<UserData> get userData {
    return _userCollection.document(uid).snapshots()
        .map(_userDataFromSnapshot);
  }

  // userData object from DocumentSnapshot
  UserData _userDataFromSnapshot(DocumentSnapshot documentSnapshot) {
    return UserData(
      uid: uid,
      firstName: documentSnapshot['firstName'],
      latitude: documentSnapshot['latitude'],
      longitude: documentSnapshot['longitude'],
    );
  }

  // Stream Document Snapshots of UserData
  Stream<DocumentSnapshot> get userDataDoc {
    return _userCollection.document(uid).snapshots();
  }

}