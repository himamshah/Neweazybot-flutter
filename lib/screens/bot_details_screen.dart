import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/bot.dart';
import '../models/trade.dart';
import '../services/unified_api_service.dart';
import '../utils/app_theme.dart';

class BotDetailsScreen extends StatefulWidget {
  final Bot bot;

  const BotDetailsScreen({
    Key? key,
    required this.bot,
  }) : super(key: key);

  @override
  State<BotDetailsScreen> createState() => _BotDetailsScreenState();
}

class _BotDetailsScreenState extends State<BotDetailsScreen> {
  bool isLoading = false;
  bool isLoadingMore = false;
  String error = '';
  String selectedFilter = 'all';
  final Set<int> expandedTrades = {};
  Bot? botDetail;
  dynamic tradesMeta;
  int currentPage = 1;
  bool hasMore = false;
  List<Trade> trades = [];
  
  @override
  void initState() {
    super.initState();
    _loadBotDetails();
  }

  Future<void> _loadBotDetails({bool isLoadMore = false}) async {
    print('DEBUG: _loadBotDetails called for bot ${widget.bot.id}');
    if (isLoadMore) {
      setState(() {
        isLoadingMore = true;
      });
    } else {
      setState(() {
        isLoading = true;
        error = '';
        currentPage = 1;
        trades.clear();
      });
    }

    try {
      final response = await UnifiedApiService.getBotDetail(
        widget.bot.id,
        tradeStatus: selectedFilter,
        limit: 20,
        offset: (currentPage - 1) * 20,
      );
      
      setState(() {
        botDetail = response.bot;
        tradesMeta = response.tradesMeta;
        
        print('DEBUG: Bot ID: ${widget.bot.id}');
        print('DEBUG: Trades count: ${response.trades.length}');
        print('DEBUG: Trades data: ${response.trades}');
        
        for (int i = 0; i < response.trades.length; i++) {
          final trade = response.trades[i];
          print('DEBUG: Trade $i - group_id: ${trade.groupId}');
          print('DEBUG: Trade $i - status: ${trade.status}');
          print('DEBUG: Trade $i - open_trade: ${trade.openTrade}');
          print('DEBUG: Trade $i - close_trade: ${trade.closeTrade}');
          if (trade.openTrade != null) {
            print('DEBUG: Trade $i - open_trade status: ${trade.openTrade!.fillStatus}');
          }
          if (trade.closeTrade != null) {
            print('DEBUG: Trade $i - close_trade status: ${trade.closeTrade!.fillStatus}');
          }
        }
        
        if (isLoadMore) {
          trades.addAll(response.trades);
        } else {
          trades = response.trades;
        }
        
        hasMore = response.tradesMeta.hasMore;
        isLoading = false;
        isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
        isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMoreTrades() async {
    if (!isLoadingMore && hasMore) {
      currentPage++;
      await _loadBotDetails(isLoadMore: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    print('DEBUG: build() called for bot ${widget.bot.id}');
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
    final bot = botDetail ?? widget.bot;
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
          if (bot.status == 'running') _buildLiquidationBar(),
          _buildCapitalGrid(),
        ],
      ),
    );
  }

  Widget _buildHeaderTop() {
    final bot = botDetail ?? widget.bot;
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
                    bot.coinSymbol,
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
                    ),
                  ),
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

  Widget _buildStatusPill() {
    final bot = botDetail ?? widget.bot;
    final isRunning = bot.status == 'running';
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
    final bot = botDetail ?? widget.bot;
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildGridCell('Realized PnL', bot.pnl.realized),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppTheme.border,
          ),
          Expanded(
            child: _buildGridCell('Unrealized', bot.pnl.unrealized),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppTheme.border,
          ),
          Expanded(
            child: _buildGridCell('Net PnL', bot.pnl.net),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceGrid() {
    final bot = botDetail ?? widget.bot;
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.border)),
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
            height: 40,
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
    );
  }

