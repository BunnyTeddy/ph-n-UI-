// File: mobile_app/lib/features/statistics/services/statistics_service.dart
// ✅ ĐÃ SỬA: Dùng root collection 'diary_entries' thay vì subcollection

import 'package:cloud_firestore/cloud_firestore.dart';

class StatisticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Lấy ngày bắt đầu dựa trên khoảng thời gian
  DateTime _getStartDate(DateTime now, String period) {
    switch (period) {
      case 'month':
        return DateTime(now.year, now.month - 1, now.day);
      case 'year':
        return DateTime(now.year - 1, now.month, now.day);
      case 'week':
      default:
        return now.subtract(const Duration(days: 7));
    }
  }

  /// Lấy dữ liệu tóm tắt (Đã sửa, yêu cầu plantId)
  /// ✅ FIXED: Dùng 'diary_entries' (root collection)
  Future<Map<String, int>> getSummaryData({
    required String plantId,
    required String period,
  }) async {
    final now = DateTime.now();
    final startDate = _getStartDate(now, period);

    try {
      // ✅ SỬA: Query từ root collection
      final querySnapshot = await _firestore
          .collection('diary_entries')
          .where('plantId', isEqualTo: plantId)
          .where('timestamp',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .get();

      if (querySnapshot.docs.isEmpty) {
        return {'wateringCount': 0, 'diaryCount': 0};
      }

      int wateringCount = 0;
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        if (data.containsKey('activityType') &&
            data['activityType'] == 'watering') {
          wateringCount++;
        }
      }
      return {
        'wateringCount': wateringCount,
        'diaryCount': querySnapshot.docs.length,
      };
    } catch (e) {
      print("Lỗi khi lấy dữ liệu tóm tắt: $e");
      return {'wateringCount': 0, 'diaryCount': 0};
    }
  }

  /// Lấy dữ liệu biểu đồ (Đã sửa, yêu cầu plantId và trả về Map<String, double>)
  /// ✅ FIXED: Dùng 'diary_entries' (root collection)
  Future<Map<String, double>> getCareHistoryChartData({
    required String plantId,
    required String period,
  }) async {
    final now = DateTime.now();
    final startDate = _getStartDate(now, period);

    try {
      // ✅ SỬA: Query từ root collection
      final querySnapshot = await _firestore
          .collection('diary_entries')
          .where('plantId', isEqualTo: plantId)
          .where('timestamp',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .orderBy('timestamp')
          .get();

      final Map<String, double> chartData = {};

      if (period == 'week') {
        // Logic 7 ngày (T2, T3, ...)
        for (var doc in querySnapshot.docs) {
          final timestamp = (doc.data()['timestamp'] as Timestamp).toDate();
          final dayKey =
              (timestamp.weekday - 1).toString(); // "0" (T2) -> "6" (CN)
          chartData[dayKey] = (chartData[dayKey] ?? 0) + 1;
        }
      } else if (period == 'month') {
        // Logic 30 ngày (1, 2, 3...)
        for (var doc in querySnapshot.docs) {
          final timestamp = (doc.data()['timestamp'] as Timestamp).toDate();
          final dayKey = timestamp.day.toString(); // "1" -> "31"
          chartData[dayKey] = (chartData[dayKey] ?? 0) + 1;
        }
      } else {
        // Logic 12 tháng (1, 2, 3...)
        for (var doc in querySnapshot.docs) {
          final timestamp = (doc.data()['timestamp'] as Timestamp).toDate();
          final monthKey = timestamp.month.toString(); // "1" (Tháng 1) -> "12"
          chartData[monthKey] = (chartData[monthKey] ?? 0) + 1;
        }
      }

      return chartData;
    } catch (e) {
      print("Lỗi khi lấy dữ liệu biểu đồ: $e");
      return {};
    }
  }

  /// Lấy dữ liệu phân loại (Đã sửa, yêu cầu plantId)
  /// ✅ FIXED: Dùng 'diary_entries' (root collection)
  Future<Map<String, double>> getActivityBreakdown({
    required String plantId,
    required String period,
  }) async {
    final now = DateTime.now();
    final startDate = _getStartDate(now, period);

    try {
      // ✅ SỬA: Query từ root collection
      final querySnapshot = await _firestore
          .collection('diary_entries')
          .where('plantId', isEqualTo: plantId)
          .where('timestamp',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .get();

      if (querySnapshot.docs.isEmpty) return {};

      final Map<String, int> activityCounts = {};
      int totalActivities = querySnapshot.docs.length;

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final activityType = data['activityType'] as String? ?? 'unknown';
        activityCounts[activityType] = (activityCounts[activityType] ?? 0) + 1;
      }

      final Map<String, double> activityPercentage = {};
      activityCounts.forEach((key, value) {
        activityPercentage[key] = (value / totalActivities) * 100;
      });

      return activityPercentage;
    } catch (e) {
      print("Lỗi khi lấy dữ liệu phân loại: $e");
      return {};
    }
  }
}

