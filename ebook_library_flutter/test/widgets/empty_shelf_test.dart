// test/widgets/empty_shelf_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ebook_library_flutter/widgets/empty_shelf.dart';
import 'package:ebook_library_flutter/theme/app_theme.dart';

void main() {
  testWidgets('renders empty shelf text', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(body: EmptyShelf()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Your shelf is empty'), findsOneWidget);
    expect(find.text('Add Your First Book'),  findsOneWidget);
  });

  testWidgets('shows descriptive subtitle', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(body: EmptyShelf()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('digital library'), findsOneWidget);
  });

  testWidgets('has an add book button', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(body: EmptyShelf()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
