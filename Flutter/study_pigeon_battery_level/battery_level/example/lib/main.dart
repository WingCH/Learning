import 'package:flutter/material.dart';
import 'package:battery_level/battery_level.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Battery Level Demo',
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

  @override
  void initState() {
    super.initState();
    _getBatteryInfo();
  }

  Future<void> _getBatteryInfo() async {
    setState(() => _isLoading = true);

    try {
      final level = await BatteryLevel.getBatteryLevel();
      final state = await BatteryLevel.getBatteryState();

      setState(() {
        _batteryLevel = level;
        _batteryState = state;
      });
    } catch (e) {
      debugPrint('Failed to get battery info: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getStateText(BatteryState state) {
    switch (state) {
      case BatteryState.charging:
        return 'Charging ⚡';
      case BatteryState.discharging:
        return 'Discharging 🔋';
      case BatteryState.full:
        return 'Full ✅';
      case BatteryState.unknown:
        return 'Unknown ❓';
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
        title: const Text('Battery Level Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.battery_std, size: 100, color: _getBatteryColor()),
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
