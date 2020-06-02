import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mvp/models/user.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {

  // collection reference
  final CollectionReference userCollection = Firestore.instance.collection('users');

  //GeoFlutterFire
  Geoflutterfire geo = Geoflutterfire();

  // id unique to user
  final String uid;

  // constructor
  DatabaseService({ this.uid });

  //update all user data
  Future updateUserData (String firstName, double latitude, double longitude, List<User> closeFriends) async {
    return await userCollection.document(uid).setData({
      'firstName': firstName,
      'latitude': latitude,
      'longitude': longitude,
      'closeFriends': closeFriends
    }, merge: true);
  }

  //update a user's firstName
  Future updateName (String firstName) async {
    return await userCollection.document(uid).setData({
      'firstName': firstName
    }, merge: true);
  }

  //update a user's location from Position
  Future updateLocationFromPosition (Position position) async {
    return await userCollection.document(uid).setData({
      'latitude': position.latitude ?? 0.0,
      'longitude': position.longitude ?? 0.0,
      'altitude': position.altitude ?? 0.0,
    }, merge: true);
  }

//  // brew list from snapshot
////  List<Brew> _brewListFromSnapshot(QuerySnapshot snapshot) {
////    return snapshot.documents.map((doc) {
////      return Brew(
////        name: doc.data['name'] ?? '',
////        strength: doc.data['strength'] ?? 0,
////        sugars: doc.data['sugars'] ?? '0',
////      );
////    }).toList();
////  }


  // userData object from DocumentSnapshot
  UserData _userDataFromSnapshot(DocumentSnapshot documentSnapshot) {
    return UserData(
      uid: uid,
      firstName: documentSnapshot['firstName'],
      latitude: documentSnapshot['latitude'],
      longitude: documentSnapshot['longitude'],
      closeFriends: documentSnapshot['closeFriends']
    );
  }

  // get user info (doc) stream
  Stream<UserData> get userData {
    return userCollection.document(uid).snapshots()
        .map(_userDataFromSnapshot);
  }

  // using this one currently because the conversation to UserData using map
  // seems to be producing null
  Stream<DocumentSnapshot> get userDataDoc {
    return userCollection.document(uid).snapshots();
  }

}