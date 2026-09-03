# 📚 Digital Ebook Library Application

**Full-Stack Developer Assignment — Sagar Fab International Company**

A complete Digital Ebook Library application built with **Ruby on Rails 7.2** as the API backend and **Flutter** as the cross-platform frontend.

The goal of the application is to provide a simple, clean, and practical way for users to upload, manage, search, read, download, and delete digital ebooks.

---

## 📌 Project Overview

The application supports:

- 📤 Uploading **PDF and EPUB** ebooks
- 📖 Reading ebooks inside the application
- 🔍 Searching ebooks by **title, author, or filename**
- ✨ Highlighting matching search terms
- 📥 Downloading ebooks to device storage
- 🗑️ Deleting ebooks with confirmation
- 🏷️ Sorting and filtering the library
- 📚 A bookshelf-style UI inspired by modern ebook library applications
- 💾 Saving the user's last reading position
- ⚠️ Proper loading, error, empty, and validation states

This was designed as a **working product rather than a basic CRUD demo**, with focus on usability, edge cases, and maintainable architecture.

---

# 🛠️ Technology Stack

| Layer | Technology |
|---|---|
| Backend | Ruby on Rails 7.2 (API mode) |
| Language | Ruby 3.3.x |
| Database | SQLite |
| File Storage | Active Storage |
| Frontend | Flutter |
| Language | Dart |
| State Management | Provider |
| HTTP Client | Dio |
| PDF Reader | Syncfusion Flutter PDF Viewer |
| EPUB Reader | epub_view |
| Backend Testing | RSpec |
| Frontend Testing | Flutter Test |
| Image Processing | ImageMagick |
| API Style | REST API |

---

# 🏗️ Application Architecture

The application follows a simple client-server architecture:

```text
┌──────────────────────────┐
│      Flutter App         │
│                          │
│  Screens / Providers     │
│  API Service / Models    │
└────────────┬─────────────┘
             │
             │ REST API
             ▼
┌──────────────────────────┐
│     Ruby on Rails API    │
│                          │
│ Controllers / Models     │
│ Serializers / Jobs       │
└────────────┬─────────────┘
             │
             ▼
┌──────────────────────────┐
│        SQLite DB         │
└──────────────────────────┘
             │
             ▼
┌──────────────────────────┐
│     Active Storage       │
│     PDF / EPUB Files     │
└──────────────────────────┘
```

---

# 📁 Project Structure

```text
Digital Ebook Library Application/
│
├── ebook_library_backend/
│   ├── app/
│   │   ├── controllers/api/
│   │   │   └── ebooks_controller.rb
│   │   ├── models/
│   │   │   └── ebook.rb
│   │   ├── serializers/
│   │   │   └── ebook_serializer.rb
│   │   └── jobs/
│   │       └── generate_cover_job.rb
│   │
│   ├── spec/
│   │   ├── models/
│   │   ├── requests/api/
│   │   └── factories/
│   │
│   ├── db/migrate/
│   └── config/
│
└── ebook_library_flutter/
    ├── lib/
    │   ├── models/
    │   ├── services/
    │   ├── providers/
    │   ├── screens/
    │   ├── widgets/
    │   └── theme/
    │
    └── test/
```

---

# ✨ Main Features

## 1. Ebook Upload

Users can upload:

- PDF files
- EPUB files

The application validates:

- File type
- File size
- Required title
- Upload status

For supported PDFs, a cover can be generated automatically when ImageMagick and GhostScript are available.

---

## 2. Digital Bookshelf

The library uses a bookshelf-style design.

Features include:

- Books displayed on wooden shelf rows
- Four books per row
- Different colors for individual books
- Tap animation when selecting a book
- Long-press context menu
- Empty-library state
- Loading shimmer state

---

## 3. Search

Users can search their library by:

- Title
- Author
- Filename

Search includes:

- Case-insensitive matching
- Partial matching
- 400ms debounce
- Highlighting of matching terms
- No-result state
- Clear-search action

---

## 4. Ebook Reading

### PDF

The PDF reader supports:

- Page navigation
- Previous / next page
- Page slider
- Zoom
- Fullscreen
- Automatic control hiding
- Saving the last reading position

### EPUB

The EPUB reader supports:

- Chapter-based reading
- In-app EPUB rendering
- Reading navigation

When the user leaves a book, the application saves the current reading position where supported.

---

## 5. Download

Users can download an ebook to device storage.

The download flow includes:

- Download progress
- Success feedback
- Device storage handling
- File opening where supported

