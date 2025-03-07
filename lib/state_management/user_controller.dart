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
    _loadUserProfileFromPrefs();
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

  void setUserProfile(Document userProfile) async {
    this.userProfile.value = userProfile;
    await _saveUserProfileToPrefs(userProfile);
  }

  void clearUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userProfile');
    userProfile.value = null;
  }

  Future<void> _saveUserProfileToPrefs(Document userProfile) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('userProfile', jsonEncode(userProfile.data));
  }

  void _loadUserProfileFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final userProfileData = prefs.getString('userProfile');
    if (userProfileData != null) {
      userProfile.value = Document(
        $id: user.value?.$id ?? '',
        $collectionId: '',
        $databaseId: '',
        $createdAt: '',
        $updatedAt: '',
        $permissions: [],
        data: jsonDecode(userProfileData),
      );
    }
  }

  Future<void> fetchUserProfile(String userId) async {
    try {
      final userProfile = await _authService.getUserProfile(userId);
      setUserProfile(userProfile);
    } catch (e) {
      print("Error fetching user profile: $e");
    }
  }

  // Method to check if the user is logged in
  bool isLoggedIn() {
    return user.value != null;
  }
}
