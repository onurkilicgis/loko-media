import 'package:firebase_auth/firebase_auth.dart';
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
  Future<User?> signInPerson(String email, String password) async {
    try {
      var user = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return user.user;
    } catch (err) {
      errorHandling(err);
    }
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

  errorHandling(err) {
    switch (err.code) {
      case 'email-already-in-use':
        {
          SBBildirim.uyari(
              'Bu mail zaten sisteme kayıtlıdır. Lütfen Giriş yapınız.');
          break;
        }
      case 'wrong-password':
        {
          SBBildirim.uyari(
              'Parolanız hatalı ya da daha önce hiç şifre belirlemediniz.');
          break;
        }
      case 'user-not-found':
        {
          SBBildirim.uyari('Böyle bir üye sistemimizde kayıtlı değildir');
          break;
        }
      case 'too-many-requests':
        {
          SBBildirim.uyari('Çok fazla istek gönderdiniz. Bir süre bekleyiniz.');
          break;
        }
      case 'unknown':
        {
          SBBildirim.uyari('Lütfen giriş bilgilerinizi kontrol ediniz.');
          break;
        }
    }
  }
}
