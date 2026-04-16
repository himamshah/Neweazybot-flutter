import 'package:flutter/material.dart';
import '../models/bot.dart';
import '../services/unified_api_service.dart';
import '../services/auth_service.dart';
import '../widgets/bot_card.dart';
import '../utils/app_theme.dart';
import 'create_bot_screen.dart';
import 'bot_details_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';

class BotsListScreen extends StatefulWidget {
  const BotsListScreen({Key? key}) : super(key: key);

  @override
  State<BotsListScreen> createState() => _BotsListScreenState();
}

class _BotsListScreenState extends State<BotsListScreen> {
  List<Bot> bots = [];
  bool isLoading = false;
  bool isLoadingMore = false;
  String error = '';
  String selectedFilter = 'all';
  String userName = '';
  
  // Pagination variables
  int currentPage = 0;
  int totalCount = 0;
  bool hasMore = false;
  final int pageSize = 20;
  
  // Separate total counts for each filter
  Map<String, int> filterTotals = {
    'all': 0,
    'running': 0,
    'paused': 0,
    'closed': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadBots();
  }

  Future<void> _loadUserInfo() async {
    final user = await AuthService.getCurrentUser();
    if (user != null) {
      setState(() {
        userName = user.name;
      });
    }
  }

  
  Future<void> _loadBots({bool isLoadMore = false}) async {
    if (isLoadMore) {
      setState(() {
        isLoadingMore = true;
      });
    } else {
      setState(() {
        isLoading = true;
        error = '';
        currentPage = 0;
        bots.clear();
      });
    }

    try {
      print('DEBUG: Starting to load bots with filter: $selectedFilter');
      print('DEBUG: Using mock data: ${UnifiedApiService.useMockData}');
      print('DEBUG: Page: $currentPage, Offset: ${currentPage * pageSize}, Limit: $pageSize');
      
      final response = await UnifiedApiService.getBots(
        status: selectedFilter,
        sortBy: 'created_at',
        sortOrder: 'desc',
        limit: pageSize,
        offset: currentPage * pageSize,
      );
      
      print('DEBUG: Successfully loaded ${response.bots.length} bots');
      print('DEBUG: Total bots: ${response.meta.total}, Has more: ${response.meta.hasMore}');
      
      setState(() {
        if (isLoadMore) {
          bots.addAll(response.bots);
        } else {
          bots = response.bots;
        }
        
        // Extract all filter counts from API response
        filterTotals['all'] = response.meta.allCount ?? 0;
        filterTotals['running'] = response.meta.runningCount ?? 0;
        filterTotals['paused'] = response.meta.pausedCount ?? 0;
        filterTotals['closed'] = response.meta.closedCount ?? 0;
        
        totalCount = response.meta.total ?? 0;
        hasMore = response.meta.hasMore ?? false;
        isLoading = false;
        isLoadingMore = false;
      });
    } catch (e, stackTrace) {
      print('ERROR: Failed to load bots: $e');
      print('ERROR: Stack trace: $stackTrace');
      print('ERROR: Error type: ${e.runtimeType}');
      
      // Handle authentication errors
      if (e.toString().contains('Session expired') || e.toString().contains('Unauthenticated')) {
        print('ERROR: Authentication error, redirecting to login');
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
        return;
      }
      
      setState(() {
        error = 'Failed to load bots: ${e.toString()}';
        isLoading = false;
        isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMoreBots() async {
    if (!isLoadingMore && hasMore) {
      currentPage++;
      await _loadBots(isLoadMore: true);
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
              if (userName.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.bg3,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 16,
                        color: AppTheme.text2,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.text2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(width: 8),
              _buildNavButton(Icons.search_outlined, false),
              const SizedBox(width: 8),
              _buildNavButton(Icons.add, true),
              const SizedBox(width: 8),
              _buildNavButton(Icons.person_outline, false, _handleProfile),
              const SizedBox(width: 8),
              _buildNavButton(Icons.logout_outlined, false, _handleLogout),
            ],
          ),
        ],
      ),
    );
  }

  void _handleProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  }

  Widget _buildNavButton(IconData icon, bool isPrimary, [VoidCallback? onPressed]) {
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
        onPressed: onPressed ?? (isPrimary ? _navigateToCreateBot : null),
        padding: EdgeInsets.zero,
        color: isPrimary ? Colors.white : AppTheme.text2,
      ),
    );
  }

  Future<void> _handleLogout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _clearTokenAndReload() async {
    await AuthService.clearAllData();
    setState(() {
      error = 'All data cleared. Please login again with fresh credentials.';
      bots = [];
    });
  }

  Widget _buildFilterBar() {
    final filters = [
      {'label': 'All', 'value': 'all'},
      {'label': 'Running', 'value': 'running'},
      {'label': 'Paused', 'value': 'paused'},
      {'label': 'Closed', 'value': 'closed'},
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
            
            // Use stored filter totals instead of counting from current bots list
            final displayCount = filterTotals[filter['value']] ?? 0;
            
            // Debug logging for counters
            print('COUNTER DEBUG: Filter ${filter['label']} (${filter['value']}) count: $displayCount (loaded: ${bots.length}, current filter total: $totalCount)');
            
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text('${filter['label']} ($displayCount)'),
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

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent && 
            !isLoadingMore && 
            hasMore) {
          _loadMoreBots();
        }
        return false;
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(14),
        itemCount: bots.length + (hasMore ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index == bots.length && hasMore) {
            // Show loading indicator at the bottom
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(
                  color: AppTheme.blue,
                ),
              ),
            );
          }
          
          final bot = bots[index];
          return BotCard(
            bot: bot,
            onViewTrades: () => _navigateToBotTrades(bot),
            onRestart: bot.status == 'stopped' ? () => _restartBot(bot) : null,
            onSettings: () => _showBotSettings(bot),
          );
        },
      ),
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
        builder: (context) => BotDetailsScreen(bot: bot),
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
