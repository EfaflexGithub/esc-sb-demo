import 'package:efa_smartconnect_modbus_demo/data/models/isar_collection_mixin.dart';
import 'package:efa_smartconnect_modbus_demo/data/repositories/crud_repository.dart';
import 'package:isar/isar.dart';

abstract base class IsarRepository<T extends IsarCollectionMixin>
    implements CrudRepository<T> {
  const IsarRepository({
    required this.isar,
  });

  final Future<Isar> isar;

  @override
  Future<int> create(T element) async {
    final isar = await this.isar;
    return isar.writeTxn(() async {
      var id = await isar.collection<T>().put(element..id = Isar.autoIncrement);
      element.id = id;
      return id;
    });
  }

  @override
  Future<int> update(T element) async {
    final isar = await this.isar;
    return isar.writeTxn(() async {
      var id = await isar.collection<T>().put(element);
      element.id = id;
      return id;
    });
  }

  @override
  Future<void> delete(T element) async {
    if (element.id == Isar.autoIncrement) {
      throw Exception('Invalid id');
    }
    final isar = await this.isar;
    return isar.writeTxn(() async {
      isar.collection<T>().delete(element.id);
    });
  }

  @override
  Future<void> deleteAll() async {
    final isar = await this.isar;
    return isar.writeTxn(() async {
      isar.collection<T>().clear();
    });
  }

  @override
  Future<List<T>> getAll() async {
    final isar = await this.isar;
    return isar.txn(() async {
      return isar.collection<T>().where().findAll();
    });
  }

  @override
  Future<T?> getById(int id) async {
    final isar = await this.isar;
    return isar.txn(() async {
      return isar.collection<T>().get(id);
    });
  }
}
