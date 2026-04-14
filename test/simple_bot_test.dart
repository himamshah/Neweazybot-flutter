import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/widgets/bot_card.dart';
import '../lib/models/bot.dart';
import '../lib/utils/app_theme.dart';

void main() {
  testWidgets('BotCard renders without error', (WidgetTester tester) async {
    // Create a simple test bot with minimal data
    final testBot = Bot(
      id: 1,
      coin: 'BTCUSDT',
      exchange: 'Binance',
      direction: 'long',
      status: 'stopped',
      createdAt: DateTime.now(),
      pnl: PnL(realized: 100.0, unrealized: 0.0, net: 100.0),
      price: Price(market: 50000.0),
      capital: Capital(assigned: 1000.0, available: 1000.0, inPosition: 0.0, availablePct: 100.0, growthPct: 0.0),
      covers: Covers(total: 0),
    );

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: BotCard(
          bot: testBot,
          onViewTrades: () {},
          onRestart: () {},
          onSettings: () {},
        ),
      ),
    ));

    expect(find.byType(BotCard), findsOneWidget);
    expect(find.text('BTCUSDT'), findsOneWidget);
  });
}
