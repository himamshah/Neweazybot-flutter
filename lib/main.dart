import 'package:flutter/material.dart';
import 'utils/app_theme.dart';
import 'screens/bots_list_screen.dart';

void main() {
  runApp(const EasyBotApp());
}

class EasyBotApp extends StatelessWidget {
  const EasyBotApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EasyBot',
      theme: AppTheme.darkTheme,
      home: const BotsListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
