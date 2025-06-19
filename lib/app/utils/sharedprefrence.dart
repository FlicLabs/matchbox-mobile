import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefService {
  static final SharedPrefService _instance = SharedPrefService._internal();

  factory SharedPrefService() {
    return _instance;
  }

  SharedPrefService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Save User Data
  Future<void> saveUserLoginDetails(String userId, String email, String name) async {
    await _prefs?.setString('userId', userId);
    await _prefs?.setString('email', email);
    await _prefs?.setString('name', name);
  }

  // Get User Data
  String? get userId => _prefs?.getString('userId');
  String? get email => _prefs?.getString('email');
  String? get name => _prefs?.getString('name');

  // Check if user is logged in
  bool get isLoggedIn => _prefs?.getString('userId') != null;

  // Clear User Data (for logout)
  Future<void> clearUserDetails() async {
    await _prefs?.clear();
  }
}
