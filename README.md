# 📚 Digital Ebook Library Application

> **Full-Stack Developer Assignment** — Sagar Fab International Company  
> Built with **Ruby on Rails 7.2** (API backend) + **Flutter** (cross-platform frontend)

---

## 🎯 Project Overview

A complete digital ebook library application that allows users to:
- 📤 Upload PDF and EPUB ebooks
- 📖 Read ebooks in-app (PDF viewer + EPUB reader)
- 🔍 Search by title, author, or filename (with highlighting)
- 📥 Download ebooks to device storage
- 🗑️ Delete ebooks with confirmation
- 🏷️ Browse a **classic bookshelf-style UI** inspired by the iOS ebook library experience

The application is designed as a real product — not a CRUD demo — with attention to UX edge cases, loading states, error handling, and visual polish.

---

## 🛠 Tech Stack

| Layer     | Technology                              |
|-----------|----------------------------------------|
| Backend   | Ruby on Rails 7.2 (API mode)           |
| Database  | SQLite (development & test)             |
| Storage   | Active Storage (local disk service)     |
| Frontend  | Flutter (Android + iOS + Windows)       |
| State Mgmt | Provider pattern                       |
| HTTP      | Dio                                    |
| PDF Viewer | Syncfusion Flutter PDF Viewer         |
| EPUB      | epub_view                              |
| Testing   | RSpec (backend), Flutter Test (frontend)|

---

## 📁 Project Structure

```
Digital Ebook Library Application/
├── ebook_library_backend/          # Rails API backend
│   ├── app/
│   │   ├── controllers/api/        # EbooksController
│   │   ├── models/                 # Ebook model
│   │   ├── serializers/            # EbookSerializer
│   │   └── jobs/                   # GenerateCoverJob (PDF cover extraction)
│   ├── spec/                       # RSpec tests
│   │   ├── models/                 # Model specs
│   │   ├── requests/api/           # Request/endpoint specs
│   │   └── factories/              # FactoryBot factories
│   ├── db/migrate/                 # Database migrations
│   └── config/                     # Routes, database, storage
│
└── ebook_library_flutter/          # Flutter frontend app
    ├── lib/
    │   ├── models/                 # Ebook Dart class
    │   ├── services/               # ApiService (Dio)
    │   ├── providers/              # EbookProvider, SearchProvider
    │   ├── screens/                # Library, Upload, Detail, Reader, Search
    │   ├── widgets/                # BookShelfRow, EmptyShelf, Shimmer, etc.
    │   └── theme/                  # AppTheme (dark, amber/wood palette)
    └── test/                       # Widget + model + provider tests
```

---

## ⚙️ Setup Instructions

### Prerequisites

| Tool            | Version  | Install |
|-----------------|----------|---------|
| Ruby            | 3.3.x    | https://rubyinstaller.org (Windows) or `rbenv install 3.3.0` |
| Rails           | 7.2.x    | Comes via bundler |
| SQLite3         | 3.x      | https://sqlite.org/download.html |
| ImageMagick     | 7.x      | https://imagemagick.org/script/download.php (for cover gen) |
| Flutter SDK     | 3.22+    | https://flutter.dev/docs/get-started/install |
| Dart            | 3.3+     | Included with Flutter |

---

### 🚀 Running the Backend

```bash
# 1. Navigate to backend directory
cd ebook_library_backend

# 2. Install dependencies
bundle install

# 3. Create & migrate database
bundle exec rails db:create
bundle exec rails db:migrate

# 4. (Optional) Seed with sample ebooks
bundle exec rails db:seed

# 5. Start the server
bundle exec rails server -p 3000
```

The API will be available at: **http://localhost:3000**

---

### 📱 Running the Flutter App

```bash
# 1. Navigate to Flutter directory
cd ebook_library_flutter

# 2. Get dependencies
flutter pub get

# 3. Check available devices
flutter devices

# 4. Run the app (pick your device)
flutter run

# For Android emulator specifically:
flutter run -d emulator-5554

# For Windows desktop:
flutter run -d windows
```

> **Important:** If running on Android emulator, the backend URL in `lib/services/api_service.dart` should be `http://10.0.2.2:3000/api`.  
> For iOS simulator or desktop, change to `http://localhost:3000/api`.

---

### 🧪 Running Tests

**Backend tests (RSpec):**
```bash
cd ebook_library_backend
bundle exec rspec --format documentation
```

