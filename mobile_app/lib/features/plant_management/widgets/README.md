# Plant Management Widgets - Hoàng Chí Bằng

Các widget tái sử dụng cho Add/Edit Plant screens.

## Widgets

### 1. PlantFormField
Custom text field cho plant forms với validation và styling đẹp.

**Props:**
- `label`: Label của field
- `hint`: Placeholder text
- `controller`: TextEditingController
- `validator`: Function validation
- `keyboardType`: Loại bàn phím (optional)
- `maxLines`: Số dòng tối đa (default: 1)
- `maxLength`: Độ dài tối đa (optional)
- `prefixIcon`: Icon ở đầu field (optional)
- `readOnly`: Chế độ chỉ đọc (default: false)
- `onTap`: Callback khi tap (optional)

**Features:**
- Custom styling với rounded corners
- Green border khi focus
- Error validation với border đỏ
- Support multi-line input
- Character counter
- Prefix icon

**Usage:**
```dart
PlantFormField(
  label: 'Tên cây *',
  hint: 'VD: Xương rồng nhà tôi',
  controller: _nameController,
  prefixIcon: Icons.eco,
  validator: (value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập tên cây';
    }
    return null;
  },
)
```

### 2. ImagePickerWidget
Widget cho phép chọn/chụp ảnh cây với preview.

**Props:**
- `imageUrl`: URL ảnh hiện tại (optional)
- `onImagePicked`: Callback khi chọn ảnh

**Features:**
- Chọn ảnh từ thư viện
- Chụp ảnh trực tiếp
- Xóa ảnh
- Preview ảnh đã chọn
- Cached network image cho ảnh từ URL
- Placeholder đẹp khi chưa có ảnh
- Modal bottom sheet chọn nguồn
- Auto resize ảnh (max 1920x1080, quality 85%)

**Usage:**
```dart
ImagePickerWidget(
  imageUrl: existingImageUrl,
  onImagePicked: (image) {
    setState(() {
      _pickedImage = image;
    });
  },
)
```

### 3. DatePickerField
Custom date picker field với Material Design.

**Props:**
- `label`: Label của field
- `selectedDate`: Ngày đã chọn (optional)
- `onDateSelected`: Callback khi chọn ngày
- `validator`: Function validation (optional)

**Features:**
- Material date picker
- Format ngày dd/MM/yyyy
- Green theme cho picker
- Validation support
- Custom styling
- Icon calendar
- Placeholder text khi chưa chọn

**Usage:**
```dart
DatePickerField(
  label: 'Ngày trồng *',
  selectedDate: _plantedDate,
  onDateSelected: (date) {
    setState(() {
      _plantedDate = date;
    });
  },
  validator: (date) {
    if (date == null) {
      return 'Vui lòng chọn ngày trồng';
    }
    return null;
  },
)
```

## Screens

### Add Plant Screen
Form thêm cây mới với đầy đủ fields và validation.

**Features:**
- Image picker
- Name field (required)
- Species field (required)
- Planted date picker (required)
- Description field (optional)
- Form validation
- Loading states
- Success/error messages
- Auto upload ảnh (placeholder - Hiệp sẽ implement)

### Edit Plant Screen
Form sửa thông tin cây với pre-filled data.

**Features:**
- Load existing plant data
- All fields như Add Plant
- Delete button trong AppBar
- Confirm dialog trước khi xóa
- Update existing image hoặc giữ nguyên
- Form validation
- Loading states
- Success/error messages

## Form Validation Rules

- **Name**: Required, không được để trống
- **Species**: Required, không được để trống
- **Planted Date**: Required, phải chọn ngày
- **Description**: Optional, max 500 characters
- **Image**: Optional

## UI/UX Features

- ✅ Clean, modern design
- ✅ Green color scheme
- ✅ Rounded corners (12px)
- ✅ Proper spacing
- ✅ Loading indicators
- ✅ Error handling
- ✅ Success feedback
- ✅ Confirmation dialogs
- ✅ Responsive layout
- ✅ Keyboard-friendly


