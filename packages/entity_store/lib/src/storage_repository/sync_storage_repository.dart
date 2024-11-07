part of '../storage_repository.dart';

/// Synchronizes data with a remote data source if there are updates.
///
/// This Repository can be used in the following cases:
///
/// - When there is a master data source remotely and a cache is held locally.
/// - When there are changes, the local data is synchronized with the remote data.
///
/// If updates are infrequent and all data is cached locally, using this Repository
/// can reduce overhead.
///
/// Cache checks are performed when data is retrieved, so if data retrieval is frequent,
/// there is a possibility that overhead will increase.
/// By setting the Option's skipSyncCheck to true, the sync check can be skipped.
abstract class SyncStorageRepository<Id, E extends Entity<Id>>
    extends StorageRepository<Id, E> {
  SyncStorageRepository({
    required super.dataSourceHandler,
    required super.controller,
  });

  Future<Result<bool, Exception>> hasUpdates();

  Future<Result<List<E>, Exception>> fetchAllData();

  @override
  Future<Result<void, Exception>> syncRemoteDataIfUpdated() async {
    final hasUpdates = await this.hasUpdates();
    if (hasUpdates.isExcept) {
      return Result.except(hasUpdates.except);
    }

    if (!hasUpdates.ok) {
      // If there are no updates, return success without doing anything.
      return Result.ok(null);
    }

    // If there are updates, fetch the remote data and save it.
    final fetchResult = await this.fetchAllData();
    return fetchResult.map(
      (entities) {
        dataSourceHandler.clear();
        for (var entity in entities) {
          dataSourceHandler.save(entity);
        }
        return Result.ok(null);
      },
      (err) => Result.except(err),
    );
  }
}
