import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/screens/bots_list_screen.dart';
import '../lib/services/unified_api_service.dart';

void main() {
  group('Bot Display Tests', () {
    testWidgets('BotsListScreen loads and displays bots', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(MaterialApp(
        home: BotsListScreen(),
      ));

      // Wait for the loading to complete
      await tester.pumpAndSettle();

      // Verify that the filter shows the correct count
      expect(find.text('All (3)'), findsOneWidget);
      expect(find.text('Running (2)'), findsOneWidget);
      expect(find.text('Stopped (1)'), findsOneWidget);

      // Verify that bot cards are displayed
      expect(find.byType(Card), findsAtLeastNWidgets(1));
    });

    test('Mock API service returns correct data', () async {
      final response = await UnifiedApiService.getBots();
      
      expect(response.bots.length, 3);
      expect(response.bots[0].coin, 'AINUSDT');
      expect(response.bots[1].coin, 'AIOTUSDT');
      expect(response.bots[2].coin, 'BTCUSDT');
    });
  });
}
