import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dar_es_salaam/models/user.dart';
import 'package:dar_es_salaam/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

// get the uid of the current user logged in
  String get getCurrentUserID {
    return _auth.currentUser.uid;
  }

  // create appuser object based on firebase user object
  AppUser _userFromFirebaseUser(User user) {
    return user != null ? AppUser(id: user.uid) : null;
  }

  // auth change user stream. We're listening to event changes i.e login and logout
  Stream<AppUser> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  // sign in anonymously
  Future signInAnonymously() async {
    try {
      var result = await _auth.signInAnonymously();
      User user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // sign in with email and password
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User user = result.user;
      return _userFromFirebaseUser(user);
    } catch (error) {
      return error.code;
    }
  }

  // sign up with email and password
  Future signUpWithEmailAndPassword(String email, String password) async {
    try {
      var result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      User user = result.user;

      // create a new document for the user with the uid
      await FirestoreService(uid: user.uid).setInitialUserData(
        username: user.email,
        email: user.email,
        phone: 'Phone not set',
        location: 'Location not set',
        description: 'Bio not set',
        booksDonated: [],
        booksReceived: [],
        library: [],
        dateJoined: Timestamp.now(),
        showBooksDonatedCount: true,
        showPhone: true,
      );

      return _userFromFirebaseUser(user);
    } catch (error) {
      return error.code;
    }
  }

  // sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }
}
