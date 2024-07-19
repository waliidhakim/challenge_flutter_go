import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_web/models/group_chat.dart';
import 'package:flutter_web/services/group_chat/group_chat_service.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  bool isLoading = true;
  Map<String, int> activityCounts = {};

  @override
  void initState() {
    super.initState();
    fetchGroupChats();
  }

  void fetchGroupChats() async {
    setState(() {
      isLoading = true;
    });
    try {
      final groupChats = await GroupChatService.fetchGroupChats();
      setState(() {
        activityCounts = _countActivities(groupChats);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Map<String, int> _countActivities(List<GroupChat> groupChats) {
    final data = <String, int>{};

    // Compter le nombre de GroupChats par activité
    for (var groupChat in groupChats) {
      data[groupChat.activity] = (data[groupChat.activity] ?? 0) + 1;
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    final int totalGroups =
        activityCounts.values.fold(0, (sum, count) => sum + count);

    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Statistiques',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlue[100],
        elevation: 4.0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(10),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const Text(
                    'Nombre de GroupChats par activité',
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(
                      height: 20), // Espace entre le texte et le graphique
                  Container(
                    height: 400, // Définir la hauteur du graphique
                    padding: const EdgeInsets.all(16.0),
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: activityCounts.values.isEmpty
                            ? 0
                            : activityCounts.values
                                    .reduce((a, b) => a > b ? a : b)
                                    .toDouble() +
                                1,
                        barGroups: _buildBarGroups(),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                if (value % 1 == 0) {
                                  return Text(value.toInt().toString());
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                final activities = activityCounts.keys.toList();
                                if (value.toInt() >= activities.length) {
                                  return const SizedBox.shrink();
                                }
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  child: Text(activities[value.toInt()]),
                                );
                              },
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: false,
                            ),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: false,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                      height: 20), // Espace entre le graphique et le texte
                  Text(
                    'Nombre total de GroupChats : $totalGroups',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    final activities = activityCounts.entries.toList();
    return activities.asMap().entries.map((entry) {
      int index = entry.key;
      MapEntry<String, int> data = entry.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data.value.toDouble(),
            //colors: [Colors.lightBlue],
            width: 16,
          ),
        ],
      );
    }).toList();
  }
}
