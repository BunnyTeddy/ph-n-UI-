import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../models/diary_entry_model.dart';

/// Diary Card Widget - Assigned to: Hoàng Chí Bằng
/// Card hiển thị diary entry trong list
class DiaryCard extends StatelessWidget {
  final DiaryEntryModel entry;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const DiaryCard({
    super.key,
    required this.entry,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Activity Type + Date + Menu
              Row(
                children: [
                  _buildActivityIcon(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getActivityLabel(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('dd/MM/yyyy • HH:mm').format(entry.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.more_vert, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _showMenu(context),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Content
              Text(
                entry.content,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[800],
                  height: 1.5,
                ),
              ),

              // Images (if any)
              if (entry.imageUrls.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildImageGallery(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityIcon() {
    Color color;
    IconData icon;

    switch (entry.activityType) {
      case 'watering':
        color = Colors.blue;
        icon = Icons.water_drop;
        break;
      case 'fertilizing':
        color = Colors.green;
        icon = Icons.energy_savings_leaf;
        break;
      case 'pruning':
        color = Colors.orange;
        icon = Icons.content_cut;
        break;
      case 'observation':
      default:
        color = Colors.purple;
        icon = Icons.visibility;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  String _getActivityLabel() {
    switch (entry.activityType) {
      case 'watering':
        return 'Tưới nước';
      case 'fertilizing':
        return 'Bón phân';
      case 'pruning':
        return 'Tỉa cành';
      case 'observation':
        return 'Quan sát';
      default:
        return 'Ghi chú';
    }
  }

  Widget _buildImageGallery() {
    if (entry.imageUrls.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: entry.imageUrls[0],
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            height: 200,
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => Container(
            height: 200,
            color: Colors.grey[200],
            child: const Icon(Icons.error),
          ),
        ),
      );
    }

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: entry.imageUrls.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(right: index < entry.imageUrls.length - 1 ? 8 : 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: entry.imageUrls[index],
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[200],
                  child: const Icon(Icons.error, size: 20),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showMenu(BuildContext context) {
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
            children: [
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Xóa nhật ký'),
                onTap: () {
                  Navigator.pop(context);
                  if (onDelete != null) onDelete!();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}


