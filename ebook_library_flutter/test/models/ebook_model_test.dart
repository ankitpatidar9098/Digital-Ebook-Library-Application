// test/models/ebook_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:ebook_library_flutter/models/ebook.dart';

void main() {
  group('Ebook.fromJson', () {
    final json = {
      'id':             1,
      'title':          'Test Book',
      'author':         'Test Author',
      'file_format':    'pdf',
      'file_size':      1024000,
      'file_size_human': '1.0 MB',
      'description':    'A test description',
      'read_position':  5,
      'last_read_at':   null,
      'created_at':     '2024-01-15T10:30:00.000Z',
      'file_url':       'http://localhost:3000/rails/active_storage/blobs/test.pdf',
      'cover_url':      null,
      'filename':       'test.pdf',
    };

    test('parses required fields correctly', () {
      final ebook = Ebook.fromJson(json);
      expect(ebook.id,          1);
      expect(ebook.title,       'Test Book');
      expect(ebook.author,      'Test Author');
      expect(ebook.fileFormat,  'pdf');
      expect(ebook.fileSize,    1024000);
      expect(ebook.readPosition, 5);
    });

    test('parses dates correctly', () {
      final ebook = Ebook.fromJson(json);
      expect(ebook.createdAt, isA<DateTime>());
      expect(ebook.lastReadAt, isNull);
    });

    test('handles missing author gracefully', () {
      final noAuthor = Map<String, dynamic>.from(json)..['author'] = null;
      final ebook    = Ebook.fromJson(noAuthor);
      expect(ebook.author, isNull);
      expect(ebook.authorDisplay, 'Unknown Author');
    });

    test('handles missing title with fallback', () {
      final noTitle = Map<String, dynamic>.from(json)..['title'] = null;
      final ebook   = Ebook.fromJson(noTitle);
      expect(ebook.title, 'Untitled');
    });
  });

  group('Ebook helpers', () {
    final ebook = Ebook(
      id:            1,
      title:         'The Hobbit',
      author:        'Tolkien',
      fileFormat:    'pdf',
      fileSize:      2000000,
      fileSizeHuman: '2.0 MB',
      readPosition:  10,
      createdAt:     DateTime(2024, 1, 15),
      lastReadAt:    DateTime(2024, 1, 16),
    );

    test('isPdf returns true for pdf format', () {
      expect(ebook.isPdf,  isTrue);
      expect(ebook.isEpub, isFalse);
    });

    test('hasBeenRead returns true when readPosition > 0', () {
      expect(ebook.hasBeenRead, isTrue);
    });

    test('hasCover returns false when coverUrl is null', () {
      expect(ebook.hasCover, isFalse);
    });

    test('formatBadge returns uppercase format', () {
      expect(ebook.formatBadge, 'PDF');
    });

    test('copyWith creates new instance with updated fields', () {
      final updated = ebook.copyWith(readPosition: 42);
      expect(updated.readPosition, 42);
      expect(updated.title,        ebook.title);   // unchanged
    });

    test('equality by id', () {
      final same    = Ebook(id: 1, title: 'Other',    fileFormat: 'epub', fileSize: 0, fileSizeHuman: '', readPosition: 0, createdAt: DateTime.now());
      final different = Ebook(id: 2, title: 'Hobbit', fileFormat: 'pdf',  fileSize: 0, fileSizeHuman: '', readPosition: 0, createdAt: DateTime.now());
      expect(ebook == same,      isTrue);
      expect(ebook == different, isFalse);
    });
  });

  group('Ebook EPUB', () {
    test('isEpub returns true for epub format', () {
      final epub = Ebook(
        id:            2,
        title:         'Epub Book',
        fileFormat:    'epub',
        fileSize:      500000,
        fileSizeHuman: '500 KB',
        readPosition:  0,
        createdAt:     DateTime.now(),
      );
      expect(epub.isEpub, isTrue);
      expect(epub.isPdf,  isFalse);
    });
  });
}
