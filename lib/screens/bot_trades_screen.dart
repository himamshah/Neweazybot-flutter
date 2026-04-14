import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/bot.dart';
import '../models/trade.dart';
import '../services/unified_api_service.dart';
import '../utils/app_theme.dart';

class BotTradesScreen extends StatefulWidget {
  final Bot bot;

  const BotTradesScreen({
    Key? key,
    required this.bot,
  }) : super(key: key);

  @override
  State<BotTradesScreen> createState() => _BotTradesScreenState();
}

class _BotTradesScreenState extends State<BotTradesScreen> {
  List<Trade> trades = [];
  bool isLoading = false;
  String error = '';
  String selectedFilter = 'all';
  final Set<int> expandedTrades = {};

  @override
  void initState() {
    super.initState();
    _loadTrades();
  }

  Future<void> _loadTrades() async {
    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      final response = await UnifiedApiService.getBotDetail(
        widget.bot.id,
        tradeStatus: selectedFilter,
      );
      
      setState(() {
        trades = response.trades;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildNavBar(),
            _buildSummaryHeader(),
            _buildFilterBar(),
            Expanded(
              child: _buildBody(),
            ),
            _buildTabBar(),
          ],
        ),
      ),
    );
  }

  
  Widget _buildNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: const BoxDecoration(
        color: AppTheme.bg2,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios, size: 8, color: AppTheme.blue),
            label: const Text(
              'Bots',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Spacer(),
          Column(
            children: [
              Text(
                widget.bot.coin,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.text,
                  letterSpacing: -0.2,
                ),
              ),
              Text(
                'Bot #${widget.bot.id}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.text3,
                ),
              ),
            ],
          ),
          const SizedBox(width: 32),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.bg3,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.border2),
            ),
            child: IconButton(
              icon: const Icon(Icons.settings, size: 14),
              onPressed: () {},
              padding: EdgeInsets.zero,
              color: AppTheme.text2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.bg2,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Column(
        children: [
          _buildHeaderTop(),
          _buildPnLGrid(),
          _buildPriceGrid(),
          if (widget.bot.status == 'running') _buildLiquidationBar(),
          _buildCapitalGrid(),
        ],
      ),
    );
  }

  Widget _buildHeaderTop() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                    widget.bot.coinSymbol,
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
                    widget.bot.coin,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.text,
                    ),
                  ),
                  Text(
                    '${widget.bot.exchange} · ${widget.bot.direction} · #${widget.bot.id}',
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

  Widget _buildStatusPill() {
    final isRunning = widget.bot.status == 'running';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isRunning ? AppTheme.greenDim : const Color(0x0DFFFFFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: isRunning ? AppTheme.green : AppTheme.text3,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            isRunning ? 'Running' : 'Stopped',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isRunning ? AppTheme.green : AppTheme.text3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPnLGrid() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildGridCell('Realized PnL', widget.bot.pnl.realized),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppTheme.border,
          ),
          Expanded(
            child: _buildGridCell('Unrealized', widget.bot.pnl.unrealized),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppTheme.border,
          ),
          Expanded(
            child: _buildGridCell('Net PnL', widget.bot.pnl.net),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceGrid() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildPriceCell(
              'Market price',
              AppTheme.formatPrice(widget.bot.price.market),
              Text('live · 2s ago', style: const TextStyle(fontSize: 10, color: AppTheme.text3)),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppTheme.border,
          ),
          Expanded(
            child: _buildPriceCell(
              'Avg entry',
              widget.bot.price.avgEntry != null 
                  ? AppTheme.formatPrice(widget.bot.price.avgEntry!)
                  : '---',
              widget.bot.price.avgEntryDistancePct != null
                  ? _buildDistanceBadge(widget.bot.price.avgEntryDistancePct!)
                  : Text('no open position', style: const TextStyle(fontSize: 10, color: AppTheme.text3)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiquidationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: const BoxDecoration(
        color: Color(0x0FFFB547),
        border: Border(top: BorderSide(color: AppTheme.border)),
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
                'Liquidation price',
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
            '${AppTheme.formatPrice(widget.bot.price.liquidation!)} +${AppTheme.formatPercentage(widget.bot.price.liquidationDistancePct!)} from mkt',
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

  Widget _buildCapitalGrid() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildCapitalCell('Assigned', widget.bot.capital.assigned, 'total capital'),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppTheme.border,
          ),
          Expanded(
            child: _buildCapitalCell('Available', widget.bot.capital.available, '${AppTheme.formatPercentage(widget.bot.capital.availablePct)} free'),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppTheme.border,
          ),
          Expanded(
            child: _buildCapitalCell('In position', widget.bot.capital.inPosition, '+${AppTheme.formatPercentage(widget.bot.capital.growthPct)}'),
          ),
        ],
      ),
    );
  }

  Widget _buildGridCell(String label, double value) {
    final color = AppTheme.getPnLColor(value);
    return Padding(
      padding: const EdgeInsets.all(14),
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
          const SizedBox(height: 3),
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

  Widget _buildPriceCell(String label, String value, Widget subtitle) {
    return Padding(
      padding: const EdgeInsets.all(14),
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
          const SizedBox(height: 2),
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
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
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

  Widget _buildCapitalCell(String label, double value, String subtitle) {
    return Padding(
      padding: const EdgeInsets.all(14),
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
            AppTheme.formatCurrency(value),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.text,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 2),
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

  Widget _buildFilterBar() {
    final filters = ['All', 'Open', 'Closed', 'Cancelled'];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: const BoxDecoration(
        color: AppTheme.bg2,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final filterValue = filter.toLowerCase();
            final isActive = selectedFilter == filterValue;
            
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(filter),
                selected: isActive,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      selectedFilter = filterValue;
                    });
                    _loadTrades();
                  }
                },
                backgroundColor: AppTheme.bg3,
                selectedColor: AppTheme.blueDim,
                labelStyle: TextStyle(
                  color: isActive ? AppTheme.blue : AppTheme.text3,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                side: const BorderSide(color: AppTheme.border),
                pressElevation: 0,
                checkmarkColor: AppTheme.blue,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppTheme.blue,
        ),
      );
    }

    if (error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppTheme.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading trades',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.text2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTrades,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (trades.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: AppTheme.text3,
            ),
            const SizedBox(height: 16),
            Text(
              'No trades found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No trades match the selected filter',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.text2,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: trades.length,
      itemBuilder: (context, index) {
        final trade = trades[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: TradeCard(
            trade: trade,
            isExpanded: expandedTrades.contains(trade.groupId),
            onToggle: () {
              setState(() {
                if (expandedTrades.contains(trade.groupId)) {
                  expandedTrades.remove(trade.groupId);
                } else {
                  expandedTrades.add(trade.groupId);
                }
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 22),
      decoration: const BoxDecoration(
        color: AppTheme.bg2,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          _buildTabItem(Icons.grid_view, 'Dashboard', false),
          _buildTabItem(Icons.trending_up, 'Bots', true),
          _buildTabItem(Icons.receipt_long, 'Trades', false),
          _buildTabItem(Icons.person, 'Account', false),
        ],
      ),
    );
  }

  Widget _buildTabItem(IconData icon, String label, bool isActive) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: isActive ? AppTheme.blue : AppTheme.text3,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isActive ? AppTheme.blue : AppTheme.text3,
            ),
          ),
          if (isActive)
            Container(
              width: 4,
              height: 4,
              margin: const EdgeInsets.only(top: 1),
              decoration: BoxDecoration(
                color: AppTheme.blue,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }
}

class TradeCard extends StatelessWidget {
  final Trade trade;
  final bool isExpanded;
  final VoidCallback onToggle;

  const TradeCard({
    Key? key,
    required this.trade,
    required this.isExpanded,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(trade.status);
    final statusBgColor = _getStatusBgColor(trade.status);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bg2,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(13),
          bottomRight: Radius.circular(13),
          bottomLeft: Radius.circular(13),
        ),
        border: Border(
          top: BorderSide(color: AppTheme.border),
          right: BorderSide(color: AppTheme.border),
          bottom: BorderSide(color: AppTheme.border),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(13),
            bottomLeft: Radius.circular(13),
          ),
          border: Border(
            left: BorderSide(
              color: statusColor,
              width: 3,
            ),
          ),
        ),
        child: Column(
          children: [
            _buildTradeHeader(statusColor, statusBgColor),
            if (trade.status == 'open') _buildProfitTakeSection(),
            if (trade.closeTrade != null && isExpanded) _buildCloseTradeSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTradeHeader(Color statusColor, Color statusBgColor) {
    return InkWell(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: statusBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  trade.coverDisplay,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${trade.coverLabel} · ${trade.openTrade.description}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        DateFormat('HH:mm:ss').format(trade.openTrade.createdAt),
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.text3,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: trade.openTrade.fillStatus == 'filled' 
                              ? AppTheme.greenDim 
                              : const Color(0x0DFFFFFF),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          trade.openTrade.fillStatus,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: trade.openTrade.fillStatus == 'filled' 
                                ? AppTheme.green 
                                : AppTheme.text3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  AppTheme.formatPrice(trade.openTrade.price),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.text,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${trade.openTrade.qty} qty · ${AppTheme.formatCurrency(trade.openTrade.amount)}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.text3,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfitTakeSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.border)),
        color: AppTheme.bg3,
      ),
      child: Row(
        children: [
          const Text(
            'Profit take',
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.text3,
            ),
          ),
          const SizedBox(width: 6),
          if (trade.pendingTp != null)
            Text(
              'Waiting · TP @ ${AppTheme.formatPrice(trade.pendingTp!.targetPrice)}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.amber,
                fontFamily: 'monospace',
              ),
            )
          else if (trade.profit != null)
            Text(
              '+${AppTheme.formatCurrency(trade.profit!)} · @${AppTheme.formatPercentage(trade.profitPct!)}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.green,
                fontFamily: 'monospace',
              ),
            )
          else
            const Text(
              '---',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.text3,
                fontFamily: 'monospace',
              ),
            ),
          const Spacer(),
          if (trade.closeTrade != null)
            TextButton.icon(
              onPressed: onToggle,
              icon: Icon(
                isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                size: 10,
                color: AppTheme.blue,
              ),
              label: const Text(
                'Close trade',
                style: TextStyle(
                  fontSize: 10,
                  color: AppTheme.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCloseTradeSection() {
    if (trade.closeTrade == null) return const SizedBox.shrink();

    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.bg3,
            ),
            child: Row(
              children: [
                Container(
                  width: 1,
                  height: 14,
                  color: AppTheme.border2,
                  margin: const EdgeInsets.only(right: 8),
                ),
                Text(
                  'Held ${_formatDuration(trade.holdDuration)}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.text3,
                  ),
                ),
                const Spacer(),
                Text(
                  'closed @${AppTheme.formatPercentage(trade.profitPct!)} TP',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.text2,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppTheme.greenDim,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 14,
                    color: AppTheme.green,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trade.closeTrade!.description,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            DateFormat('HH:mm:ss').format(trade.closeTrade!.createdAt),
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppTheme.text3,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppTheme.greenDim,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Filled',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      AppTheme.formatPrice(trade.closeTrade!.price),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.green,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${trade.closeTrade!.qty} qty · ${AppTheme.formatCurrency(trade.closeTrade!.amount)}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppTheme.text3,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'open':
        return AppTheme.amber;
      case 'closed':
        return AppTheme.green;
      case 'cancelled':
        return AppTheme.text3;
      default:
        return AppTheme.text3;
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status) {
      case 'open':
        return AppTheme.amberDim;
      case 'closed':
        return AppTheme.greenDim;
      case 'cancelled':
        return const Color(0x0DFFFFFF);
      default:
        return const Color(0x0DFFFFFF);
    }
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '---';
    
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }
}
