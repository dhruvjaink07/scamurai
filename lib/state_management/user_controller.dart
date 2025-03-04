import 'package:get/get.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scamurai/data/services/auth_service.dart';
import 'dart:convert';

class UserController extends GetxController {
  var user = Rxn<User>();
  var userProfile = Rxn<Document>();
  final AuthService _authService = AuthService();

  @override
  void onInit() {
    super.onInit();
    _loadUserFromPrefs();
  }

  void setUser(User newUser) async {
    user.value = newUser;
    await _saveUserToPrefs(newUser);
  }

  User? getUser() {
    return user.value;
  }

  Future<void> _saveUserToPrefs(User user) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('user', jsonEncode(user.toMap()));
  }

  void _loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user');
    if (userData != null) {
      user.value = User.fromMap(jsonDecode(userData));
    }
  }

  void clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('user');
    user.value = null;
  }

  Document? getUserProfile() => userProfile.value;

  void setUserProfile(Document userProfile) {
    this.userProfile.value = userProfile;
  }

  void clearUserProfile() {
    userProfile.value = null;
  }

  Future<void> fetchUserProfile(String userId) async {
    try {
      final userProfile = await _authService.getUserProfile(userId);
      setUserProfile(userProfile);
    } catch (e) {
      print("Error fetching user profile: $e");
    }
  }
}
