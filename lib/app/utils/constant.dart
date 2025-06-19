


import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../modules/home/views/notification_page.dart';
import 'app_colors.dart';

class Constant{
  static AppBar buildTransparentAppBar() {
    return AppBar(
      backgroundColor: AppColors.xlightback1,
      elevation: 0,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            color: Colors.white.withOpacity(0.2),
          ),
        ),
      ),
      title:Image.asset("assets/images/tran_logo.png",scale: 4,),
      actions: [
        IconButton(
          icon: Image.asset("assets/images/notificationicon.png", color: Colors.black,scale: 1.5,),
          onPressed: () {
            Get.to(NotificationPage());
          },
        ),
      ],
    );
  }
  static AppBar buildCutomTransparentAppBar(String title,bool add,) {
    return AppBar(
      backgroundColor: AppColors.xlightback1,
      elevation: 4,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            color: Colors.white.withOpacity(0.2),
          ),
        ),
      ),
      title: Text(title, style: TextStyle(color: Colors.black)),
      actions: [
        add? IconButton(
          icon: Image.asset("assets/images/addevent.png", color: Colors.black,scale: 1.5,),
          onPressed: () {
          },
        ):SizedBox(),
      ],
    );
  }
  static AppBar buildEventTransparentAppBar(String title,bool add,VoidCallback callback) {
    return AppBar(
      backgroundColor: AppColors.xlightback1,
      elevation: 4,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            color: Colors.white.withOpacity(0.2),
          ),
        ),
      ),
      title: Text(title, style: TextStyle(color: Colors.black)),
      actions: [
        add? IconButton(
          icon: Image.asset("assets/images/addevent.png", color: Colors.black,scale: 1.5,),
          onPressed: () {
            callback.call();
          },
        ):SizedBox(),
      ],
    );
  }

}