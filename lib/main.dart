import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';

import 'app/modules/splash/bindings/splash_binding.dart';
import 'app/routes/app_pages.dart';
import 'app/utils/sharedprefrence.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  /*FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Received a message while in foreground: ${message.notification?.title}');

    if (message.notification != null) {
    }
  });*/

  await Firebase.initializeApp();
  await SharedPrefService().init();
  runApp(
    GetMaterialApp(
      title: "MatchBox.Party",
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.INITIAL,
      initialBinding: SplashBinding(),
      getPages: AppPages.routes,
      theme: ThemeData(
        primaryColor: Color(0xFF0F2027),
        colorScheme: ColorScheme.fromSeed(
            brightness: Brightness.light,
            primary: Color(0xFF0F2027), seedColor: Color(0xFF0F2027))
      ),
    ),
  );

}

