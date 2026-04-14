import 'package:flutter/material.dart';
import '../models/bot.dart';
import '../services/unified_api_service.dart';
import '../widgets/bot_card.dart';
import '../utils/app_theme.dart';
import 'create_bot_screen.dart';
import 'bot_trades_screen.dart';

class BotsListScreen extends StatefulWidget {
  const BotsListScreen({Key? key}) : super(key: key);

  @override
  State<BotsListScreen> createState() => _BotsListScreenState();
}

class _BotsListScreenState extends State<BotsListScreen> {
  List<Bot> bots = [];
  bool isLoading = false;
  String error = '';
  String selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadBots();
  }

  Future<void> _loadBots() async {
    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      final response = await UnifiedApiService.getBots(
        status: selectedFilter,
        sortBy: 'created_at',
        sortOrder: 'desc',
      );
      
      setState(() {
        bots = response.bots;
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
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: const BoxDecoration(
        color: AppTheme.bg2,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          const Text(
            'My bots',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.text,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              _buildApiToggle(),
              const SizedBox(width: 8),
              _buildNavButton(Icons.search_outlined, false),
              const SizedBox(width: 8),
              _buildNavButton(Icons.add, true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApiToggle() {
    final isMock = UnifiedApiService.useMockData;
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: isMock ? AppTheme.greenDim : AppTheme.blueDim,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isMock ? AppTheme.green : AppTheme.blue),
      ),
      child: IconButton(
        icon: Icon(isMock ? Icons.data_object : Icons.cloud, size: 14),
        onPressed: () {
          setState(() {
            UnifiedApiService.useMockData = !isMock;
          });
          _loadBots(); // Reload data with new API setting
        },
        padding: EdgeInsets.zero,
        color: isMock ? AppTheme.green : AppTheme.blue,
      ),
    );
  }

  Widget _buildNavButton(IconData icon, bool isPrimary) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: isPrimary ? AppTheme.blue : AppTheme.bg3,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isPrimary ? AppTheme.blue : AppTheme.border2),
      ),
      child: IconButton(
        icon: Icon(icon, size: 14),
        onPressed: isPrimary ? _navigateToCreateBot : null,
        padding: EdgeInsets.zero,
        color: isPrimary ? Colors.white : AppTheme.text2,
      ),
    );
  }

  Widget _buildFilterBar() {
    final filters = [
      {'label': 'All', 'value': 'all'},
      {'label': 'Running', 'value': 'running'},
      {'label': 'Stopped', 'value': 'stopped'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: AppTheme.bg2,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isActive = selectedFilter == filter['value'];
            final count = bots.where((bot) => 
              filter['value'] == 'all' || bot.status == filter['value']
            ).length;
            
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text('${filter['label']} ($count)'),
                selected: isActive,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      selectedFilter = filter['value']!;
                    });
                    _loadBots();
                  }
                },
                backgroundColor: AppTheme.bg3,
                selectedColor: AppTheme.blueDim,
                labelStyle: TextStyle(
                  color: isActive ? AppTheme.blue : AppTheme.text2,
                  fontSize: 12,
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
              'Error loading bots',
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
              onPressed: _loadBots,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (bots.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_graph_outlined,
              size: 48,
              color: AppTheme.text3,
            ),
            const SizedBox(height: 16),
            Text(
              'No bots found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first trading bot to get started',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.text2,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(14),
      itemCount: bots.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final bot = bots[index];
        return BotCard(
          bot: bot,
          onViewTrades: () => _navigateToBotTrades(bot),
          onRestart: bot.status == 'stopped' ? () => _restartBot(bot) : null,
          onSettings: () => _showBotSettings(bot),
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

  void _navigateToCreateBot() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateBotScreen(),
      ),
    );
  }

  void _navigateToBotTrades(Bot bot) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BotTradesScreen(bot: bot),
      ),
    );
  }

  void _restartBot(Bot bot) {
    // TODO: Implement restart functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Restarting bot ${bot.coin}...'),
        backgroundColor: AppTheme.green,
      ),
    );
  }

  void _showBotSettings(Bot bot) {
    // TODO: Implement bot settings
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Settings for ${bot.coin}'),
        backgroundColor: AppTheme.blue,
      ),
    );
  }
}
