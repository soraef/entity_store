## 6.0.2

### Bug Fixes & Improvements
* **FIXED**: Implemented missing filter operators in IsarRepositoryQuery
* **FIXED**: `isLessThanOrEqualTo` now correctly uses FilterGroup.or with lessThan and equalTo
* **FIXED**: `isGreaterThanOrEqualTo` now correctly uses FilterGroup.or with greaterThan and equalTo
* **FIXED**: `arrayContainsAny` now properly supports multiple values with FilterGroup.or
* **FIXED**: `whereIn` now properly supports multiple values with FilterGroup.or
* **FIXED**: `whereNotIn` now properly uses FilterGroup.not with FilterGroup.or
* **FIXED**: `isNull` filter now properly supports both null and not null conditions
* **FIXED**: `startAfter` method now returns proper IsarRepositoryQuery instance
* **FIXED**: `startAfterId` getter now returns the correct value instead of throwing exception

### Dependencies
- entity_store: ^6.0.0
- isar_community: ^3.2.0-dev.2
- isar_community_flutter_libs: ^3.2.0-dev.2

## 6.0.1

### Updated Dependencies
* **FEAT**: Migrated from official `isar` packages to community-maintained `isar_community` packages
* **UPDATED**: Now uses `isar_community: ^3.2.0-dev.2` for continued support and development
* **UPDATED**: Now uses `isar_community_flutter_libs: ^3.2.0-dev.2` for Flutter integration
* **REMOVED**: Test files and example files to reduce package size
* **DOCS**: Updated README with isar_community usage instructions

### Dependencies
- entity_store: ^6.0.0
- isar_community: ^3.2.0-dev.2
- isar_community_flutter_libs: ^3.2.0-dev.2

## 6.0.0-dev.1

### Initial Release
* **NEW**: Isar database integration for EntityStore ecosystem
* **NEW**: High-performance local database backend using Isar 3.x
* **NEW**: Complete CRUD operations (save, findById, findAll, delete, etc.)
* **NEW**: Query builder with filtering, sorting, and pagination support
* **NEW**: Transaction support for data integrity
* **NEW**: Integration with EntityStore's reactive notification system
* **NEW**: Batch operations (saveAll, deleteAll)
* **NEW**: Upsert functionality for create-or-update operations

### Features
- Full offline support with automatic data persistence
- Type-safe operations with compile-time error checking
- Compatible with EntityStore 6.0.0-dev series
- Comprehensive documentation and examples

### Known Limitations
- `observeById` and `observeAll` streams not yet implemented (planned for future releases)
- Some advanced query operators (`whereIn`, `arrayContainsAny`) have simplified implementations
- Code generation requires compatible analyzer version

### Dependencies
- entity_store: ^6.0.0-dev.13
- isar: ^3.1.0+1
- isar_flutter_libs: ^3.1.0+1

## 6.0.0

### Stable Release
* **BREAKING CHANGE**: Updated to entity_store 6.0.0 with all breaking changes
* **FEAT**: Full Isar database integration with EntityStore ecosystem
* **FEAT**: High-performance local database backend using Isar 3.x
* **FEAT**: Complete CRUD operations (save, findById, findAll, delete, etc.)
* **FEAT**: Advanced query builder with filtering, sorting, and pagination
* **FEAT**: Transaction support for data integrity and atomic operations
* **FEAT**: Integration with EntityStore's reactive notification system
* **FEAT**: Batch operations for efficient data processing
* **FEAT**: Upsert functionality for create-or-update operations
* **PERF**: Optimized local storage operations for mobile performance

### Dependencies
- entity_store: ^6.0.0
- isar: ^3.1.0+1
- isar_flutter_libs: ^3.1.0+1