import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> languages = [];

  @override
  void initState() {
    super.initState();
    fetch();
  }

  Future<void> fetch() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      languages = prefs.getStringList('AppleLanguages') ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             Text('AppleLanguages', style: Theme.of(context).textTheme.titleSmall,),
            for (var language in languages) Text(language),
          ],
        ),
      ),
    );
  }
}
