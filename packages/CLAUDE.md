# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

EntityStore is a Flutter state management ecosystem based on entity-centric design. It's a monorepo managed with Melos containing multiple interconnected packages for entity-based state management with various backend options (in-memory, Firestore, Sembast, Isar).

## Key Commands

### Development Commands
```bash
# Install dependencies for all packages
melos pub_get

# Run static analysis
melos analyze

# Apply Dart fixes
melos fix_apply

# Clean build artifacts
melos clean

# Run tests for a specific package
cd packages/entity_store && flutter test
cd packages/entity_store_firestore && flutter test
cd packages/entity_store_sembast && flutter test

# Watch for code generation (if using build_runner)
melos build_runner_watch
```

### Testing
```bash
# Run tests in a specific package
flutter test

# Run a single test file
flutter test test/entity_store_test.dart

# Run tests with coverage
flutter test --coverage
```

## Architecture

### Core Design Principles
1. **Immutable Entities**: All entities extend `Entity<Id>` and must be immutable
2. **Repository Pattern**: Data access through `Repository<Id, E extends Entity<Id>>` interface
3. **Reactive UI**: Uses Provider package for state management with extensions like `watchOne`, `watchAll`
4. **Transaction Support**: All repository operations support optional transaction contexts

### Package Structure
```
entity_store/
├── packages/
│   ├── entity_store/           # Core package with base abstractions
│   ├── entity_store_firestore/ # Firebase Firestore integration
│   ├── entity_store_sembast/   # Sembast local database integration
│   └── entity_store_isar/      # Isar database integration (minimal)
└── example/
    ├── entity_store_simple_example/
    ├── firestore_repository_for_test/
    └── todo_app/
```

### Key Interfaces

**Entity Interface:**
```dart
abstract class Entity<Id> {
  Id get id;
}
```

**Repository Interface:**
```dart
abstract interface class Repository<Id, E extends Entity<Id>> {
  Future<E?> findById(Id id, {FindByIdOptions? options, TransactionContext? transaction});
  Future<List<E>> findAll({FindAllOptions? options, TransactionContext? transaction});
  Future<E> save(E entity, {SaveOptions? options, TransactionContext? transaction});
  Future<Id> deleteById(Id id, {DeleteOptions? options, TransactionContext? transaction});
  Stream<E?> watchById(Id id, {WatchByIdOptions? options});
  Stream<List<E>> watchAll({WatchAllOptions? options});
}
```

### UI Integration Pattern
```dart
// Wrap app with EntityStoreProviderScope
EntityStoreProviderScope(
  repositories: [repository],
  child: MyApp(),
)

// Watch entities in widgets
context.watchOne<String, TodoEntity>('id')
context.watchAll<String, TodoEntity>()
context.selectAll<String, TodoEntity, R>((entities) => ...)
```

## Version Requirements
- Dart SDK: ≥3.3.0
- Flutter: ≥1.17.0
- Current package versions: 6.0.0-dev series (pre-release)

## Important Notes
- The project uses FVM (Flutter Version Manager) - SDK path is `.fvm/flutter_sdk`
- All packages follow semantic versioning and are synchronized in the dev series
- Entity immutability is enforced by design - use `copyWith` patterns for updates
- Transaction support varies by backend (Firestore has full support, Sembast has partial)