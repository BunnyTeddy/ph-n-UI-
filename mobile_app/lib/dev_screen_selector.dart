import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/plant_management/screens/add_plant_screen.dart';
import 'features/plant_management/screens/edit_plant_screen.dart';
import 'features/diary/screens/diary_list_screen.dart';
import 'features/diary/screens/add_diary_screen.dart';
import 'features/gallery/screens/gallery_screen.dart';
import 'features/settings/screens/settings_screen.dart';
import 'features/statistics/screens/statistics_screen.dart';
import 'features/iot/screens/iot_home_screen.dart';
import 'features/iot/screens/plant_detail_iot_screen.dart';
import 'providers/plant_provider.dart';
import 'providers/iot_provider.dart';

/// Development Screen Selector
/// Màn hình này cho phép xem tất cả các screens mà không cần Firebase
/// 
/// Để sử dụng: Thay đổi initialRoute trong app.dart thành '/dev'
class DevScreenSelector extends StatefulWidget {
  const DevScreenSelector({super.key});

  @override
  State<DevScreenSelector> createState() => _DevScreenSelectorState();
}

class _DevScreenSelectorState extends State<DevScreenSelector> {
  // Mock Plant ID cho dev mode - không cần Firebase
  static const String mockPlantId = 'mock-plant-001';

  @override
  void initState() {
    super.initState();
    // Load mock data when entering dev mode
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlantProvider>().loadMockData();
      context.read<IotProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎨 Screen Selector - Dev Mode'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Chọn màn hình để xem:',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tất cả screens có thể xem mà không cần Firebase',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Authentication Screens
          _buildSection('🔐 Authentication (Sprint 1)', [
            _ScreenTile(
              title: 'Login Screen',
              subtitle: 'Màn hình đăng nhập',
              icon: Icons.login,
              color: Colors.blue,
              onTap: () => _navigateTo(context, const LoginScreen()),
            ),
            _ScreenTile(
              title: 'Register Screen',
              subtitle: 'Màn hình đăng ký',
              icon: Icons.person_add,
              color: Colors.blue,
              onTap: () => _navigateTo(context, const RegisterScreen()),
            ),
          ]),

          const SizedBox(height: 24),

          // Home Screens
          _buildSection('🏠 Home (Sprint 2)', [
            _ScreenTile(
              title: 'Home Screen',
              subtitle: 'Trang chủ với dashboard',
              icon: Icons.home,
              color: Colors.green,
              onTap: () => _navigateTo(context, const HomeScreen()),
            ),
          ]),

          const SizedBox(height: 24),

          // Plant Management
          _buildSection('🌱 Plant Management (Sprint 3)', [
            _ScreenTile(
              title: 'Add Plant Screen',
              subtitle: 'Thêm cây mới',
              icon: Icons.add_circle,
              color: Colors.teal,
              onTap: () => _navigateTo(context, const AddPlantScreen()),
            ),
            _ScreenTile(
              title: 'Edit Plant Screen',
              subtitle: 'Sửa thông tin cây (mock data)',
              icon: Icons.edit,
              color: Colors.teal,
              onTap: () => _navigateTo(
                context,
                const EditPlantScreen(plantId: _DevScreenSelectorState.mockPlantId),
              ),
            ),
          ]),

          const SizedBox(height: 24),

          // Diary
          _buildSection('📔 Diary (Sprint 4)', [
            _ScreenTile(
              title: 'Diary List Screen',
              subtitle: 'Danh sách nhật ký (mock data)',
              icon: Icons.book,
              color: Colors.orange,
              onTap: () => _navigateTo(
                context,
                const DiaryListScreen(plantId: _DevScreenSelectorState.mockPlantId),
              ),
            ),
            _ScreenTile(
              title: 'Add Diary Screen',
              subtitle: 'Thêm nhật ký (mock data)',
              icon: Icons.add_box,
              color: Colors.orange,
              onTap: () => _navigateTo(
                context,
                const AddDiaryScreen(plantId: _DevScreenSelectorState.mockPlantId),
              ),
            ),
          ]),

          const SizedBox(height: 24),

          // Gallery
          _buildSection('📷 Gallery (Sprint 5)', [
            _ScreenTile(
              title: 'Gallery Screen',
              subtitle: 'Thư viện ảnh (mock data)',
              icon: Icons.photo_library,
              color: Colors.purple,
              onTap: () => _navigateTo(
                context,
                const GalleryScreen(plantId: _DevScreenSelectorState.mockPlantId),
              ),
            ),
          ]),

          const SizedBox(height: 24),

          // Settings & Statistics
          _buildSection('⚙️ Settings & Statistics (Sprint 6)', [
            _ScreenTile(
              title: 'Settings Screen',
              subtitle: 'Cài đặt ứng dụng',
              icon: Icons.settings,
              color: Colors.grey,
              onTap: () => _navigateTo(context, const SettingsScreen()),
            ),
            _ScreenTile(
              title: 'Statistics Screen 📊 (Hoàng)',
              subtitle: 'Thống kê & báo cáo với biểu đồ',
              icon: Icons.bar_chart,
              color: Colors.indigo,
              onTap: () => _navigateTo(
                context,
                const StatisticsScreen(plantId: _DevScreenSelectorState.mockPlantId), // ✅ FIX: Truyền plantId
              ),
            ),
          ]),

          const SizedBox(height: 24),

          // IoT Screens (Tiến's work)
          _buildSection('🤖 IoT - Smart Greenhouse (Sprint 7)', [
            _ScreenTile(
              title: 'IoT Home Screen',
              subtitle: 'Smart Greenhouse Control Panel',
              icon: Icons.sensors,
              color: Colors.green,
              onTap: () => _navigateTo(context, const IotHomeScreen()),
            ),
            _ScreenTile(
              title: 'Plant Detail IoT Screen',
              subtitle: 'Chi tiết cây với IoT data',
              icon: Icons.eco,
              color: Colors.lightGreen,
              onTap: () => _navigateTo(
                context,
                const PlantDetailIotScreen(plantId: _DevScreenSelectorState.mockPlantId),
              ),
            ),
          ]),

          const SizedBox(height: 32),

          // Instructions
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Hướng dẫn',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '1. Chọn screen từ danh sách trên\n'
                    '2. Tất cả screens có thể xem ngay (dùng mock plantId)\n'
                    '3. Data sẽ là mock data (chưa có Firebase)\n'
                    '4. Một số screens có thể báo lỗi nếu chưa có data\n'
                    '5. Để tắt dev mode: Đổi initialRoute về AppRoutes.login',
                    style: TextStyle(height: 1.5),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}

class _ScreenTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ScreenTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(51),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

