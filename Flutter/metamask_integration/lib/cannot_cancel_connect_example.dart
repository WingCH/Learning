import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';

// https://github.com/RootSoft/walletconnect-dart-sdk/issues/84
void main(List<String> args) {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final WalletConnect connector = WalletConnect(
    bridge: 'https://bridge.walletconnect.org',
    clientMeta: const PeerMeta(
      name: 'My App',
      // if description is null, trust wallet (iOS 7.20 (691)) will not show the connection request
      description: 'An app for converting pictures to NFT',
      url: 'https://walletconnect.org',
      icons: ['https://files.gitbook.com/v0/b/gitbook-legacy-files/o/spaces%2F-LJJeCjcLrr53DcT1Ml7%2Favatar.png?alt=media'],
    ),
  );

  void getAddresses() async {
    try {
      var session = await connector.createSession(
        onDisplayUri: (uri) async {
          final result = await launchUrlString(
            uri.toString(),
            mode: LaunchMode.externalApplication,
          );
          print('[debug] launchUrlString: $result');
        },
      );
      print('[debug] received session: ${session.accounts}');
    } catch (e) {
      print('[debug] catched error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: getAddresses,
              child: const Text('Get Addresses'),
            ),
            TextButton(
              onPressed: () async {
                // not working
                await connector.killSession();
              },
              child: const Text('Disconnect wallet'),
            ),
          ],
        ),
      ),
    );
  }
}
