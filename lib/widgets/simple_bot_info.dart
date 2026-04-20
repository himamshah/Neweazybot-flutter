import 'package:flutter/material.dart';
import '../models/bot.dart';
import '../utils/app_theme.dart';

class SimpleBotInfo extends StatelessWidget {
  final Bot bot;

  const SimpleBotInfo({
    Key? key,
    required this.bot,
  }) : super(key: key);

  Color _getStatusColor() {
    switch (bot.status.toLowerCase()) {
      case 'running':
        return const Color(0xFF00E676); // Brighter, more vibrant green
      case 'paused':
        return AppTheme.amber;
      case 'closed':
        return AppTheme.text3;
      default:
        return AppTheme.text3;
    }
  }

  Widget _buildStatusPill() {
    String statusText;
    Color statusColor;
    Color bgColor;
    
    switch (bot.status.toLowerCase()) {
      case 'running':
        statusText = 'Running';
        statusColor = const Color(0xFF00E676);
        bgColor = const Color(0x1F00E676);
        break;
      case 'paused':
        statusText = 'Paused';
        statusColor = AppTheme.amber;
        bgColor = const Color(0x1DFFB547);
        break;
      case 'closed':
        statusText = 'Closed';
        statusColor = AppTheme.text3;
        bgColor = const Color(0x0DFFFFFF);
        break;
      default:
        statusText = 'Unknown';
        statusColor = AppTheme.text3;
        bgColor = const Color(0x0DFFFFFF);
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.bg2,
      child: Column(
        children: [
          _buildHeader(),
          _buildPnLRow(),
          _buildPriceRow(),
          if (bot.status == 'running') _buildLiquidationBar(),
          _buildCapitalRow(),
          _buildCoverSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppTheme.bg4,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: AppTheme.border2),
                ),
                child: Center(
                  child: Text(
                    bot.coin.length >= 3 ? bot.coin.substring(0, 3).toUpperCase() : bot.coin.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.blue,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bot.coin,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.text,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '${bot.exchange} · ${bot.direction} · #${bot.id}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.text3,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          _buildStatusPill(),
        ],
      ),
    );
  }

  Widget _buildPnLRow() {
    return IntrinsicHeight(
      child: Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppTheme.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildPnLCell('Realized PnL', bot.pnl.realized),
            ),
            Container(
              width: 1,
              color: AppTheme.border,
            ),
            Expanded(
              child: _buildPnLCell('Unrealized', bot.pnl.unrealized),
            ),
            Container(
              width: 1,
              color: AppTheme.border,
            ),
            Expanded(
              child: _buildPnLCell('Net PnL', bot.pnl.net),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPnLCell(String label, double value) {
    final color = AppTheme.getPnLColor(value);
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppTheme.text3,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value > 0 ? '+${AppTheme.formatCurrency(value)}' : AppTheme.formatCurrency(value),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: color,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow() {
    return IntrinsicHeight(
      child: Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppTheme.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildPriceCell(
                'Market price',
                AppTheme.formatPrice(bot.price.market),
                Text('live · 2s ago', style: const TextStyle(fontSize: 10, color: AppTheme.text3)),
              ),
            ),
            Container(
              width: 1,
              color: AppTheme.border,
            ),
            Expanded(
              child: _buildPriceCell(
                'Avg entry',
                bot.price.avgEntry != null 
                    ? AppTheme.formatPrice(bot.price.avgEntry!)
                    : '---',
                bot.price.avgEntryDistancePct != null
                    ? _buildDistanceBadge(bot.price.avgEntryDistancePct!)
                    : Text('no open position', style: const TextStyle(fontSize: 10, color: AppTheme.text3)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceCell(String label, String value, Widget subtitle) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppTheme.text3,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.text,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 3),
          _buildSubtitle(subtitle),
        ],
      ),
    );
  }

  Widget _buildSubtitle(Widget textWidget) {
    return textWidget;
  }

  Widget _buildDistanceBadge(double percentage) {
    final isNegative = percentage < 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: isNegative ? AppTheme.redDim : AppTheme.greenDim,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '${isNegative ? '' : '+'}${AppTheme.formatPercentage(percentage)} from mkt',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: isNegative ? AppTheme.red : AppTheme.green,
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  Widget _buildLiquidationBar() {
    // Only show liquidation bar if liquidation data is available
    if (bot.price.liquidation == null || bot.price.liquidationDistancePct == null) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: const BoxDecoration(
        color: Color(0x1FFFB547),
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          Row(
            children: [
              Icon(
                Icons.warning,
                size: 11,
                color: AppTheme.amber,
              ),
              const SizedBox(width: 5),
              const Text(
                'Liquidation',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.amber,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '${AppTheme.formatPrice(bot.price.liquidation!)} +${AppTheme.formatPercentage(bot.price.liquidationDistancePct!)} from mkt',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppTheme.amber,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapitalRow() {
    return IntrinsicHeight(
      child: Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppTheme.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildCapitalCell('Assigned', bot.capital.assigned, 'total capital'),
            ),
            Container(
              width: 1,
              color: AppTheme.border,
            ),
            Expanded(
              child: _buildCapitalCell('Available', bot.capital.available, '${AppTheme.formatPercentage(bot.capital.availablePct)} free'),
            ),
            Container(
              width: 1,
              color: AppTheme.border,
            ),
            Expanded(
              child: _buildCapitalCell('In position', bot.capital.inPosition, '+${AppTheme.formatPercentage(bot.capital.growthPct)}'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCapitalCell(String label, double value, String subtitle) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppTheme.text3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppTheme.formatCurrency(value),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.text,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: label == 'In position' ? AppTheme.green : AppTheme.text3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverSection() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          if (bot.covers.lastCover != null)
            _buildCoverItem(
              'LAST',
              'BUY',
              'C${bot.covers.lastCover!.buyCoverId ?? 'N/A'} · ${bot.covers.lastCover!.buyCoverDetail ?? 'N/A'}',
              '~\$${bot.covers.lastCover!.estimatedAmount?.toInt() ?? 0}',
            ),
          if (bot.covers.nextCover != null)
            _buildCoverItem(
              'NEXT',
              'BUY',
              'C${bot.covers.nextCover!.buyCoverId ?? 'N/A'} @ ${bot.covers.nextCover!.triggerPrice != null ? AppTheme.formatPrice(bot.covers.nextCover!.triggerPrice!) : 'N/A'}',
              '~\$${bot.covers.nextCover!.estimatedAmount?.toInt() ?? 0}',
            ),
        ],
      ),
    );
  }

  Widget _buildCoverItem(String tag, String badge, String text, String amount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: AppTheme.bg3,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Row(
        children: [
          Text(
            tag,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppTheme.text3,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.greenDim,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'BUY',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppTheme.green,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.text,
              ),
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppTheme.text2,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