**Backend tests with coverage summary:**
```bash
bundle exec rspec --format documentation --format progress
```

**Flutter tests:**
```bash
cd ebook_library_flutter
flutter test
```

**Flutter tests with verbose output:**
```bash
flutter test --reporter expanded
```

---

## 🌐 API Overview

Base URL: `http://localhost:3000/api`

| Method  | Endpoint                              | Description                         |
|---------|---------------------------------------|-------------------------------------|
| `GET`   | `/ebooks`                             | List all ebooks (sort, filter, page)|
| `POST`  | `/ebooks`                             | Upload a new ebook (multipart form) |
| `GET`   | `/ebooks/:id`                         | Get single ebook details            |
| `GET`   | `/ebooks/search?q=keyword`            | Search ebooks (title/author/file)   |
| `GET`   | `/ebooks/:id/download`                | Download ebook file                 |
| `PATCH` | `/ebooks/:id/read_position`           | Save last read page                 |
| `DELETE`| `/ebooks/:id`                         | Delete ebook and file               |
| `GET`   | `/up`                                 | Health check                        |

### Query Parameters

| Param      | Values                | Default   |
|------------|-----------------------|-----------|
| `sort`     | `recent, title, author` | `recent` |
| `format`   | `pdf, epub`           | (all)     |
| `page`     | integer               | `1`       |
| `per_page` | integer               | `20`      |

### Example Responses

**GET /api/ebooks**
```json
{
  "ebooks": [
    {
      "id": 1,
      "title": "The Great Gatsby",
      "author": "F. Scott Fitzgerald",
      "file_format": "pdf",
      "file_size": 2500000,
      "file_size_human": "2.5 MB",
      "read_position": 0,
      "last_read_at": null,
      "created_at": "2024-09-01T10:00:00.000Z",
      "file_url": "http://localhost:3000/rails/active_storage/blobs/...",
      "cover_url": "http://localhost:3000/rails/active_storage/blobs/...",
      "filename": "the-great-gatsby.pdf"
    }
  ],
  "pagination": {
    "count": 8,
    "page": 1,
    "pages": 1,
    "limit": 20
  }
}
```

**POST /api/ebooks (multipart/form-data)**
```
ebook[title] = "My Book"
ebook[author] = "John Doe"
ebook[file] = <PDF/EPUB file>
ebook[cover_image] = <image file> (optional)
```

---

## 🎨 UI / Design Decisions

### Bookshelf UI
- Books displayed as vertical spines on **wooden shelf rows** (4 per row)
- Each book has a unique gradient color from a curated 8-color palette
- **Lift animation** on tap — book "rises" from the shelf
- **Long-press context menu** for quick open/delete
- Custom `_WoodGrainPainter` for shelf texture

### Empty Shelf State
- Custom-painted wooden shelf with ghost book outlines
- Fade-in + slide-up entrance animation
- Clear CTA to add first book

### Loading State
- Shimmer skeleton matching the exact shelf layout

### Search
- **400ms debounce** to avoid excessive API calls on every keystroke
- **Search result highlighting** — matched term shown in amber
- Separate format/sort filters in search

### Reading Experience
- **PDF**: SfPdfViewer with page slider, prev/next buttons, zoom, fullscreen
- **EPUB**: epub_view with chapter dividers
- **Auto-save read position** on exit (PATCH request)
- Controls auto-hide after 4 seconds; tap to show

---

## 🤖 AI Tool Usage

### Tools Used
- **Antigravity IDE** (AI coding assistant) for code generation and architecture decisions
- **Reasoning model** for architectural discussions

### How AI Was Used
1. **Architecture design** — Discussed tradeoffs between different state management options (Provider vs Riverpod vs Bloc)
2. **Boilerplate generation** — Generated standard Rails API controller patterns and Flutter Provider scaffolding
3. **Edge case identification** — AI helped enumerate edge cases (file too large, wrong type, network timeout, etc.)
4. **Test structure** — Generated RSpec request spec structure following given/when/then patterns
5. **Bookshelf UI concept** — Custom `CustomPainter` for wood grain and ghost book outlines was AI-assisted

