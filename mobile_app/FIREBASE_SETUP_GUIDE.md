# 🔥 Hướng dẫn kết nối Firebase

## Tình trạng hiện tại

✅ **Đã hoàn thành:**
- Firebase packages đã được thêm vào `pubspec.yaml`
- Các Firebase service files đã được tạo và uncommented
- Main.dart đã sẵn sàng khởi tạo Firebase

⚠️ **Cần làm:**
- Chạy `flutterfire configure` để tạo file `firebase_options.dart`
- Có quyền truy cập vào Firebase project của Hiệp

---

## 📋 Các bước thực hiện

### Bước 1: Cài đặt FlutterFire CLI

Mở Terminal và chạy:

```bash
dart pub global activate flutterfire_cli
```

**Lưu ý:** Nếu lệnh `flutterfire` không được nhận diện sau khi cài, thêm vào PATH:

```bash
export PATH="$PATH":"$HOME/.pub-cache/bin"
```

Hoặc thêm dòng này vào file `~/.zshrc` (hoặc `~/.bashrc`) để vĩnh viễn.

---

### Bước 2: Đăng nhập Google (nếu chưa đăng nhập)

```bash
firebase login
```

Lệnh này sẽ mở browser để bạn đăng nhập với Google account.

---

### Bước 3: Xin quyền truy cập Firebase Project từ Hiệp

**Quan trọng!** Bạn cần Hiệp thêm email Google của bạn vào Firebase project:

