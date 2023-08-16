import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/adapters.dart';

extension HiveExtension on HiveInterface {
  Future<T?> withBox<T>(String name, ComputeCallback<Box, T?> operation) async {
    late final Box box;
    late final bool wasClosed;
    try {
      box = Hive.box(name);
      wasClosed = false;
    } on HiveError {
      box = await Hive.openBox(name);
      wasClosed = true;
    }
    T? result;
    try {
      result = await operation.call(box);
    } finally {
      if (wasClosed) {
        await box.close();
      }
    }
    return result;
  }
}
