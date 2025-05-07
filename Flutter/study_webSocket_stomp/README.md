# Flutter WebSocket STOMP with RabbitMQ Integration

This project demonstrates how to integrate a Flutter application with RabbitMQ messaging broker using WebSocket and STOMP protocol for real-time communication.

## Project Structure

```
.
├── app/                # Flutter application
│   ├── lib/            # Flutter source code
│   ├── pubspec.yaml    # Flutter dependencies
│   └── README.md       # Flutter app documentation
└── server/             # RabbitMQ server configuration
    ├── docker-compose.yml  # Docker configuration
    ├── rabbitmq/      # RabbitMQ configuration
    └── test-stomp.html # Web client for testing
```

## How It Works

### Message Flow Architecture

1. **Client-to-Message Broker**: Both the Flutter application and the web client connect to RabbitMQ through WebSocket STOMP protocol.
2. **Message Publishing**: Clients can publish messages to specified exchanges and routing keys.
3. **Message Subscription**: Clients subscribe to exchanges/topics to receive messages.
4. **Message Routing**: RabbitMQ routes messages from publishers to subscribers based on the exchange type and routing keys.

### Technology Stack

- **RabbitMQ**: Message broker handling message queuing and routing
- **STOMP Protocol**: Simple text-oriented messaging protocol for client-server communication
- **WebSocket**: Protocol providing full-duplex communication channels over a single TCP connection
- **Flutter**: UI toolkit for building cross-platform applications
- **Docker**: Containerization platform for easy deployment of RabbitMQ

## Quick Start

### 1. Start RabbitMQ Server

```bash
cd server
docker-compose up -d
```

This starts a RabbitMQ instance with:
- Management UI: http://localhost:15672 (username: admin, password: admin)
- STOMP over WebSocket: ws://localhost:15674/ws
- STOMP over TCP: stomp://localhost:61613

### 2. Run Flutter Application

```bash
cd app
fvm flutter run -d chrome  # or flutter run -d chrome
```

### 3. Web Test Client

Open http://localhost:8000/test-stomp.html in a browser (after starting an HTTP server in the server directory with `python -m http.server 8000`).

## Features

- **Real-time Messaging**: Exchange messages in real-time between different clients
- **Persistent Connections**: Maintain WebSocket connections for efficient communication
- **Flexible Routing**: Use RabbitMQ's exchange types for different message routing patterns
- **Multiple Clients**: Support for multiple client types (Flutter, web browsers)

## Common WebSocket STOMP Destinations

- `/exchange/amq.topic/flutter.messages`: Main exchange used in this example
- `/topic/[name]`: Simplified destination to publish/subscribe using topic exchange
- `/queue/[name]`: Direct queue publishing/subscription

## Troubleshooting

If you encounter connectivity issues:

1. Ensure Docker and RabbitMQ services are running
2. Check that WebSocket ports are not blocked by firewalls
3. Verify connection parameters in the application code
4. Check RabbitMQ management console (http://localhost:15672) for active connections

## Resources

- [STOMP Protocol](https://stomp.github.io/)
- [RabbitMQ WebSTOMP Plugin](https://www.rabbitmq.com/web-stomp.html)
- [Flutter Documentation](https://flutter.dev/docs)
- [RabbitMQ Documentation](https://www.rabbitmq.com/documentation.html) 