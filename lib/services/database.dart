import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mvp/models/brew.dart';

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

  // get brews screen
  Stream<List<Brew>> get brews {
    return brewCollection.snapshots()
    .map(_brewListFromSnapshot);
  }

}