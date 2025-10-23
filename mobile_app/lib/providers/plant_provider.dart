import 'package:flutter/material.dart';
import '../models/plant_model.dart';
import '../services/api/plant_api_service.dart';

class PlantProvider with ChangeNotifier {
  final PlantApiService _plantApiService = PlantApiService();
  
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

  // Load plants for a user
  Future<void> loadPlants(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _plants = await _plantApiService.getPlantsByUserId(userId);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add new plant
  Future<bool> addPlant(PlantModel plant) async {
    try {
      _isLoading = true;
      notifyListeners();

      var plantId = await _plantApiService.addPlant(plant);
      
      if (plantId != null) {
        _plants.add(plant.copyWith(id: plantId));
      }
      
      _isLoading = false;
      notifyListeners();
      
      return plantId != null;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update plant
  Future<bool> updatePlant(String plantId, PlantModel plant) async {
    try {
      _isLoading = true;
      notifyListeners();

      var success = await _plantApiService.updatePlant(plantId, plant);
      
      if (success) {
        var index = _plants.indexWhere((p) => p.id == plantId);
        if (index != -1) {
          _plants[index] = plant;
        }
      }
      
      _isLoading = false;
      notifyListeners();
      
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete plant
  Future<bool> deletePlant(String plantId) async {
    try {
      _isLoading = true;
      notifyListeners();

      var success = await _plantApiService.deletePlant(plantId);
      
      if (success) {
        _plants.removeWhere((p) => p.id == plantId);
      }
      
      _isLoading = false;
      notifyListeners();
      
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Select a plant
  void selectPlant(PlantModel plant) {
    _selectedPlant = plant;
    notifyListeners();
  }

  // Search plants
  Future<List<PlantModel>> searchPlants(String userId, String query) async {
    try {
      return await _plantApiService.searchPlants(userId, query);
    } catch (e) {
      _error = e.toString();
      return [];
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}








