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
  List<Bot> filteredBots = [];
  bool isLoading = false;
  bool isLoadingMore = false;
  String error = '';
  String selectedFilter = 'all';
  String userName = '';
  String searchQuery = '';
  
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
  
  // Performance optimization: Cache for loaded data
  Map<String, List<Bot>> _botsCache = {};
  Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(minutes: 5);
  
  // Search controller
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadBots();
  }

  @override
  void didUpdateWidget(BotsListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refresh data when returning to this screen to ensure consistency
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBots(forceRefresh: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    final user = await AuthService.getCurrentUser();
    if (user != null) {
      setState(() {
        userName = user.name;
      });
    }
  }

  
  Future<void> _loadBots({bool isLoadMore = false, bool forceRefresh = false}) async {
    final cacheKey = '${selectedFilter}_${currentPage}';
    final now = DateTime.now();
    
    // Check cache first (only for initial load, not pagination)
    if (!isLoadMore && !forceRefresh && _botsCache.containsKey(cacheKey)) {
      final cacheTime = _cacheTimestamps[cacheKey] ?? DateTime.now();
      if (now.difference(cacheTime) < _cacheExpiry) {
        final cachedBots = _botsCache[cacheKey]!;
        setState(() {
          bots = cachedBots;
          // Apply search filter only if search query exists
          if (searchQuery.isNotEmpty) {
            filteredBots = cachedBots.where((bot) =>
              bot.coin.toLowerCase().contains(searchQuery.toLowerCase()) ||
              bot.exchange.toLowerCase().contains(searchQuery.toLowerCase()) ||
              bot.direction.toLowerCase().contains(searchQuery.toLowerCase())
            ).toList();
          } else {
            filteredBots = List.from(cachedBots);
          }
          isLoading = false;
          error = '';
        });
        return;
      }
    }

    if (isLoadMore) {
      setState(() {
        isLoadingMore = true;
      });
    } else {
      setState(() {
        isLoading = true;
        error = '';
        if (!forceRefresh) {
          currentPage = 0;
          bots.clear();
        }
      });
    }

    try {
      final response = await UnifiedApiService.getBots(
        status: selectedFilter,
        sortBy: 'created_at',
        sortOrder: 'desc',
        limit: pageSize,
        offset: currentPage * pageSize,
      ).timeout(const Duration(seconds: 15)); // Add timeout
      
      setState(() {
        if (isLoadMore) {
          bots.addAll(response.bots);
        } else {
          bots = response.bots;
          // Cache the results
          _botsCache[cacheKey] = response.bots;
          _cacheTimestamps[cacheKey] = now;
        }
        
        // Apply search filter only if search query exists
        if (searchQuery.isNotEmpty) {
          _filterBots();
        } else {
          filteredBots = List.from(bots);
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
      // Handle authentication errors
      if (e.toString().contains('Session expired') || e.toString().contains('Unauthenticated')) {
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
                InkWell(
                  onTap: _handleProfile,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.bg3,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Row(
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.text2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              _buildNavButton(Icons.refresh, false, () => _loadBots(forceRefresh: true)),
              const SizedBox(width: 8),
              _buildNavButton(Icons.search_outlined, false, _showSearchDialog),
              const SizedBox(width: 8),
              _buildNavButton(Icons.add, true),
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
      child: Center(
        child: Wrap(
          spacing: 8,
          children: filters.map((filter) {
            final isActive = selectedFilter == filter['value'];
            
            // Use stored filter totals instead of counting from current bots list
            final displayCount = filterTotals[filter['value']] ?? 0;
            
            // Debug logging for counters
            print('COUNTER DEBUG: Filter ${filter['label']} (${filter['value']}) count: $displayCount (loaded: ${bots.length}, current filter total: $totalCount)');
            
            return Container(
              decoration: BoxDecoration(
                color: isActive ? AppTheme.blueDim : AppTheme.bg3,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.border),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    final previousFilter = selectedFilter;
                    setState(() {
                      selectedFilter = filter['value']!;
                      // Clear search query when switching filters to prevent interference
                      searchQuery = '';
                      _searchController.clear();
                    });
                    // Force refresh when filter changes to ensure fresh data
                    _loadBots(forceRefresh: previousFilter != filter['value']);
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Text(
                      '${filter['label']} ($displayCount)',
                      style: TextStyle(
                        color: isActive ? AppTheme.blue : AppTheme.text2,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading && bots.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppTheme.blue,
              strokeWidth: 2,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading bots...',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.text2,
              ),
            ),
          ],
        ),
      );
    }

    if (error.isNotEmpty && bots.isEmpty) {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _loadBots,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () => _loadBots(forceRefresh: true),
                  child: const Text('Force Refresh'),
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (filteredBots.isEmpty) {
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
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _navigateToCreateBot,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Create Bot'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (isLoading && filteredBots.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: AppTheme.blue,
                    strokeWidth: 2,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Refreshing...',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.text2,
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: NotificationListener<ScrollNotification>(
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
              itemCount: filteredBots.length + (hasMore ? 1 : 0),
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                if (index == filteredBots.length && hasMore) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: AppTheme.blue,
                              strokeWidth: 2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Loading more...',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.text2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                final bot = filteredBots[index];
                return BotCard(
                  bot: bot,
                  onViewTrades: () => _navigateToBotTrades(bot),
                  onRestart: bot.status == 'stopped' ? () => _restartBot(bot) : null,
                  onSettings: () => _showBotSettings(bot),
                  onTap: () => _navigateToBotTrades(bot),
                );
              },
            ),
          ),
        ),
      ],
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
    final bool isBotsTab = label == 'Bots';

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: isBotsTab && isActive 
            ? Border(left: BorderSide(color: AppTheme.green, width: 3))
            : null,
        ),
        child: InkWell(
          onTap: () => _handleTabNavigation(label),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
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
          ),
        ),
      ),
    );
  }

  void _handleTabNavigation(String tabLabel) {
    switch (tabLabel) {
      case 'Dashboard':
        // Navigate to Dashboard (could be the same screen or a separate one)
        // For now, we'll stay on the current screen as it's the main dashboard
        break;
      case 'Bots':
        // Already on Bots screen, no navigation needed
        break;
      case 'Trades':
        // Navigate to Trades screen (to be implemented)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Trades screen coming soon!'),
            backgroundColor: AppTheme.blue,
          ),
        );
        break;
      case 'Account':
        _handleProfile();
        break;
    }
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

  void _filterBots() {
    setState(() {
      if (searchQuery.isEmpty) {
        filteredBots = List.from(bots);
      } else {
        filteredBots = bots.where((bot) =>
          bot.coin.toLowerCase().contains(searchQuery.toLowerCase()) ||
          bot.exchange.toLowerCase().contains(searchQuery.toLowerCase()) ||
          bot.direction.toLowerCase().contains(searchQuery.toLowerCase())
        ).toList();
      }
    });
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Bots'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Enter bot name or strategy...',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                searchQuery = _searchController.text;
              });
              _filterBots();
              Navigator.of(context).pop();
            },
            child: const Text('Search'),
          ),
        ],
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
