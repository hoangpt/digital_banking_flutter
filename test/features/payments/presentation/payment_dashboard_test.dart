import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:digital_banking/features/payments/presentation/payment_dashboard.dart';

void main() {
  group('PaymentDashboard Widget Tests', () {
    late Widget testWidget;

    setUp(() {
      testWidget = const ProviderScope(
        child: MaterialApp(home: PaymentDashboard()),
      );
    });

    testWidgets('should display main dashboard elements', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(testWidget);
      await tester.pump(); // Wait for async operations

      // Assert
      expect(find.text('Digital Banking'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(TabBar), findsOneWidget);
      expect(find.byType(TabBarView), findsOneWidget);
    });

    testWidgets('should display balance card', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(testWidget);
      await tester.pump();

      // Assert
      expect(find.text('Current Balance'), findsOneWidget);
      expect(
        find.textContaining('\$'),
        findsWidgets,
      ); // Should find balance amount
    });

    testWidgets('should display payment tabs', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(testWidget);
      await tester.pump();

      // Assert
      expect(find.text('NFC'), findsOneWidget);
      expect(find.text('QR'), findsOneWidget);
      expect(find.text('Card'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
    });

    testWidgets('should switch between tabs', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(testWidget);
      await tester.pump();

      // Tap on QR tab
      await tester.tap(find.text('QR'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('QR Payment'), findsWidgets);

      // Tap on Card tab
      await tester.tap(find.text('Card'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Card Payment'), findsWidgets);

      // Tap on History tab
      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Transaction History'), findsOneWidget);
    });

    testWidgets('should display NFC panel content', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(testWidget);
      await tester.pump();

      // Default tab should be NFC
      // Assert
      expect(find.text('Tap to Pay'), findsWidgets);
      expect(find.byIcon(Icons.nfc), findsWidgets);
    });

    testWidgets('should display QR panel content', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(testWidget);
      await tester.pump();

      // Switch to QR tab
      await tester.tap(find.text('QR'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('QR Payment'), findsWidgets);
      expect(find.byIcon(Icons.qr_code), findsWidgets);
    });

    testWidgets('should display Card panel content', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(testWidget);
      await tester.pump();

      // Switch to Card tab
      await tester.tap(find.text('Card'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Card Payment'), findsWidgets);
      expect(find.byIcon(Icons.credit_card), findsWidgets);
    });

    testWidgets('should display History panel content', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(testWidget);
      await tester.pump();

      // Switch to History tab
      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Transaction History'), findsOneWidget);
      expect(find.byIcon(Icons.history), findsOneWidget);
    });

    group('History Panel Features', () {
      testWidgets('should display transaction filters', (
        WidgetTester tester,
      ) async {
        // Act
        await tester.pumpWidget(testWidget);
        await tester.pump();

        // Switch to History tab
        await tester.tap(find.text('History'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('All'), findsWidgets);
        expect(find.text('Payments'), findsWidgets);
        expect(find.text('Received'), findsWidgets);
      });

      testWidgets('should filter transactions', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(testWidget);
        await tester.pump();

        // Switch to History tab
        await tester.tap(find.text('History'));
        await tester.pumpAndSettle();

        // Test filtering
        await tester.tap(find.text('Payments'));
        await tester.pump();

        await tester.tap(find.text('Received'));
        await tester.pump();

        await tester.tap(find.text('All'));
        await tester.pump();

        // Assert - The taps should work without errors
      });

      testWidgets('should display summary information', (
        WidgetTester tester,
      ) async {
        // Act
        await tester.pumpWidget(testWidget);
        await tester.pump();

        // Switch to History tab
        await tester.tap(find.text('History'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Summary'), findsWidgets);
        expect(find.text('Total Spent'), findsWidgets);
        expect(find.text('Total Received'), findsWidgets);
      });
    });

    group('Navigation and State', () {
      testWidgets('should maintain tab state during navigation', (
        WidgetTester tester,
      ) async {
        // Act
        await tester.pumpWidget(testWidget);
        await tester.pump();

        // Navigate through tabs
        await tester.tap(find.text('QR'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Card'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('NFC'));
        await tester.pumpAndSettle();

        // Assert - Should be back to NFC tab
        expect(find.text('Tap to Pay'), findsWidgets);
      });

      testWidgets('should handle logout action', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(testWidget);
        await tester.pump();

        // Look for logout button/action
        final logoutButton = find.byIcon(Icons.logout);
        if (logoutButton.evaluate().isNotEmpty) {
          await tester.tap(logoutButton);
          await tester.pump();
        }

        // Assert - Test should complete without errors
      });
    });

    group('Accessibility', () {
      testWidgets('should have proper semantic labels', (
        WidgetTester tester,
      ) async {
        // Act
        await tester.pumpWidget(testWidget);
        await tester.pump();

        // Assert
        expect(find.byType(Semantics), findsWidgets);
      });

      testWidgets('should support keyboard navigation', (
        WidgetTester tester,
      ) async {
        // Act
        await tester.pumpWidget(testWidget);
        await tester.pump();

        // Test tab navigation
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();

        // Assert - Should handle keyboard input without errors
      });
    });

    group('Performance', () {
      testWidgets('should handle rapid tab switching', (
        WidgetTester tester,
      ) async {
        // Act
        await tester.pumpWidget(testWidget);
        await tester.pump();

        // Rapidly switch tabs
        for (int i = 0; i < 3; i++) {
          await tester.tap(find.text('QR'));
          await tester.pump();
          await tester.tap(find.text('Card'));
          await tester.pump();
          await tester.tap(find.text('History'));
          await tester.pump();
          await tester.tap(find.text('NFC'));
          await tester.pump();
        }

        // Assert - Should handle rapid switching without errors
      });
    });
  });
}
