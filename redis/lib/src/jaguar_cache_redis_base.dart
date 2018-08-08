// Copyright (c) 2017, teja. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'package:jaguar_cache/jaguar_cache.dart';
import 'package:resp_client/resp_client.dart';
import 'package:resp_client/resp_commands.dart';
import 'package:jaguar_serializer/jaguar_serializer.dart';

/// Cache implementation backed by redis database
class RedisCache<T> extends Cache<T> {
  /// Default expiry duration
  final Duration defaultExpiry;

  /// Connection string to redis db
  final String connectionString;

  /// Database number
  final int database;

  /// Repository to serialize/deserialize data
  final JsonRepo repo;

  /// RESP server
  RespServerConnection _server;

  RespCommands _commander;

  RedisCache(this.defaultExpiry,
      {JsonRepo repo, this.connectionString, this.database})
      : repo = repo ?? new JsonRepo();

  /// Connects to redis db
  Future<void> _connect() async {
    if (_server == null) {
      _server = await connectSocket(connectionString);

      // create a RESP client using the server connection
      _commander = RespCommands(RespClient(_server));

      // TODO select database
    }
  }

  @override

  /// Set the given key/value in the cache, overwriting any existing value
  /// associated with that key
  Future<void> upsert(String key, T value, [Duration expires]) async {
    expires ??= defaultExpiry;
    await _connect();
    if (expires != null && expires.isNegative) expires = null;
    final exp = expires == null
        ? null
        : DateTime.now().add(expires).toIso8601String();
    final String data = repo.to({'e': exp, 'v': value});
    await _commander.set(key, data);
  }

  /// Set the given key/value in the cache ONLY IF the key already exists.
  @override
  Future<void> replace(String key, T v, [Duration expires]) async {
    await _connect();
    if (await _commander.exists([key]) == 0) return;
    await upsert(key, v, expires);
  }

  /// Deletes the given key from the cache
  @override
  Future<void> remove(String key) async {
    await _connect();
    await _commander.del([key]);
  }

  /// Get the content associated multiple keys at once
  @override
  Future<List<T>> readMany(List<String> keys) async {
    await _connect();

    final ret = [];
    for (String key in keys) {
      ret.add(await read(key));
    }

    return ret;
  }

  /// Get the content associated with the given key
  @override
  Future<T> read(String key) async {
    await _connect();
    final String v = await _commander.get(key);

    if (v == null) throw cacheMiss;

    final Map map = repo.from<T>(v);

    if (map['e'] is String) {
      final time = DateTime.parse(map['e']);
      if (new DateTime.now().isAfter(time)) throw cacheMiss;
    }

    return map['v'];
  }

  @override
  Future<void> clear() async {
    // TODO await _commander.flushDb();
    throw UnimplementedError();
  }
}
