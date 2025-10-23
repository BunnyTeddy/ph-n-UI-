# Auth Widgets

**Author**: Hoàng Chí Bằng  
**Sprint**: 1  
**Status**: ✅ Completed

## 📦 Widgets có sẵn

### 1. CustomTextField
Text field tái sử dụng với thiết kế hiện đại và validation.

**Usage:**
```dart
CustomTextField(
  controller: _emailController,
  label: 'Email',
  hintText: 'example@email.com',
  prefixIcon: Icons.email_outlined,
  keyboardType: TextInputType.emailAddress,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập email';
    }
    return null;
  },
)
```

**Properties:**
- `controller`: TextEditingController (required)
- `label`: String (required)
- `hintText`: String? (optional)
- `prefixIcon`: IconData? (optional)
- `suffixIcon`: Widget? (optional)
- `keyboardType`: TextInputType (default: text)
- `validator`: Function? (optional)
- `maxLines`: int (default: 1)
- `enabled`: bool (default: true)

---

### 2. PasswordTextField
Text field chuyên dụng cho password với nút show/hide.

**Usage:**
```dart
PasswordTextField(
  controller: _passwordController,
  label: 'Mật khẩu',
  hintText: 'Nhập mật khẩu của bạn',
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    return null;
  },
)
```

**Properties:**
- `controller`: TextEditingController (required)
- `label`: String (default: 'Mật khẩu')
- `hintText`: String? (optional)
- `validator`: Function? (optional)

**Features:**
- ✨ Toggle visibility icon
- 🔒 Obscure text by default
- 👁️ Eye icon changes based on state

---

### 3. AuthButton
Button với loading state cho các màn hình authentication.

**Usage:**
```dart
AuthButton(
  text: 'Đăng nhập',
  onPressed: _handleLogin,
  isLoading: authProvider.isLoading,
)
```

**Outlined variant:**
```dart
AuthButton(
  text: 'Sign in with Google',
  onPressed: _handleGoogleLogin,
  isOutlined: true,
  backgroundColor: Colors.white,
  textColor: Colors.black87,
)
```

**Properties:**
- `text`: String (required)
- `onPressed`: VoidCallback? (required)
- `isLoading`: bool (default: false)
- `isOutlined`: bool (default: false)
- `backgroundColor`: Color? (optional)
- `textColor`: Color? (optional)

**Features:**
- 🔄 Loading indicator khi đang xử lý
- 🎨 Support cho outlined style
- 📏 Full width button (54px height)
- ⚡ Tự động disable khi loading

---

### 4. AuthHeader
Header section với logo và title cho auth screens.

**Usage:**
```dart
AuthHeader(
  title: 'Chào mừng trở lại!',
  subtitle: 'Đăng nhập để quản lý cây cảnh của bạn',
  emoji: '🌱',
)
```

**Properties:**
- `title`: String (required)
- `subtitle`: String (required)
- `emoji`: String (default: '🌱')

**Features:**
- 🎨 Circular background cho emoji/logo
- 📱 Responsive text sizing
- 🌈 Themed colors

---

## 🚀 Quick Import

Import tất cả widgets cùng lúc:

```dart
import '../widgets/auth_widgets.dart';
```

Hoặc import riêng lẻ:

```dart
import '../widgets/custom_text_field.dart';
import '../widgets/password_text_field.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_header.dart';
```

---

## 📝 Notes

- Tất cả widgets đều support dark mode
- Design tuân theo Material 3
- Rounded corners: 12px
- Consistent padding và spacing
- Validation được handle ở screen level
- Colors được lấy từ `Theme.of(context)`

---

## 🎨 Design Principles

1. **Consistency**: Tất cả widgets có cùng design language
2. **Reusability**: Dễ dàng tái sử dụng ở nhiều nơi
3. **Accessibility**: Support validation và error messages
4. **UX**: Smooth animations và transitions
5. **Clean Code**: Well-documented và maintainable

---

## 🔄 Future Improvements

- [ ] Add animation effects
- [ ] Support for different button sizes
- [ ] Custom color schemes
- [ ] More icon options
- [ ] Social login buttons


