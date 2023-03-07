// part of '../util.dart';

// class LoadingState<Id> {
//   final List<Id> loadedIds;
//   final bool hasMore;
//   final bool isLoading;

//   LoadingState({
//     required this.loadedIds,
//     required this.hasMore,
//     required this.isLoading,
//   });

//   factory LoadingState.init() {
//     return LoadingState(
//       loadedIds: [],
//       hasMore: true,
//       isLoading: false,
//     );
//   }

//   LoadingState<Id> copyWith({
//     List<Id>? loadedIds,
//     bool? hasMore,
//     bool? isLoading,
//   }) {
//     return LoadingState(
//       loadedIds: loadedIds ?? this.loadedIds,
//       hasMore: hasMore ?? this.hasMore,
//       isLoading: isLoading ?? this.isLoading,
//     );
//   }
// }

// abstract class InfiniteLoadingNotifier<Id, E extends Entity<Id>>
//     extends StateNotifier<LoadingState<Id>> {
//   InfiniteLoadingNotifier() : super(LoadingState.init());

//   IRepository<Id, E> get repo;

//   @mustCallSuper
//   Future<void> cursor(
//       RepositoryQuery<Id, E> Function(RepositoryQuery<Id, E>)
//           buildQuery) async {
//     if (!state.hasMore) return;
//     if (state.isLoading) return;
//     state = state.copyWith(isLoading: true);

//     final latestId = state.loadedIds.lastOrNull;
//     final entities = await repo.list(
//       (query) => latestId != null
//           ? buildQuery(query).startAfterId(latestId)
//           : buildQuery(query),
//     );

//     if (entities.isErr ||
//         entities.ok.isEmpty ||
//         entities.ok.lastOrNull?.id == latestId) {
//       state = state.copyWith(hasMore: false);
//     }

//     if (entities.isOk) {
//       state = state.copyWith(
//         loadedIds: state.loadedIds +
//             entities.ok
//                 .map((e) => e.id)
//                 .where((e) => !state.loadedIds.contains(e))
//                 .toList(),
//       );
//     }

//     state = state.copyWith(isLoading: false);
//   }

//   void init() {
//     state = LoadingState.init();
//   }

//   Future<void> load({
//     int limit = 10,
//   });
// }
