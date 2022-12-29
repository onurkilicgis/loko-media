import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:loko_media/services/MyLocal.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // çıkış fonksiyonu
  signOut() async {
    await MyLocal.removeKey('token');
    await MyLocal.removeKey('user');
    return true;
  }

// kayıt fonksiyonu
  Future<User?> createPerson(String name, String email, String password) async {
    var user = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);

    // firestore a veri gönderme
    await _firestore.collection('Person').doc(user.user?.uid).set({
      'userName': name,
      'email': email,
    });
    return user.user;
  }

  // şifre sıfırlama fonksiyonu
  Future<void> sendPasswordResetEmail(String email) async {
    return await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // giriş Fonksiyonu
  Future<User?> signInPerson(String email, String password) async {
    var user = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    return user.user;
  }

  // email onaylama
  Future<void> sendEmailVerification() async {
    var user = await _auth.currentUser;
    user?.sendEmailVerification();
  }
  //google ile giriş

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}
