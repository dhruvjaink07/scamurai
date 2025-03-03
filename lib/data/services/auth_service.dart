import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  late Client _client;
  late Account _account;

  AuthService() {
    _client = Client();
    _client.setProject(dotenv.env['PROJECT_ID']!); // Your project ID

    _account = Account(_client);
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

  Future<void> logout() async {
    await _account.deleteSession(sessionId: 'current');
  }
}
