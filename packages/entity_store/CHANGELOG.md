## 0.0.1-dev.1

* init

## 1.0.2

* Changed EntityStore and EntityMap to inherit from Equatable

## 2.0.0

* Change the library of Result type

## 3.0.0-dev.1

* FEAT: Introduce state management using Provider package
* REFACTOR: Move Repository interface and LocalStorageRepository from entity_store_firestore to entity_store

## 3.0.0

* FEAT: Added ability to read Entity with watchAll, watchOne, selectAll, selectOne, readAll, readOne

## 3.0.1
* REDACTOR: import paths in entity_store library


## 4.0.0-dev.1
* FEAT: Changed repository implementation to another library.

## 3.0.3
* FIX: Reverted the import method back to 3.0.0.

## 4.0.0
* FEAT:  Changed the way LocalStorageEntityHandler stores data 

## 4.1.0
* FEAT: Add Entity watch method

## 5.0.0
* BREAKING CHANGE: IGetOptions changed to FindByIdOptions
* BREAKING CHANGE: ISaveOptions changed to SaveOptions
* BREAKING CHANGE: IDeleteOptions changed to DeleteOptions
* BREAKING CHANGE: ICreateOrUpdateOptions changed to UpsertOptions
* FEAT: Add FetchPolicy

## 6.0.0-dev.1

* FEAT: Add database transaction handling to Repository

## 6.0.0-dev.2

* FEAT: Add StorageRepository which is a repository that handles a generic storage as a data source.
* FEAT: Add SyncStorageRepository which is a repository that handles a generic storage as a data source and synchronize with remote data source.
* FEAT: Add CountOptions to count method
* BREAKING CHANGE: LocalStorageRepository is deprecated. Use StorageRepository instead.

## 6.0.0-dev.3
* FEAT: Add saveAll method to DataSourceHandler

## 6.0.0-dev.4
* FEAT: Add onUpdated callback method to SyncStorageRepository

## 6.0.0-dev.5
* BREAKING CHANGE: type_result version up

## 6.0.0-dev.6
* FEAT: Add EntityStoreController.empty()

## 6.0.0-dev.7
* FIX: Update entity_store_firestore

## 6.0.0-dev.10
* BREAKING CHANGE: before callback options is removed.
* BREAKING CHANGE: load entity options is removed.

## 6.0.0-dev.11
* BREAKING CHANGE: Result type is removed.