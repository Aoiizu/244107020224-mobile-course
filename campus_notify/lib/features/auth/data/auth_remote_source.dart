class TokenPair {
  const TokenPair(this.access, this.refresh);
  final String access, refresh;
}

class AuthRemoteSource {
  Future<TokenPair> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (password.length < 6) throw Exception('Wrong email or password');
    return TokenPair('access-$email', 'refresh-$email');
  }

  Future<String> refresh(String refreshToken) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (refreshToken.isEmpty) throw Exception('No refresh token');
    return 'access-renewed-${DateTime.now().millisecondsSinceEpoch}';
  }
}
