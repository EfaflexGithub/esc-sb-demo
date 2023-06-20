import 'dart:collection';

extension ListBaseExtensions<E> on ListBase<E> {
  E? get firstOrNull {
    if (isEmpty) return null;
    return first;
  }
}
