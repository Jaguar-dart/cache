// Copyright (c) 2017, teja. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';

/// Exception thrown by the [Cache] implementation when there is a cache miss
final Exception cacheMiss = new Exception('Cache miss!');

abstract class Cache<T> {
  /// Set the given key/value in the cache, overwriting any existing value
  /// associated with that key
  FutureOr upsert(String key, T value, [Duration expires]);

  /// Get the content associated with the given key
  FutureOr<T> read(String key);

  /// Get the content associated multiple keys at once
  FutureOr<List<T>> readMany(List<String> keys);

  /// Deletes the given key from the cache
  FutureOr remove(String key);

  /// Set the given key/value in the cache ONLY IF the key already exists.
  FutureOr replace(String key, T v, [Duration expires]);
}

/// Cache item
class CacheItem<VT> {
  /// Time at which the item expires
  final DateTime expiry;

  /// Value of the cache item
  final VT value;

  const CacheItem(this.value, this.expiry);

  CacheItem.duration(this.value, Duration expire)
      : expiry = expire != null ? new DateTime.now().add(expire) : null;
}

/// In memory cache implementation
class InMemoryCache<T> implements Cache<T> {
  /// Store
  final Map<String, CacheItem<T>> _store = <String, CacheItem<T>>{};

  final Duration defaultExpiry;

  InMemoryCache(this.defaultExpiry);

  /// Set the given key/value in the cache, overwriting any existing value
  /// associated with that key
  void upsert(String key, T value, [Duration expires]) {
    expires ??= defaultExpiry;
    if (expires != null && expires.isNegative) expires = null;
    _store[key] = new CacheItem.duration(value, expires);
  }

  /// Get the content associated with the given key
  T read(String key) {
    if (!_store.containsKey(key)) {
      throw cacheMiss;
    }

    final CacheItem item = _store[key];

    final now = new DateTime.now();

    if (item.expiry is DateTime && now.isAfter(item.expiry)) {
      throw cacheMiss;
    }

    return item.value;
  }

  /// Get the content associated multiple keys at once
  List<T> readMany(List<String> keys) => keys.map(read).toList();

  /// Deletes the given key from the cache
  void remove(String key) {
    _store.remove(key);
  }

  /// Set the given key/value in the cache ONLY IF the key already exists.
  void replace(String key, T value, [Duration expires]) {
    if (!_store.containsKey(key)) return;

    upsert(key, value, expires);
  }
}
