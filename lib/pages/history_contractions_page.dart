import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryContractionsPage extends StatefulWidget {
  const HistoryContractionsPage({Key? key}) : super(key: key);

  @override
  State<HistoryContractionsPage> createState() => _HistoryContractionsPageState();
}

class _HistoryContractionsPageState extends State<HistoryContractionsPage> {
  final dbRef = FirebaseDatabase.instance.ref();
  Map<String, List<String>> groupedLogs = {};
  bool isLoading = true;

  late String uid;

  @override
  void initState() {
    super.initState();

    final args = Get.arguments ?? {};
    uid = args['uid'] ?? FirebaseAuth.instance.currentUser?.uid ?? '';

    if (uid.isNotEmpty) {
      _fetchLogs();
    }
  }

  Future<void> _fetchLogs() async {
    final snapshot = await dbRef.child('patient_data/contractions/$uid').get();

    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final Map<String, List<String>> grouped = {};

      for (final entry in data.entries) {
        final date = entry.key;
        final readings = Map<String, dynamic>.from(entry.value);

        final times = readings.keys.toList()..sort();

        grouped[date] = times;
      }

      final sorted = Map.fromEntries(
        grouped.entries.toList()..sort((a, b) => b.key.compareTo(a.key)),
      );

      setState(() {
        groupedLogs = sorted;
        isLoading = false;
      });
    } else {
      setState(() {
        groupedLogs = {};
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 54),
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
                        "Contraction Logs",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF3E95),
                        ),
                      ),
                      const SizedBox(width: 30),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: groupedLogs.isEmpty
                      ? const Center(child: Text("No contractions recorded yet."))
                      : ListView(
                          children: groupedLogs.entries.map((entry) {
                            final date = entry.key;
                            final logs = entry.value;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 4),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                                        const SizedBox(width: 8),
                                        Text(
                                          date,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFFF3E95)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(thickness: 0.8),
                                  ...logs.asMap().entries.map((log) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 4),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("${log.key + 1}"),
                                          Text(log.value),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  const Divider(thickness: 0.5),
                                ],
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
