import 'package:cloud_firestore/cloud_firestore.dart';

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

  // get brews screen
  Stream<QuerySnapshot> get brews {
    return brewCollection.snapshots();
  }

}