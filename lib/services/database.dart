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

  //   Writes   //

  //update all user data
  Future updateUserData (String firstName, Position position, List<User> closeFriends) async {
    GeoFirePoint gfp = _createGeoFirePointFromPosition(position);
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
      gp: documentSnapshot['position']['geopoint']
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

  // Get a List of UserData, getting uids from the list in the users document
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
      GeoFirePoint gfpQueryPoint = _createGeoFirePointFromPosition(position);
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

  // UserData object from DocumentSnapshot
  UserData _thisUserDataFromSnapshot(DocumentSnapshot documentSnapshot) {

    try {
      return UserData(
        uid: uid,
        firstName: documentSnapshot['firstName'] ?? "unnamed_member",
        gp: documentSnapshot['position']['geopoint'] ?? null,
        closeFriendsUIdList: documentSnapshot['closeFriendsUIdList']
            .cast<String>() ?? []
       );
    } catch(e) {
      return UserData(
        uid: uid,
        firstName: documentSnapshot['firstName'] ?? "unnamed_member",
        gp: null,
        closeFriendsUIdList: documentSnapshot['closeFriendsUIdList']
            .cast<String>() ?? []
      );
    }
  }

  // Stream Document Snapshots of UserData
//  Stream<List<UserData>> friendsUserData(UserData curUser) {
//    return _userCollection.document(uid).snapshots();
//  }


  ////    NEW    ////

  ///   User Collection   ///

  // Write

  // Write to update user collection
  Future _updateUsersCollectionDocument (String firstName, String status) async {
    try {
      return await _userCollection.document(this.uid).setData({
        'firstName': firstName,
        'status': status,
        'lastUpdated': Timestamp.now()
      }, merge: true);
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  // Update a user's firstName
  Future _updateUsersCollectionName (String firstName) async {
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
  Future _updateUsersCollectionStatus (String status) async {
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

  // Stream the users name and status
  Stream <UserData> streamthisUserData() {
    _userCollection.document(this.uid).snapshots()
        .map(_createUserDataFromSnapshot);
  }


  ///   Friends Collection   ///

  // Write

  // Add a friend
  Future _addFriendByUID (String friendUId) async {
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

  // Stream a user by UId
  Stream<UserData> _streamUserDataByUId(String userUid) {

  }

  // Helper
  // userData object from DocumentSnapshot
  UserData _createUserDataFromSnapshot(DocumentSnapshot documentSnapshot) {
    //@ToDo: refactor the UserData class

    try {
      return UserData(
          uid: documentSnapshot.documentID,
          firstName: documentSnapshot['firstName'] ?? "unnamed_member",
          status: documentSnapshot['status'] ?? null,
      );
    } catch(e) {
      print(e.toString());
      return null;
    }
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
  Stream<UserLocation> streamthisUserLocation() {
    _locationCollection.document(this.uid).snapshots()
        .map(_createUserLocationFromSnapshot);
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