# 🚀 Firebase Quick Start

## ⚡ Cách nhanh nhất (Recommended)

Chạy script tự động:

```bash
cd "/Users/banghoang/Mobile App/mobile_app"
./setup_firebase.sh
```

Script sẽ tự động:
- ✅ Cài FlutterFire CLI
- ✅ Login Firebase
- ✅ Chạy configure
- ✅ Cài dependencies

---

## 🔧 Hoặc chạy từng bước thủ công

### 1. Cài FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
export PATH="$PATH":"$HOME/.pub-cache/bin"
```

### 2. Login Firebase
```bash
firebase login
```

### 3. Configure Firebase
```bash
cd "/Users/banghoang/Mobile App/mobile_app"
flutterfire configure
```

**Chọn project của Hiệp** và chọn platforms: **android, ios**

### 4. Cài dependencies
```bash
flutter pub get
```

### 5. Test
```bash
flutter run
```

Tìm log: `✅ Firebase initialized successfully!`

---

## ⚠️ Lưu ý quan trọng

**Trước khi chạy, bạn cần:**
- ✅ Có email Google của bạn được Hiệp thêm vào Firebase project
- ✅ Biết tên Firebase project mà Hiệp đã tạo

**Liên hệ Hiệp nếu:**
- ❌ Không thấy project khi chạy `flutterfire configure`
- ❌ Lỗi "You are not authorized"
- ❌ Không biết project name

---

## 📚 Tài liệu chi tiết

Xem file `FIREBASE_SETUP_GUIDE.md` để biết thêm:
- Troubleshooting các lỗi
- Cách sử dụng từng Firebase service
- Cách tích hợp vào Providers
- Security Rules setup

---

## ✅ Kiểm tra hoàn thành

Sau khi setup, kiểm tra các file này tồn tại:

- ✅ `lib/firebase_options.dart` (QUAN TRỌNG!)
- ✅ `android/app/google-services.json`
- ✅ `ios/Runner/GoogleService-Info.plist`

Nếu thiếu file nào, chạy lại `flutterfire configure`

---

## 🎯 Next Steps - Tích hợp vào code

Sau khi Firebase connect xong, bạn cần:

1. **AuthProvider** - Thay mock login bằng Firebase Auth
2. **PlantProvider** - Load plants từ Firestore
3. **DiaryProvider** - Load diary entries từ Firestore
4. **Image Upload** - Dùng Storage service thay vì local

Xem examples trong `FIREBASE_SETUP_GUIDE.md` section "Tích hợp vào Providers"

---

**Good luck! 🚀**


