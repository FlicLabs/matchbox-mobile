import 'package:get/get.dart';
import 'package:matchbox/app/modules/splash/views/auth_view.dart';

import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/matched_userlist_view.dart';
import '../modules/home/views/home_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () =>  QuestionFlowScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.SPLASH,
      page: () =>  SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.Auth,
      page: () =>  AuthView(),
      binding: SplashBinding(),
    ),GetPage(
      name: _Paths.Auth,
      page: () =>  MatchedUsersView(currentUserId: "",),
      binding: SplashBinding(),
    ),
  ];
}
