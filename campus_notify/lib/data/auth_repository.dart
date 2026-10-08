class AuthSession {
  const AuthSession({required this.access, required this.refresh});
  final String access, refresh;
}

class AuthRepository {
  Future<AuthSession> login({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!email.contains('@') || password.length < 6) {
      throw Exception('Invalid email or password');
    }
    return AuthSession(access: 'access-$email', refresh: 'refresh-$email');
  }

  Future<String> refresh(String refreshToken) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (refreshToken.isEmpty) throw Exception('No refresh token');
    return 'access-renewed-${DateTime.now().millisecondsSinceEpoch}';
  }
}