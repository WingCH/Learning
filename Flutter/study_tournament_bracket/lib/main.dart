/// 錦標賽對陣圖 App 入口
library;

import 'package:flutter/material.dart';

import 'features/tournament_bracket/models/mock_data_generator.dart';
import 'features/tournament_bracket/widgets/tournament_bracket_view.dart';

void main() {
  runApp(const TournamentBracketApp());
}

/// 錦標賽對陣圖應用
class TournamentBracketApp extends StatelessWidget {
  const TournamentBracketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '錦標賽對陣圖',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const TournamentBracketPage(),
    );
  }
}

/// 錦標賽對陣圖頁面
class TournamentBracketPage extends StatelessWidget {
  const TournamentBracketPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 使用 Mock 資料產生器建立測試資料
    final bracket = MockDataGenerator.generate8TeamBracket();

    return Scaffold(
      appBar: AppBar(
        title: Text(bracket.name),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(child: TournamentBracketView(bracket: bracket)),
    );
  }
}
