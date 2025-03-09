import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:scamurai/core/app_constants.dart';

class AuthService {
  late Client _client;
  late Account _account;
  late Databases _database;

  AuthService() {
    _client = Client();
    _client
        .setEndpoint("https://cloud.appwrite.io/v1")
        .setProject(AppConstant.PROJECT_ID); // Your project ID

    _account = Account(_client);
    _database = Databases(_client);
  }

  Future<User> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final user = await _account.create(
      userId: ID.unique(),
      email: email,
      password: password,
      name: name,
    );
    return user;
  }

  Future<Session> login({
    required String email,
    required String password,
  }) async {
    final session = await _account.createEmailPasswordSession(
      email: email,
      password: password,
    );
    return session;
  }

  Future<User> getUserDetails() async {
    final user = await _account.get();
    return user;
  }

  Future<Document> getUserProfile(String userId) async {
    String databaseId = AppConstant.DATABASE_ID;
    String userCollectionId = AppConstant.USER_COLLECTION_ID;
    final document = await _database.getDocument(
      databaseId: databaseId,
      collectionId: userCollectionId,
      documentId: userId,
    );
    return document;
  }

  Future<void> logout() async {
    await _account.deleteSession(sessionId: 'current');
  }

  Future<String> getJWT() async {
    final jwt = await _account.createJWT();
    return jwt.jwt;
  }

  Future<User?> getCurrentUser() async {
    try {
      return await _account.get();
    } catch (e) {
      print("User is not authenticated: $e");
      return null;
    }
  }
}
