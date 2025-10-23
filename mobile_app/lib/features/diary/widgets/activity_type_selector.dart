import 'package:flutter/material.dart';
import '../../../models/diary_entry_model.dart';

/// Activity Type Selector Widget - Assigned to: Hoàng Chí Bằng
/// Widget chọn loại hoạt động chăm sóc
class ActivityTypeSelector extends StatelessWidget {
  final String selectedType;
  final Function(String) onTypeSelected;

  const ActivityTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Loại hoạt động *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _ActivityTypeChip(
              type: ActivityType.watering,
              label: 'Tưới nước',
              icon: Icons.water_drop,
              color: Colors.blue,
              isSelected: selectedType == ActivityType.watering,
              onTap: () => onTypeSelected(ActivityType.watering),
            ),
            _ActivityTypeChip(
              type: ActivityType.fertilizing,
              label: 'Bón phân',
              icon: Icons.energy_savings_leaf,
              color: Colors.green,
              isSelected: selectedType == ActivityType.fertilizing,
              onTap: () => onTypeSelected(ActivityType.fertilizing),
            ),
            _ActivityTypeChip(
              type: ActivityType.pruning,
              label: 'Tỉa cành',
              icon: Icons.content_cut,
              color: Colors.orange,
              isSelected: selectedType == ActivityType.pruning,
              onTap: () => onTypeSelected(ActivityType.pruning),
            ),
            _ActivityTypeChip(
              type: ActivityType.observation,
              label: 'Quan sát',
              icon: Icons.visibility,
              color: Colors.purple,
              isSelected: selectedType == ActivityType.observation,
              onTap: () => onTypeSelected(ActivityType.observation),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActivityTypeChip extends StatelessWidget {
  final String type;
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ActivityTypeChip({
    required this.type,
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


