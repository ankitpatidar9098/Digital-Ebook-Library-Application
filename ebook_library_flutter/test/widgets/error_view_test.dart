// test/widgets/error_view_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ebook_library_flutter/widgets/error_view.dart';
import 'package:ebook_library_flutter/theme/app_theme.dart';

void main() {
  testWidgets('shows error message', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(
          body: ErrorView(message: 'Cannot connect to server'),
        ),
      ),
    );

    expect(find.text('Something went wrong'),        findsOneWidget);
    expect(find.text('Cannot connect to server'),    findsOneWidget);
  });

  testWidgets('shows retry button when onRetry provided', (tester) async {
    var retryTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: ErrorView(
            message: 'Error',
            onRetry: () => retryTapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Try Again'), findsOneWidget);
    await tester.tap(find.text('Try Again'));
    expect(retryTapped, isTrue);
  });

  testWidgets('hides retry button when onRetry is null', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(
          body: ErrorView(message: 'Error'),
        ),
      ),
    );

    expect(find.text('Try Again'), findsNothing);
  });
}
