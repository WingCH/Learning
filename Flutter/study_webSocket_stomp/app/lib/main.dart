import 'package:flutter/material.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

// Constants for STOMP connection
class StompSettings {
  // Connection parameters
  static const String webSocketUrl = 'ws://localhost:15674/ws';
  static const String username = 'admin';
  static const String password = 'admin';

  // Different channel types to test
  static const String topicExchangePath =
      '/exchange/amq.topic/flutter.messages';
  static const String directExchangePath =
      '/exchange/amq.direct/flutter.direct';
  static const String queuePath = '/queue/flutter.queue';
  static const String topicPath = '/topic/flutter.topic';

  // Headers
  static const Map<String, String> connectHeaders = {
    'login': username,
    'passcode': password,
  };

  static const Map<String, String> contentHeaders = {
    'content-type': 'text/plain'
  };
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'STOMP WebSocket Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const StompPage(),
    );
  }
}

class StompPage extends StatefulWidget {
  const StompPage({super.key});

  @override
  State<StompPage> createState() => _StompPageState();
}

class _StompPageState extends State<StompPage> {
  StompClient? stompClient;
  bool isConnected = false;
  Map<String, List<String>> channelMessages = {
    'topic': [],
    'direct': [],
    'queue': [],
    'simple-topic': [],
  };

  final TextEditingController messageController = TextEditingController();
  String selectedChannel = 'topic'; // Default to topic exchange

  @override
  void initState() {
    super.initState();
    _setupStompClient();
  }

  @override
  void dispose() {
    stompClient?.deactivate();
    messageController.dispose();
    super.dispose();
  }

  void _setupStompClient() {
    stompClient = StompClient(
      config: StompConfig(
        url: StompSettings.webSocketUrl,
        onConnect: onConnect,
        onWebSocketError: _handleWebSocketError,
        onStompError: _handleStompError,
        onDisconnect: _handleDisconnect,
        stompConnectHeaders: StompSettings.connectHeaders,
        webSocketConnectHeaders: StompSettings.connectHeaders,
      ),
    );
  }

  // Error handling functions
  void _handleWebSocketError(dynamic error) {
    print('WebSocket Error: ${error.toString()}');
    _setDisconnected();
  }

  void _handleStompError(StompFrame frame) {
    print('STOMP Error: ${frame.body}');
    _setDisconnected();
  }

  void _handleDisconnect(StompFrame frame) {
    print('STOMP Disconnected: ${frame.body}');
    _setDisconnected();
  }

  void _setDisconnected() {
    setState(() {
      isConnected = false;
    });
  }

  void onConnect(StompFrame frame) {
    print('STOMP Connected successfully! ${frame.body}');
    setState(() {
      isConnected = true;
      channelMessages = {
        'topic': [],
        'direct': [],
        'queue': [],
        'simple-topic': [],
      };
    });

    // Subscribe to topic exchange
    print('Subscribing to topic exchange: ${StompSettings.topicExchangePath}');
    stompClient?.subscribe(
      destination: StompSettings.topicExchangePath,
      callback: (StompFrame frame) {
        _handleMessage(frame, 'topic');
      },
    );

    // Subscribe to direct exchange
    print(
        'Subscribing to direct exchange: ${StompSettings.directExchangePath}');
    stompClient?.subscribe(
      destination: StompSettings.directExchangePath,
      callback: (StompFrame frame) {
        _handleMessage(frame, 'direct');
      },
    );

    // Subscribe to queue
    print('Subscribing to queue: ${StompSettings.queuePath}');
    stompClient?.subscribe(
      destination: StompSettings.queuePath,
      callback: (StompFrame frame) {
        _handleMessage(frame, 'queue');
      },
    );

    // Subscribe to simple topic
    print('Subscribing to simple topic: ${StompSettings.topicPath}');
    stompClient?.subscribe(
      destination: StompSettings.topicPath,
      callback: (StompFrame frame) {
        _handleMessage(frame, 'simple-topic');
      },
    );

    print('All subscriptions successful');
  }

