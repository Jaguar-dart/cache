// Copyright (c) 2017, teja. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';

/// Exception thrown by the [Cache] implementation when there is a cache miss
final Exception cacheMiss = new Exception('Cache miss!');

abstract class Cache {
  /// Set the given key/value in the cache, overwriting any existing value
  /// associated with that key
  FutureOr upsert<T>(String key, T value, Duration expires);

  /// Get the content associated with the given key
  FutureOr<T> read<T>(String key);

  /// Get the content associated multiple keys at once
  FutureOr<List<T>> readMany<T>(List<String> keys);

  /// Deletes the given key from the cache
  FutureOr remove<T>(String key);

  /// Set the given key/value in the cache ONLY IF the key already exists.
  FutureOr replace<T>(String key, T v, Duration expires);
}

/// Cache item
class CacheItem<VT> {
  /// Time at which the item expires
  final DateTime expiry;

  /// Value of the cache item
  final VT value;

  const CacheItem(this.value, this.expiry);

  CacheItem.duration(this.value, Duration expire)
      : expiry = new DateTime.now().add(expire);
}

/// In memory cache implementation
class InMemoryCache implements Cache {
  //TODO implement lock

  /// Store
  final Map<String, CacheItem> _store = <String, CacheItem>{};

  InMemoryCache();

  /// Set the given key/value in the cache, overwriting any existing value
  /// associated with that key
  void upsert<T>(String key, T value, Duration expires) {
    _store[key] = new CacheItem.duration(value, expires);
  }

  /// Get the content associated with the given key
  T read<T>(String key) {
    if (!_store.containsKey(key)) {
      throw cacheMiss;
    }

    final CacheItem item = _store[key];

    if (new DateTime.now().isAfter(item.expiry)) {
      throw cacheMiss;
    }

    return item.value;
  }

  /// Get the content associated multiple keys at once
  List<T> readMany<T>(List<String> keys) => keys.map(read).toList();

  /// Deletes the given key from the cache
  void remove<T>(String key) {
    _store.remove(key);
  }

  /// Set the given key/value in the cache ONLY IF the key already exists.
  void replace<T>(String key, T value, Duration expires) {
    if (!_store.containsKey(key)) return;

    _store[key] = new CacheItem.duration(value, expires);
  }
}
