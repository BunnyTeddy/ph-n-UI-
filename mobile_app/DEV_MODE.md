# 🎨 Dev Mode - Xem UI Screens Không Cần Firebase

## Giới thiệu

Dev Mode cho phép bạn xem và test tất cả các UI screens mà **không cần setup Firebase** hoặc authentication.

Rất hữu ích khi:
- ✅ Muốn xem nhanh UI design
- ✅ Test layout trên các devices khác nhau
- ✅ Demo cho team/khách hàng
- ✅ Phát triển UI mà backend chưa sẵn sàng
- ✅ Chụp screenshots cho documentation

---

## Cách Sử Dụng

### Bước 1: Bật Dev Mode

Mở file `lib/app.dart` và đảm bảo dòng này được uncomment:

```dart
initialRoute: AppRoutes.dev,
```

### Bước 2: Chạy App

```bash
flutter run
```

Hoặc chọn device cụ thể:

```bash
flutter devices
flutter run -d <device-id>
```

### Bước 3: Chọn Screen

Bạn sẽ thấy màn hình **Screen Selector** với danh sách tất cả screens:

```
🔐 Authentication (Sprint 1)
  - Login Screen
  - Register Screen

🏠 Home (Sprint 2)
  - Home Screen

🌱 Plant Management (Sprint 3)
  - Add Plant Screen
  - Edit Plant Screen

📔 Diary (Sprint 4)
  - Diary List Screen
  - Add Diary Screen

📷 Gallery (Sprint 5)
  - Gallery Screen

⚙️ Settings & Statistics (Sprint 6)
  - Settings Screen
  - Statistics Screen
```

Chỉ cần **tap vào screen** muốn xem!

---

## Screens Có Thể Xem Độc Lập

### ✅ Không Cần Tham Số

Các screens này có thể xem ngay:

- ✅ **Login Screen** - Đăng nhập
- ✅ **Register Screen** - Đăng ký
- ✅ **Home Screen** - Trang chủ (với mock data)
- ✅ **Add Plant Screen** - Form thêm cây
- ✅ **Settings Screen** - Cài đặt
- ✅ **Statistics Screen** - Thống kê

### ⚠️ Cần Plant ID

Các screens này cần `plantId` - xem từ Home Screen trước:

- ⚠️ **Edit Plant Screen** - Cần chọn cây từ Home
- ⚠️ **Diary List Screen** - Cần chọn cây từ Home
- ⚠️ **Add Diary Screen** - Cần chọn cây từ Home
- ⚠️ **Gallery Screen** - Cần chọn cây từ Home

---

## Xem Screen Trực Tiếp

Nếu muốn xem 1 screen cụ thể ngay khi launch:

### Option 1: Trong app.dart

```dart
// Thay vì AppRoutes.dev, dùng route cụ thể:
initialRoute: AppRoutes.login,        // Xem Login
initialRoute: AppRoutes.home,         // Xem Home
initialRoute: AppRoutes.addPlant,     // Xem Add Plant
initialRoute: AppRoutes.statistics,   // Xem Statistics
```

### Option 2: Navigate từ code

```dart
Navigator.pushNamed(context, AppRoutes.login);
```

---

## Tips & Tricks

### 1. Hot Reload

Sau khi thay đổi UI code:
- **iOS/Android**: Press `r` in terminal
- **Hot Restart**: Press `R` in terminal

### 2. Xem Trên Nhiều Devices

```bash
# Xem các devices có sẵn
flutter devices

# Run trên nhiều devices cùng lúc
flutter run -d all

# Run trên device cụ thể
flutter run -d chrome           # Web
flutter run -d emulator-5554    # Android Emulator
flutter run -d iPhone-14        # iOS Simulator
```

### 3. Screenshot

Để chụp screenshot từ code:

```dart
// Đã có sẵn trong các screens
flutter screenshot
```

### 4. Inspect UI

Enable Flutter Inspector trong IDE:
- **VS Code**: View → Command Palette → "Flutter: Open DevTools"
- **Android Studio**: View → Tool Windows → Flutter Inspector

---

## Mock Data

Dev Mode sử dụng mock data:

### Providers có mock data:
- ✅ **AuthProvider** - Mock user đã login
- ✅ **PlantProvider** - 2-3 mock plants
- ✅ **DiaryProvider** - Mock diary entries

### Nếu muốn thêm mock data:

Xem file providers và thêm data vào constructor hoặc init method.

---

## Tắt Dev Mode

Khi đã có Firebase và muốn test production:

### Bước 1: Comment Dev Route

Trong `lib/app.dart`:

```dart
// initialRoute: AppRoutes.dev,  // <-- Comment dòng này

// Uncomment dòng production:
initialRoute: authProvider.isAuthenticated 
    ? AppRoutes.home 
    : AppRoutes.login,
```

### Bước 2: Restart App

```bash
flutter run
```

---

## Troubleshooting

### Lỗi: "No MaterialLocalizations found"

**Fix**: Wrap screen với MaterialApp:

```dart
MaterialApp(
  home: YourScreen(),
)
```

### Lỗi: "Provider not found"

**Fix**: Một số screens cần providers. Trong dev mode, provider có thể null.

**Solution**: Kiểm tra null trước khi dùng:

```dart
final provider = context.read<PlantProvider>();
if (provider.plants.isEmpty) {
  return EmptyState();
}
```

### Lỗi: "Navigator operation requested with a context..."

**Fix**: Thêm delay trước navigate:

```dart
Future.delayed(Duration.zero, () {
  Navigator.pushNamed(context, route);
});
```

---

## All Available Routes

```dart
// Development
AppRoutes.dev              // Screen Selector

// Auth
AppRoutes.login            // Login Screen
AppRoutes.register         // Register Screen

// Main
AppRoutes.home             // Home Screen

// Plant Management
AppRoutes.addPlant         // Add Plant Screen
AppRoutes.editPlant        // Edit Plant Screen (need plantId)

// Diary
AppRoutes.diaryList        // Diary List (need plantId)
AppRoutes.addDiary         // Add Diary (need plantId)

// Gallery
AppRoutes.gallery          // Gallery Screen (need plantId)

// IoT
AppRoutes.plantDetailIot   // Plant IoT Detail (need plantId)

// Statistics & Settings
AppRoutes.statistics       // Statistics Screen
AppRoutes.settings         // Settings Screen
```

---

## Sprint Progress

- ✅ Sprint 1: Auth Screens (2 screens)
- ✅ Sprint 2: Home Screen (1 screen)
- ✅ Sprint 3: Plant Management (2 screens)
- ✅ Sprint 4: Diary Module (2 screens)
- ✅ Sprint 5: Gallery Module (1 screen)
- 🚧 Sprint 6: Settings & Polish (2 screens)

**Total: 10 screens có thể xem trong Dev Mode**

---

## Notes

- 📱 UI đã responsive cho mọi screen sizes
- 🎨 Design tuân theo Material 3 guidelines
- 🌍 Vietnamese localization hoàn chỉnh
- ♿ Loading states và error handling đầy đủ
- 🔄 Pull-to-refresh ở các danh sách
- 📝 Form validation đầy đủ

---

**Happy Coding! 🚀**

Nếu gặp vấn đề, check:
1. Console logs
2. Flutter DevTools
3. Provider states
4. Route definitions

---

Created by: Hoàng Chí Bằng  
Date: October 2024

