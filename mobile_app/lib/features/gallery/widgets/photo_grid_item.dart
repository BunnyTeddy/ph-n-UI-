import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Photo Grid Item Widget - Sprint 5
/// Displays a single photo in the gallery grid
class PhotoGridItem extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;

  const PhotoGridItem({
    super.key,
    required this.imageUrl,
    required this.onTap,
    this.onLongPress,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 3,
                )
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.broken_image,
                    size: 40,
                    color: Colors.grey,
                  ),
                ),
              ),
              
              // Selection overlay
              if (isSelected)
                Container(
                  color: Theme.of(context).primaryColor.withAlpha(76),
                  child: Center(
                    child: Icon(
                      Icons.check_circle,
                      color: Theme.of(context).primaryColor,
                      size: 40,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

