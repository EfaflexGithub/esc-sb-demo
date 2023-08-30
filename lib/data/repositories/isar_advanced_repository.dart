import 'package:efa_smartconnect_modbus_demo/data/models/isar_collection_mixin.dart';
import 'package:efa_smartconnect_modbus_demo/data/repositories/crud_repository.dart';
import 'package:isar/isar.dart';

abstract base class IsarAdvancedRepository<T extends IsarCollectionMixin,
    C extends IsarCollectionMixin> implements CrudRepository<C> {
  IsarAdvancedRepository({
    required this.isar,
  });

  final Future<Isar> isar;

  T Function(C crud) get crudToIsar;
  C Function(T isar) get isarToCrud;

  @override
  Future<int> create(C element) async {
    final isar = await this.isar;
    return isar.writeTxn(() async {
      var id = await isar
          .collection<T>()
          .put(crudToIsar.call(element)..id = Isar.autoIncrement);
      element.id = id;
      return id;
    });
  }

  @override
  Future<int> update(C element) async {
    final isar = await this.isar;
    return isar.writeTxn(() async {
      var id = await isar.collection<T>().put(crudToIsar.call(element));
      element.id = id;
      return id;
    });
  }

  @override
  Future<void> delete(C element) async {
    final isar = await this.isar;
    return isar.writeTxn(() async {
      isar.collection<T>().delete(crudToIsar.call(element).id);
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
  Future<List<C>> getAll() async {
    final isar = await this.isar;
    return isar.txn(() async {
      return (await isar.collection<T>().where().findAll())
          .map((e) => isarToCrud.call(e))
          .toList();
    });
  }

  @override
  Future<C?> getById(int id) async {
    final isar = await this.isar;
    return isar.txn(() async {
      var element = await isar.collection<T>().get(id);
      if (element == null) {
        return null;
      }
      return isarToCrud.call(element);
    });
  }
}
