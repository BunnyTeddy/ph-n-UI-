import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/diary_provider.dart';
import '../../../providers/plant_provider.dart';
import '../../../models/diary_entry_model.dart';
import '../widgets/activity_type_selector.dart';
import '../widgets/multi_image_picker.dart';

/// Add Diary Screen - Assigned to: Hoàng Chí Bằng
/// Task 1.4: Trang Ghi nhật ký chăm sóc
class AddDiaryScreen extends StatefulWidget {
  final String plantId;

  const AddDiaryScreen({
    super.key,
    required this.plantId,
  });

  @override
  State<AddDiaryScreen> createState() => _AddDiaryScreenState();
}

class _AddDiaryScreenState extends State<AddDiaryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  
  String _selectedActivityType = ActivityType.observation;
  List<XFile> _pickedImages = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.currentUser == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }

      // TODO: Upload images to Firebase Storage (Hiệp will implement)
      List<String> imageUrls = [];
      if (_pickedImages.isNotEmpty) {
        // imageUrls = await uploadImages(_pickedImages);
        imageUrls = _pickedImages
            .map((img) => 'https://placeholder.com/diary-${DateTime.now().millisecondsSinceEpoch}.jpg')
            .toList();
      }

      final entry = DiaryEntryModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        plantId: widget.plantId,
        userId: authProvider.currentUser!.id,
        content: _contentController.text.trim(),
        imageUrls: imageUrls,
        activityType: _selectedActivityType,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await context.read<DiaryProvider>().addEntry(entry);

      if (mounted) {
        setState(() => _isLoading = false);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã lưu nhật ký'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lỗi khi lưu nhật ký'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
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
            const Text('Ghi nhật ký'),
            Text(
              plant.name,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Quick Info Card
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.eco,
                        color: Colors.green[400],
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plant.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${plant.species} • ${plant.ageInDays} ngày tuổi',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Activity Type Selector
            ActivityTypeSelector(
              selectedType: _selectedActivityType,
              onTypeSelected: (type) {
                setState(() {
                  _selectedActivityType = type;
                });
              },
            ),
            const SizedBox(height: 24),

            // Content Field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nội dung *',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _contentController,
                  maxLines: 6,
                  maxLength: 1000,
                  decoration: InputDecoration(
                    hintText: 'Ghi chú về hoạt động chăm sóc...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.green, width: 2),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập nội dung';
                    }
                    return null;
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Multi Image Picker
            MultiImagePicker(
              onImagesSelected: (images) {
                setState(() {
                  _pickedImages = images;
                });
              },
              maxImages: 5,
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Lưu nhật ký',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Help Text
            Center(
              child: Text(
                '* Trường bắt buộc',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
