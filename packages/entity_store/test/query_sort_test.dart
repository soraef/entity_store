import 'package:entity_store/entity_store.dart';
import 'package:flutter_test/flutter_test.dart';

import 'entity.dart';

/// An in-memory query whose filters/sorts drive [IRepositoryQuery.findEntities].
class _SortOnly implements IRepositoryQuery<UserId, User> {
  _SortOnly(this.sorts);
  @override
  final List<RepositorySort> sorts;
  @override
  List<RepositoryFilter> get filters => const [];
  @override
  int? get limitNum => null;
  @override
  UserId? get startAfterId => null;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final objects = <Map<String, dynamic>>[
    {'id': 'b', 'endedAt': '2026-10-02T00:00:00Z'},
    {'id': 'unfinished', 'endedAt': null},
    {'id': 'c', 'endedAt': '2026-10-03T00:00:00Z'},
    {'id': 'a', 'endedAt': '2026-10-01T00:00:00Z'},
  ];

  List<String?> ids(List<Map<String, dynamic>> rows) =>
      rows.map((r) => r['id'] as String?).toList();

  test('sorting by a field some records lack does not throw', () {
    final descending = IRepositoryQuery.findEntities<User, UserId>(objects,
        _SortOnly([RepositorySort('endedAt', true)]));
    // Like SQLite: nulls last when descending.
    expect(ids(descending), ['c', 'b', 'a', 'unfinished']);

    final ascending = IRepositoryQuery.findEntities<User, UserId>(
        objects, _SortOnly([RepositorySort('endedAt', false)]));
    // Like SQLite: nulls first when ascending.
    expect(ids(ascending), ['unfinished', 'a', 'b', 'c']);
  });
}