---

## 6. Delete Ebook

Users can delete an ebook from:

- The bookshelf context menu
- The ebook detail screen

A confirmation dialog is shown before deletion.

---

## 7. Sorting & Filtering

The library supports sorting by:

- Recent
- Title
- Author

Users can also filter ebooks by:

- PDF
- EPUB

---

# 🌐 API Documentation

**Base URL**

```text
http://localhost:3000/api
```

## Endpoints

| Method | Endpoint | Purpose |
|---|---|---|
| `GET` | `/ebooks` | List ebooks |
| `POST` | `/ebooks` | Upload ebook |
| `GET` | `/ebooks/:id` | Get ebook details |
| `GET` | `/ebooks/search?q=keyword` | Search ebooks |
| `GET` | `/ebooks/:id/download` | Download ebook |
| `PATCH` | `/ebooks/:id/read_position` | Save reading position |
| `DELETE` | `/ebooks/:id` | Delete ebook |
| `GET` | `/up` | Health check |

## Query Parameters

| Parameter | Values | Default |
|---|---|---|
| `sort` | `recent`, `title`, `author` | `recent` |
| `format` | `pdf`, `epub` | All |
| `page` | Integer | `1` |
| `per_page` | Integer | `20` |

---

# 📦 Example API Response

### `GET /api/ebooks`

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

---

# ⚙️ Setup & Installation

## Prerequisites

Install the following before running the application:

| Tool | Version |
|---|---|
| Ruby | 3.3.x |
| Rails | 7.2.x |
| SQLite3 | 3.x |
| ImageMagick | 7.x |
| Flutter | 3.22+ |
| Dart | 3.3+ |

### Installation Resources

- Ruby: https://rubyinstaller.org/
- SQLite: https://sqlite.org/download.html
- ImageMagick: https://imagemagick.org/script/download.php
- Flutter: https://flutter.dev/docs/get-started/install

---

# 🚀 Running the Backend

Open a terminal and run:

```bash
cd ebook_library_backend

bundle install

bundle exec rails db:create
bundle exec rails db:migrate

# Optional: add sample data
bundle exec rails db:seed

bundle exec rails server -p 3000
```

The Rails API will be available at:

```text
http://localhost:3000
```

API base URL:

```text
http://localhost:3000/api
```

---

# 📱 Running the Flutter Application

Open another terminal:

```bash
cd ebook_library_flutter

flutter pub get

flutter devices

flutter run
```

### Android Emulator

For an Android emulator, use:

```text
http://10.0.2.2:3000/api
```

The API URL can be configured in:

```text
lib/services/api_service.dart
```

### iOS Simulator / Windows

Use:

```text
http://localhost:3000/api
```

---

# 🧪 Testing

The application has been tested on both backend and frontend.

## Backend — RSpec

Run:

```bash
cd ebook_library_backend

bundle exec rspec --format documentation
```

The backend test suite covers areas such as:

- Model behavior
- API request/endpoint behavior
- Ebook validation
- API responses
- Ebook-related functionality

## Flutter — Flutter Test

Run:

```bash
cd ebook_library_flutter

flutter test
```

For detailed output:

```bash
flutter test --reporter expanded
```

The Flutter tests cover the application's relevant models, widgets, and providers.

---

# 🎨 UI / Design Decisions

## Bookshelf

The main library was designed around a classic bookshelf concept:

- Wooden shelf rows
- Four books per row
- Individual book colors
- Book lift animation on tap
- Long-press actions
- Custom wood-grain painting

## Empty State

When there are no books:

- A custom bookshelf illustration is displayed
- Ghost book outlines are shown
- An entrance animation is used
- A clear CTA guides the user to add the first book

## Loading State

A shimmer loading state is used to make loading feel consistent with the bookshelf layout.

## Reading Experience

The reading screen provides:

- Page navigation
- Page slider
- Zoom
- Fullscreen mode
- Auto-hiding controls
- Saved reading position

---

# 🤖 AI-Assisted Development

AI tools were used as **development assistance**, while the implementation was reviewed, tested, and debugged during development.

## Tools Used

- **Antigravity IDE** — AI-assisted coding and development
- **Reasoning model** — architecture discussions and implementation guidance

## How AI Was Used

AI assistance was used for:

1. Discussing architecture and technical trade-offs
2. Generating some boilerplate code
3. Suggesting edge cases
4. Helping structure tests
5. Assisting with Flutter UI alignment and styling
6. Suggesting color combinations for the frontend
7. Debugging specific frontend issues
8. Reviewing possible implementation approaches

