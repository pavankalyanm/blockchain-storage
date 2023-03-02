import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/data/repositories/user_repository.dart';
import 'package:todo_app/data/repositories/firestore_crud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_app/globals.dart' as globals;

class FirebaseAuthRepo implements UserRepository {
  final _firebaseAuth = FirebaseAuth.instance;

  FirebaseAuthRepo();

  @override
  Future<void> login({required String email, required String password}) async {
    try {
      await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((currentuser) async {
        globals.uid = currentuser.user!.uid;
        final SharedPreferences preferences =
            await SharedPreferences.getInstance();
        preferences.setString('uid', currentuser.user!.uid);
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        throw 'Wrong password provided for that user.';
      }
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<void> register({
    required String fullname,
    required String email,
    required String roll,
    required String password,
  }) async {
    try {
      await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((currentUser) async {
        globals.uid = currentUser.user!.uid;

        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.user?.uid)
            .set({
          'email': email,
          'fullname': fullname,
          'role': 'student',
          'roll': roll,
          'uid': currentUser.user?.uid,
          'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
          'updatedAt': DateTime.now().millisecondsSinceEpoch.toString()
        });
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        throw 'The account already exists for that email.';
      } else {
        throw 'Please check your email address.';
      }
    } catch (e) {
      throw Exception('oops,Something wrong happend!');
    }
  }

  Future<void> googleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      await _firebaseAuth.signInWithCredential(credential);
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  logout() async {
    try {
      globals.uid = null;
      globals.role = '';
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      preferences.setString('uid', '');
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> signinanonym() async {
    try {
      await _firebaseAuth.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      throw Exception(e.toString());
    }
  }
}
