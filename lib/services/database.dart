import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mvp/models/brew.dart';
import 'package:mvp/models/user.dart';

class DatabaseService {

  // collection reference
  final CollectionReference brewCollection = Firestore.instance.collection('brews');

  final String uid;

  // constructor
  DatabaseService({ this.uid });

  Future updateUserData (String sugars, String name, int strength) async {
    return await brewCollection.document(uid).setData({
      'sugars': sugars,
      'name': name,
      'strength': strength,
    });
  }

  // brew list from snapshot
  List<Brew> _brewListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc) {
      return Brew(
        name: doc.data['name'] ?? '',
        strength: doc.data['strength'] ?? 0,
        sugars: doc.data['sugars'] ?? '0',
      );
    }).toList();
  }

  // get brews stream
  Stream<List<Brew>> get brews {
    return brewCollection.snapshots()
    .map(_brewListFromSnapshot);
  }

  // userData object from DocumentSnapshot
  UserData _userDataFromSnapshot(DocumentSnapshot documentSnapshot) {
    return UserData(
      uid: uid,
      name: documentSnapshot['name'],
      sugars: documentSnapshot['sugars'],
      strength: documentSnapshot['strength']
    );
  }

  // get user info (doc) stream
  Stream<UserData> get userData {
    return brewCollection.document(uid).snapshots()
        .map(_userDataFromSnapshot);
  }

}