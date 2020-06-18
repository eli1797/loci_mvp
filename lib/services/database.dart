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
  final CollectionReference _openCollection = Firestore.instance.collection('open');

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

  // Stream the users name and status
  Stream<UserData> streamUserDataByUId(String userUId) {
    try {
      return _userCollection.document(userUId).snapshots()
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

  /// Open Collection ///

  // Write

  // Go open
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

  // while open update position
  // called by a subscription to onChange of location service
  Future updateOpenPosition(Position position) async {
    try {
      GeoFirePoint gfp = _createGeoFirePointFromPosition(position);
      return await _openCollection.document(this.uid).setData({
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

  // Go hidden
  Future goHidden() async {
    try {
      return await _openCollection.document(this.uid).delete();
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  // Stream other opens nearby
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
      var result = streamUserDataByUIdList(event.friendUIds);
      print("Result: " + result.toString());
      return result;
    });
  }

  Stream streamFriendsData() async* {
    //@Todo: Look into StreamSink
    try {
      // get a UserFriend obj which contains list of friendUIds
      var userFriend = streamThisUserFriends();
      // use the friendUIds list to fetch their user data
      var userDataList = await streamUserDataList(userFriend).first;
      // only keep the UserData which not hidden
      var result = userDataList.where((element) => element.openness != 0.0)
          .toList();

      // stream the location of these users
      var userLocationList = await streamUserLocationsFromUserDataList(result).first;
      // combine the UserData and Location into a map
      Map<UserData, UserLocation> mapRes = Map.fromIterables(result, userLocationList);
      yield* Stream.value(mapRes);

      //@Todo: read about Stream error catching
    } catch(e) {
      print(e.toString());
    }
  }

  Stream<List<UserLocation>> streamUserLocationsFromUserDataList(List<UserData> userDataList) {
    List<String> userIDs = [];
    userDataList.forEach((element) {
      userIDs.add(element.uid);
    });

    try {
      return _locationCollection.where(FieldPath.documentId, whereIn: userIDs)
          .snapshots()
          .map((qSnap) {
        return qSnap.documents.map(_createUserLocationFromSnapshot).toList();
      });
    } catch(e) {
      print(e.toString());
    }
  }

  Stream<List<UserData>> streamUserDataList(Stream<UserFriends> userFriends) async* {
    List<String> userIDs = [];
    userFriends.forEach((element) {
      print("Ele" + element.toString());
      userIDs.add(element.uid);
    });

    print(userIDs);

    try {
      _userCollection.where(FieldPath.documentId, whereIn: userIDs)
          .snapshots()
          .map((qSnap) {
            return qSnap.documents.map(_createUserDataFromSnapshot).toList();
          });
    } catch(e) {
      print(e.toString());
    }
  }



  // read: https://stackoverflow.com/questions/52636766/how-to-query-firestore-document-inside-streambuilder-and-update-the-listview

  // Stream a user by UId
  Stream streamUserDataByUIdList(List userUids) async* {
    yield _userCollection.where(FieldPath.documentId, whereIn: userUids)
        .snapshots()
        .listen((event) {
      List<UserData> userDataList = event.documents.map(
          _createUserDataFromSnapshot).toList();

      userDataList.forEach((element) {
        print(element.firstName);
        print(element.uid);
        print(element.openness);
        Stream<UserLocation> userLocation = _streamUserLocation(element.uid);
        userLocation.listen((event) {
          print(event.uid);
          print(event.geoPoint.toString());
        });
      });
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

  // Stream the users name and status
  Stream<UserLocation> _streamUserLocation(String userUId) {
    try {
      return _locationCollection.document(userUId).snapshots()
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

}