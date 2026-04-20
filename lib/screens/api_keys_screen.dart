import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/api_key.dart';
import '../services/api_service.dart';
import '../utils/app_theme.dart';

class ApiKeysScreen extends StatefulWidget {
  const ApiKeysScreen({Key? key}) : super(key: key);

  @override
  State<ApiKeysScreen> createState() => _ApiKeysScreenState();
}

class _ApiKeysScreenState extends State<ApiKeysScreen> {
  List<ApiKey> apiKeys = [];
  bool isLoading = false;
  bool isCreating = false;
  String error = '';
  bool showAddForm = false;

  // Form controllers
  final _nameController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _apiSecretController = TextEditingController();
  String selectedEnvironment = 'SANDBOX';
  int selectedExchangeId = 1; // Default to Binance
  
  // Available exchanges
  final List<Map<String, dynamic>> availableExchanges = [
    {'id': 1, 'name': 'Binance'},
    {'id': 2, 'name': 'CoinDCX'},
  ];

  @override
  void initState() {
    super.initState();
    _loadApiKeys();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _apiKeyController.dispose();
    _apiSecretController.dispose();
    super.dispose();
  }

  Future<void> _loadApiKeys() async {
    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      final response = await ApiService.getApiKeys();
      setState(() {
        apiKeys = response.apiKeys;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load API keys: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<void> _createApiKey() async {
    final name = _nameController.text.trim();
    final apiKey = _apiKeyController.text.trim();
    final apiSecret = _apiSecretController.text.trim();

    if (name.isEmpty || apiKey.isEmpty || apiSecret.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }

    setState(() {
      isCreating = true;
    });

    try {
      final request = CreateApiKeyRequest(
        name: name,
        environment: selectedEnvironment,
        apiKey: apiKey,
        apiSecret: apiSecret,
        exchangeId: selectedExchangeId,
      );

      await ApiService.createApiKey(request);
      
      _showSuccess('API key created successfully!');
      _clearForm();
      _loadApiKeys();
    } catch (e) {
      _showError('Failed to create API key: ${e.toString()}');
    } finally {
      setState(() {
        isCreating = false;
      });
    }
  }

  Future<void> _deleteApiKey(int apiKeyId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.bg2,
        title: const Text(
          'Delete API Key',
          style: TextStyle(color: AppTheme.text),
        ),
        content: const Text(
          'Are you sure you want to delete this API key? This action cannot be undone.',
          style: TextStyle(color: AppTheme.text2),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.text2)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: AppTheme.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ApiService.deleteApiKey(apiKeyId);
      _showSuccess('API key deleted successfully');
      _loadApiKeys();
    } catch (e) {
      _showError('Failed to delete API key: ${e.toString()}');
    }
  }

  void _clearForm() {
    _nameController.clear();
    _apiKeyController.clear();
    _apiSecretController.clear();
    setState(() {
      showAddForm = false;
      selectedEnvironment = 'SANDBOX';
      selectedExchangeId = 1; // Reset to Binance
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.green,
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    _showSuccess('Copied to clipboard!');
  }

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
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back,
              size: 16,
              color: AppTheme.blue,
            ),
            label: const Text(
              'Account',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Spacer(),
          Expanded(
            child: Text(
              'Exchange API keys',
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.text,
              ),
            ),
          ),
          const Spacer(),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.blue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.add, size: 13, color: Colors.white),
              onPressed: () => setState(() => showAddForm = !showAddForm),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          _buildInfoBanner(),
          const SizedBox(height: 12),
          if (!showAddForm) _buildAddKeyButton(),
          if (showAddForm) _buildAddKeyForm(),
          if (isLoading) ...[
            const Center(
              child: CircularProgressIndicator(color: AppTheme.blue),
            ),
          ] else if (error.isNotEmpty) ...[
            _buildErrorWidget(),
          ] else if (apiKeys.isEmpty && !showAddForm) ...[
            _buildEmptyState(),
          ] else ...[
            ...apiKeys.map((apiKey) => _buildApiKeyCard(apiKey)),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppTheme.blueDim,
        border: Border.all(color: AppTheme.blue.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: AppTheme.blue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Use read + trade permissions only. Never enable withdrawals. Keys are encrypted at rest.',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.blue,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddKeyButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton.icon(
        onPressed: () => setState(() => showAddForm = true),
        icon: const Icon(Icons.add, size: 18),
        label: const Text(
          'Add New API Key',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          shadowColor: AppTheme.blue.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildAddKeyForm() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.bg2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormHeader(),
          _buildFormField('KEY LABEL', 'e.g. Main trading key', _nameController),
          _buildFormField('API KEY', 'Paste your API key', _apiKeyController, isMono: true),
          _buildSecretField(),
          _buildExchangeSelector(),
          _buildEnvironmentSelector(),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildFormHeader() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          Icon(Icons.add_circle_outline, size: 14, color: AppTheme.teal),
          const SizedBox(width: 8),
          const Text(
            'Add new API key',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.teal,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _clearForm,
            child: Icon(Icons.close, size: 16, color: AppTheme.text3),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField(String label, String placeholder, TextEditingController controller, {bool isMono = false}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.text3,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.text,
              fontFamily: isMono ? 'monospace' : null,
              letterSpacing: isMono ? 0.5 : null,
            ),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: const TextStyle(color: AppTheme.text3),
              filled: true,
              fillColor: AppTheme.bg3,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppTheme.border2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppTheme.border2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppTheme.blue, width: 0.4),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecretField() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SECRET KEY',
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.text3,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _apiSecretController,
                  obscureText: true,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.text,
                    fontFamily: 'monospace',
                    letterSpacing: 0.5,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Paste your secret',
                    hintStyle: const TextStyle(color: AppTheme.text3),
                    filled: true,
                    fillColor: AppTheme.bg3,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppTheme.border2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppTheme.border2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppTheme.blue, width: 0.4),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.visibility_outlined, size: 16, color: AppTheme.text3),
                onPressed: () {
                  // Toggle password visibility would need state management
                },
                padding: const EdgeInsets.all(4),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExchangeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
          child: const Text(
            'EXCHANGE',
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.text3,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppTheme.border)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: selectedExchangeId,
              isExpanded: true,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.text,
              ),
              dropdownColor: AppTheme.bg3,
              items: availableExchanges.map((exchange) {
                return DropdownMenuItem<int>(
                  value: exchange['id'] as int,
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppTheme.bg4,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppTheme.border2),
                        ),
                        child: Center(
                          child: Text(
                            _getExchangeLogoById(exchange['id'] as int),
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              color: _getExchangeColorById(exchange['id'] as int),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        exchange['name'] as String,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.text,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedExchangeId = value;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  String _getExchangeLogoById(int exchangeId) {
    switch (exchangeId) {
      case 1:
        return 'BNB'; // Binance
      case 2:
        return 'DCX'; // CoinDCX
      default:
        return 'EXC';
    }
  }

  Color _getExchangeColorById(int exchangeId) {
    switch (exchangeId) {
      case 1:
        return const Color(0xFFF0B90B); // Binance yellow
      case 2:
        return const Color(0xFF00D4AA); // CoinDCX green
      default:
        return AppTheme.blue;
    }
  }

  Widget _buildEnvironmentSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
          child: const Text(
            'ENVIRONMENT',
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.text3,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppTheme.border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => selectedEnvironment = 'LIVE'),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: selectedEnvironment == 'LIVE' ? AppTheme.blueDim : AppTheme.bg3,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selectedEnvironment == 'LIVE' ? AppTheme.blue.withOpacity(0.3) : AppTheme.border2,
                      ),
                    ),
                    child: Text(
                      'Live',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: selectedEnvironment == 'LIVE' ? AppTheme.blue : AppTheme.text3,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => selectedEnvironment = 'SANDBOX'),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: selectedEnvironment == 'SANDBOX' ? AppTheme.blueDim : AppTheme.bg3,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selectedEnvironment == 'SANDBOX' ? AppTheme.blue.withOpacity(0.3) : AppTheme.border2,
                      ),
                    ),
                    child: Text(
                      'Testnet',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: selectedEnvironment == 'SANDBOX' ? AppTheme.blue : AppTheme.text3,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(10, 10, 10, 8),
          child: ElevatedButton(
            onPressed: isCreating ? null : _createApiKey,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.tealDim,
              foregroundColor: AppTheme.teal,
              padding: const EdgeInsets.all(11),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: AppTheme.teal.withOpacity(0.3)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isCreating)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.teal),
                  )
                else
                  const Icon(Icons.trending_up, size: 14),
                const SizedBox(width: 7),
                Text(
                  isCreating ? 'Creating...' : 'Test connection',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(10, 0, 10, 14),
          child: ElevatedButton(
            onPressed: isCreating ? null : _createApiKey,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
              ),
              elevation: 4,
              shadowColor: AppTheme.blue.withOpacity(0.25),
            ),
            child: Text(
              isCreating ? 'Creating...' : 'Save API key',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildApiKeyCard(ApiKey apiKey) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.bg2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Left colored border indicator - curved and status-based
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 3,
                decoration: BoxDecoration(
                  color: apiKey.isActive ? const Color(0xFF00E676) : AppTheme.text3,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.only(left: 6, top: 1, right: 1, bottom: 1),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.bg2,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                ),
                child: Column(
                  children: [
                    _buildKeyHeader(apiKey),
                    _buildKeyBody(apiKey),
                    _buildKeyFooter(apiKey),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyHeader(ApiKey apiKey) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.bg4,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.border2),
            ),
            child: Center(
              child: Text(
                _getExchangeLogo(apiKey.exchange),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: _getExchangeColor(apiKey.exchange),
                  letterSpacing: -0.3,
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
                  apiKey.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.text,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  '${apiKey.exchange.name} · Futures',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.text3,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: apiKey.isActive ? AppTheme.greenDim : AppTheme.bg3.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: apiKey.isActive ? AppTheme.green : AppTheme.text3,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  apiKey.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: apiKey.isActive ? AppTheme.green : AppTheme.text3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyBody(ApiKey apiKey) {
    return Column(
      children: [
        _buildPermissions(),
        _buildKeyRow('API key', apiKey.maskedKey, apiKey.maskedKey),
        _buildKeyRow('Environment', apiKey.environment, null),
        _buildKeyRow('Bots using this key', '3 active', null),
        _buildKeyRow('Added', _formatDate(apiKey.createdAt), null),
      ],
    );
  }

  Widget _buildPermissions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Wrap(
        alignment: WrapAlignment.start,
        spacing: 6,
        children: [
          _buildPermissionTag('Read', AppTheme.blueDim, AppTheme.blue),
          _buildPermissionTag('Futures trade', AppTheme.greenDim, AppTheme.green),
          _buildPermissionTag('No withdraw', AppTheme.redDim, AppTheme.red),
        ],
      ),
    );
  }

  Widget _buildPermissionTag(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildKeyRow(String label, String value, String? copyValue) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.text3,
            ),
          ),
          const Spacer(),
          if (copyValue != null)
            Row(
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.text2,
                    fontFamily: 'monospace',
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _copyToClipboard(copyValue),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.copy, size: 12, color: AppTheme.blue),
                      const SizedBox(width: 5),
                      const Text(
                        'Copy',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: value == 'LIVE' ? AppTheme.green : AppTheme.text2,
                fontFamily: 'monospace',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildKeyFooter(ApiKey apiKey) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.bg3,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => _showError('Test connection not implemented'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
                side: const BorderSide(color: AppTheme.border2),
                backgroundColor: AppTheme.bg4,
                foregroundColor: AppTheme.text2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Test connection',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _showError('Edit label not implemented'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
                side: const BorderSide(color: AppTheme.border2),
                backgroundColor: AppTheme.bg4,
                foregroundColor: AppTheme.text2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Edit label',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _deleteApiKey(apiKey.id),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
                side: BorderSide(color: AppTheme.red.withOpacity(0.2)),
                backgroundColor: AppTheme.redDim,
                foregroundColor: AppTheme.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Delete',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: AppTheme.red),
          const SizedBox(height: 16),
          Text(
            'Error loading API keys',
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
            onPressed: _loadApiKeys,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(Icons.vpn_key_outlined, size: 48, color: AppTheme.text3),
          const SizedBox(height: 16),
          Text(
            'No API keys found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first API key to start trading',
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
          _buildTabItem(Icons.trending_up, 'Bots', false),
          _buildTabItem(Icons.receipt_long, 'Trades', false),
          _buildTabItem(Icons.person, 'Account', true),
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

  String _getExchangeLogo(Exchange exchange) {
    switch (exchange.id) {
      case 1:
        return 'BNB'; // Binance
      case 2:
        return 'DCX'; // CoinDCX
      default:
        return exchange.name.substring(0, 3).toUpperCase();
    }
  }

  Color _getExchangeColor(Exchange exchange) {
    switch (exchange.id) {
      case 1:
        return const Color(0xFFF0B90B); // Binance yellow
      case 2:
        return const Color(0xFF00D4AA); // CoinDCX green
      default:
        return AppTheme.blue;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
