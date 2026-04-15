import 'package:entity_store_flutter/entity_store_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class TestEntity extends Entity<String> {
  @override
  final String id;

  final String name;

  TestEntity({
    required this.id,
    required this.name,
  });
}

void main() {
  testWidgets('EntityStoreProviderScope exposes notifier-backed state', (
    tester,
  ) async {
    final notifier = EntityStoreNotifier();
    final controller = EntityStoreController(notifier);
    controller.put<String, TestEntity>(TestEntity(id: '1', name: 'Alice'));

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: EntityStoreProviderScope(
          entityStoreNotifier: notifier,
          child: Builder(
            builder: (context) {
              final entity = context.watchOne<String, TestEntity>('1');
              return Text(entity?.name ?? 'missing');
            },
          ),
        ),
      ),
    );

    expect(find.text('Alice'), findsOneWidget);
  });
}
