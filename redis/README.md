# jaguar_cache_redis

Cache implementation based on Redis

# Example

```dart
import 'dart:async';
import 'package:jaguar_cache_redis/jaguar_cache_redis.dart';
import 'package:jaguar_serializer/serializer.dart';

main() async {
  final cache = new RedisCache(new Duration(minutes: 1), new JsonRepo());

  // Upsert
  await cache.upsert('one', 1, new Duration(seconds: 5));
  print(await cache.read('one'));

  // Replace
  await cache.replace('one', 2, new Duration(seconds: 5));
  print(await cache.read('one'));

  // Expire
  await new Future.delayed(new Duration(seconds: 5));

  try {
    await cache.read('one');
  } catch (e) {
    print('Success! $e');
  }

  await cache.upsert('one', 1.0, new Duration(seconds: 10));
  await cache.upsert('two', 2.0, new Duration(seconds: 10));

  print(await cache.readMany(['one', 'two']));

  await cache.remove('one');

  try {
    await cache.read('one');
  } catch (e) {
    print('Success! $e');
  }
}
```

# Operations

## Upsert

Sets the given key/value in the cache, overwriting any existing value associated with that key.

```dart
await cache.upsert('one', 1, new Duration(seconds: 5));
print(await cache.read('one'));
```

## Read

Get the content associated with the given key

```dart
print(await cache.read('one'));
```

## Read many

Get the content associated multiple keys at once.

```dart
await cache.upsert('one', 1.0, new Duration(seconds: 10));
await cache.upsert('two', 2.0, new Duration(seconds: 10));

print(await cache.readMany(['one', 'two']));
```

## Replace

Set the given key/value in the cache ONLY IF the key already exists.

```dart
await cache.replace('one', 2, new Duration(seconds: 5));
print(await cache.read('one'));
```

## Remove

Deletes the given key from the cache

```dart
await cache.remove('one');
```