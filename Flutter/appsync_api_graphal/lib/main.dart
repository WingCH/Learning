import 'dart:async';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

import 'amplifyconfiguration.dart';
import 'models/ModelProvider.dart';

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
  // StreamSubscription<GraphQLResponse<Channel>>? subscription;

  @override
  void initState() {
    super.initState();
    _configureAmplify();
  }

  Future<void> _configureAmplify() async {
    final api = AmplifyAPI(modelProvider: ModelProvider.instance);
    await Amplify.addPlugin(api);

    try {
      await Amplify.configure(amplifyconfig);

      // try {
      //   final channel = Channel(name: 'channel', data: "{\"msg\": \"hello world!\"}");
      //   final request = ModelMutations.create(channel);
      //   final response = await Amplify.API.mutate(request: request).response;
      //
      //   final createdTodo = response.data;
      //   if (createdTodo == null) {
      //     print('errors: ${response.errors}');
      //     return;
      //   }
      //   print('Mutation result: ${createdTodo.name}');
      // } on ApiException catch (e) {
      //   print('Mutation failed: $e');
      // }

      // final subscriptionRequest = ModelSubscriptions.onCreate(Channel.classType);
      // final Stream<GraphQLResponse<Channel>> operation = Amplify.API.subscribe(
      //   subscriptionRequest,
      //   onEstablished: () {
      //     print('Subscription established');
      //   },
      // );
      // subscription =  operation.listen(
      //       (event) {
      //     print('Subscription event data received: ${event.data}');
      //   },
      //   onError: (Object e) {
      //     print('Error in subscription stream: $e');
      //   },
      // );

      // https://docs.amplify.aws/guides/api-graphql/subscriptions-by-id/q/platform/flutter/
      const graphQLDocument = r'''
      subscription SubscribeToData {
          subscribe(name:"channel") {
            name
            data
          }
      }
    ''';
      final Stream<GraphQLResponse<String>> operation = Amplify.API.subscribe(
        GraphQLRequest<String>(
          document: graphQLDocument,
          // variables: <String, String>{'channelName': 'channel'},
        ),
        onEstablished: () => print('Subscription established'),
      );

      try {
        await for (var event in operation) {
          print('Subscription event data received: ${event.data}');
        }
      } on Exception catch (e) {
        print('Error in subscription stream: $e');
      }
    } on AmplifyAlreadyConfiguredException catch (error) {
      print('AmplifyAlreadyConfiguredException: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appsync Api GraphQL Demo'),
      ),
      body: const Center(
        child: Text('Hello World'),
      ),
    );
  }
}
