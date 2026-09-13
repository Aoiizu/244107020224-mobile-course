import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week3_assignment/main.dart';

void main() {
  testWidgets('adds a new task', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();
    expect(find.text('No tasks yet'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Do week 3 homework');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text('Do week 3 homework'), findsOneWidget);
  });

  testWidgets('bottom nav switches between Tasks and Stats', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    expect(find.text('ToDo Riverpod'), findsOneWidget);

    await tester.tap(find.text('Stats'));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.text('Stats'), findsWidgets);
  });
}