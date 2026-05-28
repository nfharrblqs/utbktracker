import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StatistikScreen extends StatelessWidget {
  const StatistikScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F2FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Statistik Peluang Masuk PTN',
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black, blurRadius: 4)],
              ),
              child: const Center(
                child: Text(
                  'Rasionalisasi TO UTBK SNBT',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2B4C7E),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Column(
                children: [
                  Text(
                    "Analisis Peluang Nilai Saat Ini (600)",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Divider(),
                  Text("• Target Nilai Pilihan 1: 650 (Kurang -50 poin lagi)"),
                  Text(
                    "• Peluang Lolos Pilihan 1: Rendah/Cukup (Tingkatkan Sesi TPS!)",
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            _buildPilihanCard('Pilihan Pertama'),
            _buildPilihanCard('Pilihan Kedua'),
            _buildPilihanCard('Pilihan Ketiga'),
          ],
        ),
      ),
    );
  }

  Widget _buildPilihanCard(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [BoxShadow(color: Colors.black, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF2B4C7E),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Perguruan Tinggi Negeri',
            style: TextStyle(fontSize: 12, color: Colors.blueGrey),
          ),
          const SizedBox(height: 5),
          _dropdownPlaceHolder('Pilih PTN'),
          const SizedBox(height: 10),
          const Text(
            'Program Studi',
            style: TextStyle(fontSize: 12, color: Colors.blueGrey),
          ),
          const SizedBox(height: 5),
          _dropdownPlaceHolder('Pilih Prodi'),
        ],
      ),
    );
  }

  Widget _dropdownPlaceHolder(String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF9BC8EB).withOpacity(0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            hint,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const Icon(Icons.keyboard_arrow_down, size: 18),
        ],
      ),
    );
  }

  Widget buildGrafikNilai() {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: true),
          titlesData: const FlTitlesData(show: true),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: [
                const FlSpot(1, 550), //nilai to ke-1
                const FlSpot(2, 580),
                const FlSpot(3, 600),
              ],
              isCurved: true,
              color: Colors.blue,
              barWidth: 4,
            ),
          ],
        ),
      ),
    );
  }
}

