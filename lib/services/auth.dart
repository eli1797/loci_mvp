import 'package:firebase_auth/firebase_auth.dart';
import 'package:mvp/models/user.dart';
import 'package:mvp/services/database.dart';

class AuthService {

  /// Firebase authentication instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  /// Create a User object from a FirebaseUser
  User _userFromFirebaseUser(FirebaseUser firebaseUser) {
    return firebaseUser != null ? User(uid: firebaseUser.uid) : null;
  }

  /// Auth change user stream
  ///
  /// Streams changes in user object as authentication state changes
  Stream<User> get user {
    return _auth.onAuthStateChanged
      // Convert the Firebase user returned to a user
      .map(_userFromFirebaseUser);
  }

  /// Sign in with email and password
  ///
  /// Returns User if login successful, null otherwise
  Future signInEmailPass(String email, String password) async {
    try {
      // create a user in firebase
      AuthResult result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser firebaseUser = result.user;

      // convert firebase user to User Model
      return _userFromFirebaseUser(firebaseUser);
    } catch(e) {
      print(e.toString());
      return null;
    }
  }


  /// Register with email and password
  ///
  /// Returns User if login successful, null otherwise
  Future registerEmailPass(String email, String password) async {
    try {
      // create a user in firebase
      AuthResult result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser firebaseUser = result.user;

      // create a new document in Firestore tied to the user by uid
      await DatabaseService(uid: firebaseUser.uid)
          .updateThisUserDocument(firstName: 'unnamed_member');

      // convert firebase user to User Model
      return _userFromFirebaseUser(firebaseUser);
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  /// Sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch(e) {
      print(e.toString());
      return null;
    }
  }
}