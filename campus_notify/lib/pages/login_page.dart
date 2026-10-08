import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../data/app_deps.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.deps});
  final AppDeps deps;
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController(text: 'student@campus.edu');
  final _pass = TextEditingController(text: 'password');
  String? _error;
  bool _busy = false;

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      // Router's refreshListenable handles the redirect (incl. ?from=).
      await widget.deps.session.login(_email.text.trim(), _pass.text);
    } on DioException {
      if (mounted) setState(() => _error = 'Invalid email or password');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Campus Login')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            TextField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email')),
            TextField(
                controller: _pass,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password')),
            const SizedBox(height: 16),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            FilledButton(
                onPressed: _busy ? null : _submit, child: const Text('Log in')),
          ]),
        ),
      );
}