  Widget _buildLiquidationBar() {
    final bot = botDetail ?? widget.bot;
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

  Widget _buildCapitalGrid() {
    final bot = botDetail ?? widget.bot;
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildCapitalCell('Assigned', bot.capital.assigned, 'total capital'),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppTheme.border,
          ),
          Expanded(
            child: _buildCapitalCell('Available', bot.capital.available, '${AppTheme.formatPercentage(bot.capital.availablePct)} free'),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppTheme.border,
          ),
          Expanded(
            child: _buildCapitalCell('In position', bot.capital.inPosition, '+${AppTheme.formatPercentage(bot.capital.growthPct)}'),
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
                    _loadBotDetails();
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
    print('DEBUG: _buildBody() called, isLoading: $isLoading, trades.length: ${trades.length}');
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
              onPressed: _loadBotDetails,
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

    return ListView.separated(
      padding: const EdgeInsets.all(14),
      itemCount: trades.length + (hasMore ? 1 : 0),
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        if (index == trades.length && hasMore) {
          // Show loading indicator at bottom
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(
                color: AppTheme.blue,
              ),
            ),
          );
        }
        
        final trade = trades[index];
        return _buildTradeCard(trade);
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

  Widget _buildTradeCard(Trade trade) {
    try {
      print('DEBUG: Building trade card for trade ${trade.groupId}');
      final isOpen = trade.status == 'open';
      final isClosed = trade.status == 'closed';
      final openTrade = trade.openTrade;
      print('DEBUG: openTrade is null: ${openTrade == null}');
      print('DEBUG: closeTrade is null: ${trade.closeTrade == null}');
      final isCancelled = openTrade != null && openTrade.fillStatus == 'CANCELLED';
      print('DEBUG: isCancelled: $isCancelled');
    
    Color borderColor;
    Color numberColor;
    Color numberBg;
    
    if (isCancelled) {
      borderColor = AppTheme.text3;
      numberColor = AppTheme.text3;
      numberBg = const Color(0x0DFFFFFF);
    } else if (isOpen) {
      borderColor = AppTheme.amber;
      numberColor = AppTheme.amber;
      numberBg = AppTheme.amberDim;
    } else {
      borderColor = AppTheme.green;
      numberColor = AppTheme.red;
      numberBg = AppTheme.redDim;
    }

    final isExpanded = expandedTrades.contains(trade.groupId);
    
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bg2,
        border: Border(
          top: BorderSide(color: AppTheme.border),
          right: BorderSide(color: AppTheme.border),
          bottom: BorderSide(color: AppTheme.border),
          left: BorderSide(
            color: borderColor,
            width: 3,
          ),
        ),
      ),
      child: Column(
        children: [
          // Main trade info
          InkWell(
            onTap: () {
              if (isClosed && trade.closeTrade != null) {
                setState(() {
                  if (isExpanded) {
                    expandedTrades.remove(trade.groupId);
                  } else {
                    expandedTrades.add(trade.groupId);
                  }
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Trade number
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: numberBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        trade.coverLabel == 'Initial order' ? 'INI' : 
                        trade.coverLabel.replaceAll('Cover ', 'C'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: numberColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  
                  // Trade details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          openTrade?.description ?? 'Trade',
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
                              DateFormat('HH:mm:ss').format(openTrade?.createdAt ?? DateTime.now()),
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
                                color: isCancelled ? const Color(0x0DFFFFFF) : AppTheme.greenDim,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isCancelled ? 'Cancelled' : 'Filled',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: isCancelled ? AppTheme.text3 : AppTheme.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Price and quantity
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        AppTheme.formatPrice(openTrade?.price ?? 0.0),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isCancelled ? AppTheme.text3 : AppTheme.text,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${openTrade?.qty.toString() ?? '0'} qty · ${AppTheme.formatCurrency(openTrade?.amount ?? 0.0)}',
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
          ),
          
          // Profit take section
          Container(
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
                Expanded(
                  child: Text(
                    _getProfitTakeText(trade),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _getProfitTakeColor(trade),
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                if (isClosed && trade.closeTrade != null)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        if (isExpanded) {
                          expandedTrades.remove(trade.groupId);
                        } else {
                          expandedTrades.add(trade.groupId);
                        }
                      });
                    },
                    icon: Icon(
                      isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      size: 14,
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
          ),
          
          // Expanded close trade details
          if (isExpanded && trade.closeTrade != null)
            _buildCloseTradeDetails(trade),
        ],
      ),
    );
    } catch (e, stackTrace) {
      print('ERROR: Exception in _buildTradeCard for trade ${trade.groupId}: $e');
      print('ERROR: Stack trace: $stackTrace');
      print('ERROR: Trade data: $trade');
      
      // Return a fallback widget to prevent crashes
      return Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppTheme.bg2,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: AppTheme.red),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Error displaying trade ${trade.groupId}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.red,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Status: ${trade.status}',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.text3,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildCloseTradeDetails(Trade trade) {
    try {
      final closeTrade = trade.closeTrade;
      final holdDuration = trade.holdDurationSeconds;
      print('DEBUG: Building close trade details for trade ${trade.groupId}');
      print('DEBUG: closeTrade is null: ${closeTrade == null}');
      print('DEBUG: closeTrade status: ${closeTrade?.fillStatus}');
    
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: Column(
        children: [
          // Hold duration and close info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            color: AppTheme.bg3,
            child: Row(
              children: [
                Container(
                  width: 1,
                  height: 14,
                  color: AppTheme.border2,
                  margin: const EdgeInsets.only(right: 8),
                ),
                Text(
                  'Held ${_formatDuration(holdDuration)}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.text3,
                  ),
                ),
                const Spacer(),
                Text(
                  'closed @${trade.profitPct}% TP',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.text2,
                  ),
                ),
              ],
            ),
          ),
          
          // Close trade details
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
                        closeTrade?.description ?? 'Close trade',
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
                            DateFormat('HH:mm:ss').format(closeTrade?.createdAt ?? DateTime.now()),
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
                      AppTheme.formatPrice(closeTrade?.price ?? 0.0),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.green,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${closeTrade?.qty.toString() ?? '0'} qty · ${AppTheme.formatCurrency(closeTrade?.amount ?? 0.0)}',
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
    } catch (e, stackTrace) {
      print('ERROR: Exception in _buildCloseTradeDetails for trade ${trade.groupId}: $e');
      print('ERROR: Stack trace: $stackTrace');
      
      // Return a fallback widget to prevent crashes
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.red)),
        ),
        child: Text(
          'Error displaying close trade details',
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.red,
          ),
        ),
      );
    }
  }

  String _getProfitTakeText(Trade trade) {
    final openTrade = trade.openTrade;
    if (openTrade != null && openTrade.fillStatus == 'CANCELLED') {
      return '— order cancelled';
    } else if (trade.status == 'open') {
      return 'Waiting · TP @ ${AppTheme.formatPrice(trade.pendingTp?.targetPrice ?? 0.0)}';
    } else if (trade.status == 'closed') {
      final profit = trade.profit ?? 0.0;
      final profitPct = trade.profitPct ?? 0.0;
      return '${profit > 0 ? '+' : ''}${AppTheme.formatCurrency(profit)} · @${profitPct.toStringAsFixed(0)}%';
    }
    return '—';
  }

  Color _getProfitTakeColor(Trade trade) {
    final openTrade = trade.openTrade;
    if (openTrade != null && openTrade.fillStatus == 'CANCELLED') {
      return AppTheme.text3;
    } else if (trade.status == 'open') {
      return AppTheme.amber;
    } else if (trade.status == 'closed') {
      final profit = trade.profit ?? 0.0;
      return profit > 0 ? AppTheme.green : AppTheme.red;
    }
    return AppTheme.text3;
  }

  String _formatDuration(int? seconds) {
    if (seconds == null) return '—';
    
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${secs}s';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }
}
