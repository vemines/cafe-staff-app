// // lib/core/services/socket_service.dart
// import 'package:socket_io_client/socket_io_client.dart' as io;

// import '/app/flavor.dart';

// class SocketService {
//   io.Socket? _socket;
//   final Map<String, dynamic> Function() headers;

//   io.Socket? get socket => _socket;

//   SocketService({required this.headers});

//   void connect() {
//     if (_socket != null) {
//       disconnect(); // Clean up any existing connection
//     }
//     print("CALL CONNECT");
//     _socket = io.io(
//       FlavorService.instance.config.baseUrl,
//       io.OptionBuilder()
//           .setTransports(['websocket'])
//           .setExtraHeaders(headers()) // Call the function to get *current* headers.
//           .enableAutoConnect() // Re-enable autoConnect (safer).
//           .build(),
//     );

//     _socket!.onConnect((_) {
//       print('Socket connected');
//     });
//     _socket!.onDisconnect((_) => print('Socket disconnected'));
//     _socket!.onConnectError((data) => print('Connect Error: $data'));
//     _socket!.onError((data) => print('Socket Error: $data'));
//   }

//   void disconnect() {
//     print("CALL DISCONNECT");
//     if (_socket != null) {
//       _socket!.disconnect();
//       _socket = null;
//     }
//   }

//   void dispose() {
//     disconnect();
//     _socket?.dispose();
//   }

//   void emitOrderCreated(Map<String, dynamic> orderData) {
//     if (_socket != null) {
//       _socket!.emit('order_created', orderData);
//     }
//   }

//   void emitTableStatusUpdated(String tableId, String status) {
//     if (_socket != null) {
//       _socket!.emit('table_status_updated', {'tableId': tableId, 'status': status});
//     }
//   }

//   void emitOrderUpdated(Map<String, dynamic> orderData) {
//     if (_socket != null) {
//       _socket!.emit('order_updated', orderData);
//     }
//   }

//   void emitOrderCompleted(Map<String, dynamic> orderData) {
//     if (_socket != null) {
//       _socket!.emit('order_completed', orderData);
//     }
//   }

//   void emitMergeRequestCreated(Map<String, dynamic> mergeRequestData) {
//     if (_socket != null) {
//       _socket!.emit('merge_request_created', mergeRequestData);
//     }
//   }

//   void emitMergeRequestApproved(Map<String, dynamic> data) {
//     if (_socket != null) {
//       _socket!.emit('merge_request_approved', data);
//     }
//   }

//   void emitMergeRequestRejected(Map<String, dynamic> data) {
//     if (_socket != null) {
//       _socket!.emit('merge_request_rejected', data);
//     }
//   }

//   void emitOrderSplitted(Map<String, dynamic> data) {
//     if (_socket != null) {
//       _socket!.emit('order_splitted', data);
//     }
//   }
// }
