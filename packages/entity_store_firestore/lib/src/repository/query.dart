import 'package:entity_store/entity_store.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as f;

extension QueryX on Query {
  f.Query buildFilterQuery(f.Query query) {
    for (final filter in getFilters) {
      switch (filter.operator) {
        case FilterOperator.isEqualTo:
          query = query.where(filter.field, isEqualTo: filter.value);
          break;
        case FilterOperator.isNotEqualTo:
          query = query.where(filter.field, isNotEqualTo: filter.value);
          break;
        case FilterOperator.isLessThan:
          query = query.where(filter.field, isLessThan: filter.value);
          break;
        case FilterOperator.isLessThanOrEqualTo:
          query = query.where(filter.field, isLessThanOrEqualTo: filter.value);
          break;
        case FilterOperator.isGreaterThan:
          query = query.where(filter.field, isGreaterThan: filter.value);
          break;
        case FilterOperator.isGreaterThanOrEqualTo:
          query =
              query.where(filter.field, isGreaterThanOrEqualTo: filter.value);
          break;
        case FilterOperator.arrayContains:
          query = query.where(filter.field, arrayContains: filter.value);
          break;
        case FilterOperator.arrayContainsAny:
          query = query.where(filter.field, arrayContainsAny: filter.value);
          break;
        case FilterOperator.whereIn:
          query = query.where(filter.field, whereIn: filter.value);
          break;
        case FilterOperator.whereNotIn:
          query = query.where(filter.field, whereNotIn: filter.value);
          break;
        case FilterOperator.isNull:
          query = query.where(filter.field, isNull: filter.value);
          break;
      }
    }
    return query;
  }

  f.Query buildSortQuery(f.Query query) {
    for (final sort in getSorts) {
      query = query.orderBy(sort.field, descending: sort.descending);
    }
    return query;
  }

  f.Query buildLimitQuery(f.Query query) {
    final lim = getLimit;
    if (lim != null) {
      return query.limit(lim);
    }
    return query;
  }
}
