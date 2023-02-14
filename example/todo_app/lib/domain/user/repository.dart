import 'package:entity_store_firestore/entity_store_firestore.dart';

import 'entity.dart';
import 'id.dart';

final userCollectionType = CollectionType<UserId, User>(
  fromJson: User.fromJson,
  toJson: (e) => e.toJson(),
  idToString: (e) => e.value,
  collectionName: "User",
);
