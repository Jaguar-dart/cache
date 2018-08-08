# jaguar_cache

Cache layer for Jaguar

# Example

```dart
import 'dart:async';
import 'package:jaguar_cache/jaguar_cache.dart';
import 'package:jaguar_serializer/serializer.dart';

main() async {
  final repo = new JsonRepo();
  final cache = new InMemoryCache(repo);

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
  } catch(e) {
    print('Success! $e');
  }

  cache.upsert('one', 1.0, new Duration(seconds: 5));
  cache.upsert('two', 2.0, new Duration(seconds: 5));

  print(cache.readMany(['one', 'two']));
}
```

# Operations

## Upsert

Sets the given key/value in the cache, overwriting any existing value associated with that key.

```dart
  cache.upsert('one', 1, new Duration(seconds: 5));
  print(cache.read('one'));
```

## Read

Get the content associated with the given key

```dart
  print(cache.read('one'));
```

## Read many

Get the content associated multiple keys at once.

```dart
  cache.upsert('one', 1.0, new Duration(seconds: 5));
  cache.upsert('two', 2.0, new Duration(seconds: 5));

  print(cache.readMany(['one', 'two']));
```

## Replace

Set the given key/value in the cache ONLY IF the key already exists.

```dart
  cache.replace('one', 2, new Duration(seconds: 5));
  print(cache.read('one'));
```

## Remove

Deletes the given key from the cache

```dart
cache.remove('one');
```