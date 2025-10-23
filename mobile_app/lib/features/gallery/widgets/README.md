# Gallery Widgets

Sprint 5 - Gallery Module widgets created by **Hoàng Chí Bằng**

## Overview

This directory contains reusable widgets for the Gallery feature, allowing users to view, add, and manage photos of their plants.

## Widgets

### 1. PhotoGridItem

**File:** `photo_grid_item.dart`

**Purpose:** Displays a single photo in the gallery grid with selection state support.

**Features:**
- Cached network image loading
- Loading placeholder
- Error handling with broken image icon
- Selection overlay with checkmark
- Tap gesture support
- Long press gesture support
- Rounded corners (12px)
- 3px border when selected

**Properties:**
- `imageUrl` (String, required) - URL of the image to display
- `onTap` (VoidCallback, required) - Callback when tapped
- `onLongPress` (VoidCallback?, optional) - Callback when long pressed
- `isSelected` (bool, default: false) - Whether the item is selected

**Usage:**
```dart
PhotoGridItem(
  imageUrl: 'https://example.com/photo.jpg',
  onTap: () => _viewPhoto(index),
  onLongPress: () => _selectPhoto(index),
  isSelected: _selectedPhotos.contains(index),
)
```

**Design:**
- Square aspect ratio
- Rounded corners for modern look
- Selection overlay with primary color
- Smooth transitions
- Image fit: cover (fills entire space)

---

### 2. FullScreenImageViewer

**File:** `full_screen_image_viewer.dart`

**Purpose:** Full-screen photo viewer with zoom, swipe, and delete capabilities.

**Features:**
- Pinch to zoom (powered by photo_view package)
- Swipe to navigate between photos
- Double tap to zoom
- Photo counter (current/total)
- Delete functionality with confirmation
- Black background for focus
- Hero animations support
- Loading progress indicator

**Properties:**
- `imageUrls` (List<String>, required) - List of image URLs to display
- `initialIndex` (int, default: 0) - Starting photo index
- `onDelete` (Function(int)?, optional) - Callback when delete is confirmed

**Usage:**
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => FullScreenImageViewer(
      imageUrls: allPhotos,
      initialIndex: selectedIndex,
      onDelete: (index) async {
        await _deletePhoto(index);
      },
    ),
  ),
)
```

**Design:**
- Immersive black background
- White text and icons for contrast
- Smooth page transitions
- Bounce physics for natural feel
- Loading indicator with progress

**Gestures:**
- **Swipe left/right:** Navigate between photos
- **Pinch:** Zoom in/out
- **Double tap:** Quick zoom
- **Drag:** Pan when zoomed

---

## Integration with Gallery Screen

The `GalleryScreen` uses both widgets:

1. **PhotoGridItem** - Displays photos in a 3-column grid
2. **FullScreenImageViewer** - Opens when photo is tapped

### Data Flow:

```
Gallery Screen
  ↓
Load photos from:
  - Plant image
  - Diary entry images
  ↓
Display in PhotoGridItem grid
  ↓
Tap → Open FullScreenImageViewer
  ↓
Delete → Confirm → Remove from Storage
```

---

## Dependencies

### Required Packages:

Add to `pubspec.yaml`:

```yaml
dependencies:
  cached_network_image: ^3.3.0
  photo_view: ^0.14.0
  image_picker: ^1.0.4
```

### Imports:

```dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:image_picker/image_picker.dart';
```

---

## Features Implemented

### Gallery Screen Features:
- ✅ Load all photos from plant and diary entries
- ✅ Display photos in 3-column grid
- ✅ Add new photos (camera or gallery)
- ✅ View photos in full screen
- ✅ Delete photos with confirmation
- ✅ Pull to refresh
- ✅ Empty state when no photos
- ✅ Loading states
- ✅ Error handling

### Photo Management:
- ✅ Image compression (1920x1080, 85% quality)
- ✅ Upload to Firebase Storage
- ✅ Delete from Firebase Storage
- ✅ Cached loading for performance
- ✅ Placeholder while loading
- ✅ Error icons for failed loads

---

## UI/UX Best Practices

1. **Performance:**
   - Images are cached for fast loading
   - Compressed images reduce data usage
   - Lazy loading in grid view

2. **User Feedback:**
   - Loading indicators during operations
   - Success/error snackbars
   - Confirmation dialogs for destructive actions
   - Pull to refresh for manual reload

3. **Accessibility:**
   - Tooltips on action buttons
   - Clear visual feedback for selections
   - Readable text with good contrast

4. **Modern Design:**
   - Rounded corners (12px)
   - Clean grid layout with spacing
   - Immersive full-screen viewer
   - Material Design principles

---

## Notes for Future Improvements

1. **Batch Selection:**
   - Add multi-select mode
   - Bulk delete/share options
   - Selection counter

2. **Photo Metadata:**
   - Add date taken
   - Add location (optional)
   - Add captions/notes

3. **Gallery Organization:**
   - Create dedicated gallery collection in Firestore
   - Sort by date/type
   - Filter by source (plant photo vs diary)

4. **Sharing:**
   - Share photos to social media
   - Export multiple photos
   - Create collages

5. **Advanced Features:**
   - Photo editing (crop, rotate, filters)
   - Slideshow mode
   - Cloud backup indicators
   - Download to device option

---

## Testing Checklist

- [ ] Load gallery with photos
- [ ] Load gallery with no photos (empty state)
- [ ] Add photo from camera
- [ ] Add photo from gallery
- [ ] View photo in full screen
- [ ] Zoom in/out on photo
- [ ] Swipe between photos
- [ ] Delete photo with confirmation
- [ ] Delete photo and cancel
- [ ] Pull to refresh
- [ ] Handle network errors
- [ ] Handle permission denials
- [ ] Test on different screen sizes

---

**Created by:** Hoàng Chí Bằng  
**Sprint:** 5  
**Date:** October 2024  
**Status:** ✅ Complete

