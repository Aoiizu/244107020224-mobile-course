import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pages/stat_pages.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MaterialApp(
        home: StatsPage(),
      ),
    ),
  );
}