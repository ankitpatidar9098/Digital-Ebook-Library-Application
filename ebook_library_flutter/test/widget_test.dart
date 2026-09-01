// test/widget_test.dart
// Master test runner — imports all widget tests

import 'package:flutter_test/flutter_test.dart';

import 'widgets/empty_shelf_test.dart'    as empty_shelf;
import 'widgets/error_view_test.dart'     as error_view;
import 'widgets/search_screen_test.dart'  as search_screen;
import 'providers/ebook_provider_test.dart' as ebook_provider;
import 'models/ebook_model_test.dart'     as ebook_model;

void main() {
  group('EmptyShelf Widget', empty_shelf.main);
  group('ErrorView Widget',  error_view.main);
  group('Search Screen',     search_screen.main);
  group('EbookProvider',     ebook_provider.main);
  group('Ebook Model',       ebook_model.main);
}
