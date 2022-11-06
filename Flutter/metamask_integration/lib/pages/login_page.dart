import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? _uri;
  SessionStatus? _session;
  WCSessionUpdateResponse? _payload;

  void loginUsingMetamask(BuildContext context) async {
    // since `killSession` is not work in `walletconnect_dart: ^0.0.11`
    // so we need always create new connector to make sure we have a new session
    // https://github.com/RootSoft/walletconnect-dart-sdk/issues/78
    // https://github.com/RootSoft/walletconnect-dart-sdk/issues/17
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
    try {
      var session = await connector.createSession(
        onDisplayUri: (uri) async {
          // e.g: wc:6fabddfa-5353-4011-8f08-f458f4f877bf@1?bridge=https%3A%2F%2Ft.bridge.walletconnect.org&key=a00825511cb421c5e6c9f4a4f9142797a0667a96516a82293a2adf7513a5b441
          _uri = uri;

          // trustwallet, https://link.trustwallet.com.
          // https://developer.trustwallet.com/deeplinking#connect-to-a-walletconnect-session
          // e.g: https://link.trustwallet.com/wc?uri=wc%3A0c1773eb-33d5-4e10-96ce-61ecca6469e6%401%3Fbridge%3Dhttps%253A%252F%252Fs.bridge.walletconnect.org%26key%3D5d6d84b2fb06829f38fb5f5d2e23f96e361bbf895f1d896a9cfbf8b38fed32c3
          // tested in iOS and Android, both works
          final trustWalletUri = Uri.https('link.trustwallet.com', 'wc', {'uri': uri});
          print('[debug] trustWalletUri: $trustWalletUri');

          // metamask, https://metamask.app.link
          // https://github.com/WalletConnect/walletconnect-monorepo/issues/647
          // e.g:  https://metamask.app.link/wc?uri=wc%3A1c7b2142-8fe4-4e32-b619-4cb1bbc9ac31%401%3Fbridge%3Dhttps%253A%252F%252F6.bridge.walletconnect.org%26key%3Da4265e07a7ba0d39ff6c41e2a9177de1a3cbef7ea77c9f33fd8746effa5ba6a7
          // tested in iOS and Android, both works
          final metamaskUri = Uri.https('metamask.app.link', 'wc', {'uri': uri});

          // other way
          // metamask, work in ios and android
          // metamask://wc?uri=wc%3A75fc02ac-b8a0-4761-91f7-5addfb414f3d%401%3Fbridge%3Dhttps%253A%252F%252Fu.bridge.walletconnect
          final metamaskUri2 = 'metamask://wc?uri=$uri';

          // trustwallet, not work in ios and android (can open app, but not auth popup)
          final trustWalletUri2 = 'trust://wc?uri=$uri';

          // exodus, not work in android and ios (can open app, but not auth popup)
          final exodusWalletUri = 'exodus://wc?uri=$uri';

          // crypto.com defi wallet, not work in android and ios (can open app, but not auth popup)
          // ios first time not have popup , second time have,
          // android not work (can open app, but not auth popup)
          final cryptoComWalletUri = 'dfw://wc?uri=$uri';

          await launchUrlString(
            metamaskUri.toString(),
            mode: LaunchMode.externalApplication,
          );
        },
      );

      print('[debug] received session: $session');
      setState(() {
        _session = session;
      });
      print('[debug] killSession');
      connector.killSession();
    } catch (exp) {
      print('[debug] catch error: $exp');
    }
  }

  @override
  void initState() {
    super.initState();
    // connector.on<SessionStatus>(
    //   'connect',
    //   (session) {
    //     print('[debug][subscription] `connect` received session: $session');
    //     setState(() {
    //       _session = session;
    //     });
    //   },
    // );
    // connector.on<WCSessionUpdateResponse>(
    //   'session_update',
    //   (payload) {
    //     print('[debug][subscription]  `session_update` received session: $payload');
    //     setState(() {
    //       _payload = payload;
    //     });
    //   },
    // );
    // connector.on<SessionStatus>(
    //   'disconnect',
    //   (session) {
    //     print('[debug][subscription]  `disconnect` received session: $session');
    //     setState(() {
    //       _session = session;
    //     });
    //   },
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/main_page_image.png',
                fit: BoxFit.fitHeight,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Uri:',
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              Text('$_uri'),
              ElevatedButton(
                onPressed: () => loginUsingMetamask(context),
                child: const Text("Connect with Metamask"),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Session:',
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              Text('$_session'),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Payload:',
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              Text('$_payload'),
              TextButton(
                onPressed: () {
                  setState(() {
                    _session = null;
                  });
                },
                child: const Text('Clear Session'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
