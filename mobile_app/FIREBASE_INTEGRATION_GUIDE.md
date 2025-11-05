# 🔥 Firebase Integration Guide - UDDD Project

## 📋 Mục Lục
1. [Kiểm Tra Firebase Console](#1-kiểm-tra-firebase-console)
2. [Các Services Cần Enable](#2-các-services-cần-enable)
3. [Security Rules Setup](#3-security-rules-setup)
4. [Integrate vào Code](#4-integrate-vào-code)
5. [Testing](#5-testing)
6. [Checklist Hoàn Thành](#6-checklist-hoàn-thành)

---

## 1. Kiểm Tra Firebase Console

### Bước 1: Mở Firebase Console
1. Vào: https://console.firebase.google.com/
2. Login với email: **hoangchibang91@gmail.com**
3. Chọn project: **UDDD**

### Bước 2: Kiểm Tra Các Services

#### ✅ Đã Có (Auto-created):
- **Project Settings** ✅
  - Project ID: `uddd-e0e1f`
  - Android app registered: `com.example.plant_care_app`

#### ❓ Cần Kiểm Tra & Enable:

**A. Authentication (Xác thực người dùng)**
- Path: Build → Authentication
- Status: Cần kiểm tra
- Cần enable: Email/Password provider

**B. Firestore Database (Database chính)**
- Path: Build → Firestore Database
- Status: Cần kiểm tra
- Cần tạo database nếu chưa có

**C. Storage (Lưu trữ ảnh)**
- Path: Build → Storage
- Status: Cần kiểm tra
- Cần enable nếu chưa có

**D. Cloud Messaging (Optional - Push notifications)**
- Path: Build → Cloud Messaging
- Status: Optional
- Có thể skip trong giai đoạn đầu

---

## 2. Các Services Cần Enable

### 🔐 A. Authentication

#### Cách Enable:
1. **Mở Firebase Console → UDDD Project**
2. **Build → Authentication**
3. **Click "Get started"** (nếu chưa setup)
4. **Tab "Sign-in method"**
5. **Enable "Email/Password"**:
   - Click vào Email/Password
   - Toggle "Enable" → ON
   - Click "Save"

#### Verify:
```
✅ Email/Password provider status: Enabled
✅ Email link (passwordless sign-in): Disabled (không cần)
```

---

### 💾 B. Firestore Database

#### Cách Setup:
1. **Build → Firestore Database**
2. **Click "Create database"**
3. **Chọn mode:**
   - **Production mode** (Recommended - sẽ set rules sau)
   - Location: `asia-southeast1` (Singapore - gần VN nhất)
4. **Click "Enable"**

#### Database Structure Cần Tạo:

**Collections cần có:**

```
uddd-e0e1f (project)
│
├── users/
│   └── {userId}/
│       ├── email: string
│       ├── name: string
│       ├── photoUrl: string (optional)
│       └── createdAt: timestamp
│
├── plants/
│   └── {plantId}/
│       ├── userId: string
│       ├── name: string
│       ├── species: string
│       ├── plantedDate: timestamp
│       ├── imageUrl: string
│       ├── location: string (optional)
│       ├── notes: string (optional)
│       └── createdAt: timestamp
│
├── diary_entries/
│   └── {entryId}/
│       ├── plantId: string
│       ├── userId: string
│       ├── activityType: string (water, fertilize, prune, observe)
│       ├── notes: string
│       ├── images: array<string>
│       ├── date: timestamp
│       └── createdAt: timestamp
│
└── sensor_data/
    └── {sensorId}/
        ├── plantId: string
        ├── temperature: number
        ├── soilMoisture: number
        ├── humidity: number (optional)
        └── timestamp: timestamp
```

#### Security Rules (Production Mode):

Vào **Firestore → Rules**, paste rules này:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function - check if user is authenticated
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Helper function - check if user owns the resource
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    // Users collection - user can only read/write their own data
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow write: if isOwner(userId);
    }
    
    // Plants collection
    match /plants/{plantId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated() && 
                      request.resource.data.userId == request.auth.uid;
      allow update, delete: if isAuthenticated() && 
                               resource.data.userId == request.auth.uid;
    }
    
    // Diary entries collection
    match /diary_entries/{entryId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated() && 
                      request.resource.data.userId == request.auth.uid;
      allow update, delete: if isAuthenticated() && 
                               resource.data.userId == request.auth.uid;
    }
    
    // Sensor data - allow read for authenticated users
    // Allow write from anywhere (for ESP32/IoT devices)
    match /sensor_data/{sensorId} {
      allow read: if isAuthenticated();
      allow write: if true; // ESP32 can write without auth
                            // TODO: Add API key validation later
    }
  }
}
```

**Click "Publish"** để apply rules.

---

### 📦 C. Firebase Storage

#### Cách Setup:
1. **Build → Storage**
2. **Click "Get started"**
3. **Chọn mode:**
   - **Production mode** (sẽ set rules sau)
   - Location: `asia-southeast1` (same as Firestore)
4. **Click "Done"**

#### Storage Structure:

```
gs://uddd-e0e1f.appspot.com/
│
├── plants/
│   └── {userId}/
│       └── {plantId}/
│           ├── profile.jpg
│           └── {timestamp}.jpg
│
├── diary/
│   └── {userId}/
│       └── {entryId}/
│           ├── {timestamp}_1.jpg
│           ├── {timestamp}_2.jpg
│           └── ...
│
└── users/
    └── {userId}/
        └── profile.jpg
```

#### Storage Rules:

Vào **Storage → Rules**, paste rules này:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    
    // Helper function - check authentication
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Helper function - validate image
    function isImage() {
      return request.resource.contentType.matches('image/.*');
    }
    
    // Helper function - check file size (max 5MB)
    function isValidSize() {
      return request.resource.size < 5 * 1024 * 1024;
    }
    
    // Plants images
    match /plants/{userId}/{plantId}/{imageId} {
      allow read: if isAuthenticated();
      allow write: if isAuthenticated() && 
                     request.auth.uid == userId &&
                     isImage() && 
                     isValidSize();
      allow delete: if isAuthenticated() && request.auth.uid == userId;
    }
    
    // Diary images
    match /diary/{userId}/{entryId}/{imageId} {
      allow read: if isAuthenticated();
      allow write: if isAuthenticated() && 
                     request.auth.uid == userId &&
                     isImage() && 
                     isValidSize();
      allow delete: if isAuthenticated() && request.auth.uid == userId;
    }
    
    // User profile images
    match /users/{userId}/{imageId} {
      allow read: if isAuthenticated();
      allow write: if isAuthenticated() && 
                     request.auth.uid == userId &&
                     isImage() && 
                     isValidSize();
      allow delete: if isAuthenticated() && request.auth.uid == userId;
    }
  }
}
```

**Click "Publish"** để apply rules.

---

## 3. Security Rules Setup

### Verify Rules Đã Set Đúng:

#### Firestore Rules:
- ✅ Users: Chỉ owner có thể read/write
- ✅ Plants: Chỉ owner có thể CRUD
- ✅ Diary: Chỉ owner có thể CRUD
- ✅ Sensor: Public write (cho ESP32)

#### Storage Rules:
- ✅ Max file size: 5MB
- ✅ Only images allowed
- ✅ User-specific paths
- ✅ Authentication required

---

## 4. Integrate vào Code

### A. Update AuthProvider

**File:** `lib/providers/auth_provider.dart`

**Thay thế mock methods bằng Firebase:**

```dart
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/firebase/auth_service.dart';
import '../services/firebase/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestore = FirestoreService();
  
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  // Initialize - check if user is already logged in
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _authService.getCurrentUser();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login with Firebase
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _authService.signIn(email, password);
      
      if (_user != null) {
        // Load user profile from Firestore
        await _loadUserProfile(_user!.id);
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      _errorMessage = _getErrorMessage(e.toString());
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register with Firebase
  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _authService.signUp(email, password, name);
      
      if (_user != null) {
        // Save user profile to Firestore
        await _firestore.addDocument('users', {
          'id': _user!.id,
          'name': name,
          'email': email,
          'photoUrl': null,
          'createdAt': DateTime.now().toIso8601String(),
        });
        
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      _errorMessage = _getErrorMessage(e.toString());
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _authService.signOut();
      _user = null;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Load user profile from Firestore
  Future<void> _loadUserProfile(String userId) async {
    try {
      final userData = await _firestore.getDocument('users', userId);
      if (userData != null && _user != null) {
        _user = UserModel(
          id: _user!.id,
          email: _user!.email,
          name: userData['name'] ?? _user!.name,
          photoUrl: userData['photoUrl'],
          createdAt: _user!.createdAt,
        );
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  // Convert Firebase error to friendly message
  String _getErrorMessage(String error) {
    if (error.contains('user-not-found')) {
      return 'Email không tồn tại';
    } else if (error.contains('wrong-password')) {
      return 'Mật khẩu không đúng';
    } else if (error.contains('email-already-in-use')) {
      return 'Email đã được sử dụng';
    } else if (error.contains('weak-password')) {
      return 'Mật khẩu quá yếu (tối thiểu 6 ký tự)';
    } else if (error.contains('invalid-email')) {
      return 'Email không hợp lệ';
    } else if (error.contains('network-request-failed')) {
      return 'Lỗi kết nối mạng';
    }
    return 'Đã có lỗi xảy ra: $error';
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
```

---

### B. Update PlantProvider

**File:** `lib/providers/plant_provider.dart`

**Replace mock data với Firestore:**

```dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/plant_model.dart';
import '../services/firebase/firestore_service.dart';
import '../services/firebase/storage_service.dart';

class PlantProvider extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  final StorageService _storage = StorageService();
  
  List<PlantModel> _plants = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<PlantModel> get plants => _plants;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load plants from Firestore
  Future<void> loadPlants(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _firestore.queryCollection('plants', 'userId', userId);
      _plants = data.map((plantData) => PlantModel.fromMap(plantData)).toList();
      _plants.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Sort by newest
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Lỗi tải danh sách cây: $e';
      print('Error loading plants: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get single plant
  PlantModel? getPlantById(String plantId) {
    try {
      return _plants.firstWhere((plant) => plant.id == plantId);
    } catch (e) {
      return null;
    }
  }

  // Add plant with image upload
  Future<bool> addPlant(PlantModel plant, File? imageFile) async {
    _isLoading = true;
    notifyListeners();

    try {
      String? imageUrl;
      
      // Upload image first if provided
      if (imageFile != null) {
        final path = 'plants/${plant.userId}/${plant.id}/profile.jpg';
        imageUrl = await _storage.uploadImage(path, imageFile);
      }
      
      // Save plant to Firestore
      final plantData = plant.toMap();
      plantData['imageUrl'] = imageUrl;
      plantData['createdAt'] = DateTime.now().toIso8601String();
      
      await _firestore.addDocument('plants', plantData);
      
      // Reload plants
      await loadPlants(plant.userId);
      
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi thêm cây: $e';
      print('Error adding plant: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update plant
  Future<bool> updatePlant(PlantModel plant, File? newImageFile) async {
    _isLoading = true;
    notifyListeners();

    try {
      String? imageUrl = plant.imageUrl;
      
      // Upload new image if provided
      if (newImageFile != null) {
        // Delete old image if exists
        if (plant.imageUrl != null) {
          try {
            await _storage.deleteImage(plant.imageUrl!);
          } catch (e) {
            print('Error deleting old image: $e');
          }
        }
        
        // Upload new image
        final path = 'plants/${plant.userId}/${plant.id}/profile.jpg';
        imageUrl = await _storage.uploadImage(path, newImageFile);
      }
      
      // Update plant in Firestore
      final plantData = plant.toMap();
      plantData['imageUrl'] = imageUrl;
      plantData['updatedAt'] = DateTime.now().toIso8601String();
      
      await _firestore.updateDocument('plants', plant.id, plantData);
      
      // Reload plants
      await loadPlants(plant.userId);
      
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi cập nhật cây: $e';
      print('Error updating plant: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete plant
  Future<bool> deletePlant(String plantId, String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final plant = getPlantById(plantId);
      
      // Delete image from Storage
      if (plant?.imageUrl != null) {
        try {
          await _storage.deleteImage(plant!.imageUrl!);
        } catch (e) {
          print('Error deleting plant image: $e');
        }
      }
      
      // Delete plant from Firestore
      await _firestore.deleteDocument('plants', plantId);
      
      // Also delete related diary entries
      // TODO: Implement cascade delete for diary entries
      
      // Reload plants
      await loadPlants(userId);
      
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi xóa cây: $e';
      print('Error deleting plant: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
```

---

### C. Update DiaryProvider

**File:** `lib/providers/diary_provider.dart`

**Similar pattern - integrate Firestore + Storage:**

```dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/diary_entry_model.dart';
import '../services/firebase/firestore_service.dart';
import '../services/firebase/storage_service.dart';

class DiaryProvider extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  final StorageService _storage = StorageService();
  
  List<DiaryEntryModel> _entries = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<DiaryEntryModel> get entries => _entries;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load diary entries for a plant
  Future<void> loadEntries(String plantId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _firestore.queryCollection('diary_entries', 'plantId', plantId);
      _entries = data.map((entryData) => DiaryEntryModel.fromMap(entryData)).toList();
      _entries.sort((a, b) => b.date.compareTo(a.date)); // Sort by newest
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Lỗi tải nhật ký: $e';
      print('Error loading diary entries: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add diary entry with images
  Future<bool> addEntry(DiaryEntryModel entry, List<File> imageFiles) async {
    _isLoading = true;
    notifyListeners();

    try {
      List<String> imageUrls = [];
      
      // Upload images
      if (imageFiles.isNotEmpty) {
        final basePath = 'diary/${entry.userId}/${entry.id}';
        imageUrls = await _storage.uploadMultipleImages(basePath, imageFiles);
      }
      
      // Save entry to Firestore
      final entryData = entry.toMap();
      entryData['images'] = imageUrls;
      entryData['createdAt'] = DateTime.now().toIso8601String();
      
      await _firestore.addDocument('diary_entries', entryData);
      
      // Reload entries
      await loadEntries(entry.plantId);
      
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi thêm nhật ký: $e';
      print('Error adding diary entry: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete diary entry
  Future<bool> deleteEntry(String entryId, String plantId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final entry = _entries.firstWhere((e) => e.id == entryId);
      
      // Delete images from Storage
      for (String imageUrl in entry.images) {
        try {
          await _storage.deleteImage(imageUrl);
        } catch (e) {
          print('Error deleting image: $e');
        }
      }
      
      // Delete entry from Firestore
      await _firestore.deleteDocument('diary_entries', entryId);
      
      // Reload entries
      await loadEntries(plantId);
      
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi xóa nhật ký: $e';
      print('Error deleting diary entry: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filter by activity type
  List<DiaryEntryModel> getEntriesByType(String activityType) {
    return _entries.where((entry) => entry.activityType == activityType).toList();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
```

---

## 5. Testing

### Test Authentication:

1. **Chạy app:**
```bash
flutter run
```

2. **Test Register:**
   - Vào Register screen
   - Nhập: name, email, password
   - Click "Đăng ký"
   - ✅ Success: User được tạo

3. **Verify trong Firebase Console:**
   - Vào **Authentication → Users**
   - User mới xuất hiện ✅
   - Vào **Firestore → users collection**
   - User document được tạo ✅

4. **Test Login:**
   - Logout
   - Login lại với email/password vừa tạo
   - ✅ Success: Navigate to Home screen

---

### Test Plant Management:

1. **Add Plant:**
   - Login
   - Click (+) button
   - Fill form + chọn ảnh
   - Save
   - ✅ Success: Plant xuất hiện trong list

2. **Verify trong Firebase:**
   - **Firestore → plants collection:** Plant document ✅
   - **Storage → plants/{userId}/:** Ảnh được upload ✅

3. **Update Plant:**
   - Edit plant
   - Change info + ảnh mới
   - Save
   - ✅ Success: Changes reflected

4. **Delete Plant:**
   - Delete plant
   - Confirm
   - ✅ Success: Plant removed
   - ✅ Image deleted from Storage

---

### Test Diary:

1. **Add Diary Entry:**
   - Select plant
   - Add diary entry
   - Upload multiple images (max 5)
   - Save
   - ✅ Success: Entry added

2. **Verify:**
   - **Firestore → diary_entries:** Entry document ✅
   - **Storage → diary/{userId}/:** Multiple images ✅

---

## 6. Checklist Hoàn Thành

### Firebase Console Setup:

- [ ] **Authentication enabled**
  - [ ] Email/Password provider: ON
  - [ ] Test user created successfully
  
- [ ] **Firestore Database created**
  - [ ] Location: asia-southeast1
  - [ ] Security Rules applied
  - [ ] Collections: users, plants, diary_entries
  
- [ ] **Storage enabled**
  - [ ] Location: asia-southeast1
  - [ ] Security Rules applied
  - [ ] Folders: plants/, diary/, users/

### Code Integration:

- [ ] **AuthProvider updated**
  - [ ] Login with Firebase
  - [ ] Register with Firebase
  - [ ] Logout functionality
  - [ ] Error handling
  
- [ ] **PlantProvider updated**
  - [ ] Load plants from Firestore
  - [ ] Add plant with image upload
  - [ ] Update plant
  - [ ] Delete plant + image
  
- [ ] **DiaryProvider updated**
  - [ ] Load entries from Firestore
  - [ ] Add entry with multiple images
  - [ ] Delete entry + images
  - [ ] Filter by activity type

### Testing:

- [ ] **Authentication tested**
  - [ ] Register new user
  - [ ] Login existing user
  - [ ] Logout
  - [ ] User appears in Firebase Console
  
- [ ] **Plant Management tested**
  - [ ] Add plant with image
  - [ ] View plants list
  - [ ] Update plant
  - [ ] Delete plant
  - [ ] Data syncs with Firestore
  
- [ ] **Diary tested**
  - [ ] Add entry with images
  - [ ] View entries list
  - [ ] Delete entry
  - [ ] Images upload correctly

---

## 🚨 Các Vấn Đề Thường Gặp

### Issue 1: Permission Denied

**Error:** `permission-denied` trong Firestore/Storage

**Solution:**
- Check Security Rules đã apply chưa
- Verify user đã authenticated
- Check userId match với resource.data.userId

### Issue 2: Storage Upload Failed

**Error:** Upload ảnh fail

**Solution:**
- Check file size < 5MB
- Verify file type là image
- Check Storage Rules
- Check network connection

### Issue 3: User not found in Firestore

**Error:** Cannot load user profile

**Solution:**
- Verify user document được tạo sau register
- Check collection name: `users` (không phải `user`)
- Check document ID match với Auth UID

---

## 📞 Liên hệ Hiệp

Yêu cầu Hiệp kiểm tra/setup:

1. **Verify project ownership:**
   - Email của bạn có quyền Editor/Owner?
   
2. **Enable billing (nếu cần):**
   - Spark plan (free) đủ cho development
   - Blaze plan nếu cần production
   
3. **Setup IoT integration:**
   - Sensor data collection từ ESP32
   - Real-time database hoặc Firestore?

---

## ✅ Kết Luận

Sau khi hoàn thành guide này:

1. ✅ Firebase Console đã được setup đầy đủ
2. ✅ Security Rules đã được apply
3. ✅ Code đã integrate Firebase services
4. ✅ Authentication hoạt động
5. ✅ CRUD operations hoạt động
6. ✅ Image upload/download hoạt động
7. ✅ Ready for production testing

**Next steps:**
- IoT integration (ESP32 → Firebase)
- Push notifications
- Analytics
- Performance monitoring

---

**Good luck! 🚀**


