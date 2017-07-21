// Copyright (c) 2017, teja. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'package:jaguar_cache/jaguar_cache.dart';

main() async {
  final cache = new InMemoryCache();

  // Upsert
  cache.upsert('one', 1, new Duration(seconds: 5));
  print(cache.read('one'));

  // Replace
  cache.replace('one', 2, new Duration(seconds: 5));
  print(cache.read('one'));

  // Expire
  await new Future.delayed(new Duration(seconds: 5));

  try {
    cache.read('one');
  } catch (e) {
    print('Success! $e');
  }

  cache.upsert('one', 1.0, new Duration(seconds: 10));
  cache.upsert('two', 2.0, new Duration(seconds: 10));

  print(cache.readMany(['one', 'two']));

  cache.remove('one');

  try {
    cache.read('one');
  } catch (e) {
    print('Success! $e');
  }
}
