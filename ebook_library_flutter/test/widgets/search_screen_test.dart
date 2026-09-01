// test/widgets/search_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ebook_library_flutter/providers/search_provider.dart';
import 'package:ebook_library_flutter/screens/search_screen.dart';
import 'package:ebook_library_flutter/theme/app_theme.dart';

Widget _buildTestApp() => MaterialApp(
  theme: AppTheme.dark,
  home: ChangeNotifierProvider(
    create: (_) => SearchProvider(),
    child: const SearchScreen(),
  ),
);

void main() {
  testWidgets('shows initial hint state', (tester) async {
    await tester.pumpWidget(_buildTestApp());
    await tester.pump();

    expect(find.text('Search your library'),     findsOneWidget);
    expect(find.text('Find books by title, author, or filename'), findsOneWidget);
  });
}
