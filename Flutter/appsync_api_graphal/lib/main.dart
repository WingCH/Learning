import 'dart:async';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

import 'amplifyconfiguration.dart';

//AWS AppSync console: https://us-west-1.console.aws.amazon.com/appsync/home?region=us-west-1#/ow5ukem53jhr3f6mv2y4vuioa4/v1/schema
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String coinTickerResult = '';
  String topNft = '';

  @override
  void initState() {
    super.initState();
    _configureAmplify();
  }

  Future<void> _configureAmplify() async {
    final api = AmplifyAPI();
    await Amplify.addPlugin(api);

    try {
      await Amplify.configure(amplifyconfig);
      _getCoinTicker();
      _getTopNft();
    } on AmplifyAlreadyConfiguredException catch (error) {
      print('AmplifyAlreadyConfiguredException: $error');
    }
  }

  void _getCoinTicker() async {
    // https://docs.amplify.aws/guides/api-graphql/subscriptions-by-id/q/platform/flutter/
    const graphQLDocument = r'''
      subscription sub($channelName: String!) {
          subscribe(name: $channelName) {
            name
            data
          }
      }
    ''';
    final Stream<GraphQLResponse<String>> operation = Amplify.API.subscribe(
      GraphQLRequest<String>(
        document: graphQLDocument,
        variables: <String, String>{'channelName': 'coinTicker'},
      ),
      onEstablished: () => print('Subscription established'),
    );

    try {
      await for (var event in operation) {
        print('Subscription event data received: ${event.data}');
        setState(() {
          coinTickerResult = event.data ?? '';
        });
      }
    } on Exception catch (e) {
      print('Error in subscription stream: $e');
    }
  }

  void _getTopNft() async {
    // https://docs.amplify.aws/guides/api-graphql/subscriptions-by-id/q/platform/flutter/
    const graphQLDocument = r'''
      subscription sub($channelName: String!) {
          subscribe(name: $channelName) {
            name
            data
          }
      }
    ''';
    final Stream<GraphQLResponse<String>> operation = Amplify.API.subscribe(
      GraphQLRequest<String>(
        document: graphQLDocument,
        variables: <String, String>{'channelName': 'topNft'},
      ),
      onEstablished: () => print('Subscription established'),
    );

    try {
      await for (var event in operation) {
        print('Subscription event data received: ${event.data}');
        setState(() {
          topNft = event.data ?? '';
        });
      }
    } on Exception catch (e) {
      print('Error in subscription stream: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appsync Api GraphQL Demo'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                Text('coinTicker',
                    style: Theme.of(context).textTheme.headline6),
                Expanded(
                  child: coinTickerResult.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : Text(coinTickerResult),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: Column(
              children: [
                Text('topNft', style: Theme.of(context).textTheme.headline6),
                Expanded(
                  child: topNft.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : Text(topNft),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
