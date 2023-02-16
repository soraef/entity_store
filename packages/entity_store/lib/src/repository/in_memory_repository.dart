part of "../repository.dart";

class InMemoryRepository<Id, E extends Entity<Id>> extends IRepository<Id, E> {
  InMemoryRepository(super.controller, this.converter);

  final EntityJsonConverter<Id, E> converter;

  @override
  Future<Result<E, Exception>> save(
    E entity, {
    SaveOptions options = const SaveOptions(),
  }) async {
    controller.dispatch(SaveEvent<Id, E>.now(entity));
    return Result.ok(entity);
  }

  @override
  Future<Result<List<E>, Exception>> list(Query<Id, E> query) async {
    var entities = controller
        .where<Id, E>(
          (e) => query.test(
            converter.toJson(e),
          ),
        )
        .toList();

    final sorts = query.getSorts;
    for (final sort in sorts.reversed) {
      entities = entities.sorted(
        (a, b) {
          final fieldA = converter.toJson(a)[sort.field] as Comparable;
          final fieldB = converter.toJson(b)[sort.field] as Comparable;
          if (sort.descending) {
            return fieldB.compareTo(fieldA);
          } else {
            return fieldA.compareTo(fieldB);
          }
        },
      );
    }

    final startAfterId = query.getStartAfterId;
    if (startAfterId != null) {
      entities =
          entities.skipWhile((e) => e.id != startAfterId).skip(1).toList();
    }

    final limit = query.getLimit;
    if (limit != null) {
      entities = entities.take(limit).toList();
    }

    controller.dispatch(ListEvent.now(entities));
    return Result.ok(entities);
  }

  @override
  Future<Result<E, Exception>> delete(
    E entity, {
    DeleteOptions options = const DeleteOptions(),
  }) async {
    controller.dispatch(DeleteEvent<Id, E>.now(entity.id));
    return Result.ok(entity);
  }

  @override
  Future<Result<E?, Exception>> get(
    Id id, {
    GetOptions options = const GetOptions(),
  }) async {
    final entity = controller.get<Id, E>(id);
    controller.dispatch(GetEvent.now(id, entity));
    return Result.ok(entity);
  }
}

class InMemoryRepositoryFactory implements IRepositoryFactory {
  final EntityStoreController controller;
  final Map<Type, EntityJsonConverter> _converters;

  InMemoryRepositoryFactory(this.controller, this._converters);

  InMemoryRepositoryFactory regist<Id, E extends Entity<Id>>(
    EntityJsonConverter<Id, E> converter,
  ) {
    return InMemoryRepositoryFactory(
      controller,
      {..._converters, E: converter},
    );
  }

  @override
  InMemoryRepositoryFactory fromSubCollection<Id, E extends Entity<Id>>(Id id) {
    return this;
  }

  @override
  InMemoryRepository<Id, E> getRepo<Id, E extends Entity<Id>>() {
    return InMemoryRepository<Id, E>(
      controller,
      _converters[E] as EntityJsonConverter<Id, E>,
    );
  }
}
