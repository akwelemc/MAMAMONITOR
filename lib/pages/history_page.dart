import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  Map<String, List<Map<String, String>>> groupedReadings = {};

  @override
  void initState() {
    super.initState();
    fetchHeartRateHistory();
  }

  Future<void> fetchHeartRateHistory() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final dbRef = FirebaseDatabase.instance.ref().child('patient_data/heart_rate/$uid');
    final snapshot = await dbRef.get();

    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);

      final Map<String, List<Map<String, String>>> grouped = {};

      for (final entry in data.entries) {
        final key = entry.key;
        final bpm = entry.value.toString();

        try {
          final dateTime = DateFormat('yyyy-MM-dd_HH:mm:ss').parse(key);
          final date = DateFormat('yyyy-MM-dd').format(dateTime);
          final time = DateFormat('HH:mm:ss').format(dateTime);

          final record = {'time': time, 'fhr': bpm};

          if (!grouped.containsKey(date)) {
            grouped[date] = [];
          }
          grouped[date]!.add(record);
        } catch (_) {}
      }

      for (var list in grouped.values) {
        list.sort((a, b) => a['time']!.compareTo(b['time']!));
      }

      final sortedGrouped = Map.fromEntries(grouped.entries.toList()
        ..sort((a, b) => b.key.compareTo(a.key)));

      setState(() => groupedReadings = sortedGrouped);
    }
  }

  void _showGraphPopup(BuildContext context, List<Map<String, String>> data, String date) {
    final spots = data.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final fhr = double.tryParse(entry.value['fhr'] ?? '') ?? 0;
      return FlSpot(index, fhr);
    }).toList();

    final maxY = spots.map((e) => e.y).fold<double>(0, max);
    final minY = spots.map((e) => e.y).fold<double>(200, min);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(8),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.95,
            height: 350,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("FHR Graph for $date", style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                Expanded(
                  child: LineChart(
                    LineChartData(
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          axisNameWidget: const Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Text("Time (s)", style: TextStyle(fontSize: 12)),
                          ),
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 50,
                            getTitlesWidget: (value, meta) => Text('${value.toInt()}', style: const TextStyle(fontSize: 10)),
                          ),
                        ),
                        leftTitles: AxisTitles(
                          axisNameWidget: const Text("BPM", style: TextStyle(fontSize: 12)),
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 20,
                            getTitlesWidget: (value, meta) => Text('${value.toInt()}', style: const TextStyle(fontSize: 10)),
                          ),
                        ),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      minY: minY - 5,
                      maxY: maxY + 5,
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: const Color(0xFFFF3E95),
                          barWidth: 2,
                          dotData: FlDotData(show: false),
                        )
                      ],
                      gridData: FlGridData(show: true),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Get.toNamed('/nav_page'),
                  child: const Icon(Icons.menu, size: 30),
                ),
                const Text(
                  'Historical Readings',
                  style: TextStyle(
                    color: Color(0xFFFF3E95),
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: const Icon(Icons.chevron_left, size: 30),
                ),
                const SizedBox(width: 30),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Padding(
            padding: EdgeInsets.only(left: 22),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("See all your historical readings Mama!", style: TextStyle(fontSize: 13)),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: groupedReadings.isEmpty
                ? const Center(child: Text("No readings yet..."))
                : ListView(
                    children: groupedReadings.entries.map((entry) {
                      final date = entry.key;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: ElevatedButton(
                          onPressed: () => _showGraphPopup(context, entry.value, date),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF3E95),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              date,
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
