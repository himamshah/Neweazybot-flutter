import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/widgets/bot_card.dart';
import '../lib/models/bot.dart';
import '../lib/utils/app_theme.dart';

void main() {
  group('BotCard Border Color Tests', () {
    testWidgets('Running bot should have green border', (WidgetTester tester) async {
      // Create a running bot
      final runningBot = Bot(
        id: 1,
        coin: 'BTC',
        exchange: 'Binance',
        direction: 'long',
        status: 'running',
        createdAt: DateTime.now(),
        pnl: PnL(
          realized: 100.0,
          unrealized: 50.0,
          net: 150.0,
        ),
        price: Price(
          market: 50000.0,
          avgEntry: 48000.0,
          avgEntryDistancePct: -4.0,
        ),
        capital: Capital(
          assigned: 1000.0,
          available: 500.0,
          inPosition: 500.0,
          availablePct: 50.0,
          growthPct: 10.0,
        ),
        covers: Covers(total: 0),
      );

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BotCard(
              bot: runningBot,
              onViewTrades: () {},
            ),
          ),
        ),
      );

      // Find the left border container
      final borderFinder = find.byType(Container).first;
      final container = tester.widget<Container>(borderFinder);
      final decoration = container.decoration as BoxDecoration;
      
      // Verify the color is green for running status
      expect(decoration.color, AppTheme.green);
    });

    testWidgets('Paused bot should have gray border', (WidgetTester tester) async {
      // Create a paused bot
      final pausedBot = Bot(
        id: 2,
        coin: 'ETH',
        exchange: 'Binance',
        direction: 'short',
        status: 'paused',
        createdAt: DateTime.now(),
        pnl: PnL(
          realized: -50.0,
          unrealized: -25.0,
          net: -75.0,
        ),
        price: Price(
          market: 3000.0,
          avgEntry: 3100.0,
          avgEntryDistancePct: 3.3,
        ),
        capital: Capital(
          assigned: 1000.0,
          available: 800.0,
          inPosition: 200.0,
          availablePct: 80.0,
          growthPct: -5.0,
        ),
        covers: Covers(total: 0),
      );

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BotCard(
              bot: pausedBot,
              onViewTrades: () {},
            ),
          ),
        ),
      );

      // Find the left border container
      final borderFinder = find.byType(Container).first;
      final container = tester.widget<Container>(borderFinder);
      final decoration = container.decoration as BoxDecoration;
      
      // Verify the color is gray for non-running status
      expect(decoration.color, AppTheme.text3);
    });

    testWidgets('Closed bot should have gray border', (WidgetTester tester) async {
      // Create a closed bot
      final closedBot = Bot(
        id: 3,
        coin: 'SOL',
        exchange: 'Binance',
        direction: 'long',
        status: 'closed',
        createdAt: DateTime.now(),
        pnl: PnL(
          realized: 200.0,
          unrealized: 0.0,
          net: 200.0,
        ),
        price: Price(
          market: 100.0,
          avgEntry: 80.0,
          avgEntryDistancePct: -20.0,
        ),
        capital: Capital(
          assigned: 1000.0,
          available: 1000.0,
          inPosition: 0.0,
          availablePct: 100.0,
          growthPct: 20.0,
        ),
        covers: Covers(total: 0),
      );

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BotCard(
              bot: closedBot,
              onViewTrades: () {},
            ),
          ),
        ),
      );

      // Find the left border container
      final borderFinder = find.byType(Container).first;
      final container = tester.widget<Container>(borderFinder);
      final decoration = container.decoration as BoxDecoration;
      
      // Verify the color is gray for closed status
      expect(decoration.color, AppTheme.text3);
    });
  });
}
