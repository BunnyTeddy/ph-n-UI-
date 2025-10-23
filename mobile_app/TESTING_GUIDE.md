# Testing Guide - UI Screens

Hướng dẫn xem từng màn hình UI trong Chrome.

## 🚀 Cách xem các màn hình

### Bước 1: Mở file `lib/app.dart`

### Bước 2: Thay đổi `initialRoute` ở line 27

### Bước 3: Save file và app sẽ tự động hot reload

---

## 📱 Danh sách các màn hình

### ✅ Sprint 1 - Auth Screens

#### Login Screen
```dart
initialRoute: AppRoutes.login,
```
**Features:**
- Email field
- Password field với show/hide
- Login button
- Link đến Register

#### Register Screen
```dart
initialRoute: AppRoutes.register,
```
**Features:**
- Name field
- Email field
- Password field
- Confirm password field
- Register button

---

### ✅ Sprint 2 - Home Screen

#### Home Screen (Dashboard)
```dart
initialRoute: AppRoutes.home,
```
**Features:**
- Dashboard cards (Tổng số cây, Tuổi TB)
- Quick actions (Nhật ký, Thư viện, Thống kê)
- Plant list (empty state nếu chưa có cây)
- FAB thêm cây

---

### ✅ Sprint 3 - Plant Management

#### Add Plant Screen
```dart
initialRoute: AppRoutes.addPlant,
```
**Features:**
- Image picker
- Name field
- Species field
- Planted date picker
- Description field
- Submit button

#### Edit Plant Screen
**Lưu ý:** Cần plantId, không thể xem trực tiếp
- Navigate từ Home screen → Click plant → Menu → Edit

---

### ✅ Sprint 4 - Diary Module

#### Diary List Screen
**Lưu ý:** Cần plantId, không thể xem trực tiếp
- Navigate từ Home screen → Click plant

#### Add Diary Screen
**Lưu ý:** Cần plantId, không thể xem trực tiếp
- Navigate từ Diary List → FAB

---

### ⏳ Sprint 5 - Gallery Module (TODO)

#### Gallery Screen
**Lưu ý:** Cần plantId
```dart
// Will be available after Sprint 5
initialRoute: AppRoutes.gallery,
```

---

### ⏳ Sprint 6 - Settings Module (TODO)

#### Settings Screen
```dart
initialRoute: AppRoutes.settings,
```
**Features:**
- Profile settings
- App preferences
- About
- Logout

---

## 💡 Tips

### Xem màn hình cần plantId

Các màn hình này cần plantId nên không thể xem trực tiếp:
- Edit Plant
- Diary List
- Add Diary
- Gallery
- Plant Detail IoT

**Cách xem:**
1. Chạy app với Home screen
2. Thêm cây mới (hoặc có data test)
3. Navigate từ Home → Click plant

### Hot Reload

Khi sửa `initialRoute`:
1. Save file (Cmd+S / Ctrl+S)
2. App tự động reload trong vài giây
3. Xem màn hình mới

### Restore về bình thường

Khi test xong, uncomment code gốc:
```dart
initialRoute: authProvider.isAuthenticated 
    ? AppRoutes.home 
    : AppRoutes.login,
```

---

## 🎨 Màn hình đã hoàn thành (67%)

- ✅ Login Screen
- ✅ Register Screen
- ✅ Home Screen
- ✅ Add Plant Screen
- ✅ Edit Plant Screen
- ✅ Diary List Screen
- ✅ Add Diary Screen
- ⏳ Gallery Screen (Sprint 5)
- ⏳ Settings Screen (Sprint 6)

---

## 📊 URL trong Browser

**Lưu ý:** Flutter web là SPA nên tất cả đều chạy trên:
```
http://localhost:PORT
```

Không có URL riêng cho từng màn hình như:
- ❌ http://localhost/login
- ❌ http://localhost/home
- ❌ http://localhost/plants/add

Thay vào đó, routing được xử lý bởi Flutter internally.

---

## 🐛 Troubleshooting

### App không reload sau khi sửa initialRoute?
- Nhấn `R` trong terminal để hot restart
- Hoặc `r` để hot reload

### Màn hình bị lỗi?
- Check console trong Chrome DevTools
- Xem terminal output
- Đảm bảo Firebase placeholders đã được init

### Muốn test với data thật?
- Đợi Hiệp setup Firebase
- Hoặc tạo mock data trong providers


