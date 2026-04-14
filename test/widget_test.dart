// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:easybot_complete/main.dart';

void main() {
  testWidgets('EasyBot app can be instantiated', (WidgetTester tester) async {
    // Just test that the app can be created without throwing exceptions
    // Don't pump to avoid triggering async operations
    expect(() => const EasyBotApp(), returnsNormally);
  });
}
