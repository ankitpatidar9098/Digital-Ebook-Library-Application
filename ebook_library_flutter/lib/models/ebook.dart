// lib/models/ebook.dart
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class Ebook {
  final int id;
  final String title;
  final String? author;
  final String fileFormat;
  final int fileSize;
  final String fileSizeHuman;
  final String? description;
  final int readPosition;
  final DateTime? lastReadAt;
  final DateTime createdAt;
  final String? fileUrl;
  final String? coverUrl;
  final String? filename;

  String? get fullFileUrl => fileUrl != null ? '${ApiService.hostUrl}$fileUrl' : null;
  String? get fullCoverUrl => coverUrl != null ? '${ApiService.hostUrl}$coverUrl' : null;

  const Ebook({
    required this.id,
    required this.title,
    this.author,
    required this.fileFormat,
    required this.fileSize,
    required this.fileSizeHuman,
    this.description,
    required this.readPosition,
    this.lastReadAt,
    required this.createdAt,
    this.fileUrl,
    this.coverUrl,
    this.filename,
  });

  factory Ebook.fromJson(Map<String, dynamic> json) {
    return Ebook(
      id:            json['id'] as int,
      title:         json['title'] as String? ?? 'Untitled',
      author:        json['author'] as String?,
      fileFormat:    json['file_format'] as String? ?? 'pdf',
      fileSize:      json['file_size'] as int? ?? 0,
      fileSizeHuman: json['file_size_human'] as String? ?? 'Unknown',
      description:   json['description'] as String?,
      readPosition:  json['read_position'] as int? ?? 0,
      lastReadAt:    json['last_read_at'] != null
          ? DateTime.tryParse(json['last_read_at'] as String)
          : null,
      createdAt:     DateTime.parse(json['created_at'] as String),
      fileUrl:       json['file_url'] as String?,
      coverUrl:      json['cover_url'] as String?,
      filename:      json['filename'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':             id,
    'title':          title,
    'author':         author,
    'file_format':    fileFormat,
    'file_size':      fileSize,
    'file_size_human': fileSizeHuman,
    'description':    description,
    'read_position':  readPosition,
    'last_read_at':   lastReadAt?.toIso8601String(),
    'created_at':     createdAt.toIso8601String(),
    'file_url':       fileUrl,
    'cover_url':      coverUrl,
    'filename':       filename,
  };

  Ebook copyWith({
    int? readPosition,
    DateTime? lastReadAt,
    String? coverUrl,
  }) =>
      Ebook(
        id:            id,
        title:         title,
        author:        author,
        fileFormat:    fileFormat,
        fileSize:      fileSize,
        fileSizeHuman: fileSizeHuman,
        description:   description,
        readPosition:  readPosition ?? this.readPosition,
        lastReadAt:    lastReadAt ?? this.lastReadAt,
        createdAt:     createdAt,
        fileUrl:       fileUrl,
        coverUrl:      coverUrl ?? this.coverUrl,
        filename:      filename,
      );

  // Helpers
  bool get isPdf  => fileFormat.toLowerCase() == 'pdf';
  bool get isEpub => fileFormat.toLowerCase() == 'epub';
  bool get hasCover => coverUrl != null && coverUrl!.isNotEmpty;
  bool get hasBeenRead => readPosition > 0;

  String get formattedDate =>
      DateFormat('MMM d, yyyy').format(createdAt);

  String get authorDisplay => author?.isNotEmpty == true ? author! : 'Unknown Author';

  String get formatBadge => fileFormat.toUpperCase();

  @override
  bool operator ==(Object other) => other is Ebook && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Ebook(id: $id, title: $title)';
}
