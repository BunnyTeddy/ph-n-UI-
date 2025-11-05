import 'dart:io';
import 'package:flutter/material.dart';
import '../models/plant_model.dart';
import '../services/firebase/firestore_service.dart';
import '../services/firebase/storage_service.dart';

class PlantProvider with ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  final StorageService _storage = StorageService();
  
  List<PlantModel> _plants = [];
  PlantModel? _selectedPlant;
  bool _isLoading = false;
  String? _error;

  List<PlantModel> get plants => _plants;
  PlantModel? get selectedPlant => _selectedPlant;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 🎨 DEV MODE: Load mock data for testing without Firebase
  void loadMockData() {
    _plants = [
      PlantModel(
        id: 'mock-plant-001',
        userId: 'mock-user',
        name: '🌵 Sen Đá',
        species: 'Succulent',
        description: 'Cây sen đá dễ trồng, chịu hạn tốt',
        plantedDate: DateTime.now().subtract(const Duration(days: 30)),
        imageUrl: 'https://images.unsplash.com/photo-1459156212016-c812468e2115?w=500',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      PlantModel(
        id: 'mock-plant-002',
        userId: 'mock-user',
        name: '🌿 Trầu Bà',
        species: 'Pothos',
        description: 'Cây trầu bà lá xanh mát, dễ chăm sóc',
        plantedDate: DateTime.now().subtract(const Duration(days: 45)),
        imageUrl: 'https://images.unsplash.com/photo-1463320726281-696a485928c7?w=500',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      PlantModel(
        id: 'mock-plant-003',
        userId: 'mock-user',
        name: '🌸 Hoa Hồng',
        species: 'Rose',
        description: 'Hoa hồng đỏ thắm, hương thơm ngát',
        plantedDate: DateTime.now().subtract(const Duration(days: 60)),
        imageUrl: 'https://images.unsplash.com/photo-1518709594023-6eab9bab7b23?w=500',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
    notifyListeners();
  }

  // Load plants from Firestore
  Future<void> loadPlants(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _firestore.queryCollection('plants', 'userId', userId);
      _plants = data.map((plantData) => PlantModel.fromMap(plantData)).toList();
      _plants.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Sort by newest
      _error = null;
    } catch (e) {
      _error = 'Lỗi tải danh sách cây: $e';
      print('Error loading plants: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get single plant by ID
  PlantModel? getPlantById(String plantId) {
    try {
      return _plants.firstWhere((plant) => plant.id == plantId);
    } catch (e) {
      return null;
    }
  }

  // Add plant with image upload
  Future<bool> addPlant(PlantModel plant, {File? imageFile}) async {
    _isLoading = true;
    notifyListeners();

    try {
      String? imageUrl;
      
      // Upload image first if provided
      if (imageFile != null) {
        final path = 'plants/${plant.userId}/${plant.id}/profile.jpg';
        imageUrl = await _storage.uploadImage(path, imageFile);
      }
      
      // Save plant to Firestore
      final plantData = plant.toMap();
      if (imageUrl != null) {
        plantData['imageUrl'] = imageUrl;
      }
      plantData['createdAt'] = DateTime.now().toIso8601String();
      
      await _firestore.addDocument('plants', plantData);
      
      // Reload plants
      await loadPlants(plant.userId);
      
      _error = null;
      return true;
    } catch (e) {
      _error = 'Lỗi thêm cây: $e';
      print('Error adding plant: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update plant
  Future<bool> updatePlant(String plantId, PlantModel plant, {File? newImageFile}) async {
    _isLoading = true;
    notifyListeners();

    try {
      String? imageUrl = plant.imageUrl;
      
      // Upload new image if provided
      if (newImageFile != null) {
        // Delete old image if exists
        if (plant.imageUrl != null && plant.imageUrl!.isNotEmpty) {
          try {
            await _storage.deleteImage(plant.imageUrl!);
          } catch (e) {
            print('Error deleting old image: $e');
          }
        }
        
        // Upload new image
        final path = 'plants/${plant.userId}/$plantId/profile.jpg';
        imageUrl = await _storage.uploadImage(path, newImageFile);
      }
      
      // Update plant in Firestore
      final plantData = plant.toMap();
      plantData['imageUrl'] = imageUrl;
      plantData['updatedAt'] = DateTime.now().toIso8601String();
      
      await _firestore.updateDocument('plants', plantId, plantData);
      
      // Reload plants
      await loadPlants(plant.userId);
      
      _error = null;
      return true;
    } catch (e) {
      _error = 'Lỗi cập nhật cây: $e';
      print('Error updating plant: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete plant
  Future<bool> deletePlant(String plantId, String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final plant = getPlantById(plantId);
      
      // Delete image from Storage
      if (plant?.imageUrl != null && plant!.imageUrl!.isNotEmpty) {
        try {
          await _storage.deleteImage(plant.imageUrl!);
        } catch (e) {
          print('Error deleting plant image: $e');
        }
      }
      
      // Delete plant from Firestore
      await _firestore.deleteDocument('plants', plantId);
      
      // TODO: Also delete related diary entries (cascade delete)
      
      // Reload plants
      await loadPlants(userId);
      
      _error = null;
      return true;
    } catch (e) {
      _error = 'Lỗi xóa cây: $e';
      print('Error deleting plant: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Select a plant
  void selectPlant(PlantModel plant) {
    _selectedPlant = plant;
    notifyListeners();
  }

  // Search plants (local search)
  List<PlantModel> searchPlants(String query) {
    if (query.isEmpty) return _plants;
    
    query = query.toLowerCase();
    return _plants.where((plant) {
      return plant.name.toLowerCase().contains(query) ||
             (plant.species?.toLowerCase().contains(query) ?? false) ||
             (plant.description?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}








