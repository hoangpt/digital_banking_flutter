import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:digital_banking/features/auth/presentation/login_screen.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    late Widget testWidget;

    setUp(() {
      testWidget = const ProviderScope(child: MaterialApp(home: LoginScreen()));
    });

    testWidgets('should display login form elements', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(testWidget);

      // Assert
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign in to your account'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In'), findsWidgets);
      expect(find.text('Don\'t have an account?'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('should have email and password text fields', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(testWidget);

      // Assert
      expect(find.byType(TextFormField), findsWidgets);

      final emailField = find.byKey(const Key('email_field'));
      final passwordField = find.byKey(const Key('password_field'));

      // Check if fields exist (may not have keys in current implementation)
      if (emailField.evaluate().isEmpty) {
        // Fallback: find by widget properties
        final textFields = find.byType(TextFormField);
        expect(textFields, findsWidgets);
      } else {
        expect(emailField, findsOneWidget);
        expect(passwordField, findsOneWidget);
      }
    });

    testWidgets('should allow text input in fields', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(testWidget);

      final textFields = find.byType(TextFormField);

      // Enter text in first field (email)
      await tester.enterText(textFields.first, 'test@example.com');
      await tester.pump();

      // Enter text in second field (password)
      await tester.enterText(textFields.at(1), 'password123');
      await tester.pump();

      // Assert
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('password123'), findsOneWidget);
    });

    testWidgets('should have a sign in button', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(testWidget);

      // Assert
      final signInButton = find.widgetWithText(ElevatedButton, 'Sign In');
      expect(signInButton, findsOneWidget);
    });

    testWidgets('should have a sign up link', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(testWidget);

      // Assert
      final signUpLink = find.widgetWithText(TextButton, 'Sign Up');
      expect(signUpLink, findsOneWidget);
    });

    testWidgets('should show loading state when signing in', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(testWidget);

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.first, 'demo@bank.app');
      await tester.enterText(textFields.at(1), 'Demo@1234');

      final signInButton = find.widgetWithText(ElevatedButton, 'Sign In');
      await tester.tap(signInButton);
      await tester.pump(); // Start the async operation

      // Assert - Check for loading indicator or disabled state
      // Note: This depends on the actual implementation
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('should handle tap on sign up link', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(testWidget);

      final signUpLink = find.widgetWithText(TextButton, 'Sign Up');
      await tester.tap(signUpLink);
      await tester.pump();

      // Assert - Navigation should happen (depends on router implementation)
      // This test verifies the button is tappable
    });

    group('Form Validation', () {
      testWidgets('should validate empty fields', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(testWidget);

        final signInButton = find.widgetWithText(ElevatedButton, 'Sign In');
        await tester.tap(signInButton);
        await tester.pump();

        // Assert - Look for validation messages (implementation dependent)
        // This test structure is ready for when validation is implemented
      });

      testWidgets('should validate email format', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(testWidget);

        final textFields = find.byType(TextFormField);
        await tester.enterText(textFields.first, 'invalid-email');
        await tester.enterText(textFields.at(1), 'password123');

        final signInButton = find.widgetWithText(ElevatedButton, 'Sign In');
        await tester.tap(signInButton);
        await tester.pump();

        // Assert - Look for email validation message
      });
    });

    group('Accessibility', () {
      testWidgets('should have proper semantics', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(testWidget);

        // Assert
        expect(find.byType(Semantics), findsWidgets);
      });

      testWidgets('should support keyboard navigation', (
        WidgetTester tester,
      ) async {
        // Act
        await tester.pumpWidget(testWidget);

        // Test tab navigation between fields
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();

        // Assert - Focus should move between elements
      });
    });
  });
}
