import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

/// Owns its own state, so loading the token rebuilds only this label.
class FcmTokenLabel extends StatefulWidget {
  const FcmTokenLabel({super.key});

  @override
  State<FcmTokenLabel> createState() => _FcmTokenLabelState();
}

class _FcmTokenLabelState extends State<FcmTokenLabel> {
  String _token = '...';

  @override
  void initState() {
    super.initState();
    if (Firebase.apps.isNotEmpty) {
      FirebaseMessaging.instance.getToken().then((t) {
        if (mounted && t != null) {
          setState(() => _token = '${t.substring(0, 12)}...');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text('FCM token: $_token'),
    );
  }
}
