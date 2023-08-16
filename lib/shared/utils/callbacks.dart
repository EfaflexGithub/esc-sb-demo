import 'dart:async';

typedef AsyncValueChanged<T> = Future<void> Function(T value);
