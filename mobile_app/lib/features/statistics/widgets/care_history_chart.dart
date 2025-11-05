// File: mobile_app/lib/features/statistics/widgets/care_history_chart.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../services/statistics_service.dart';

class CareHistoryChart extends StatefulWidget {
  final String period;
  final String plantId;

  const CareHistoryChart({
    super.key,
    required this.period,
    required this.plantId,
  });

  @override
  State<CareHistoryChart> createState() => _CareHistoryChartState();
}

class _CareHistoryChartState extends State<CareHistoryChart> {
  final StatisticsService _service = StatisticsService();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        child: FutureBuilder<Map<String, double>>(
          future: _service.getCareHistoryChartData(
            plantId: widget.plantId,
            period: widget.period,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()));
            }
            if (snapshot.hasError) {
              return SizedBox(
                  height: 200,
                  child: Center(child: Text('Lỗi: ${snapshot.error}')));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const SizedBox(
                  height: 200, child: Center(child: Text('Không có dữ liệu.')));
            }

            final data = snapshot.data!;
            final maxYValue = data.values.isEmpty
                ? 2
                : data.values.reduce((a, b) => a > b ? a : b);

            return SizedBox(
              height: 200,
              // Dùng SingleChildScrollView để cho phép cuộn ngang khi xem "Tháng"
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  // Tính toán độ rộng linh hoạt
                  width: _calculateChartWidth(widget.period),
                  child: BarChart(
                    BarChartData(
                      maxY: (maxYValue + 2).toDouble(),
                      barGroups: _createBarGroups(data, widget.period),
                      titlesData: _buildTitles(data, widget.period),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (BarChartGroupData group) =>
                              Colors.blueGrey,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '${rod.toY.round()} lần',
                              const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Hàm tính độ rộng (Mới)
  double _calculateChartWidth(String period) {
    switch (period) {
      case 'month':
        return 800; // Cần rộng hơn để chứa 31 ngày
      case 'year':
        return 500; // 12 tháng
      case 'week':
      default:
        return 300; // 7 ngày
    }
  }

  /// Hàm tạo cột (LINH HOẠT)
  List<BarChartGroupData> _createBarGroups(
    Map<String, double> data,
    String period,
  ) {
    if (period == 'week') {
      // Logic 7 ngày
      return List.generate(7, (index) {
        final key = index.toString(); // "0"
        return BarChartGroupData(x: index, barRods: [
          BarChartRodData(
              toY: data[key] ?? 0,
              color: Colors.teal,
              width: 15,
              borderRadius: BorderRadius.circular(4)),
        ]);
      });
    } else if (period == 'month') {
      // Logic 31 ngày
      return List.generate(31, (index) {
        final key = (index + 1).toString(); // "1"
        return BarChartGroupData(x: index, barRods: [
          BarChartRodData(
              toY: data[key] ?? 0,
              color: Colors.teal,
              width: 8,
              borderRadius: BorderRadius.circular(2)),
        ]);
      });
    } else {
      // Logic 12 tháng
      return List.generate(12, (index) {
        final key = (index + 1).toString(); // "1"
        return BarChartGroupData(x: index, barRods: [
          BarChartRodData(
              toY: data[key] ?? 0,
              color: Colors.teal,
              width: 20,
              borderRadius: BorderRadius.circular(4)),
        ]);
      });
    }
  }

  /// Hàm tạo tiêu đề (LINH HOẠT)
  FlTitlesData _buildTitles(Map<String, double> data, String period) {
    return FlTitlesData(
      show: true,
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
          sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                if (value % 2 != 0 || value == 0) return const SizedBox();
                return Text(value.toInt().toString(),
                    style: const TextStyle(color: Colors.grey, fontSize: 12));
              })),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 28,
          getTitlesWidget: (value, meta) {
            const style = TextStyle(
                color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold);
            String text = '';
            int intValue = value.toInt();

            if (period == 'week') {
              switch (intValue) {
                case 0:
                  text = 'T2';
                  break;
                case 1:
                  text = 'T3';
                  break;
                case 2:
                  text = 'T4';
                  break;
                case 3:
                  text = 'T5';
                  break;
                case 4:
                  text = 'T6';
                  break;
                case 5:
                  text = 'T7';
                  break;
                case 6:
                  text = 'CN';
                  break;
              }
            } else if (period == 'month') {
              // Chỉ hiển thị mỗi 5 ngày
              if ((intValue + 1) % 5 == 0) {
                text = (intValue + 1).toString();
              }
            } else {
              // Hiển thị các tháng
              text = 'T${intValue + 1}';
            }
            return SideTitleWidget(
                axisSide: meta.axisSide, child: Text(text, style: style));
          },
        ),
      ),
    );
  }
}

