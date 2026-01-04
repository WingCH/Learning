// Copyright 2024 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:battery_level_ios/battery_level_ios.dart';
import 'package:battery_level_platform_interface/battery_level_platform_interface.dart';

void main() {
  // Register the iOS implementation
  BatteryLevelIOS.registerWith();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Battery Level iOS Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const BatteryHomePage(),
    );
  }
}

class BatteryHomePage extends StatefulWidget {
  const BatteryHomePage({super.key});

  @override
  State<BatteryHomePage> createState() => _BatteryHomePageState();
}

class _BatteryHomePageState extends State<BatteryHomePage> {
  int _batteryLevel = -1;
  BatteryState _batteryState = BatteryState.unknown;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _getBatteryInfo();
  }

  Future<void> _getBatteryInfo() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final level = await BatteryLevelPlatform.instance.getBatteryLevel();
      final state = await BatteryLevelPlatform.instance.getBatteryState();

      setState(() {
        _batteryLevel = level;
        _batteryState = state;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to get battery info: $e';
      });
      debugPrint(_errorMessage);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getStateText(BatteryState state) {
    switch (state) {
      case BatteryState.charging:
        return 'Charging';
      case BatteryState.discharging:
        return 'Discharging';
      case BatteryState.full:
        return 'Full';
      case BatteryState.unknown:
        return 'Unknown';
    }
  }

  IconData _getStateIcon(BatteryState state) {
    switch (state) {
      case BatteryState.charging:
        return Icons.battery_charging_full;
      case BatteryState.discharging:
        return Icons.battery_std;
      case BatteryState.full:
        return Icons.battery_full;
      case BatteryState.unknown:
        return Icons.battery_unknown;
    }
  }

  Color _getBatteryColor() {
    if (_batteryLevel < 0) return Colors.grey;
    if (_batteryLevel <= 20) return Colors.red;
    if (_batteryLevel <= 50) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Battery Level iOS'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _errorMessage != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _getBatteryInfo,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getStateIcon(_batteryState),
                    size: 100,
                    color: _getBatteryColor(),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _batteryLevel >= 0 ? '$_batteryLevel%' : 'N/A',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: _getBatteryColor(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _getStateText(_batteryState),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Platform: iOS',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 40),
                  FilledButton.icon(
                    onPressed: _getBatteryInfo,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
      ),
    );
  }
}
