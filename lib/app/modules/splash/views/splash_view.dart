import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:matchbox/app/utils/app_colors.dart';

import '../../../routes/app_pages.dart';
import '../../../utils/background_gradient.dart';
import '../../../utils/sharedprefrence.dart';
import '../../home/views/matched_userlist_view.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    Timer(Duration(seconds: 3), () {
      Future.delayed(Duration(seconds: 2), () async {
        if (SharedPrefService().isLoggedIn) {
          FirebaseFirestore _firestore = FirebaseFirestore.instance;

          final FirebaseAuth _auth = FirebaseAuth.instance;
          User? user = _auth.currentUser;
          String uid = _auth.currentUser!.uid;

          DocumentSnapshot<Map<String, dynamic>> snapshot =
              await _firestore.collection('users').doc(uid).get();
          var userData = snapshot.data();
          if (userData!['questionAnswers'] != null) {
            Get.off(MatchedUsersView(currentUserId: uid));
          } else {
            Get.offAllNamed(Routes.HOME);
          }
        } else {
          Get.offAllNamed(Routes.Auth);
        }
      });
    });
    return Scaffold(
      body: Container(
        height: Get.height,
        alignment: Alignment.center,
        decoration: AppDecorations.gradientBackground,
        child: Image.asset(
          "assets/images/tran_logo.png",
          scale: 1.3,
        ),
      ),
    );
  }
}
