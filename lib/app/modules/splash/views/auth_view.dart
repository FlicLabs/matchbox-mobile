import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../routes/app_pages.dart';
import '../../../utils/background_gradient.dart';
import '../../../utils/sharedprefrence.dart';
import '../controllers/splash_controller.dart';

class AuthView extends StatefulWidget {
  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignInProvider _authProvider = GoogleSignInProvider();
  User? _user;
  @override
  Widget build(BuildContext context) {

    void _signIn() async {
      // Get.offAllNamed(Routes.HOME);

      UserCredential? userCredential = await _authProvider.signInWithGoogle();
      if (userCredential != null) {
          _user = userCredential.user;
          print("$_user");
          await SharedPrefService().saveUserLoginDetails(
            userCredential.user?.uid ?? '',
            userCredential.user?.email ?? '',
            userCredential.user?.displayName ?? '',
          );
          await _db.collection('users').doc(_user!.uid).set({
            'uid': _user!.uid,
            'name': _user!.displayName,
            'email': _user!.email,
            'photoURL': _user!.photoURL,
            'lastSignIn': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true)); // merge to avoid overwriting existing fields
          Get.offAllNamed(Routes.HOME);
      }
    }
    return Scaffold(
      body: Container(
        height: Get.height,
        alignment: Alignment.center,
        decoration: AppDecorations.gradientBackground,
        child: Column(
          children: [
            Image.asset("assets/images/logoimg.png",scale: 2,),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: Colors.grey,
                          width: 1,
                        )),
                  ),
                  // onPressed: () {
                  onPressed: _signIn,
                  // Get.off(() => const EmailLoginScreen());
                  // },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("assets/images/google.png", height: 20),
                      SizedBox(
                        width: 15,
                      ),
                      Text(
                        "Continue with Google",
                        style: TextStyle(fontSize: 15, color: Colors.black),
                      )
                    ],
                  )),
            ),

          ],
        ),
      ),
    );
  }
}


///---- Google Sign in Provider
class GoogleSignInProvider {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User canceled login

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in the user with Firebase
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
