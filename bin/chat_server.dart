import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// List to hold connected clients as WebSocketChannel
final List<WebSocketChannel> clients = [];

void main() async {
  // WebSocket handler that will manage client connections
  final handler = webSocketHandler((WebSocketChannel socket) {
    // Add client to the list when connected
    clients.add(socket);
    print('Client connected');

    // Listen for messages from the connected client
    socket.stream.listen(
          (message) {
        print('Received message: $message');

        // Broadcast the message to all connected clients except the sender
        for (var client in clients) {
          if (client != socket) {
            client.sink.add(message);
          }
        }
      },
      onDone: () {
        // Remove client from list when they disconnect
        clients.remove(socket);
        print('Client disconnected');
      },
      onError: (error) {
        // Log and remove client on error
        print('Error: $error');
        clients.remove(socket);
      },
    );
  });

  // Set up and start the server
  final server = await shelf_io.serve(handler, '192.168.1.3', 8081);
  print('Server running on ws://${server.address.host}:${server.port}');
}
