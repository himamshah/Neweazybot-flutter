import 'package:flutter/material.dart';
import 'models/bot.dart';
import 'services/mock_api_service.dart';

class DebugTestScreen extends StatefulWidget {
  const DebugTestScreen({Key? key}) : super(key: key);

  @override
  State<DebugTestScreen> createState() => _DebugTestScreenState();
}

class _DebugTestScreenState extends State<DebugTestScreen> {
  List<Bot> bots = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await MockApiService.getBots();
      setState(() {
        bots = response.bots;
        isLoading = false;
      });
      print('DEBUG: Loaded ${bots.length} bots');
      for (final bot in bots) {
        print('DEBUG: Bot: ${bot.id} - ${bot.coin} - ${bot.status}');
      }
    } catch (e) {
      print('DEBUG: Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const CircularProgressIndicator()
            else
              Text('Loaded ${bots.length} bots'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Reload'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: bots.length,
                itemBuilder: (context, index) {
                  final bot = bots[index];
                  return ListTile(
                    title: Text(bot.coin),
                    subtitle: Text('ID: ${bot.id} - Status: ${bot.status}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
