# ✅ Firebase Setup Checklist - UDDD Project

## 🔍 Kiểm Tra Firebase Console

### Bước 1: Mở Firebase Console
```
URL: https://console.firebase.google.com/
Email: hoangchibang91@gmail.com
Project: UDDD (uddd-e0e1f)
```

---

## 📋 Quick Checklist

### A. Firebase Console Setup

#### 1. Authentication ✅❌
```
Path: Build → Authentication → Sign-in method
Action: Enable "Email/Password"
```
- [ ] Authentication enabled
- [ ] Email/Password provider: ON
- [ ] Test với 1 user thử

#### 2. Firestore Database ✅❌
```
Path: Build → Firestore Database
Action: Create database (Production mode, asia-southeast1)
```
- [ ] Database created
- [ ] Location: asia-southeast1 (Singapore)
- [ ] Security Rules applied (copy từ guide)
- [ ] Test: Tạo 1 document thử

#### 3. Storage ✅❌
```
Path: Build → Storage
Action: Get started (Production mode, asia-southeast1)
```
- [ ] Storage enabled
- [ ] Location: asia-southeast1
- [ ] Security Rules applied (copy từ guide)
- [ ] Test: Upload 1 file thử

---

### B. Security Rules

#### Firestore Rules ✅❌
```
Path: Firestore → Rules tab
Action: Copy rules từ FIREBASE_INTEGRATION_GUIDE.md
```
- [ ] Rules copied & published
- [ ] Tested: User can only access own data

#### Storage Rules ✅❌
```
Path: Storage → Rules tab
Action: Copy rules từ FIREBASE_INTEGRATION_GUIDE.md
```
- [ ] Rules copied & published
- [ ] Tested: Max 5MB, images only

---

### C. Code Integration

#### AuthProvider ✅❌
File: `lib/providers/auth_provider.dart`
- [ ] Import Firebase services
- [ ] Replace mock login → Firebase signIn
- [ ] Replace mock register → Firebase signUp
- [ ] Add error handling
- [ ] Test: Register + Login works

#### PlantProvider ✅❌
File: `lib/providers/plant_provider.dart`
- [ ] Import Firestore + Storage services
- [ ] Replace mock data → Firestore query
- [ ] Add plant → Save to Firestore + Upload image
- [ ] Update plant → Update Firestore + Replace image
- [ ] Delete plant → Delete from Firestore + Storage
- [ ] Test: Full CRUD works

#### DiaryProvider ✅❌
File: `lib/providers/diary_provider.dart`
- [ ] Import Firestore + Storage services
- [ ] Load entries → Query Firestore
- [ ] Add entry → Save + Upload multiple images
- [ ] Delete entry → Delete document + images
- [ ] Test: CRUD works

---

### D. Testing

#### Authentication Test ✅❌
- [ ] Register user qua app
- [ ] User xuất hiện trong Firebase Console → Authentication
- [ ] User document tạo trong Firestore → users collection
- [ ] Login với user vừa tạo → Success
- [ ] Logout → Success

#### Plant Management Test ✅❌
- [ ] Add plant với ảnh → Success
- [ ] Plant document trong Firestore → plants collection
- [ ] Ảnh trong Storage → plants/{userId}/{plantId}/
- [ ] Update plant → Changes reflected
- [ ] Delete plant → Document + ảnh deleted

#### Diary Test ✅❌
- [ ] Add diary entry với 3 ảnh → Success
- [ ] Entry trong Firestore → diary_entries collection
- [ ] 3 ảnh trong Storage → diary/{userId}/{entryId}/
- [ ] View entries list → All entries shown
- [ ] Delete entry → Document + ảnh deleted

---

## 🚨 Troubleshooting Quick Reference

### Permission Denied
```
Check: Security Rules đã publish chưa?
Check: User đã login chưa?
Check: userId trong data match với auth.uid?
```

### Upload Failed
```
Check: File size < 5MB?
Check: File type = image?
Check: Storage Rules đã apply?
```

### Data Not Loading
```
Check: Internet connection
Check: Firestore collection names đúng chưa?
       - "users" (không phải "user")
       - "plants" (không phải "plant")
       - "diary_entries" (không phải "diary")
Check: Query field names đúng chưa? (userId, plantId, etc)
```

---

## 📊 Progress Tracker

**Overall Progress:**
```
Firebase Console Setup:    [ ] 0% → [ ] 100%
Security Rules:            [ ] 0% → [ ] 100%
Code Integration:          [ ] 0% → [ ] 100%
Testing:                   [ ] 0% → [ ] 100%
```

**Estimated Time:**
- Firebase Console Setup: 30 phút
- Security Rules: 15 phút
- Code Integration: 2-3 giờ
- Testing: 1 giờ
- **Total: ~4-5 giờ**

---

## 🎯 Priority Order

**Phase 1: Setup (Làm trước)**
1. Enable Authentication ⭐⭐⭐
2. Create Firestore Database ⭐⭐⭐
3. Enable Storage ⭐⭐⭐
4. Apply Security Rules ⭐⭐

**Phase 2: Integration (Làm tiếp)**
1. Update AuthProvider ⭐⭐⭐
2. Test Authentication ⭐⭐⭐
3. Update PlantProvider ⭐⭐
4. Update DiaryProvider ⭐⭐

**Phase 3: Testing (Cuối cùng)**
1. Full flow testing ⭐⭐⭐
2. Bug fixes ⭐⭐
3. Performance testing ⭐

---

## 📱 Quick Test Commands

**Start emulator & run:**
```bash
flutter emulators --launch Medium_Phone
sleep 30
flutter run
```

**Hot reload (khi đang chạy):**
```
Press 'r' in terminal
```

**Hot restart (reset state):**
```
Press 'R' in terminal
```

**View logs:**
```bash
flutter logs | grep -i firebase
```

---

## 📞 Cần Hỏi Hiệp

- [ ] Email của bạn có quyền Editor/Owner trong project UDDD?
- [ ] Firebase project đã enable Billing chưa? (Spark = free)
- [ ] Có cần setup IoT integration (ESP32) không?
- [ ] Database structure trong guide có đúng với plan không?

---

## ✅ Completion Criteria

Project hoàn thành khi:
- ✅ Đăng ký user mới → User trong Firebase Console
- ✅ Login → Navigate to Home screen
- ✅ Add plant với ảnh → Plant + ảnh trong Firebase
- ✅ View plants list → Load từ Firestore
- ✅ Update plant → Changes sync
- ✅ Delete plant → Xóa khỏi Firestore + Storage
- ✅ Add diary → Entry + ảnh trong Firebase
- ✅ View diary → Load từ Firestore
- ✅ Delete diary → Xóa khỏi Firestore + Storage

---

**Start with Phase 1! Check Firebase Console first! 🚀**


