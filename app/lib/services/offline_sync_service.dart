import 'dart:convert';
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

typedef SyncActionHandler = Future<void> Function(Map<String, dynamic> payload);

class OfflineSyncService {
  final Connectivity _connectivity;
  final Map<String, SyncActionHandler> _handlers;

  Database? _database;
  StreamSubscription<dynamic>? _connectivitySubscription;

  OfflineSyncService({
    required Map<String, SyncActionHandler> handlers,
    Connectivity? connectivity,
  })  : _handlers = handlers,
        _connectivity = connectivity ?? Connectivity();

  Future<void> initialize() async {
    if (_database != null) {
      return;
    }

    final databasesPath = await getDatabasesPath();
    final dbPath = p.join(databasesPath, 'duckbooks_offline_sync.db');

    _database = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE pending_actions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            action TEXT NOT NULL,
            payload TEXT NOT NULL,
            created_at INTEGER NOT NULL
          )
        ''');
      },
    );

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((result) async {
      if (_hasConnection(result)) {
        await syncPending();
      }
    });

    await syncPending();
  }

  Future<void> dispose() async {
    await _connectivitySubscription?.cancel();
    await _database?.close();
    _database = null;
  }

  Future<bool> isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return _hasConnection(result);
  }

  Future<void> enqueueAction({
    required String action,
    required Map<String, dynamic> payload,
  }) async {
    final db = _requireDatabase();
    await db.insert('pending_actions', {
      'action': action,
      'payload': jsonEncode(payload),
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<int> pendingCount() async {
    final db = _requireDatabase();
    final result =
        await db.rawQuery('SELECT COUNT(*) as count FROM pending_actions');
    final count = result.first['count'];
    if (count is int) {
      return count;
    }
    return int.tryParse(count.toString()) ?? 0;
  }

  Future<void> syncPending() async {
    if (!await isOnline()) {
      return;
    }

    final db = _requireDatabase();
    final rows = await db.query(
      'pending_actions',
      orderBy: 'id ASC',
    );

    for (final row in rows) {
      final id = row['id'] as int;
      final action = row['action'] as String;
      final payloadJson = row['payload'] as String;

      final handler = _handlers[action];
      if (handler == null) {
        // Se não houver handler registrado, remove para evitar loop infinito.
        await db.delete('pending_actions', where: 'id = ?', whereArgs: [id]);
        continue;
      }

      try {
        final payload =
            Map<String, dynamic>.from(jsonDecode(payloadJson) as Map);
        await handler(payload);
        await db.delete('pending_actions', where: 'id = ?', whereArgs: [id]);
      } catch (_) {
        // Mantém na fila para tentar novamente em outra oportunidade.
      }
    }
  }

  Database _requireDatabase() {
    final db = _database;
    if (db == null) {
      throw StateError('OfflineSyncService não foi inicializado.');
    }
    return db;
  }

  bool _hasConnection(dynamic result) {
    if (result is ConnectivityResult) {
      return result != ConnectivityResult.none;
    }

    if (result is List<ConnectivityResult>) {
      return result.any((r) => r != ConnectivityResult.none);
    }

    return false;
  }
}
