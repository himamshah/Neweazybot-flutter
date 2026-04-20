import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/widgets/bot_card.dart';
import '../lib/models/bot.dart';

void main() {
  group('BotCard Click Tests', () {
    testWidgets('Entire bot card should be clickable', (WidgetTester tester) async {
      bool wasClicked = false;
      
      // Create a test bot
      final testBot = Bot(
        id: 1,
        coin: 'BTC',
        exchange: 'Binance',
        direction: 'long',
        status: 'running',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        pnl: PnL(
          realized: 100.0,
          unrealized: 50.0,
          net: 150.0,
        ),
        price: BotPrice(
          market: 50000.0,
          avgEntry: 48000.0,
          avgEntryDistancePct: -4.0,
        ),
        capital: BotCapital(
          assigned: 1000.0,
          available: 500.0,
          availablePct: 50.0,
          inPosition: 500.0,
          growthPct: 10.0,
        ),
        covers: BotCovers(),
      );

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BotCard(
              bot: testBot,
              onViewTrades: () {
                wasClicked = true;
              },
            ),
          ),
        ),
      );

      // Find the bot card container
      final botCardFinder = find.byType(InkWell);
      expect(botCardFinder, findsOneWidget);

      // Tap anywhere on the card (not on the button)
      await tester.tap(botCardFinder);
      await tester.pump();

      // Verify the callback was called
      expect(wasClicked, true);
    });

    testWidgets('View trades button should also be clickable', (WidgetTester tester) async {
      bool wasClicked = false;
      
      // Create a test bot
      final testBot = Bot(
        id: 1,
        coin: 'BTC',
        exchange: 'Binance',
        direction: 'long',
        status: 'running',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        pnl: PnL(
          realized: 100.0,
          unrealized: 50.0,
          net: 150.0,
        ),
        price: BotPrice(
          market: 50000.0,
          avgEntry: 48000.0,
          avgEntryDistancePct: -4.0,
        ),
        capital: BotCapital(
          assigned: 1000.0,
          available: 500.0,
          availablePct: 50.0,
          inPosition: 500.0,
          growthPct: 10.0,
        ),
        covers: BotCovers(),
      );

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BotCard(
              bot: testBot,
              onViewTrades: () {
                wasClicked = true;
              },
            ),
          ),
        ),
      );

      // Find and tap the "View trades" button
      final buttonFinder = find.text('View trades');
      expect(buttonFinder, findsOneWidget);

      await tester.tap(buttonFinder);
      await tester.pump();

      // Verify the callback was called
      expect(wasClicked, true);
    });
  });
}
