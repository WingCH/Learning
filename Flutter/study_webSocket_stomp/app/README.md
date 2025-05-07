# Flutter WebSocket STOMP Client Example

This Flutter application demonstrates how to connect to a RabbitMQ server using WebSocket and STOMP protocol.

## Features

- Connect and disconnect from STOMP WebSocket
- Send messages to a specified topic
- Receive messages from the subscribed topic
- Clean user interface showing connection status and messages

## Setup Instructions

### 1. Start the RabbitMQ Server

In the `server` folder at the project root, run the following command to start the RabbitMQ server:

```bash
cd ../server
docker-compose up -d
```

This will start a RabbitMQ server with the STOMP plugin enabled.

### 2. Run the Flutter Application

In the `app` directory, run the following command to start the Flutter application:

```bash
# If using fvm (Flutter Version Management)
fvm flutter run -d chrome

# Or directly using flutter command
flutter run -d chrome
```

> Note: It's recommended to run this example in Chrome since WebSocket connections require network access.

## Connection Details

The application uses the following parameters to connect to the RabbitMQ STOMP service:

- WebSocket URL: `ws://localhost:15674/ws`
- Credentials: `admin` / `admin`
- Subscription topic: `/exchange/amq.topic/flutter.messages`
- Publishing topic: `/exchange/amq.topic/flutter.messages`

## Common Issues

1. **Unable to connect to WebSocket**
   - Ensure the RabbitMQ server is running
   - Check if your firewall settings allow WebSocket traffic
   - Try accessing the RabbitMQ management interface (http://localhost:15672) to confirm the server is running properly

2. **Connected but not receiving messages**
   - Verify that you're subscribing to the correct topic
   - Check if other clients are publishing messages to the same topic

## Technical Details

This example uses the following Flutter packages:

- `stomp_dart_client`: For STOMP protocol communication
- `web_socket_channel`: For WebSocket connection support
