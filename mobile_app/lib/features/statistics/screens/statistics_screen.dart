import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Statistics Screen - Assigned to: Thái Dương Hoàng
/// Task 4.1: Trang Thống kê & Báo cáo
/// Enhanced by: Hoàng Chí Bằng (Sprint 5 - Mock Data & Charts)
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String _selectedPeriod = 'week';

  // 🎨 Mock data cho biểu đồ
  final List<FlSpot> _careHistoryData = [
    const FlSpot(0, 3),
    const FlSpot(1, 4),
    const FlSpot(2, 2),
    const FlSpot(3, 5),
    const FlSpot(4, 3),
    const FlSpot(5, 4),
    const FlSpot(6, 6),
  ];

  final List<FlSpot> _temperatureData = [
    const FlSpot(0, 25),
    const FlSpot(1, 26),
    const FlSpot(2, 27),
    const FlSpot(3, 28),
    const FlSpot(4, 27),
    const FlSpot(5, 26),
    const FlSpot(6, 25),
  ];

  final List<FlSpot> _humidityData = [
    const FlSpot(0, 60),
    const FlSpot(1, 65),
    const FlSpot(2, 70),
    const FlSpot(3, 68),
    const FlSpot(4, 72),
    const FlSpot(5, 75),
    const FlSpot(6, 70),
  ];

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
            // Period selector
            Row(
              children: [
                ChoiceChip(
                  label: const Text('Tuần'),
                  selected: _selectedPeriod == 'week',
                  onSelected: (selected) {
                    setState(() => _selectedPeriod = 'week');
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Tháng'),
                  selected: _selectedPeriod == 'month',
                  onSelected: (selected) {
                    setState(() => _selectedPeriod = 'month');
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Năm'),
                  selected: _selectedPeriod == 'year',
                  onSelected: (selected) {
                    setState(() => _selectedPeriod = 'year');
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Summary cards
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.blue[100],
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            '15',
                            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                          ),
                          Text('Lần tưới nước'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    color: Colors.green[100],
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            '8',
                            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                          ),
                          Text('Nhật ký'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Care history chart
            const Text(
              'Lịch sử chăm sóc',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Số lần chăm sóc trong tuần',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 1,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Colors.grey.withAlpha(51),
                                strokeWidth: 1,
                              );
                            },
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                interval: 1,
                                getTitlesWidget: (double value, TitleMeta meta) {
                                  const days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
                                  if (value.toInt() >= 0 && value.toInt() < days.length) {
                                    return Text(
                                      days[value.toInt()],
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 2,
                                reservedSize: 30,
                                getTitlesWidget: (double value, TitleMeta meta) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: false,
                          ),
                          minX: 0,
                          maxX: 6,
                          minY: 0,
                          maxY: 8,
                          lineBarsData: [
                            LineChartBarData(
                              spots: _careHistoryData,
                              isCurved: true,
                              color: Colors.green,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 4,
                                    color: Colors.green,
                                    strokeWidth: 2,
                                    strokeColor: Colors.white,
                                  );
                                },
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                color: Colors.green.withAlpha(51),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Sensor data chart
            const Text(
              'Dữ liệu cảm biến',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Nhiệt độ (°C)',
                          style: TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Độ ẩm (%)',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 20,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Colors.grey.withAlpha(51),
                                strokeWidth: 1,
                              );
                            },
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                interval: 1,
                                getTitlesWidget: (double value, TitleMeta meta) {
                                  const days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
                                  if (value.toInt() >= 0 && value.toInt() < days.length) {
                                    return Text(
                                      days[value.toInt()],
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 20,
                                reservedSize: 35,
                                getTitlesWidget: (double value, TitleMeta meta) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: false,
                          ),
                          minX: 0,
                          maxX: 6,
                          minY: 0,
                          maxY: 80,
                          lineBarsData: [
                            // Temperature line
                            LineChartBarData(
                              spots: _temperatureData,
                              isCurved: true,
                              color: Colors.orange,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 4,
                                    color: Colors.orange,
                                    strokeWidth: 2,
                                    strokeColor: Colors.white,
                                  );
                                },
                              ),
                              belowBarData: BarAreaData(
                                show: false,
                              ),
                            ),
                            // Humidity line
                            LineChartBarData(
                              spots: _humidityData,
                              isCurved: true,
                              color: Colors.blue,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 4,
                                    color: Colors.blue,
                                    strokeWidth: 2,
                                    strokeColor: Colors.white,
                                  );
                                },
                              ),
                              belowBarData: BarAreaData(
                                show: false,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSensorInfo(
                          '🌡️',
                          '26.5°C',
                          'Nhiệt độ TB',
                          Colors.orange,
                        ),
                        _buildSensorInfo(
                          '💧',
                          '68%',
                          'Độ ẩm TB',
                          Colors.blue,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Activity breakdown
            const Text(
              'Phân loại hoạt động',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.water_drop, color: Colors.blue),
                      title: const Text('Tưới nước'),
                      trailing: const Text('60%', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    ListTile(
                      leading: const Icon(Icons.grass, color: Colors.green),
                      title: const Text('Bón phân'),
                      trailing: const Text('20%', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    ListTile(
                      leading: const Icon(Icons.content_cut, color: Colors.orange),
                      title: const Text('Tỉa cành'),
                      trailing: const Text('10%', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    ListTile(
                      leading: const Icon(Icons.visibility, color: Colors.purple),
                      title: const Text('Quan sát'),
                      trailing: const Text('10%', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorInfo(String emoji, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}








