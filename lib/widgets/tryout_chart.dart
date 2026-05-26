import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TryoutChart extends StatelessWidget {
  final List<Map<String, dynamic>> riwayatTryout;

  const TryoutChart({super.key, required this.riwayatTryout});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> sortedData = List.from(
      riwayatTryout.reversed,
    );

    if (sortedData.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Center(
          child: Text(
            'Belum ada data tryout',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      height: 280,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Grafik Perkembangan Nilai Tryout',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF2B4C7E),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(child: _buildLineChart(sortedData)),
          const SizedBox(height: 8),
          _buildChartInfo(sortedData),
        ],
      ),
    );
  }

  Widget _buildLineChart(List<Map<String, dynamic>> sortedData) {
    List<FlSpot> spots = [];
    for (int i = 0; i < sortedData.length; i++) {
      final score = sortedData[i]['total_score'] as int? ?? 0;
      spots.add(FlSpot(i.toDouble(), score.toDouble()));
    }

    double maxScore = 1000;
    double minScore = 0;
    if (spots.isNotEmpty) {
      maxScore = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
      minScore = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);

      maxScore = (maxScore + 50).clamp(0, 1000);
      minScore = (minScore - 50).clamp(0, 1000);
      if (minScore < 0) minScore = 0;
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 100,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey[300]!, strokeWidth: 1);
          },
          getDrawingVerticalLine: (value) {
            return FlLine(color: Colors.grey[300]!, strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();

                if (index >= 0 && index < sortedData.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(fontSize: 10),
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
              reservedSize: 40,
              interval: 100,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
        minX: 0,
        maxX: (spots.length - 1).toDouble(),
        minY: minScore,
        maxY: maxScore,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: const Color(0xFF2B4C7E),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 6,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: const Color(0xFF2B4C7E),
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF2B4C7E).withOpacity(0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((spot) {
                final int index = spot.x.toInt();
                final double value = spot.y;
                final int tryoutNumber = index + 1;
                return LineTooltipItem(
                  'Tryout ke-$tryoutNumber\n${value.toInt()} poin',
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildChartInfo(List<Map<String, dynamic>> sortedData) {
    if (sortedData.length < 2) {
      return const SizedBox.shrink();
    }

    final firstScore = sortedData.first['total_score'] as int? ?? 0;
    final lastScore = sortedData.last['total_score'] as int? ?? 0;
    final difference = lastScore - firstScore;
    final isImprovement = difference > 0;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isImprovement ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Tryout 1: $firstScore', style: const TextStyle(fontSize: 11)),
          Row(
            children: [
              Icon(
                isImprovement ? Icons.trending_up : Icons.trending_down,
                size: 16,
                color: isImprovement ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 4),
              Text(
                '${difference >= 0 ? '+' : ''}$difference',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isImprovement ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          Text(
            'Tryout ${sortedData.length}: $lastScore',
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }
}
