import 'package:flutter/material.dart';
import '../models/create_bot.dart';
import '../services/unified_api_service.dart';
import '../utils/app_theme.dart';

class CreateBotScreen extends StatefulWidget {
  const CreateBotScreen({Key? key}) : super(key: key);

  @override
  State<CreateBotScreen> createState() => _CreateBotScreenState();
}

class _CreateBotScreenState extends State<CreateBotScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _error = '';

  // Bot Details
  String _selectedExchange = '';
  int _selectedApiKey = 0; // Changed to int for exchange_key_id
  String _selectedTradingPair = '';
  int _selectedPreset = 0; // 0 for Custom, 1 for Conservative, 2 for Aggressive
  double _botCapital = 1000.0;
  double _initialSizePct = 5.0;

  // Configuration
  String _direction = 'short';
  double? _triggerPrice;
  double _takeProfitPct = 1.5;
  bool _cycleContinuous = false;
  bool _autoCompounding = false;

  // Risk Management
  double _netProfitPct = 1.2;
  double _stopLossPct = 1.0;

  // Cover Settings
  List<Cover> _covers = [
    Cover(coverNumber: 1, dropdownPct: 1.0, takeProfitPct: 2.0, qtyMultiplier: 1.0, basePrice: 'previous_order'),
    Cover(coverNumber: 2, dropdownPct: 1.0, takeProfitPct: 2.0, qtyMultiplier: 1.0, basePrice: 'previous_order'),
    Cover(coverNumber: 3, dropdownPct: 1.0, takeProfitPct: 2.0, qtyMultiplier: 1.0, basePrice: 'previous_order'),
    Cover(coverNumber: 4, dropdownPct: 1.0, takeProfitPct: 2.0, qtyMultiplier: 1.0, basePrice: 'previous_order'),
    Cover(coverNumber: 5, dropdownPct: 1.0, takeProfitPct: 2.0, qtyMultiplier: 1.0, basePrice: 'previous_order'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildNavBar(),
            Expanded(
              child: _buildBody(),
            ),
            _buildFooter(),
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
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppTheme.blueDim,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.trending_up,
                  size: 15,
                  color: AppTheme.blue,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Create trading bot',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.text,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildBotDetailsSection(),
            const SizedBox(height: 12),
            _buildConfigurationSection(),
            const SizedBox(height: 12),
            _buildRiskSection(),
            const SizedBox(height: 12),
            _buildCoverSection(),
            if (_error.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildErrorWidget(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBotDetailsSection() {
    return _buildSection(
      title: 'Bot details',
      icon: Icons.description,
      children: [
        _buildFieldRow('Exchange', _selectedExchange.isEmpty ? 'Select exchange' : _selectedExchange, () => _showExchangeSelector()),
        _buildFieldRow('API key', _selectedApiKey == 0 ? 'Select API key' : 'API Key $_selectedApiKey', () => _showApiKeySelector()),
        _buildHint('Masked key · environment aware'),
        _buildFieldRow('Trading pair', _selectedTradingPair.isEmpty ? 'Select symbol' : _selectedTradingPair, () => _showTradingPairSelector()),
        _buildFieldRow('Preset', _getPresetName(_selectedPreset), () => _showPresetSelector()),
        _buildTwoColumnRow(
          'Bot capital',
          _botCapital.toStringAsFixed(0),
          'Initial size %',
          _initialSizePct.toStringAsFixed(1),
          () => _showBotCapitalDialog(),
          () => _showInitialSizeDialog(),
        ),
      ],
    );
  }

  Widget _buildConfigurationSection() {
    return _buildSection(
      title: 'Bot configuration',
      icon: Icons.settings,
      children: [
        _buildFieldRow('Direction', _direction, () => _showDirectionSelector()),
        _buildFieldRow('Trigger price', _triggerPrice?.toStringAsFixed(6) ?? 'Optional', () => _showTriggerPriceDialog()),
        _buildFieldRow('Take profit %', '${_takeProfitPct.toStringAsFixed(1)}%', () => _showTakeProfitDialog()),
        _buildToggleRow('Cycle continuous mode', _cycleContinuous, (value) => setState(() => _cycleContinuous = value)),
        _buildToggleRow('Auto compounding', _autoCompounding, (value) => setState(() => _autoCompounding = value)),
      ],
    );
  }

  Widget _buildRiskSection() {
    return _buildSection(
      title: 'Risk management',
      icon: Icons.security,
      children: [
        _buildTwoColumnRow(
          'Net profit %',
          _netProfitPct.toStringAsFixed(1),
          'Stop loss %',
          _stopLossPct.toStringAsFixed(1),
          () => _showNetProfitDialog(),
          () => _showStopLossDialog(),
        ),
      ],
    );
  }

  Widget _buildCoverSection() {
    return _buildSection(
      title: 'Cover settings',
      icon: Icons.table_chart,
      badge: '${_covers.length} covers',
      children: [
        _buildBulkApplySection(),
        _buildCoverTableHeader(),
        ...List.generate(_covers.length, (index) => _buildCoverRow(_covers[index], index)),
        _buildAddCoverButton(),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    String? badge,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bg2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.border)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 14, color: AppTheme.blue),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.blue,
                  ),
                ),
                if (badge != null) ...[
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.blueDim,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.blue,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildFieldRow(String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppTheme.border)),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.text2,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    color: value.contains('Select') || value.contains('Optional') ? AppTheme.text3 : AppTheme.text,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right, size: 12, color: AppTheme.text3),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 14, right: 14, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          color: AppTheme.text3,
        ),
      ),
    );
  }

  Widget _buildTwoColumnRow(
    String label1,
    String value1,
    String label2,
    String value2,
    VoidCallback onTap1,
    VoidCallback onTap2,
  ) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: onTap1,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppTheme.border), right: BorderSide(color: AppTheme.border)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label1,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.text2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value1,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.text,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: onTap2,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppTheme.border)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label2,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.text2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value2,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.text,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleRow(String label, bool value, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.text,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => onChanged(!value),
            child: Container(
              width: 40,
              height: 22,
              decoration: BoxDecoration(
                color: value ? AppTheme.blue : AppTheme.bg4,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: value ? AppTheme.blue : AppTheme.border2),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 150),
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 18,
                  height: 18,
                  margin: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulkApplySection() {
    return Container(
      margin: const EdgeInsets.all(14),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.tealDim,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 13, color: AppTheme.teal),
          const SizedBox(width: 8),
          const Text(
            'Bulk apply to multiple covers',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.teal,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.bg3,
        border: const Border(
          top: BorderSide(color: AppTheme.border),
          bottom: BorderSide(color: AppTheme.border),
        ),
      ),
      child: const Row(
        children: [
          SizedBox(width: 28),
          Expanded(child: Text('#', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppTheme.text3), textAlign: TextAlign.center)),
          Expanded(child: Text('Drop %', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppTheme.text3), textAlign: TextAlign.center)),
          Expanded(child: Text('TP %', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppTheme.text3), textAlign: TextAlign.center)),
          Expanded(child: Text('Qty ×', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppTheme.text3), textAlign: TextAlign.center)),
          SizedBox(width: 28),
        ],
      ),
    );
  }

  Widget _buildCoverRow(Cover cover, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: AppTheme.bg3,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: AppTheme.border2),
            ),
          ),
          Expanded(
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.text,
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              cover.dropdownPct.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.text,
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              cover.takeProfitPct.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.text,
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              cover.qtyMultiplier.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.text,
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.center,
            ),
          ),
          GestureDetector(
            onTap: () => _removeCover(index),
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: AppTheme.redDim,
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Icon(
                Icons.close,
                size: 9,
                color: AppTheme.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddCoverButton() {
    return InkWell(
      onTap: _addCover,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.border)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, size: 14, color: AppTheme.blue),
            const SizedBox(width: 6),
            const Text(
              'Add cover',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppTheme.bg2,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _createBot,
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow, size: 13),
                  SizedBox(width: 8),
                  Text('Start bot'),
                ],
              ),
      ),
    );
  }

  String _getPresetName(int presetId) {
    switch (presetId) {
      case 0:
        return 'Custom';
      case 1:
        return 'Conservative';
      case 2:
        return 'Aggressive';
      default:
        return 'Custom';
    }
  }

  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.redDim,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.red),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 16, color: AppTheme.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _error,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addCover() {
    setState(() {
      final newCoverNumber = _covers.isEmpty ? 1 : _covers.last.coverNumber + 1;
      _covers.add(Cover(
        coverNumber: newCoverNumber,
        dropdownPct: 1.0,
        takeProfitPct: 2.0,
        qtyMultiplier: 1.0,
        basePrice: 'previous_order',
      ));
    });
  }

  void _removeCover(int index) {
    if (_covers.length > 1) {
      setState(() {
        _covers.removeAt(index);
      });
    }
  }

  Future<void> _createBot() async {
    if (_selectedExchange.isEmpty || _selectedApiKey == 0 || _selectedTradingPair.isEmpty) {
      setState(() {
        _error = 'Please fill in all required fields';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      // Debug logging
      print('DEBUG: Creating bot with the following parameters:');
      print('DEBUG: Exchange: $_selectedExchange');
      print('DEBUG: API Key ID: $_selectedApiKey');
      print('DEBUG: Trading Pair: $_selectedTradingPair');
      print('DEBUG: Preset: $_selectedPreset');
      print('DEBUG: Bot Capital: $_botCapital');
      print('DEBUG: Initial Size %: $_initialSizePct');
      print('DEBUG: Direction: $_direction');
      print('DEBUG: Trigger Price: $_triggerPrice');
      print('DEBUG: Take Profit %: $_takeProfitPct');
      print('DEBUG: Net Profit %: $_netProfitPct');
      print('DEBUG: Stop Loss %: $_stopLossPct');
      print('DEBUG: Covers count: ${_covers.length}');

      // Validate all numeric values are not null
      if (_botCapital == null) {
        throw Exception('Bot capital cannot be null');
      }
      if (_initialSizePct == null) {
        throw Exception('Initial size percentage cannot be null');
      }
      if (_takeProfitPct == null) {
        throw Exception('Take profit percentage cannot be null');
      }
      if (_netProfitPct == null) {
        throw Exception('Net profit percentage cannot be null');
      }
      if (_stopLossPct == null) {
        throw Exception('Stop loss percentage cannot be null');
      }

      final request = CreateBotRequest(
        exchangeKeyId: _selectedApiKey,
        tradingPair: _selectedTradingPair,
        preset: _selectedPreset,
        botDetails: BotDetails(
          assignedCapital: _botCapital,
          initialSizePct: _initialSizePct,
        ),
        configuration: Configuration(
          direction: _direction,
          triggerPrice: _triggerPrice,
          takeProfitPct: _takeProfitPct,
          cycleContinuous: _cycleContinuous,
          autoCompounding: _autoCompounding,
        ),
        risk: Risk(
          netProfitPct: _netProfitPct,
          stopLossPct: _stopLossPct,
        ),
        covers: _covers,
      );

      print('DEBUG: Request JSON: ${request.toJson()}');

      final response = await UnifiedApiService.createBot(request);
      
      print('DEBUG: Bot created successfully: ${response.coin}');
      
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bot ${response.coin} created successfully!'),
            backgroundColor: AppTheme.green,
          ),
        );
      }
    } catch (e, stackTrace) {
      print('ERROR: Failed to create bot: $e');
      print('ERROR: Stack trace: $stackTrace');
      
      setState(() {
        _error = 'Failed to create bot: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // Dialog methods (simplified for demo)
  void _showExchangeSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Exchange'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Binance', 'Coinbase', 'Kraken'].map((exchange) {
            return ListTile(
              title: Text(exchange),
              onTap: () {
                setState(() => _selectedExchange = exchange);
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showApiKeySelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select API Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            {'id': 1, 'name': 'Binance API Key 1'},
            {'id': 2, 'name': 'Binance API Key 2'},
          ].map((keyData) {
            return ListTile(
              title: Text(keyData['name'] as String),
              subtitle: const Text('Masked key · environment aware'),
              onTap: () {
                setState(() => _selectedApiKey = keyData['id'] as int);
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showTradingPairSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Trading Pair'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['BTCUSDT', 'ETHUSDT', 'AINUSDT', 'AIOTUSDT'].map((pair) {
            return ListTile(
              title: Text(pair),
              onTap: () {
                setState(() => _selectedTradingPair = pair);
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showPresetSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Preset'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            {'id': 0, 'name': 'Custom'},
            {'id': 1, 'name': 'Conservative'},
            {'id': 2, 'name': 'Aggressive'},
          ].map((presetData) {
            return ListTile(
              title: Text(presetData['name'] as String),
              onTap: () {
                setState(() => _selectedPreset = presetData['id'] as int);
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showDirectionSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Direction'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['short', 'long', 'both'].map((direction) {
            return ListTile(
              title: Text(direction),
              onTap: () {
                setState(() => _direction = direction);
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showBotCapitalDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bot Capital'),
        content: TextField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Enter amount in USDT',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            final capital = double.tryParse(value);
            if (capital != null && capital > 0) {
              setState(() => _botCapital = capital);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showInitialSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Initial Size %'),
        content: TextField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Enter percentage',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            final size = double.tryParse(value);
            if (size != null && size > 0) {
              setState(() => _initialSizePct = size);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showTriggerPriceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Trigger Price (Optional)'),
        content: TextField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Enter trigger price',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            final price = double.tryParse(value);
            if (price != null && price > 0) {
              setState(() => _triggerPrice = price);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showTakeProfitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Take Profit %'),
        content: TextField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Enter percentage',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            final tp = double.tryParse(value);
            if (tp != null && tp > 0) {
              setState(() => _takeProfitPct = tp);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showNetProfitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Net Profit %'),
        content: TextField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Enter percentage',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            final profit = double.tryParse(value);
            if (profit != null && profit > 0) {
              setState(() => _netProfitPct = profit);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showStopLossDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stop Loss %'),
        content: TextField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Enter percentage',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            final loss = double.tryParse(value);
            if (loss != null && loss > 0) {
              setState(() => _stopLossPct = loss);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
