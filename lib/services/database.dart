import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mvp/models/user.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

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
  Future addFriendByFirstName (String firstName) async {
    // need to get a random uid from the server
    try {
      UserData nameUserData = await queryOnFirstName(firstName);
      print(nameUserData.firstName);
      print(nameUserData);
      // add that uid to my close friends subcollection
      return await _userCollection.document(uid)
          .collection('closeFriends')
          .document(nameUserData.uid)
          .setData({
        'friend': nameUserData.uid
      }, merge: true);
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  //update add a random friend
  Future addFriendByFirstNameToList (String firstName) async {
    // need to get a random uid from the server
    try {
      UserData nameUserData = await queryOnFirstName(firstName);
      print(nameUserData.firstName);
      print(nameUserData);
      // add that uid to my close friends subcollection
      return await _userCollection.document(uid)
          .setData({
        'closeFriendsUIdList': FieldValue.arrayUnion([nameUserData.uid])
      }, merge: true);
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  //   QUERIES   //

  // get UserData from first name
  Future<UserData> queryOnFirstName(String firstName) async {
    try {
      QuerySnapshot qSnap = await _userCollection.where(
          "firstName", isEqualTo: firstName).limit(1)
          .getDocuments();

      print(qSnap.documents[0].data);

      return qSnap.documents
          .map(_userDataFromSnapshot)
          .toList()
          .first;
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  // get UserData from uid
  Future<UserData> queryOnUId(String userUId) async {
    try {
     return await _userCollection.document(userUId).get().then((value) => _userDataFromSnapshot(value));
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  // userData object from DocumentSnapshot
  UserData _userDataFromSnapshot(DocumentSnapshot documentSnapshot) {

    print(documentSnapshot['position'].runtimeType);
    return UserData(
      uid: documentSnapshot.documentID,
      firstName: documentSnapshot['firstName'],
      gfp: documentSnapshot['position']['geopoint']
    );
  }


  Future<List<UserData>> queryFriends() async {
    CollectionReference collecRef = _userCollection.document(uid).collection(
        "closeFriends");

    List<String> friendUId = [];

    await collecRef.getDocuments().then((value){
      value.documents.forEach((element) {
        friendUId.add(element.data['friend']);
      });
    });

//    QuerySnapshot qSnap = await _userCollection.where(FieldPath.documentId, isEqualTo: friendUId)
//        .getDocuments();

//    return qSnap.documents.map(_userDataFromSnapshot).toList();
    List<UserData> toReturn = new List<UserData>();

    if (friendUId.isNotEmpty) {
      for (var i in friendUId) {
        QuerySnapshot qSnap = await _userCollection.where(FieldPath.documentId, isEqualTo: i)
            .getDocuments();
        toReturn.add(qSnap.documents.map(_userDataFromSnapshot).toList()[0]);
      }
      return toReturn;
    } else {
      return [];
    }
  }

  //this only returns friends uid, not an actual reference to their UserData
  Future<List<UserData>> queryFriendsFromList() async {

    List friendsUIds = [];
    await _userCollection.document(uid).get().then((value) => friendsUIds = value.data['closeFriendsUIdList']);

    List<UserData> toReturn = new List<UserData>();
    if (friendsUIds.isNotEmpty) {
      for (var i in friendsUIds) {
        toReturn.add(await queryOnUId(i));
      }
      return toReturn;
    } else {
      return [];
    }

  }



  // Doesn't work without replication
  // Query a collection for Document Snapshots within range of a position
  Stream<List<DocumentSnapshot>> queryFriendsWithinRange(Position position, double rangeInKM) {
    try {
      GeoFirePoint gfpQueryPoint = createGeoFirePointFromPosition(position);
      //This doesn't work unless the closeFriends data are duplicated
      var geoRef = geo.collection(collectionRef: _userCollection.document(uid).collection("closeFriends"));
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
        .map(_thisUserDataFromSnapshot);
  }

  // userData object from DocumentSnapshot
  UserData _thisUserDataFromSnapshot(DocumentSnapshot documentSnapshot) {
    try {
      return UserData(
        uid: uid,
        firstName: documentSnapshot['firstName'] ?? "unnamed_member",
        gfp: documentSnapshot['position']['geopoint'] ?? null
       );
    } catch(e) {
      return UserData(
        uid: uid,
        firstName: documentSnapshot['firstName'] ?? "unnamed_member",
        gfp: null
      );
    }
  }

  // Stream Document Snapshots of UserData
  Stream<DocumentSnapshot> get userDataDoc {
    return _userCollection.document(uid).snapshots();
  }

}