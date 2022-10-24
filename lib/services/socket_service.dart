import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:socket_io_client/socket_io_client.dart' as io;

enum ServerStatus { online, offline, connecting }

class SocketService extends ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.connecting;
  io.Socket? _socket;

  ServerStatus get serverStatus => _serverStatus;
  io.Socket? get socket => _socket;
  void get emit => _socket?.emit;

  SocketService() {
    _initConfig();
  }

  void _initConfig() {
    // Dart client
    _socket = io.io('http://localhost:3000', {
      'transports': ['websocket'],
      'autoConnect': true
    });

    _socket?.onConnect((_) {
      log('connect');
      _serverStatus = ServerStatus.online;
      notifyListeners();
    });

    _socket?.onDisconnect((_) {
      log('disconnect');
      _serverStatus = ServerStatus.offline;
      notifyListeners();
    });
    // socket.on('nuevo-mensaje', (payload) {
    //   log(payload['nombre']);
    // });
  }
}
