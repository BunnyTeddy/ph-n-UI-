import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

/// IoT Provider for managing real-time sensor data and device controls
/// Uses Firebase Realtime Database for IoT communication
class IotProvider with ChangeNotifier {
  final DatabaseReference _sensorRef = FirebaseDatabase.instance.ref("sensorData");
  final DatabaseReference _controlRef = FirebaseDatabase.instance.ref("controls");
  
  Map<String, dynamic>? _latestSensorData;
  Map<String, dynamic> _controlStates = {
    'fan': false,
    'pump': false,
    'light': false,
    'autoMode': true,
  };
  
  bool _isLoading = false;
  String? _error;
  
  // Getters
  Map<String, dynamic>? get latestSensorData => _latestSensorData;
  Map<String, dynamic> get controlStates => _controlStates;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  bool get fanState => _controlStates['fan'] ?? false;
  bool get pumpState => _controlStates['pump'] ?? false;
  bool get lightState => _controlStates['light'] ?? false;
  bool get autoMode => _controlStates['autoMode'] ?? true;
  
  /// Initialize listeners for real-time data
  void initialize() {
    _listenToSensorData();
    _listenToControls();
  }
  
  /// Listen to sensor data updates
  void _listenToSensorData() {
    _sensorRef.onValue.listen((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        try {
          Map<dynamic, dynamic> allData = event.snapshot.value as Map<dynamic, dynamic>;
          // Get the latest sensor reading
          var lastKey = allData.keys.last;
          _latestSensorData = Map<String, dynamic>.from(allData[lastKey]);
          notifyListeners();
        } catch (e) {
          _error = 'Error parsing sensor data: $e';
          notifyListeners();
        }
      }
    }, onError: (error) {
      _error = 'Error listening to sensor data: $error';
      notifyListeners();
    });
  }
  
  /// Listen to control state updates
  void _listenToControls() {
    _controlRef.onValue.listen((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        try {
          Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
          _controlStates = {
            'fan': data['fan'] ?? false,
            'pump': data['pump'] ?? false,
            'light': data['light'] ?? false,
            'autoMode': data['autoMode'] ?? true,
          };
          notifyListeners();
        } catch (e) {
          _error = 'Error parsing control data: $e';
          notifyListeners();
        }
      }
    }, onError: (error) {
      _error = 'Error listening to controls: $error';
      notifyListeners();
    });
  }
  
  /// Set a control device state
  Future<bool> setControl(String device, bool value) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _controlRef.child(device).set(value);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error setting control: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  /// Update multiple controls at once
  Future<bool> updateControls(Map<String, dynamic> updates) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _controlRef.update(updates);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error updating controls: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  /// Control fan
  Future<bool> controlFan(bool state) async {
    return await setControl('fan', state);
  }
  
  /// Control pump
  Future<bool> controlPump(bool state) async {
    return await setControl('pump', state);
  }
  
  /// Control light
  Future<bool> controlLight(bool state) async {
    return await setControl('light', state);
  }
  
  /// Set auto mode
  Future<bool> setAutoMode(bool state) async {
    return await setControl('autoMode', state);
  }
  
  /// Get sensor value by key
  double? getSensorValue(String key) {
    if (_latestSensorData == null) return null;
    var value = _latestSensorData![key];
    if (value == null) return null;
    return (value is int) ? value.toDouble() : value as double?;
  }
  
  /// Get temperature
  double? get temperature => getSensorValue('temperature');
  
  /// Get humidity
  double? get humidity => getSensorValue('humidity');
  
  /// Get soil moisture
  int? get soilMoisture {
    if (_latestSensorData == null) return null;
    return _latestSensorData!['soilMoisture'] as int?;
  }
  
  /// Get light level
  double? get lightLevel => getSensorValue('lightLevel');
  
  /// Get CO2 level
  int? get co2Level {
    if (_latestSensorData == null) return null;
    return _latestSensorData!['co2Level'] as int?;
  }
  
  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  @override
  void dispose() {
    // Firebase listeners are automatically cleaned up
    super.dispose();
  }
}
