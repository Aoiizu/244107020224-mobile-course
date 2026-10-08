import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/api_errors.dart';
import '../providers/auth_providers.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _email = TextEditingController();
  final _pass = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
          TextField(controller: _pass, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
          const SizedBox(height: 16),
          if (auth.hasError)
            Text(friendlyError(auth.error!), style: const TextStyle(color: Colors.red)),
          FilledButton(
            onPressed: auth.isLoading
                ? null
                : () => ref.read(authStateProvider.notifier).login(_email.text.trim(), _pass.text),
            child: auth.isLoading ? const CircularProgressIndicator() : const Text('Login'),
          ),
        ]),
      ),
    );
  }
}