## Backend Contribution

The backend was primarily implemented based on my own Ruby on Rails knowledge and experience.

Approximately:

- **80%** — implemented based on my own technical knowledge and decisions
- **20%** — AI-assisted for selected implementation/debugging tasks

The backend was also manually reviewed and debugged to verify the generated or suggested code.

## Frontend Contribution

On the Flutter side, AI assistance was used more heavily for:

- UI alignment
- Styling
- Color selection
- Fixing frontend issues when components or layouts were breaking

The changes were reviewed and tested before being kept in the application.

---

# 🔍 Important Manual Reviews & Corrections

During development, AI-generated suggestions were not blindly accepted. Several suggestions were manually tested and corrected.

### Backend

- Simplified the `Ebook` model search query after testing revealed SQL JOIN issues.
- Corrected PDF reading position handling after identifying a page-index mismatch.
- Added a fallback for the download directory.
- Updated CORS configuration to expose the `Content-Disposition` header.
- Made cover generation failure non-fatal when ImageMagick is unavailable.

### Frontend / Packages

Some initial AI suggestions were replaced after evaluating compatibility:

- `blueprinter` → `active_model_serializers`
- `flutter_pdfview` → `syncfusion_flutter_pdfviewer`
- `vocsy_epub_viewer` → `epub_view`

The changes were made based on project requirements and platform compatibility.

---

# ⚠️ Known Limitations

The following limitations are currently known:

1. **Cover generation** requires ImageMagick and GhostScript. If unavailable, cover generation is skipped and placeholder book spines are displayed.
2. **Background jobs** currently use Rails' default `:async` adapter. For production, Sidekiq would be a better option.
3. **Authentication** is not implemented because this assignment is designed as a single-user local application.
4. **Complex EPUB styling** may have rendering differences depending on the EPUB file.
5. **Windows download directory** may return `null`, so the application falls back to the application documents directory.
6. **EPUB in-content search** is not implemented; backend search covers metadata such as filename.
7. **Pagination** is implemented at the API level, while the Flutter application currently loads the first page of 20 books.

---

# ✅ Functional Testing Checklist

The following scenarios were considered during application testing.

## Upload

- Select PDF and upload successfully
- Select EPUB and upload successfully
- Reject unsupported file types
- Validate empty title
- Validate files larger than 50MB
- Confirm successful upload and library update

## Library

- Display books on bookshelf
- Display four books per shelf row
- Sort by Recent / Title / Author
- Filter PDF / EPUB
- Display empty-library state
- Pull to refresh

## Reading

- Open ebook details
- Open PDF reader
- Open EPUB reader
- Navigate pages
- Use page slider
- Use previous / next controls
- Toggle fullscreen
- Save reading position
- Reopen ebook at saved position

## Search

- Search by title
- Search by author
- Search by filename
- Partial matching
- Case-insensitive search
- Search debounce
- Highlight matching text
- Display no-results state

## Download

- Start download
- Display progress
- Save file to device
- Display success feedback
- Open downloaded file where supported

## Delete

- Delete from bookshelf
- Delete from detail screen
- Display confirmation dialog
- Cancel deletion
- Confirm deletion
- Update library after deletion

## Error Handling

- Backend unavailable
- Network request failure
- Invalid file type
- File too large
- Retry after connection failure

---

# 📸 Screenshots

Screenshots can be added here to demonstrate the main application flows.

Recommended screenshots:

1. Library / Bookshelf
2. Upload Ebook
3. Ebook Details
4. PDF Reader
5. EPUB Reader
6. Search
7. Download
8. Delete Confirmation
9. Empty Library
10. Error State

---

# 🏃 Quick Start

### Terminal 1 — Rails Backend

```bash
cd ebook_library_backend

bundle install

bundle exec rails db:create
bundle exec rails db:migrate

bundle exec rails server -p 3000
```

### Terminal 2 — Flutter App

```bash
cd ebook_library_flutter

flutter pub get

flutter run
```

---

# 📄 Additional Documentation

For detailed environment and setup information, refer to:

```text
SETUP.md
```

For the complete project documentation, architecture, API information, testing, and development approach, refer to this README.

---

# 👨‍💻 Assignment Submission

**Company:** Sagar Fab International Company

**Role:** Full Stack Developer — Ruby on Rails + Flutter

**Assignment:** Digital Ebook Library Application

**Repository:**  
https://github.com/ankitpatidar9098/Digital-Ebook-Library-Application

