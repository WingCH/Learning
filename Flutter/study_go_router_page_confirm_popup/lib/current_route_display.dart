import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CurrentRouteDisplay extends StatefulWidget {
  final GoRouter router;
  
  const CurrentRouteDisplay({super.key, required this.router});

  @override
  State<CurrentRouteDisplay> createState() => _CurrentRouteDisplayState();
}

class _CurrentRouteDisplayState extends State<CurrentRouteDisplay> {
  String _currentRoute = '/';
  List<String> _routeStack = ['/'];
  
  @override
  void initState() {
    super.initState();
    // Listen to route changes
    widget.router.routerDelegate.addListener(_updateRoute);
    _updateRoute();
  }
  
  @override
  void dispose() {
    widget.router.routerDelegate.removeListener(_updateRoute);
    super.dispose();
  }
  
  void _updateRoute() {
    final List<RouteMatch> matches = widget.router.routerDelegate.currentConfiguration.matches;
    
    if (matches.isNotEmpty) {
      setState(() {
        _currentRoute = matches.last.matchedLocation;
        
        // Get all routes in the stack
        _routeStack = matches.map((match) {
          return match.matchedLocation;
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Current Route: $_currentRoute',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          const Text(
            'Route Stack:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          ...List.generate(_routeStack.length, (index) {
            return Padding(
              padding: EdgeInsets.only(left: 8.0 * (index + 1)),
              child: Text('${index + 1}. ${_routeStack[index]}', style: const TextStyle(fontSize: 12)),
            );
          }),
        ],
      ),
    );
  }
}
