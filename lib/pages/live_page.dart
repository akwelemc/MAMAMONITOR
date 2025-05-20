import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';

class LivePage extends StatefulWidget {
  const LivePage({Key? key}) : super(key: key);

  @override
  _LivePageState createState() => _LivePageState();
}

class _LivePageState extends State<LivePage> with SingleTickerProviderStateMixin {
  final GlobalKey _chartKey = GlobalKey();
  int? _currentHeartRate;
  String? _reactionMessage;
  Timer? _reactionTimer;
  DateTime? _outOfRangeStartTime;
  bool _isAlerting = false;
  String _userName = '';

  final List<String> positiveMessages = [
    "Baby’s doing great ❤️",
    "All smooth in there 🍼",
    "Everything looks normal ☺️",
    "Keep relaxing, Mama 🧘🏾‍♀️",
    "Perfect heart rate! 💖",
  ];

  final List<String> alertMessages = [
    "Unusual heart rate detected ⚠️",
    "Please alert your doctor 🧰",
    "Something’s off — stay calm 🪢",
  ];

  late DatabaseReference _heartRateRef;
  late AnimationController _heartbeatController;
  List<FlSpot> _heartRateSpots = [];
  int _tick = 0;
  StreamSubscription<DatabaseEvent>? _heartRateSubscription;

  @override
  void initState() {
    super.initState();
    _heartbeatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      lowerBound: 1.0,
      upperBound: 1.2,
    );

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _heartRateRef = FirebaseDatabase.instance.ref().child('patient_data/heart_rate/$uid');
      FirebaseDatabase.instance.ref().child('users/$uid/name').get().then((snapshot) {
        if (snapshot.exists) {
          setState(() => _userName = snapshot.value.toString());
        }
      });

      _heartRateSubscription = _heartRateRef.onValue.listen((event) {
        if (FirebaseAuth.instance.currentUser == null) return;

        final data = event.snapshot.value as Map?;
        if (data != null && data.isNotEmpty) {
          final Map<String, dynamic> bpmMap = Map<String, dynamic>.from(data);
          final sortedKeys = bpmMap.keys.toList()..sort();
          final latestKey = sortedKeys.last;
          final latestValue = bpmMap[latestKey];

          if (latestValue is int) {
            setState(() {
              _currentHeartRate = latestValue;
              _heartRateSpots.add(FlSpot(_tick.toDouble(), latestValue.toDouble()));
              _tick++;
            });

            _heartbeatController.forward().then((_) => _heartbeatController.reverse());
            _handleReaction(latestValue);
          }
        }
      });
    }
  }

  void _handleReaction(int bpm) {
    final now = DateTime.now();
    if (bpm >= 110 && bpm <= 160) {
      _outOfRangeStartTime = null;
      _isAlerting = false;
      _showReaction((positiveMessages..shuffle()).first);
    } else {
      if (_outOfRangeStartTime == null) {
        _outOfRangeStartTime = now;
      } else if (!_isAlerting && now.difference(_outOfRangeStartTime!).inSeconds >= 15) {
        _showReaction((alertMessages..shuffle()).first);
        _isAlerting = true;
      }
    }
  }

  void _showReaction(String message) {
    setState(() => _reactionMessage = message);
    _reactionTimer?.cancel();
    _reactionTimer = Timer(const Duration(milliseconds: 2500), () => setState(() => _reactionMessage = null));
  }

  Future<void> _exportChartToPDF() async {
    try {
      RenderRepaintBoundary boundary = _chartKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image chartImage = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await chartImage.toByteData(format: ui.ImageByteFormat.png);
      Uint8List chartBytes = byteData!.buffer.asUint8List();

      final pdf = pw.Document();
      final image = pw.MemoryImage(chartBytes);

      pdf.addPage(
        pw.Page(
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text('MamaMonitor: Enhancing Prenatal Care', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(0xFFFF3E95))),
              pw.SizedBox(height: 8),
              pw.Text('Patient: $_userName', style: pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 24),
              pw.Image(image, width: 500, fit: pw.BoxFit.contain),
            ],
          ),
        ),
      );

      await Printing.layoutPdf(onLayout: (format) => pdf.save());
    } catch (e) {
      print("Export error: $e");
    }
  }

  @override
  void dispose() {
    _reactionTimer?.cancel();
    _heartbeatController.dispose();
    _heartRateSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: GestureDetector(
                onTap: () => Get.toNamed('/nav_page'),
                child: const Icon(Icons.menu, size: 30),
              ),
            ),
            const SizedBox(height: 22),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 22),
              child: Text("Live Fetal Heart Rate...", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFFF3E95))),
            ),
            const SizedBox(height: 12),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _heartbeatController,
                    builder: (context, child) => Transform.scale(
                      scale: _heartbeatController.value,
                      child: Image.asset('assets/images/heart5.png', height: 140),
                    ),
                  ),
                  Text(
                    _currentHeartRate != null ? '$_currentHeartRate bpm' : '...bpm',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ],
              ),
            ),
            if (_reactionMessage != null)
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.pink.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(_reactionMessage!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              child: ElevatedButton(
                onPressed: _exportChartToPDF,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF3E95),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("Export Chart to PDF", style: TextStyle(color: Colors.white)),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Center(
                child: Text("Live Fetal Heart Rate", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            Expanded(
              child: RepaintBoundary(
                key: _chartKey,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: _heartRateSpots.isNotEmpty ? (_heartRateSpots.last.x + 2).ceilToDouble() : 50,
                      minY: 80,
                      maxY: _heartRateSpots.isNotEmpty
                          ? ((_heartRateSpots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 5) / 5).ceil() * 5
                          : 200,
                      titlesData: FlTitlesData(
                        show: true,
                        leftTitles: AxisTitles(
                          axisNameWidget: const Text('BPM', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          sideTitles: SideTitles(showTitles: true, interval: 20, reservedSize: 36, getTitlesWidget: (value, meta) => Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(value.toInt().toString(), style: const TextStyle(fontSize: 11)),
                          )),
                        ),
                        bottomTitles: AxisTitles(
                          axisNameWidget: const Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: Text('Time (s)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                          sideTitles: SideTitles(showTitles: true, interval: 10, reservedSize: 30, getTitlesWidget: (value, meta) => Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(value.toInt().toString(), style: const TextStyle(fontSize: 11)),
                          )),
                        ),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(show: true),
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _heartRateSpots,
                          isCurved: true,
                          color: const Color(0xFFFF3E95),
                          barWidth: 2,
                          dotData: FlDotData(show: false),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem('assets/images/live_icon.png', 'Live Data', '/live'),
            _buildNavItem('assets/images/history.png', 'History', '/history'),
            _buildNavItem('assets/images/bang.png', 'Contractions', '/contractions'),
            _buildNavItem('assets/images/logout_icon.png', 'Logout', '/login'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(String assetPath, String label, String route) {
    return GestureDetector(
      onTap: () => Get.toNamed(route),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(assetPath, height: 30),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
