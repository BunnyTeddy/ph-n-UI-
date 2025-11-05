// File: mobile_app/lib/features/statistics/screens/statistics_screen.dart
// ✅ ĐÃ SỬA: observing → observation

import 'package:flutter/material.dart';
import '../services/statistics_service.dart';
import '../widgets/statistics_card.dart';
import '../widgets/care_history_chart.dart';

class StatisticsScreen extends StatefulWidget {
  // Yêu cầu plantId
  final String plantId;

  const StatisticsScreen({
    super.key,
    required this.plantId,
  });

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final StatisticsService _statisticsService = StatisticsService();
  String _selectedPeriod = 'week';

  late Future<Map<String, int>> _summaryDataFuture;
  late Future<Map<String, double>> _activityBreakdownFuture;

  @override
  void initState() {
    super.initState();
    _fetchStatistics();
  }

  void _fetchStatistics() {
    setState(() {
      _summaryDataFuture = _statisticsService.getSummaryData(
        plantId: widget.plantId,
        period: _selectedPeriod,
      );
      _activityBreakdownFuture = _statisticsService.getActivityBreakdown(
        plantId: widget.plantId,
        period: _selectedPeriod,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê & Báo cáo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPeriodSelector(),
            const SizedBox(height: 24),
            _buildSummarySection(),
            const SizedBox(height: 24),
            const Text(
              'Lịch sử chăm sóc',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            // Truyền plantId thật cho biểu đồ
            CareHistoryChart(
              period: _selectedPeriod,
              plantId: widget.plantId,
            ),
            const SizedBox(height: 24),
            const Text(
              'Phân loại hoạt động',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildActivityBreakdownSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Row(
      children: [
        ChoiceChip(
          label: const Text('Tuần'),
          selected: _selectedPeriod == 'week',
          onSelected: (selected) {
            if (selected) {
              setState(() => _selectedPeriod = 'week');
              _fetchStatistics();
            }
          },
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('Tháng'),
          selected: _selectedPeriod == 'month',
          onSelected: (selected) {
            if (selected) {
              setState(() => _selectedPeriod = 'month');
              _fetchStatistics();
            }
          },
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('Năm'),
          selected: _selectedPeriod == 'year',
          onSelected: (selected) {
            if (selected) {
              setState(() => _selectedPeriod = 'year');
              _fetchStatistics();
            }
          },
        ),
      ],
    );
  }

  Widget _buildSummarySection() {
    return FutureBuilder<Map<String, int>>(
      future: _summaryDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
              height: 140, child: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Lỗi tải dữ liệu: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Không có dữ liệu.'));
        }

        final summaryData = snapshot.data!;
        final wateringCount = summaryData['wateringCount'] ?? 0;
        final diaryCount = summaryData['diaryCount'] ?? 0;

        return Row(
          children: [
            StatisticsCard(
              title: 'Lần tưới nước',
              value: wateringCount.toString(),
              icon: Icons.water_drop_outlined,
              color: Colors.blue,
            ),
            const SizedBox(width: 12),
            StatisticsCard(
              title: 'Nhật ký',
              value: diaryCount.toString(),
              icon: Icons.book_outlined,
              color: Colors.green,
            ),
          ],
        );
      },
    );
  }

  Widget _buildActivityBreakdownSection() {
    // ✅ FIXED: Đổi 'observing' thành 'observation'
    final activityDetails = {
      'watering': {'icon': Icons.water_drop, 'color': Colors.blue},
      'fertilizing': {'icon': Icons.grass, 'color': Colors.green},
      'pruning': {'icon': Icons.content_cut, 'color': Colors.orange},
      'observation': {'icon': Icons.visibility, 'color': Colors.purple}, // ✅ FIXED
      'unknown': {'icon': Icons.help_outline, 'color': Colors.grey},
    };

    // Map Vietnamese names
    final activityNames = {
      'watering': 'Tưới nước',
      'fertilizing': 'Bón phân',
      'pruning': 'Tỉa cành',
      'observation': 'Quan sát',
      'unknown': 'Khác',
    };

    return FutureBuilder<Map<String, double>>(
      future: _activityBreakdownFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
              child:
                  Center(heightFactor: 3, child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return Card(
              child: Center(
                  heightFactor: 3, child: Text('Lỗi: ${snapshot.error}')));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Card(
              child: Center(heightFactor: 3, child: Text('Không có dữ liệu.')));
        }

        final breakdownData = snapshot.data!;

        return Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              children: breakdownData.entries.map((entry) {
                final activityName = entry.key;
                final percentage = entry.value;
                final details = activityDetails[activityName] ??
                    activityDetails['unknown']!;

                return ListTile(
                  leading: Icon(details['icon'] as IconData,
                      color: details['color'] as Color),
                  title: Text(activityNames[activityName] ?? activityName),
                  trailing: Text('${percentage.toStringAsFixed(0)}%',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
