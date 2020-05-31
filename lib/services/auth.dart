import 'package:firebase_auth/firebase_auth.dart';
import 'package:mvp/models/user.dart';

class AuthService {

  // private firebase auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // create user obj based on FirebaseUser
  User _userFromFirebaseUser(FirebaseUser firebaseUser) {
    return firebaseUser != null ? User(uid: firebaseUser.uid) : null; 
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


  // register with email and pass


  // sign out
}