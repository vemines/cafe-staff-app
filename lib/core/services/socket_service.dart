import 'package:cafe_staff_app/app/flavor.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService {
  late final io.Socket _socket;
  final String userId;

  io.Socket get socket => _socket;

  SocketService({required this.userId}) {
    _initSocket();
  }

  Future<void> _initSocket() async {
    Map<String, dynamic> headers = {};
    headers = {'userid': userId, 'Content-Type': 'application/json'};

    _socket = io.io(
      FlavorService.instance.config.baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setExtraHeaders(headers)
          .enableAutoConnect()
          .build(),
    );
    _socket.onConnect((_) {
      print('Socket connected');
    });
    _socket.onDisconnect((_) => print('Socket disconnected'));
    _socket.onConnectError((data) => print('Connect Error: $data'));
    _socket.onError((data) => print('Socket Error: $data'));
  }

  // --- Methods to EMIT events ---
  void emitOrderCreated(Map<String, dynamic> orderData) {
    _socket.emit('order_created', orderData);
  }

  void emitTableStatusUpdated(String tableId, String status) {
    _socket.emit('table_status_updated', {'tableId': tableId, 'status': status});
  }

  void emitOrderUpdated(Map<String, dynamic> orderData) {
    _socket.emit('order_updated', orderData);
  }

  void emitOrderCompleted(Map<String, dynamic> orderData) {
    _socket.emit('order_completed', orderData);
  }

  void emitMergeRequestCreated(Map<String, dynamic> mergeRequestData) {
    _socket.emit('merge_request_created', mergeRequestData);
  }

  void emitMergeRequestApproved(Map<String, dynamic> data) {
    _socket.emit('merge_request_approved', data);
  }

  void emitMergeRequestRejected(Map<String, dynamic> data) {
    _socket.emit('merge_request_rejected', data);
  }

  void emitOrderSplitted(Map<String, dynamic> data) {
    _socket.emit('order_splitted', data); //Use on backend
  }

  void dispose() {
    _socket.disconnect();
    _socket.dispose();
  }
}
