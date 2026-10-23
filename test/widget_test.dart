import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verso_admin/core/design/components/verso_button.dart';
import 'package:verso_admin/core/design/components/verso_card.dart';
import 'package:verso_admin/features/dashboard/models/dashboard_stats.dart';
import 'package:verso_admin/features/system/models/system_config.dart';

void main() {
  group('Models Unit Tests', () {
    test('SystemConfig defaults and copyWith work as expected', () {
      const config = SystemConfig();
      expect(config.forceUpdate, isFalse);
      expect(config.maintenanceMode, isFalse);
      expect(config.minRequiredVersion, '2.0.0');

      final updated = config.copyWith(
        forceUpdate: true,
        minRequiredVersion: '2.5.0',
      );
      expect(updated.forceUpdate, isTrue);
      expect(updated.minRequiredVersion, '2.5.0');
    });

    test('DashboardStats empty constructor initializes correctly', () {
      final stats = DashboardStats.empty();
      expect(stats.totalUsers, 0);
      expect(stats.activeReadersToday, 0);
      expect(stats.newSignupsToday, 0);
      expect(stats.openFeedbackCount, 0);
    });
  });

  group('Design System Widget Tests', () {
    testWidgets('VersoButton renders label and handles tap', (tester) async {
      var wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VersoButton(
              label: 'Test Button',
              onPressed: () => wasPressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
      await tester.tap(find.byType(VersoButton));
      expect(wasPressed, isTrue);
    });

    testWidgets('VersoCard displays child widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VersoCard(
              child: Text('Card Content'),
            ),
          ),
        ),
      );

      expect(find.text('Card Content'), findsOneWidget);
    });
  });
}
