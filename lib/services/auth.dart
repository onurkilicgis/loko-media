import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:loko_media/services/MyLocal.dart';
import 'package:loko_media/services/utils.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // çıkış fonksiyonu
  signOut() async {
    await MyLocal.removeKey('token');
    await MyLocal.removeKey('user');
    return true;
  }

// kayıt fonksiyonu
  Future<User?> createPerson(String name, String email, String password) async {
    try {
      var user = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      user.user?.updateDisplayName(name);
      return user.user;
    } catch (err) {
      errorHandling(err);
    }
  }

  // şifre sıfırlama fonksiyonu
  Future<void> sendPasswordResetEmail(String email) async {
    return await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // giriş Fonksiyonu
  Future<User?> signInPerson(
      String email, String password, Function callback) async {
    try {
      var user = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return user.user;
    } catch (err) {
      callback();
      errorHandling(err);
    }
  }

  // email onaylama
  Future<void> sendEmailVerification() async {
    var user = await _auth.currentUser;
    user?.sendEmailVerification();
  }
  //google ile giriş

  signInWithGoogle() async {
    // Trigger the authentication flow
    try {
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
    } catch (err) {
      errorHandling(err);
    }
  }

  static errorHandling(err) {
    switch (err.code) {
      case 'sign_in_failed':
        {
          SBBildirim.uyari(Utils.getComplexLanguage(
              'a235'.tr, {'mesaj': err.message.toString()}));
          break;
        }
      case 'email-already-in-use':
        {
          SBBildirim.uyari('a236'.tr);
          break;
        }
      case 'wrong-password':
        {
          SBBildirim.uyari('a237'.tr);
          break;
        }
      case 'user-not-found':
        {
          SBBildirim.uyari('a238'.tr);
          break;
        }
      case 'too-many-requests':
        {
          SBBildirim.uyari('a239'.tr);
          break;
        }
      case 'unknown':
        {
          SBBildirim.uyari('a240'.tr);
          break;
        }
    }
  }
}
