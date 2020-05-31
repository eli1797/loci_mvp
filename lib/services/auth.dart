import 'package:firebase_auth/firebase_auth.dart';

class AuthService {

  // private firebase auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // sign in without email and password
  Future signInAnon() async {
    try {
      AuthResult result = await _auth.signInAnonymously();
      FirebaseUser user = result.user;
      return user;
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  // sign in with email and password


  // register with email and pass


  // sign out
}