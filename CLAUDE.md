# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

EntityStore is a Dart/Flutter monorepo providing entity-centric state management. It uses the repository pattern to abstract data sources, with reactive UI integration via the Provider package. Managed with **Melos**.

## Packages

- **entity_store** (v6.0.0) — Core package: `Entity<Id>` interface, `EntityStore`, `EntityStoreController`, `EntityStoreNotifier`, `Repository` interface, `StorageRepository` with `IDataSourceHandler`, and Provider-based UI extensions (`watchOne`, `watchAll`, `selectOne`, `selectAll`, `readOne`, `readAll`).
- **entity_store_firestore** (v6.0.0) — Firestore backend via `cloud_firestore`. Supports transactions.
- **entity_store_sembast** (v6.0.1) — Sembast local database backend.
- **entity_store_isar** (v6.0.2) — Isar database backend using `isar_community` packages.

## Common Commands

```bash
# Install dependencies (all packages)
melos pub_get

# Run analysis
melos analyze

# Apply dart fixes
melos fix_apply

# Run tests for a specific package
cd packages/entity_store && fvm flutter test
cd packages/entity_store_firestore && fvm flutter test
cd packages/entity_store_sembast && fvm flutter test

# Run a single test file
cd packages/entity_store && fvm flutter test test/entity_store_test.dart

# Code generation (build_runner)
melos build_runner_watch
```

Uses **FVM** (Flutter Version Manager) — Flutter 3.29.2, SDK path `.fvm/flutter_sdk`. Use `fvm flutter` to run Flutter commands.

## Architecture

### Data Flow

```
UI (BuildContext extensions) → EntityStoreNotifier (ChangeNotifier)
    ↕ watches/selects
EntityStore (immutable state container of EntityMap<Id, E>)
    ↕ dispatches PersistenceEvents
EntityStoreController → Repository → DataSource/Backend
```

### Key Layers

1. **Entity** (`Entity<Id>`) — Immutable data objects with a unique `id`. State changes produce new instances.
2. **EntityStore** — Immutable container holding `EntityMap<Id, E>` collections keyed by entity type.
3. **EntityStoreNotifier** — `ChangeNotifier` wrapping `EntityStore`, drives UI rebuilds via Provider.
4. **EntityStoreController** — Dispatches `PersistenceEvent`s (Get, Save, Delete, List) that mutate the store. Bridges repositories and the store.
5. **Repository** (`Repository<Id, E>`) — Interface for CRUD + query + observe. All operations support optional `TransactionContext`.
6. **StorageRepository** — Abstract base using `IDataSourceHandler` for pluggable backends. Subclasses must implement `toJson`, `fromJson`, `idToString`.
7. **EntityStoreProviderScope** — Widget that provides `EntityStoreNotifier` via `ChangeNotifierProvider`. Must wrap the widget tree.

### UI Integration

`BuildContext` extensions for reactive entity access:
- `watchOne<Id, E>(id)` / `watchAll<Id, E>()` — Rebuilds widget on entity changes
- `selectOne<Id, E, T>(id, selector)` / `selectAll<Id, E, T>(selector)` — Selective rebuilds
- `readOne<Id, E>(id)` / `readAll<Id, E>()` — One-time reads without subscribing

### Backend Packages

Each backend package provides an `IDataSourceHandler` or `Repository` implementation. Repositories must be constructed with an `EntityStoreController` and their backend-specific handler/configuration. Subclasses override `toJson`/`fromJson`/`idToString` for serialization.

### FetchPolicy

Repository `findById` supports `FetchPolicy`:
- `storeFirst` — Return from in-memory store if available, else fetch from data source
- `storeOnly` — Only return from in-memory store
- `persistent` (default) — Always fetch from data source

## Conventions

- Entities must be immutable; use factory constructors or `copyWith` for state changes
- Dart SDK ≥3.3.0
- Package dependencies reference published versions (path dependencies are commented out for local dev)
