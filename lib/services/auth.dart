import 'package:firebase_auth/firebase_auth.dart';
import 'package:mvp/models/user.dart';
import 'package:mvp/services/database.dart';

class AuthService {

  // private firebase auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // create user obj based on FirebaseUser
  User _userFromFirebaseUser(FirebaseUser firebaseUser) {
    return firebaseUser != null ? User(uid: firebaseUser.uid) : null; 
  }

  // auth change user stream
  Stream<User> get user {
    return _auth.onAuthStateChanged
      // Convert the Firebase user returned to a user
      // .map((FirebaseUser user) => _userFromFirebaseUser(user));
      .map(_userFromFirebaseUser);
  }

  // sign in without email and password
  Future signInAnon() async {
    try {
      AuthResult result = await _auth.signInAnonymously();
      FirebaseUser firebaseUser = result.user;
      return _userFromFirebaseUser(firebaseUser);
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  // sign in with email and password
  Future signInEmailPass(String email, String password) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser firebaseUser = result.user;
      return _userFromFirebaseUser(firebaseUser);
    } catch(e) {
      print(e.toString());
      return null;
    }
  }


  // register with email and pass
  Future registerEmailPass(String email, String password) async {
    try {
      // create a user
      AuthResult result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser firebaseUser = result.user;

      // create a new document  in Firestore tied to the user by uid
      await DatabaseService(uid: firebaseUser.uid).updateUserData(
          'New Member', 0.0, 0.0, [],);

      return _userFromFirebaseUser(firebaseUser);
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  // sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch(e) {
      print(e.toString());
      return null;
    }
  }
}