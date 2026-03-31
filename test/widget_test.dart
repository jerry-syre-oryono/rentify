import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rentify/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: RentifyApp()));

    // Since it starts with a splash screen redirecting to login, 
    // we just check if it loads.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
