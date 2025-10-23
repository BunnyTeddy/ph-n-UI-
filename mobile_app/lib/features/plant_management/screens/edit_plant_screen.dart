import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../providers/plant_provider.dart';
import '../../../models/plant_model.dart';
import '../widgets/plant_form_field.dart';
import '../widgets/image_picker_widget.dart';
import '../widgets/date_picker_field.dart';

/// Edit Plant Screen - Assigned to: Hoàng Chí Bằng
/// Task 1.3: Trang Thêm / Xoá / Sửa thông tin cây
class EditPlantScreen extends StatefulWidget {
  final String plantId;

  const EditPlantScreen({
    super.key,
    required this.plantId,
  });

  @override
  State<EditPlantScreen> createState() => _EditPlantScreenState();
}

class _EditPlantScreenState extends State<EditPlantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _speciesController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  DateTime? _plantedDate;
  XFile? _pickedImage;
  String? _existingImageUrl;
  bool _isLoading = false;
  PlantModel? _plant;

  @override
  void initState() {
    super.initState();
    _loadPlantData();
  }

  void _loadPlantData() {
    final plantProvider = context.read<PlantProvider>();
    _plant = plantProvider.plants.firstWhere(
      (p) => p.id == widget.plantId,
      orElse: () => throw Exception('Plant not found'),
    );

    _nameController.text = _plant!.name;
    _speciesController.text = _plant!.species;
    _descriptionController.text = _plant!.description ?? '';
    _plantedDate = _plant!.plantedDate;
    _existingImageUrl = _plant!.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_plantedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày trồng')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: Upload new image if changed (Hiệp will implement)
      String? imageUrl = _existingImageUrl;
      if (_pickedImage != null) {
        // imageUrl = await uploadImage(_pickedImage!);
        imageUrl = 'https://placeholder.com/plant-updated.jpg';
      }

      final updatedPlant = _plant!.copyWith(
        name: _nameController.text.trim(),
        species: _speciesController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        plantedDate: _plantedDate!,
        imageUrl: imageUrl,
        updatedAt: DateTime.now(),
      );

      final success = await context.read<PlantProvider>().updatePlant(
        widget.plantId,
        updatedPlant,
      );

      if (mounted) {
        setState(() => _isLoading = false);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã cập nhật thông tin cây'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lỗi khi cập nhật'),
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

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa "${_plant!.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isLoading = true);
      
      final success = await context.read<PlantProvider>().deletePlant(widget.plantId);
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã xóa cây'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lỗi khi xóa cây'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_plant == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chỉnh sửa cây')),
        body: const Center(child: Text('Không tìm thấy cây')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Chỉnh sửa thông tin'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _isLoading ? null : _handleDelete,
            tooltip: 'Xóa cây',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Image Picker
            ImagePickerWidget(
              imageUrl: _existingImageUrl,
              onImagePicked: (image) {
                setState(() {
                  _pickedImage = image;
                });
              },
            ),
            const SizedBox(height: 24),

            // Name Field
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
            ),
            const SizedBox(height: 20),

            // Species Field
            PlantFormField(
              label: 'Loài cây *',
              hint: 'VD: Xương rồng, Cây Sen Đá',
              controller: _speciesController,
              prefixIcon: Icons.category,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập loài cây';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Planted Date
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
            ),
            const SizedBox(height: 20),

            // Description Field
            PlantFormField(
              label: 'Mô tả (Tùy chọn)',
              hint: 'Ghi chú về cây của bạn...',
              controller: _descriptionController,
              prefixIcon: Icons.note,
              maxLines: 4,
              maxLength: 500,
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
                        'Lưu thay đổi',
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
