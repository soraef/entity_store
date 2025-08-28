## 0.0.1

* TODO: Describe initial release.

## 1.0.2

* Changed the version of the entity_store package to 1.0.2

## 2.0.0

* Change the library of Result type

## 2.1.0

* Added LocalStorageRepository for storing Entity in local storage

## 2.1.1

* Fix import

## 2.1.2

* Fix import

## 2.1.3

* Fix LocalStorage key

## 2.1.4

* Change merge to false even by default in save and createOrUpdate methods


## 2.2.0

* Add count method to Repository

## 2.2.1

* [FIX] Changed the order in which startAfterDocument is called (Firestore specification required it to be called after orderBy).

## 3.0.0-dev.1

* REFACTOR: Move Repository interface and LocalStorageRepository from entity_store_firestore to entity_store

## 3.0.0

* FIX: change createOrUpdate to upsert


## 4.0.0-dev.1

* FIX: upgrade entity_store 4.0.0-dev.1

## 3.0.3

* FIX: upgrade entity_store 3.0.3

## 3.0.4

* FIX: fix import error

## 4.0.0

* FIX: upgrade entity_store 4.0.0
* FIX: upgrade dependency

## 4.1.0
* FIX: upgrade entity_store 4.0.0

## 4.1.1
* FIX: upgrade firebase SDK version up

## 5.0.0
* FIX: upgrade entity_store 5.0.0
* FEAT: Add observeAll and observeById options to repository interface

## 6.0.0-dev.1

* feat: Add database transaction handling to Repository

## 6.0.0-dev.2

* feat: Add CountOptions to count method

## 6.0.0-dev.3

* feat: Add saveAll method to DataSourceHandler

## 6.0.0-dev.4

* feat: Add onUpdated callback method to SyncStorageRepository

## 6.0.0-dev.5

* BREAKING CHANGE: type_result version up

## 6.0.0-dev.7

* FIX: Change Fetch Policy


## 6.0.0-dev.11

* BREAKING CHANGE: Result type is removed.
* BREAKING CHANGE: before callback options is removed.
* BREAKING CHANGE: load entity options is removed.

## 6.0.0-dev.15
* Update entity_store version

## 6.0.0
* BREAKING CHANGE: Updated to entity_store 6.0.0 with all breaking changes
* FEAT: Full Firestore transaction support with TransactionContext
* FEAT: Improved query builder with type-safe filters and sorting
* FEAT: Better offline support and conflict resolution
* FEAT: Enhanced FetchPolicy implementation for cache control
* REFACTOR: Cleaner repository implementation aligned with entity_store interface
* FIX: Improved error handling for network and permission issues