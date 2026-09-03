# 🚀 Developer Setup Guide

Welcome to the **Digital Ebook Library Application** project! This document contains all the commands and steps a new developer needs to easily run this application on their local machine.

This project is split into two parts:
1. **Ruby on Rails Backend** (API & Database)
2. **Flutter Frontend** (Web/Mobile UI)

---

## 🛠️ 1. Start the Backend Server
*The backend must be running before you start the frontend app.*

1. Open a new PowerShell terminal.
2. Navigate into the backend folder:
   ```powershell
   cd "Digital Ebook Library Application\ebook_library_backend"
   ```
3. Install all the required Ruby gems (dependencies):
   ```powershell
   bundle install
   ```
4. Setup the SQLite database (this creates the tables and adds test dummy data):
   ```powershell
   bundle exec rails db:prepare db:seed
   ```
5. Start the Rails API server:
   ```powershell
   bundle exec rails server -p 3000
   ```
*Leave this terminal running in the background!*

---

## 📱 2. Start the Flutter Web App

1. Open a **second** new PowerShell terminal.
2. Navigate into the frontend folder:
   ```powershell
   cd "Digital Ebook Library Application\ebook_library_flutter"
   ```
3. Install all the required Flutter packages:
   ```powershell
   flutter pub get
   ```
4. Run the application in the Chrome browser for testing:
   ```powershell
   flutter run -d chrome
   ```

---

## 💡 Troubleshooting
- **"Flutter failed to delete a directory at build/flutter_assets"**:
  If you get a file locking error on Windows, stop your server (press `q`) and run the included cleanup script before trying again:
  ```powershell
  .\clean_locks.ps1
  ```

- **Backend Connection Errors**:
  If the frontend says "Cannot connect to server", ensure your Rails backend terminal is running and that no other application is blocking port `3000`.