1. Hiệp vào [Firebase Console](https://console.firebase.google.com/)
2. Chọn project (ví dụ: `plant-care-app`)
3. Vào **Settings (⚙️) → Users and Permissions**
4. Click **Add Member**
5. Thêm email Google của bạn với role **Editor** hoặc **Owner**

---

### Bước 4: Chạy FlutterFire Configure

```bash
cd "/Users/banghoang/Mobile App/mobile_app"
flutterfire configure
```

**Quá trình này sẽ:**
1. Hiển thị danh sách Firebase projects của bạn
2. Chọn project mà Hiệp đã tạo (hoặc tạo project mới)
3. Chọn platforms: Android, iOS (chọn cả 2)
4. Tự động tạo file `lib/firebase_options.dart`
5. Tự động config Android (`android/app/google-services.json`)
6. Tự động config iOS (`ios/Runner/GoogleService-Info.plist`)

**Output mẫu:**
```
i Found 1 Firebase projects.
✔ Select a Firebase project to configure your Flutter application with · plant-care-app (plant-care-app)
✔ Which platforms should your configuration support (use arrow keys & space to select)? · android, ios
i Firebase android app com.example.plant_care_app is already registered.
i Firebase ios app com.example.plantCareApp is already registered.
i Generated FirebaseOptions file lib/firebase_options.dart already exists.
✔ Successfully wrote configuration.
```

---

### Bước 5: Kiểm tra file được tạo

File `lib/firebase_options.dart` sẽ được tạo với nội dung như:

```dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('DefaultFirebaseOptions have not been configured for web');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      // ... other platforms
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'your-project-id',
    storageBucket: 'your-project-id.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'your-project-id',
    storageBucket: 'your-project-id.appspot.com',
    iosBundleId: 'com.example.plantCareApp',
  );
}
```

---

### Bước 6: Cài đặt dependencies

```bash
flutter pub get
```

---

### Bước 7: Test kết nối

Chạy app trên emulator hoặc thiết bị thật:

```bash
flutter run
```

Kiểm tra console logs, bạn sẽ thấy:
```
✅ Firebase initialized successfully!
```

Nếu có lỗi, xem phần **Troubleshooting** bên dưới.

---

## 🔧 Các Firebase services đã sẵn sàng

### 1. AuthService (`lib/services/firebase/auth_service.dart`)
```dart
final authService = AuthService();

// Đăng ký
await authService.signUp(email, password, name);

// Đăng nhập
await authService.signIn(email, password);

// Đăng xuất
await authService.signOut();

// Lấy user hiện tại
UserModel? user = await authService.getCurrentUser();

// Stream theo dõi auth state
authService.authStateChanges.listen((user) {
  if (user != null) {
    print('User logged in: ${user.email}');
  } else {
    print('User logged out');
  }
});
```

### 2. FirestoreService (`lib/services/firebase/firestore_service.dart`)
```dart
final firestore = FirestoreService();

// Thêm document
String? docId = await firestore.addDocument('plants', {
  'name': 'Cây sen đá',
  'species': 'Succulent',
  'userId': 'user123',
});

// Lấy document
Map<String, dynamic>? plant = await firestore.getDocument('plants', docId);

// Update document
await firestore.updateDocument('plants', docId, {'name': 'Cây mới'});

// Xóa document
await firestore.deleteDocument('plants', docId);

// Query collection
List<Map<String, dynamic>> myPlants = await firestore.queryCollection(
  'plants', 
  'userId', 
  'user123',
);

// Stream real-time data
firestore.streamCollection('plants').listen((plants) {
  print('Plants updated: ${plants.length}');
});
```

### 3. StorageService (`lib/services/firebase/storage_service.dart`)
```dart
final storage = StorageService();

// Upload 1 ảnh
File imageFile = File('/path/to/image.jpg');
String? imageUrl = await storage.uploadImage(
  'plants/plant_123.jpg',
  imageFile,
);

// Upload nhiều ảnh
List<File> imageFiles = [file1, file2, file3];
List<String> imageUrls = await storage.uploadMultipleImages(
  'diary/entry_456',
  imageFiles,
);

// Xóa ảnh
await storage.deleteImage(imageUrl);

// Lấy download URL
String? url = await storage.getDownloadUrl('plants/plant_123.jpg');
```

---

## 🎯 Bước tiếp theo - Tích hợp vào Providers

Hiện tại các Providers đang dùng mock data. Bạn cần tích hợp Firebase services vào:

### 1. AuthProvider
File: `lib/providers/auth_provider.dart`

```dart
import '../services/firebase/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  
  // Thay mock login bằng Firebase
  Future<void> login(String email, String password) async {
    try {
      _user = await _authService.signIn(email, password);
      notifyListeners();
    } catch (e) {
      // Handle error
      rethrow;
    }
  }
  
  // Tương tự cho register, logout, etc.
}
```

### 2. PlantProvider
File: `lib/providers/plant_provider.dart`

```dart
import '../services/firebase/firestore_service.dart';
import '../services/firebase/storage_service.dart';

class PlantProvider extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  final StorageService _storage = StorageService();
  
  // Thay mock data bằng Firebase
  Future<void> loadPlants(String userId) async {
    try {
      final data = await _firestore.queryCollection('plants', 'userId', userId);
      _plants = data.map((d) => PlantModel.fromMap(d)).toList();
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }
  
  Future<void> addPlant(PlantModel plant, File? imageFile) async {
    try {
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _storage.uploadImage(
          'plants/${plant.id}.jpg',
          imageFile,
        );
      }
      
      await _firestore.addDocument('plants', {
        ...plant.toMap(),
        'imageUrl': imageUrl,
      });
      
      await loadPlants(plant.userId);
    } catch (e) {
      // Handle error
    }
  }
}
```

### 3. DiaryProvider
File: `lib/providers/diary_provider.dart`

Similar pattern - thay mock methods bằng Firebase calls.

---

## 🐛 Troubleshooting

### Lỗi: `firebase_options.dart` không tồn tại

**Nguyên nhân:** Chưa chạy `flutterfire configure`

**Giải pháp:**
```bash
cd "/Users/banghoang/Mobile App/mobile_app"
flutterfire configure
```

---

### Lỗi: "You are not authorized to access this project"

**Nguyên nhân:** Chưa có quyền truy cập Firebase project

**Giải pháp:** 
1. Liên hệ Hiệp
2. Hiệp thêm email Google của bạn vào Firebase Console
3. Chạy lại `flutterfire configure`

---

### Lỗi: "No Firebase project found"

**Nguyên nhân:** 
- Chưa đăng nhập Firebase CLI
- Hiệp chưa tạo project

**Giải pháp:**
```bash
firebase login
firebase projects:list
```

Nếu không thấy project, yêu cầu Hiệp share project ID.

---

### Lỗi Android: "google-services.json missing"

**Nguyên nhân:** FlutterFire config chưa chạy đúng cho Android

**Giải pháp:**
```bash
flutterfire configure --platforms=android
```

File sẽ được tạo tại: `android/app/google-services.json`

---

### Lỗi iOS: "GoogleService-Info.plist missing"

**Nguyên nhân:** FlutterFire config chưa chạy đúng cho iOS

**Giải pháp:**
```bash
flutterfire configure --platforms=ios
```

File sẽ được tạo tại: `ios/Runner/GoogleService-Info.plist`

---

### Lỗi: "Multidex error" trên Android

**Nguyên nhân:** App vượt quá 64K methods (do Firebase packages lớn)

**Giải pháp:** Enable Multidex

File `android/app/build.gradle.kts`:
```kotlin
android {
    defaultConfig {
        multiDexEnabled = true
    }
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
}
```

---

## 📱 Test trên thiết bị

### Android
```bash
flutter run
```

### iOS (cần Mac)
```bash
flutter run -d ios
```

### Web (nếu cần)
```bash
flutter run -d chrome
```

**Lưu ý:** Phải config thêm web platform nếu muốn chạy web.

---

## 🔒 Firebase Security Rules

Yêu cầu Hiệp set up Firestore Security Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Plants collection
    match /plants/{plantId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                     request.resource.data.userId == request.auth.uid;
      allow delete: if request.auth != null && 
                      resource.data.userId == request.auth.uid;
    }
    
    // Diary entries collection
    match /diary_entries/{entryId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                     request.resource.data.userId == request.auth.uid;
      allow delete: if request.auth != null && 
                      resource.data.userId == request.auth.uid;
    }
    
    // Sensor data collection
    match /sensor_data/{plantId} {
      allow read: if request.auth != null;
      allow write: if true; // Allow ESP32 to write (có thể restrict bằng API key)
    }
  }
}
```

Firebase Storage Rules:
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /plants/{userId}/{imageId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
      allow delete: if request.auth != null && request.auth.uid == userId;
    }
    
    match /diary/{userId}/{imageId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
      allow delete: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## ✅ Checklist hoàn thành

- [ ] Cài đặt FlutterFire CLI
- [ ] Đăng nhập Firebase (`firebase login`)
- [ ] Có quyền truy cập Firebase project của Hiệp
- [ ] Chạy `flutterfire configure`
- [ ] File `firebase_options.dart` được tạo
- [ ] Chạy `flutter pub get`
- [ ] Test app - thấy log "✅ Firebase initialized successfully!"
- [ ] Test đăng ký user mới
- [ ] Test đăng nhập
- [ ] Tích hợp Firebase vào AuthProvider
- [ ] Tích hợp Firebase vào PlantProvider
- [ ] Tích hợp Firebase vào DiaryProvider
- [ ] Test upload ảnh lên Storage
- [ ] Test CRUD operations với Firestore

---

## 📞 Liên hệ

Nếu gặp vấn đề:
1. Check console logs (tìm dòng có emoji ✅ hoặc ❌)
2. Hỏi Hiệp về Firebase project setup
3. Check [Firebase Documentation](https://firebase.google.com/docs/flutter/setup)
4. Check [FlutterFire Documentation](https://firebase.flutter.dev/)

---

**Chúc may mắn! 🚀**


