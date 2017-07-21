// Copyright (c) 2017, teja. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'package:jaguar_cache/jaguar_cache.dart';
import 'package:test/test.dart';

void main() {
  group('InMemoryCache tests', () {
    final cache = new InMemoryCache(new Duration(minutes: 1));

    setUp(() {});

    test('Miss', () {
      expect(() => cache.read('one'), throwsA(cacheMiss));
    });

    test('Hit', () {
      cache.upsert('one', 1, new Duration(seconds: 10));
      cache.upsert('two', 2, new Duration(seconds: 10));
      expect(cache.read('one'), 1);
      expect(cache.read('two'), 2);
    });

    test('Miss expired', () async {
      cache.upsert('one', 1, new Duration(seconds: 5));
      cache.upsert('two', 2, new Duration(seconds: 10));
      expect(cache.read('one'), 1);
      expect(cache.read('two'), 2);
      await new Future.delayed(new Duration(seconds: 5));
      expect(() => cache.read('one'), throwsA(cacheMiss));
      expect(cache.read('two'), 2);
      await new Future.delayed(new Duration(seconds: 5));
      expect(() => cache.read('one'), throwsA(cacheMiss));
      expect(() => cache.read('two'), throwsA(cacheMiss));
    });
  });
}
