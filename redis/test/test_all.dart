// Copyright (c) 2017, teja. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'package:jaguar_cache/jaguar_cache.dart';
import 'package:jaguar_cache_redis/jaguar_cache_redis.dart';
import 'package:test/test.dart';

void main() {
  group('Redis tests', () {
    final cache = new RedisCache(new Duration(minutes: 1));

    test('Miss', () async {
      expect(() async => await cache.read('one'), throwsA(cacheMiss));
    });

    test('Hit', () async {
      await cache.upsert('one', 1, new Duration(seconds: 10));
      await cache.upsert('two', 2, new Duration(seconds: 10));
      expect(await cache.read('one'), 1);
      expect(await cache.read('two'), 2);
    });

    test('Miss expired', () async {
      await cache.upsert('one', 1, new Duration(seconds: 5));
      await cache.upsert('two', 2, new Duration(seconds: 10));
      expect(await cache.read('one'), 1);
      expect(await cache.read('two'), 2);
      await new Future.delayed(new Duration(seconds: 5));
      expect(() async => await cache.read('one'), throwsA(cacheMiss));
      expect(await cache.read('two'), 2);
      await new Future.delayed(new Duration(seconds: 5));
      expect(() async => await cache.read('one'), throwsA(cacheMiss));
      expect(() async => await cache.read('two'), throwsA(cacheMiss));
    });
  });
}
