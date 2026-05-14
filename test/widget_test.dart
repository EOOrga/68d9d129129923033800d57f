import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aulard_ops/main.dart';

void main() {
  testWidgets('shows the operations dashboard and module navigation', (
    tester,
  ) async {
    final store = OperationsStore.memory();

    await tester.pumpWidget(AulardOpsApp(store: store));
    await tester.pumpAndSettle();

    expect(find.text('Operations hub'), findsOneWidget);
    expect(find.text('Priority queue'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('nav-quality')));
    await tester.pumpAndSettle();

    expect(find.text('Quality control'), findsOneWidget);
    expect(find.text('Dispatch lane 4'), findsOneWidget);
  });

  testWidgets('creates a local visitor record from the form', (tester) async {
    final store = OperationsStore.memory([]);

    await tester.pumpWidget(AulardOpsApp(store: store));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('nav-visitors')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('add-visitor-button')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('record-title-field')),
      'Morgan Vale',
    );
    await tester.enterText(
      find.byKey(const ValueKey('record-subtitle-field')),
      'Safety vendor | Host: Claire R.',
    );
    await tester.enterText(
      find.byKey(const ValueKey('record-detail-field')),
      'Arriving for a controlled access maintenance review.',
    );

    await tester.tap(find.byKey(const ValueKey('save-record-button')));
    await tester.pumpAndSettle();

    expect(store.recordsFor(ModuleType.visitor), hasLength(1));
    expect(find.text('Morgan Vale'), findsOneWidget);
  });

  testWidgets('opens the local privacy settings screen', (tester) async {
    final store = OperationsStore.memory();

    await tester.pumpWidget(AulardOpsApp(store: store));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('settings-button')));
    await tester.pumpAndSettle();

    expect(find.text('Local privacy'), findsOneWidget);
    expect(find.text('No cloud sync'), findsOneWidget);
  });
}
