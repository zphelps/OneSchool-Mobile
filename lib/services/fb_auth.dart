import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class FBAuth with ChangeNotifier {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? getTenantID() => _auth.currentUser!.tenantId!;

  String? getUserID() => _auth.currentUser?.uid;

  //sign in with email and password
  Future signInWithEmailAndPassword({required String tenantID, required String email, required String password}) async {
    try {
      _auth.tenantId = tenantID;
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      notifyListeners();
      return result;
    }
    catch(e) {
      return e.toString();
    }
  }

  Future registerUserWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      notifyListeners();
      return result;
    }
    catch(e) {
      return e.toString();
    }
  }

  //sign in with email and password
  Future<String?> updatePassword(String oldPassword, String newPassword) async {
    final user = _auth.currentUser!;
    final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword);
    try {
      await user.reauthenticateWithCredential(credential);
      await _auth.currentUser?.updatePassword(newPassword);
      return null;
    } on FirebaseAuthException catch (e) {
      return 'Old password is incorrect';
    }
  }

  Future sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      notifyListeners();
    }
    catch(e) {
      print(e.toString());
      return null;
    }
  }

  Future sendVerificationEmail() async {
    try {
      if (_auth.currentUser != null && !_auth.currentUser!.emailVerified) {
        await _auth.currentUser!.sendEmailVerification();
      }
      else {
        print('Error - Email Verification');
      }
      notifyListeners();
    }
    catch(e) {
      print(e.toString());
      return null;
    }
  }

  Future deleteUserAuth() async {
    try {
      return await _auth.currentUser?.delete();
    }
    catch(e) {
      print(e.toString());
      return null;
    }
  }

  //sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    }
    catch(e) {
      print(e.toString());
      return null;
    }
  }

}