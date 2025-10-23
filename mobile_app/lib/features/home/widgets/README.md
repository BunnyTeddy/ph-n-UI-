# Home Widgets - Hoàng Chí Bằng

Các widget tái sử dụng cho Home Screen.

## Widgets

### 1. DashboardCard
Card hiển thị thống kê trên dashboard với gradient màu đẹp.

**Props:**
- `title`: Tiêu đề card
- `value`: Giá trị hiển thị
- `icon`: Icon
- `color`: Màu gradient
- `onTap`: Callback khi tap (optional)

**Usage:**
```dart
DashboardCard(
  title: 'Tổng số cây',
  value: '10',
  icon: Icons.eco,
  color: Colors.green,
  onTap: () {
    // Handle tap
  },
)
```

### 2. PlantListItem
Item hiển thị thông tin cây trong danh sách với image, thông tin và menu actions.

**Props:**
- `plant`: PlantModel
- `onTap`: Callback khi tap vào item
- `onEdit`: Callback khi chọn edit (optional)
- `onDelete`: Callback khi chọn delete (optional)

**Features:**
- Hiển thị ảnh cây (hoặc placeholder nếu không có)
- Thông tin: tên, loài, tuổi cây
- Menu actions (edit/delete)
- Cached network image

### 3. QuickActionButton
Button cho thao tác nhanh với icon và label.

**Props:**
- `label`: Text hiển thị
- `icon`: Icon
- `color`: Màu chủ đạo
- `onTap`: Callback khi tap

### 4. EmptyStateWidget
Widget hiển thị trạng thái empty với icon, message và button.

**Props:**
- `icon`: Icon hiển thị
- `title`: Tiêu đề
- `message`: Nội dung message
- `buttonText`: Text của button (optional)
- `onButtonPressed`: Callback của button (optional)

## Home Screen Features

### ✅ Dashboard Section
- Card tổng số cây
- Card tuổi trung bình
- Gradient cards đẹp

### ✅ Quick Actions Section
- Nút Nhật ký
- Nút Thư viện
- Nút Thống kê

### ✅ Plant List Section
- Danh sách cây với ảnh
- Menu edit/delete cho mỗi cây
- Pull-to-refresh

### ✅ Empty State
- Hiển thị khi chưa có cây
- Có nút thêm cây mới

### ✅ Other Features
- AppBar với greeting user
- Notifications button (coming soon)
- Settings button
- FAB thêm cây mới
- Confirm dialog khi xóa cây


