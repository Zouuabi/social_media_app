import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media_app/models/user.dart' as m;
import 'package:social_media_app/resources/storage.dart';

class Auth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> signUpUser({
    //! make this function return Fuctur<String> in order to controle errors
    required String username,
    required String email,
    required String password,
    required String bio,
    required Uint8List file,
  }) async {
    String status;
    try {
      //! must be tested not empty before creating user
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      String photoUrl =
          await Storage().uploadImageToStorage('profilePics', file, false);

      String uid = cred.user!.uid;
      m.User user = m.User(
          username: username,
          uid: uid,
          email: email,
          bio: bio,
          profileUrl: photoUrl,
          followers: [],
          following: []);
      _firestore.collection('users').doc(uid).set(user.getUserInfo());

      status = 'Success';
    } on FirebaseAuthException catch (e) {
      // if (e.code == 'invalid-email') {
      //   status = 'A samir yehdik rabi l\'email yabda hakka \n monji@gmail.com';
      // } else if (e.code == 'weak_password') {
      //   status = 'Chnya tw qawi mot de pass mte3k zooz markhoufin yeeser raw';
      // } else if (e.code == 'email-already-in-use') {
      //   status = 'emai mosta3ml chouf wehd akher';
      // } else {
      //   // status = 'famma mochkl ya3rfou ken rabi sobhanou ';
      //   status = e.message.
      // }
      status = e.message.toString();
    }

    return status;
  }

  Future<String> singInUser(
      {required String email, required String password}) async {
    String status;
    try {
      if (email.isNotEmpty & password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        status = 'Success';
      } else {
        status = "dakhel adress w mot de pass makhyeb rasek ";
      }
    } on FirebaseAuthException catch (e) {
      status = e.message.toString();
    }

    return status;
  }

  signUserOut() async {
    await _auth.signOut();
  }
}