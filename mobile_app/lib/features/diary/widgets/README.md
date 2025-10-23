# Diary Widgets - Hoàng Chí Bằng

Các widget tái sử dụng cho Diary Module.

## Widgets

### 1. DiaryCard
Card hiển thị diary entry trong list với đầy đủ thông tin.

**Props:**
- `entry`: DiaryEntryModel - entry cần hiển thị
- `onTap`: Callback khi tap vào card (optional)
- `onDelete`: Callback khi xóa entry (optional)

**Features:**
- Hiển thị activity type với icon và màu tương ứng:
  - 💧 Tưới nước (Blue)
  - 🌿 Bón phân (Green)
  - ✂️ Tỉa cành (Orange)
  - 👁️ Quan sát (Purple)
- Format ngày giờ dd/MM/yyyy • HH:mm
- Hiển thị nội dung với line height thoải mái
- Image gallery:
  - 1 ảnh: full width 200px height
  - Nhiều ảnh: horizontal scroll 100x100
- Menu actions với bottom sheet
- Cached network images

**Usage:**
```dart
DiaryCard(
  entry: diaryEntry,
  onTap: () {
    // Navigate to detail
  },
  onDelete: () {
    // Delete entry
  },
)
```

### 2. ActivityTypeSelector
Widget chọn loại hoạt động chăm sóc với chips đẹp.

**Props:**
- `selectedType`: String - activity type đã chọn
- `onTypeSelected`: Function(String) - callback khi chọn type

**Features:**
- 4 activity types:
  - watering (Tưới nước)
  - fertilizing (Bón phân)
  - pruning (Tỉa cành)
  - observation (Quan sát)
- Chip design với icon + label
- Selected state với background màu, text trắng
- Unselected state với background nhạt, text màu
- Wrap layout tự động xuống dòng
- Border thickness khác nhau cho selected/unselected

**Usage:**
```dart
ActivityTypeSelector(
  selectedType: _selectedActivityType,
  onTypeSelected: (type) {
    setState(() {
      _selectedActivityType = type;
    });
  },
)
```

### 3. MultiImagePicker
Widget chọn nhiều ảnh cho diary entry.

**Props:**
- `existingImageUrls`: List<String>? - URLs ảnh hiện có (optional)
- `onImagesSelected`: Function(List<XFile>) - callback khi chọn ảnh
- `maxImages`: int - số ảnh tối đa (default: 5)

**Features:**
- Pick multiple images từ gallery
- Pick single image từ camera
- Display thumbnails với delete button
- Counter hiển thị số ảnh (X/5)
- Add button khi chưa đủ max
- Image compression (1920x1080, quality 85%)
- Modal bottom sheet chọn nguồn
- Horizontal scroll cho thumbnails
- Stack layout với X button overlay

**Usage:**
```dart
MultiImagePicker(
  onImagesSelected: (images) {
    setState(() {
      _pickedImages = images;
    });
  },
  maxImages: 5,
)
```

## Screens

### Diary List Screen
Hiển thị danh sách nhật ký của cây.

**Features:**
- AppBar với plant name subtitle
- Filter button (lọc theo activity type)
- Pull to refresh
- Empty state khi chưa có nhật ký
- List of diary cards
- Delete với confirmation
- FAB "Ghi nhật ký"
- Filter modal bottom sheet với 5 options

**Navigation:**
- Requires `plantId` as argument
- Navigate to AddDiaryScreen với plantId

### Add Diary Screen
Form thêm nhật ký mới.

**Features:**
- AppBar với plant name subtitle
- Quick info card (plant overview)
- Activity type selector (required)
- Content text field (required, max 1000 chars)
- Multi image picker (optional, max 5)
- Form validation
- Loading states
- Success/error messages
- Auto-upload images (placeholder)

**Form Fields:**
- Activity Type: Required, 4 options
- Content: Required, multi-line, max 1000 chars
- Images: Optional, max 5 images

## Activity Types

```dart
class ActivityType {
  static const String watering = 'watering';      // Tưới nước
  static const String fertilizing = 'fertilizing'; // Bón phân
  static const String pruning = 'pruning';         // Tỉa cành
  static const String observation = 'observation'; // Quan sát
}
```

## UI/UX Features

- ✅ Color-coded activity types
- ✅ Beautiful chips design
- ✅ Multi-image support
- ✅ Image compression
- ✅ Horizontal gallery scroll
- ✅ Empty states
- ✅ Loading states
- ✅ Error handling
- ✅ Pull to refresh
- ✅ Filter functionality
- ✅ Confirmation dialogs
- ✅ Cached network images
- ✅ Responsive layouts
- ✅ Material 3 design


