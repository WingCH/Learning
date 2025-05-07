# RabbitMQ with STOMP Docker Setup

This project contains configuration for running RabbitMQ with STOMP protocol using Docker.

## Prerequisites

- Docker
- Docker Compose

## How to Start

Run the following command to start the RabbitMQ server:

```bash
docker-compose up -d
```

## Access Methods

- RabbitMQ Management Interface: http://localhost:15672 (username: admin, password: admin)
- STOMP Connection: `ws://localhost:15674/ws` (WebSocket) or `stomp://localhost:61613` (TCP)

## STOMP Connection Parameters

- Host: `localhost`
- Port: `61613` (TCP) or `15674` (WebSocket)
- Virtual Host: `/`
- Credentials: admin/admin

## Testing with Web Client

The project includes a web-based STOMP client for testing the connection:

### 1. Start a Local HTTP Server

Run the following command in the server directory:

```bash
python -m http.server 8000
```

### 2. Access the Test Client

Open your browser and navigate to:

```
http://localhost:8000/test-stomp.html
```

### 3. Using the Test Client

1. Click the "Connect" button to establish a WebSocket STOMP connection
2. Once connected, you can type messages in the input field
3. Click "Send Message" to publish messages to the `/exchange/amq.topic/flutter.messages` destination
4. Any messages sent to this destination will appear in the message log area
5. You can disconnect by clicking the "Disconnect" button

### 4. Integration with Flutter App

The test client is configured to use the same message destination as the Flutter application, allowing you to:

- Test message publishing and receiving without running the Flutter app
- Verify that messages sent from the Flutter app are properly received
- Test the RabbitMQ server configuration independently from the Flutter app 