  void _handleMessage(StompFrame frame, String channel) {
    print('Message received on $channel: ${frame.body}');
    if (frame.body != null) {
      setState(() {
        channelMessages[channel]?.add(frame.body!);
      });
    }
  }

  void connect() {
    print('Attempting to connect to ${StompSettings.webSocketUrl}...');
    try {
      stompClient?.activate();
    } catch (e) {
      print('Connection error: $e');
      _setDisconnected();
    }
  }

  void disconnect() {
    stompClient?.deactivate();
    _setDisconnected();
  }

  void sendMessage() {
    if (isConnected && messageController.text.isNotEmpty) {
      final message = messageController.text;
      final timestamp = DateTime.now().toString();
      final fullMessage = '[Flutter $timestamp] $message';

      String destination;
      switch (selectedChannel) {
        case 'topic':
          destination = StompSettings.topicExchangePath;
          break;
        case 'direct':
          destination = StompSettings.directExchangePath;
          break;
        case 'queue':
          destination = StompSettings.queuePath;
          break;
        case 'simple-topic':
          destination = StompSettings.topicPath;
          break;
        default:
          destination = StompSettings.topicExchangePath;
      }

      print('Sending message to $destination: $fullMessage');

      try {
        stompClient?.send(
          destination: destination,
          body: fullMessage,
          headers: StompSettings.contentHeaders,
        );
        print('Message sent');

        messageController.clear();
      } catch (e) {
        print('Error sending message: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('STOMP WebSocket Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildConnectionControls(),
            const SizedBox(height: 20),
            _buildChannelSelector(),
            const SizedBox(height: 10),
            _buildMessageInput(),
            const SizedBox(height: 20),
            const Text('Received Messages:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildMessagesDisplay(),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionControls() {
    return Row(
      children: [
        ElevatedButton(
          onPressed: isConnected ? null : connect,
          child: const Text('Connect'),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: isConnected ? disconnect : null,
          child: const Text('Disconnect'),
        ),
        const SizedBox(width: 10),
        Text(
          isConnected ? 'Connected' : 'Not Connected',
          style: TextStyle(
            color: isConnected ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildChannelSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select channel to send message:',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          children: [
            _buildChannelOption('topic', 'AMQ.TOPIC'),
            _buildChannelOption('direct', 'AMQ.DIRECT'),
            _buildChannelOption('queue', 'QUEUE'),
            _buildChannelOption('simple-topic', 'TOPIC'),
          ],
        ),
      ],
    );
  }

  Widget _buildChannelOption(String value, String label) {
    final isSelected = selectedChannel == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: isConnected
          ? (bool selected) {
              setState(() {
                selectedChannel = value;
              });
            }
          : null,
      backgroundColor: Colors.grey[200],
      selectedColor: Colors.deepPurple[100],
    );
  }

  Widget _buildMessageInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: messageController,
            decoration: const InputDecoration(
              hintText: 'Enter message...',
              border: OutlineInputBorder(),
            ),
            enabled: isConnected,
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: isConnected ? sendMessage : null,
          child: const Text('Send'),
        ),
      ],
    );
  }

  Widget _buildMessagesDisplay() {
    return Expanded(
      child: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            Container(
              constraints: const BoxConstraints(maxHeight: 35),
              child: const TabBar(
                tabs: [
                  Tab(text: 'AMQ.TOPIC'),
                  Tab(text: 'AMQ.DIRECT'),
                  Tab(text: 'QUEUE'),
                  Tab(text: 'TOPIC'),
                ],
                labelColor: Colors.deepPurple,
                dividerColor: Colors.grey,
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildMessagesTab(channelMessages['topic'] ?? []),
                  _buildMessagesTab(channelMessages['direct'] ?? []),
                  _buildMessagesTab(channelMessages['queue'] ?? []),
                  _buildMessagesTab(channelMessages['simple-topic'] ?? []),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesTab(List<String> messages) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: messages.isEmpty
          ? const Center(child: Text('No messages received'))
          : ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(messages[index]),
                );
              },
            ),
    );
  }
}
