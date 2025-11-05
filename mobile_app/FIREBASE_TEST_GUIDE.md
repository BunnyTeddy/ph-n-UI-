# 🧪 Firebase Test Guide

## ✅ Setup Đã Hoàn Thành

### Firebase Configuration:
- **Project:** UDDD (uddd-e0e1f)
- **Platform:** Android
- **Package:** com.example.plant_care_app
- **App ID:** 1:99119582981:android:8f06cd69fd6cc1f3a5716c
- **Config File:** ✅ `lib/firebase_options.dart` created

---

## 📱 Test trên Android Emulator

### Bước 1: Start Emulator
```bash
flutter emulators --launch Medium_Phone
```

Đợi emulator boot xong (30-60 giây).

### Bước 2: Chạy App
```bash
cd "/Users/banghoang/Mobile App/mobile_app"
flutter run
```

### Bước 3: Kiểm Tra Logs

Trong terminal output, tìm các dòng sau:

**✅ Thành công nếu thấy:**
```
✅ Firebase initialized successfully!
```

**❌ Lỗi nếu thấy:**
```
Error: MissingPluginException
Error: Firebase not initialized
PlatformException
```

---

## 🔍 Cách Xem Logs Chi Tiết

### Option 1: Terminal logs
Khi chạy `flutter run`, tất cả logs sẽ hiển thị trong terminal.

### Option 2: Android Studio Logcat
1. Mở Android Studio
2. View → Tool Windows → Logcat
3. Filter: `firebase`
4. Tìm dòng "Firebase initialized"

### Option 3: VS Code Debug Console
1. Chạy app trong debug mode (F5)
2. Xem Debug Console tab
3. Tìm log "Firebase initialized"

---

## ✅ Checklist - Verify Firebase Setup

Khi app chạy, kiểm tra:

- [ ] App launch thành công (không crash)
- [ ] Thấy log "✅ Firebase initialized successfully!"
- [ ] Không có error về Firebase trong console
- [ ] Login screen hiển thị đúng
- [ ] Home screen hiển thị đúng

---

## 🧪 Test Firebase Services

### Test 1: Check Firebase Initialization
App sẽ tự động initialize Firebase khi start. Xem log trong `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initialize(); // ← Check log here
  runApp(...);
}
```

### Test 2: Test Authentication (Manual)
1. Vào Register screen
2. Nhập email/password mới
3. Click "Đăng ký"
4. Xem console logs

**Expected behavior:**
- Nếu Firebase hoạt động: Error hoặc success từ Firebase Auth
- Nếu Firebase chưa hoạt động: Local placeholder message

### Test 3: Check Firebase Console
1. Mở [Firebase Console](https://console.firebase.google.com/)
2. Chọn project **UDDD**
3. Vào **Authentication** → Users
4. Thử đăng ký từ app
5. Xem user có xuất hiện trong console không

---

## 🐛 Troubleshooting

### Issue 1: App crashes on startup

**Nguyên nhân:** Firebase config file có vấn đề

**Giải pháp:**
```bash
# Re-configure Firebase
flutterfire configure --project=uddd-e0e1f --platforms=android --yes

# Clean rebuild
flutter clean
flutter pub get
flutter run
```

### Issue 2: "MissingPluginException"

**Nguyên nhân:** Flutter chưa register plugins

**Giải pháp:**
```bash
flutter clean
flutter pub get
flutter run --no-hot-reload
```

### Issue 3: Không thấy log Firebase

**Nguyên nhân:** Log bị ẩn

**Giải pháp:**
- Chạy với verbose: `flutter run -v`
- Hoặc search trong logs: tìm "Firebase" hoặc "initialized"

### Issue 4: "FirebaseException: No Firebase App"

**Nguyên nhân:** Firebase chưa initialize

**Kiểm tra:**
- File `main.dart` có gọi `FirebaseService.initialize()` không?
- File `firebase_options.dart` có tồn tại không?
- Import đúng chưa?

---

## 📊 Expected Console Output

Khi app chạy thành công, console sẽ hiển thị:

```
Launching lib/main.dart on sdk gphone64 arm64 in debug mode...
Running Gradle task 'assembleDebug'...
✓ Built build/app/outputs/flutter-apk/app-debug.apk.
Installing build/app/outputs/flutter-apk/app-debug.apk...
Waiting for sdk gphone64 arm64 to report its views...
Debug service listening on ws://127.0.0.1:xxxxx
Syncing files to device sdk gphone64 arm64...

Flutter run key commands.
r Hot reload. 🔥🔥🔥
R Hot restart.
h List all available interactive commands.
d Detach (terminate "flutter run" but leave application running).
c Clear the screen
q Quit (terminate the application on the device).

💪 Running with sound null safety 💪

✅ Firebase initialized successfully!  ← QUAN TRỌNG!
```

---

## 🎯 Next Steps After Successful Test

Nếu Firebase initialize thành công:

### 1. Enable Firebase Authentication
Vào Firebase Console → Authentication → Sign-in method
- Enable **Email/Password**
- Save

### 2. Setup Firestore Database
Vào Firebase Console → Firestore Database
- Click "Create database"
- Start in **test mode** (for development)
- Choose location: `asia-southeast1` (Singapore)

### 3. Setup Storage
Vào Firebase Console → Storage
- Click "Get started"
- Start in **test mode**
- Same location as Firestore

### 4. Test Real Authentication
Sau khi enable Authentication:
- Chạy app
- Vào Register screen
- Đăng ký user mới
- Check Firebase Console → Authentication → Users
- User mới sẽ xuất hiện!

---

## 📝 Quick Test Commands

**Start fresh test:**
```bash
# Clean everything
flutter clean

# Get dependencies
flutter pub get

# Start emulator
flutter emulators --launch Medium_Phone

# Wait 30 seconds for emulator to boot
sleep 30

# Run app
flutter run
```

**Check logs only:**
```bash
# Run and grep for Firebase
flutter run 2>&1 | grep -i firebase
```

**Quick rebuild:**
```bash
# Hot restart without losing emulator
# Press 'R' in the running flutter terminal
```

---

## ✅ Success Criteria

Firebase setup hoàn toàn thành công khi:

1. ✅ App launch không crash
2. ✅ Console log: "✅ Firebase initialized successfully!"
3. ✅ Không có Firebase errors
4. ✅ Firebase Console có thể thấy app connection
5. ✅ Có thể đăng ký user mới (sau khi enable Auth)
6. ✅ User xuất hiện trong Firebase Console

---

## 📞 Need Help?

Nếu gặp vấn đề:
1. Copy full error message
2. Check `FIREBASE_SETUP_GUIDE.md` → Troubleshooting section
3. Verify file `lib/firebase_options.dart` exists
4. Check Firebase Console → Project Settings → Apps
5. Verify app is registered correctly

---

**Good luck testing! 🚀**

---

## 📱 Manual Test Checklist

Test từng màn hình:

- [ ] **Login Screen** - Hiển thị đúng
- [ ] **Register Screen** - Hiển thị đúng
- [ ] **Home Screen** - Hiển thị mock plants
- [ ] **Add Plant** - Form hoạt động
- [ ] **Diary** - List hiển thị
- [ ] **Gallery** - Grid hiển thị
- [ ] **Statistics** - Charts hiển thị

Tất cả screens nên hoạt động với **mock data** hiện tại.
Firebase integration sẽ thay thế mock data sau.


