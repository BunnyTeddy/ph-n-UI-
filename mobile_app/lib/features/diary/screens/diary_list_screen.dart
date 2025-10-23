import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/diary_provider.dart';
import '../../../providers/plant_provider.dart';
import '../../../core/routes/app_routes.dart';
import '../widgets/diary_card.dart';
import '../../home/widgets/empty_state_widget.dart';

/// Diary List Screen - Assigned to: Hoàng Chí Bằng
/// Task 1.4: Trang Ghi nhật ký chăm sóc
class DiaryListScreen extends StatefulWidget {
  final String plantId;

  const DiaryListScreen({
    super.key,
    required this.plantId,
  });

  @override
  State<DiaryListScreen> createState() => _DiaryListScreenState();
}

class _DiaryListScreenState extends State<DiaryListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEntries();
    });
  }

  Future<void> _loadEntries() async {
    await context.read<DiaryProvider>().loadEntries(widget.plantId);
  }

  @override
  Widget build(BuildContext context) {
    final plant = context.read<PlantProvider>().plants.firstWhere(
          (p) => p.id == widget.plantId,
          orElse: () => throw Exception('Plant not found'),
        );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nhật ký chăm sóc'),
            Text(
              plant.name,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Lọc theo loại',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadEntries,
        child: Consumer<DiaryProvider>(
          builder: (context, diaryProvider, _) {
            if (diaryProvider.isLoading && diaryProvider.entries.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (diaryProvider.entries.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.book,
                title: 'Chưa có nhật ký',
                message: 'Hãy ghi lại hành trình chăm sóc\ncây của bạn nhé!',
                buttonText: 'Ghi nhật ký đầu tiên',
                onButtonPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.addDiary,
                    arguments: widget.plantId,
                  );
                },
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: diaryProvider.entries.length,
              itemBuilder: (context, index) {
                final entry = diaryProvider.entries[index];
                return DiaryCard(
                  entry: entry,
                  onTap: () {
                    // TODO: Navigate to diary detail screen (optional)
                  },
                  onDelete: () => _confirmDelete(entry.id),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(
            context,
            AppRoutes.addDiary,
            arguments: widget.plantId,
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Ghi nhật ký'),
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Lọc theo loại hoạt động',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _FilterOption(
                icon: Icons.clear_all,
                label: 'Tất cả',
                color: Colors.grey,
                onTap: () {
                  Navigator.pop(context);
                  _loadEntries();
                },
              ),
              _FilterOption(
                icon: Icons.water_drop,
                label: 'Tưới nước',
                color: Colors.blue,
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Filter by watering
                },
              ),
              _FilterOption(
                icon: Icons.energy_savings_leaf,
                label: 'Bón phân',
                color: Colors.green,
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Filter by fertilizing
                },
              ),
              _FilterOption(
                icon: Icons.content_cut,
                label: 'Tỉa cành',
                color: Colors.orange,
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Filter by pruning
                },
              ),
              _FilterOption(
                icon: Icons.visibility,
                label: 'Quan sát',
                color: Colors.purple,
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Filter by observation
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(String entryId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa nhật ký này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<DiaryProvider>().deleteEntry(entryId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Đã xóa nhật ký' : 'Lỗi khi xóa'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }
}

class _FilterOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _FilterOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
