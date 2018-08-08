// Copyright (c) 2017, teja. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'package:jaguar_cache_redis/jaguar_cache_redis.dart';

main() async {
  final cache = RedisCache(Duration(minutes: 1));

  // Upsert
  await cache.upsert('one', 1, Duration(seconds: 5));
  print(await cache.read('one'));

  // Replace
  await cache.replace('one', 2, Duration(seconds: 5));
  print(await cache.read('one'));

  // Expire
  await new Future.delayed(Duration(seconds: 5));

  try {
    await cache.read('one');
  } catch (e) {
    print('Success! $e');
  }

  await cache.upsert('one', 1.0, Duration(seconds: 10));
  await cache.upsert('two', 2.0, Duration(seconds: 10));

  print(await cache.readMany(['one', 'two']));

  await cache.remove('one');

  try {
    await cache.read('one');
  } catch (e) {
    print('Success! $e');
  }
}
