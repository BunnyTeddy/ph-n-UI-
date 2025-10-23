import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../providers/plant_provider.dart';
import '../../../providers/diary_provider.dart';
import '../../../services/firebase/storage_service.dart';
import '../widgets/photo_grid_item.dart';
import '../widgets/full_screen_image_viewer.dart';
import '../../home/widgets/empty_state_widget.dart';

/// Gallery Screen - Assigned to: Hoàng Chí Bằng
/// Task 1.5: Trang Thư viện ảnh của cây
class GalleryScreen extends StatefulWidget {
  final String plantId;

  const GalleryScreen({super.key, required this.plantId});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final _imagePicker = ImagePicker();
  final _storageService = StorageService();
  bool _isLoading = false;
  List<String> _allPhotos = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPhotos();
    });
  }

  Future<void> _loadPhotos() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);

    try {
      // Load diary entries to get all photos
      final diaryProvider = context.read<DiaryProvider>();
      final plantProvider = context.read<PlantProvider>();
      
      await diaryProvider.loadEntries(widget.plantId);
      final diaryEntries = diaryProvider.entries;

      // Get plant photo
      final plant = plantProvider.plants.firstWhere(
            (p) => p.id == widget.plantId,
            orElse: () => throw Exception('Plant not found'),
          );

      // Collect all photos
      final photos = <String>[];
      
      // Add plant image if exists
      final plantImage = plant.imageUrl;
      if (plantImage != null && plantImage.isNotEmpty) {
        photos.add(plantImage);
      }

      // Add all diary images
      for (final entry in diaryEntries) {
        final entryImages = entry.imageUrls;
        if (entryImages.isNotEmpty) {
          photos.addAll(entryImages);
        }
      }

      if (mounted) {
        setState(() {
          _allPhotos = photos;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tải ảnh: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addPhoto() async {
    final source = await _showImageSourceDialog();
    if (source == null) return;

    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      setState(() => _isLoading = true);

      // Upload to Firebase Storage
      final file = File(pickedFile.path);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final imagePath = 'plants/${widget.plantId}/gallery/$timestamp.jpg';
      final imageUrl = await _storageService.uploadImage(imagePath, file);

      if (imageUrl == null) {
        throw Exception('Failed to upload image');
      }

      // Add to gallery (you might want to create a dedicated gallery collection)
      // For now, we'll just reload the photos
      await _loadPhotos();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã thêm ảnh vào thư viện'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi thêm ảnh: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Chọn nguồn ảnh',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: const Text('Chụp ảnh'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.green),
                title: const Text('Thư viện'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _viewPhoto(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImageViewer(
          imageUrls: _allPhotos,
          initialIndex: index,
          onDelete: (deleteIndex) async {
            // Note: This is a simplified delete - in production you'd want to
            // track which photos belong to which entries and delete appropriately
            await _confirmDeletePhoto(deleteIndex);
          },
        ),
      ),
    );
  }

  Future<void> _confirmDeletePhoto(int index) async {
    final imageUrl = _allPhotos[index];
    
    try {
      // Delete from Firebase Storage
      await _storageService.deleteImage(imageUrl);
      
      // Reload photos
      await _loadPhotos();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa ảnh'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi xóa ảnh: $e'),
            backgroundColor: Colors.red,
          ),
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
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Thư viện ảnh'),
            Text(
              plant.name,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.add_photo_alternate),
              onPressed: _addPhoto,
              tooltip: 'Thêm ảnh',
            ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadPhotos,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _allPhotos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_allPhotos.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.photo_library,
        title: 'Chưa có ảnh',
        message: 'Hãy thêm ảnh đầu tiên vào\nthư viện của cây này nhé!',
        buttonText: 'Thêm ảnh',
        onButtonPressed: _addPhoto,
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _allPhotos.length,
      itemBuilder: (context, index) {
        return PhotoGridItem(
          imageUrl: _allPhotos[index],
          onTap: () => _viewPhoto(index),
        );
      },
    );
  }
}








