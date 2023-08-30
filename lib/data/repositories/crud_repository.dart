abstract interface class CrudRepository<T> {
  const CrudRepository();

  Future<void> create(T element);

  Future<List<T>> getAll();

  Future<T?> getById(int id);

  Future<int> update(T element);

  Future<void> delete(T element);

  Future<void> deleteAll();
}
