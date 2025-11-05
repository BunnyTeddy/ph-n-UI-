import 'dart:io';
import 'package:flutter/material.dart';
import '../models/diary_entry_model.dart';
import '../services/firebase/firestore_service.dart';
import '../services/firebase/storage_service.dart';

class DiaryProvider with ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  final StorageService _storage = StorageService();
  
  List<DiaryEntryModel> _entries = [];
  bool _isLoading = false;
  String? _error;

  List<DiaryEntryModel> get entries => _entries;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load diary entries from Firestore for a plant
  Future<void> loadEntries(String plantId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _firestore.queryCollection('diary_entries', 'plantId', plantId);
      _entries = data.map((entryData) => DiaryEntryModel.fromMap(entryData)).toList();
      _entries.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Sort by newest
      _error = null;
    } catch (e) {
      _error = 'Lỗi tải nhật ký: $e';
      print('Error loading diary entries: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add new diary entry with multiple images
  Future<bool> addEntry(DiaryEntryModel entry, {List<File>? imageFiles}) async {
    _isLoading = true;
    notifyListeners();

    try {
      List<String> imageUrls = [];
      
      // Upload images if provided
      if (imageFiles != null && imageFiles.isNotEmpty) {
        final basePath = 'diary/${entry.userId}/${entry.id}';
        imageUrls = await _storage.uploadMultipleImages(basePath, imageFiles);
      }
      
      // Save entry to Firestore
      final entryData = entry.toMap();
      entryData['images'] = imageUrls;
      entryData['createdAt'] = DateTime.now().toIso8601String();
      
      await _firestore.addDocument('diary_entries', entryData);
      
      // Reload entries
      await loadEntries(entry.plantId);
      
      _error = null;
      return true;
    } catch (e) {
      _error = 'Lỗi thêm nhật ký: $e';
      print('Error adding diary entry: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update diary entry
  Future<bool> updateEntry(String entryId, DiaryEntryModel entry, {List<File>? newImageFiles}) async {
    _isLoading = true;
    notifyListeners();

    try {
      List<String> imageUrls = entry.imageUrls;
      
      // If new images provided, delete old and upload new
      if (newImageFiles != null && newImageFiles.isNotEmpty) {
        // Delete old images
        for (String oldImageUrl in entry.imageUrls) {
          try {
            await _storage.deleteImage(oldImageUrl);
          } catch (e) {
            print('Error deleting old image: $e');
          }
        }
        
        // Upload new images
        final basePath = 'diary/${entry.userId}/$entryId';
        imageUrls = await _storage.uploadMultipleImages(basePath, newImageFiles);
      }
      
      // Update entry in Firestore
      final entryData = entry.toMap();
      entryData['images'] = imageUrls;
      entryData['updatedAt'] = DateTime.now().toIso8601String();
      
      await _firestore.updateDocument('diary_entries', entryId, entryData);
      
      // Reload entries
      await loadEntries(entry.plantId);
      
      _error = null;
      return true;
    } catch (e) {
      _error = 'Lỗi cập nhật nhật ký: $e';
      print('Error updating diary entry: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete diary entry
  Future<bool> deleteEntry(String entryId, String plantId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final entry = _entries.firstWhere((e) => e.id == entryId);
      
      // Delete images from Storage
      for (String imageUrl in entry.imageUrls) {
        try {
          await _storage.deleteImage(imageUrl);
        } catch (e) {
          print('Error deleting image: $e');
        }
      }
      
      // Delete entry from Firestore
      await _firestore.deleteDocument('diary_entries', entryId);
      
      // Reload entries
      await loadEntries(plantId);
      
      _error = null;
      return true;
    } catch (e) {
      _error = 'Lỗi xóa nhật ký: $e';
      print('Error deleting diary entry: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get entries by activity type
  List<DiaryEntryModel> getEntriesByType(String activityType) {
    return _entries.where((e) => e.activityType == activityType).toList();
  }

  // Get recent entries
  List<DiaryEntryModel> getRecentEntries(int count) {
    return _entries.take(count).toList();
  }

  // Get entry by ID
  DiaryEntryModel? getEntryById(String entryId) {
    try {
      return _entries.firstWhere((e) => e.id == entryId);
    } catch (e) {
      return null;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}