### What Was Manually Reviewed / Improved
- The `Ebook` model search query (the `.or()` with JOIN was simplified after testing showed SQL join issues)
- The `PdfViewerController.jumpToPage()` — initially the position was off by 1
- Download flow in `ebook_detail_screen.dart` — added proper `getDownloadsDirectory()` fallback
- CORS configuration — ensured `expose: ["Content-Disposition"]` was included for download headers
- `GenerateCoverJob` graceful failure (non-fatal) was added after realizing ImageMagick might not be installed

### AI Code Rejected / Corrected
- Initial suggestion to use `blueprinter` was replaced with `active_model_serializers` for better Active Storage URL helpers
- AI initially generated `flutter_pdfview` (Android-only) — replaced with `syncfusion_flutter_pdfviewer` for cross-platform support
- Initial EPUB viewer package suggestion (`vocsy_epub_viewer`) was Windows-incompatible — switched to `epub_view`

---

## ⚠️ Known Limitations

1. **Cover auto-generation requires ImageMagick + GhostScript** — if not installed, covers are skipped (non-fatal). Books will show colored placeholder spines instead.
2. **Background jobs** — `GenerateCoverJob` runs via Rails' default `:async` queue adapter. In production, switch to Sidekiq.
3. **No authentication** — This is a single-user local application. API endpoints are open.
4. **Large EPUB display** — Complex EPUB files with heavy CSS may render with styling differences in `epub_view`.
5. **Windows download path** — `getDownloadsDirectory()` returns null on Windows desktop; falls back to `getApplicationDocumentsDirectory()`.
6. **EPUB search** — Filename search in the backend works; in-content search is not implemented.
7. **Pagination** — Flutter app loads the first page (20 books). Infinite scroll/load more is not implemented.

---

## ✅ Manual Testing Checklist

### Upload Flow
- [ ] Tap "Add Book" → Upload screen opens
- [ ] Select a PDF file → Filename auto-fills in title field
- [ ] Select an EPUB file → Works correctly
- [ ] Try uploading `.txt` file → Error: "must be a PDF or EPUB file"
- [ ] Leave title empty → Validation error shown
- [ ] Upload file > 50MB → Error: "file is too large"
- [ ] Successful upload → Returns to library, book appears on shelf

### Library View
- [ ] Library loads books on wooden shelves
- [ ] 4 books per shelf row
- [ ] Sort by Recent / Title / Author → List reorders
- [ ] Filter by PDF / EPUB → Correct books shown
- [ ] Empty library → Empty shelf illustration shown
- [ ] Pull to refresh → Reloads from API

### Reading
- [ ] Tap a book → Detail screen opens
- [ ] Tap "Read Now" → PDF reader opens
- [ ] PDF loads and is readable
- [ ] Page slider works
- [ ] Prev / Next page buttons work
- [ ] Tap screen → Controls appear/hide
- [ ] Fullscreen toggle → Status bar hides
- [ ] Go back → Position is saved
- [ ] Re-open same book → Opens at saved page
- [ ] "Continue Reading" section appears in library for read books

### Search
- [ ] Tap search icon → Search screen opens with keyboard
- [ ] Type "Gatsby" → Results appear after 400ms
- [ ] Partial match works ("Gats")
- [ ] Case-insensitive search works
- [ ] Clear button clears results
- [ ] No results → "No results for..." message shown
- [ ] Tap a result → Book detail opens
- [ ] Search result highlights matched term in amber

### Download
- [ ] Tap "Download" → Progress bar appears
- [ ] File downloads to device
- [ ] Success snackbar shown
- [ ] File opens in system viewer (where supported)

### Delete
- [ ] Long press on book → Context menu appears
- [ ] Tap "Delete" → Confirmation dialog shown
- [ ] Cancel → Nothing happens
- [ ] Confirm → Book removed from shelf
- [ ] Delete from detail screen → Navigates back to library

### Error States
- [ ] Turn off backend → "Cannot connect to server" error with retry button
- [ ] Retry → Reloads successfully when backend is back
- [ ] Invalid file type → Appropriate error message

---

## 📸 Screenshots

*(Run the app and add screenshots here)*

---

## 🏃 Quick Start (All in One)

```bash
# Terminal 1 — Backend
cd "Digital Ebook Library Application/ebook_library_backend"
bundle install && bundle exec rails db:create db:migrate db:seed
bundle exec rails server

# Terminal 2 — Flutter
cd "Digital Ebook Library Application/ebook_library_flutter"
flutter pub get && flutter run
```
#   D i g i t a l - E b o o k - L i b r a r y - A p p l i c a t i o n  
 