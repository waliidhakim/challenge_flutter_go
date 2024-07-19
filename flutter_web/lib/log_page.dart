import 'package:flutter/material.dart';
import 'package:flutter_web/models/log_model.dart';
import 'package:flutter_web/services/logs/logs_service.dart';

class LogPage extends StatefulWidget {
  const LogPage({super.key});

  @override
  _LogPageState createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  final LogService logService = LogService();
  List<Log> logs = [];
  bool isLoading = true;
  String? filterLevel;
  int currentPage = 1;
  int totalPages = 1;

  @override
  void initState() {
    super.initState();
    fetchLogs();
  }

  void fetchLogs() async {
    setState(() {
      isLoading = true;
    });
    try {
      final result =
          await logService.fetchLogs(page: currentPage, logLevel: filterLevel);
      setState(() {
        logs = result['logs'];
        currentPage = result['currentPage'];
        totalPages = result['totalPages'];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  DataRow _buildRow(Log log) {
    Color rowColor = log.logLevel == 'info'
        ? Colors.blue.withOpacity(0.1)
        : Colors.red.withOpacity(0.1);
    return DataRow(
      color: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          return rowColor; // Use the color.
        },
      ),
      cells: [
        DataCell(Text(log.id.toString())),
        DataCell(Text(log.logLevel)),
        DataCell(Text(log.logMessage)),
        DataCell(Text(log.creationDate.toString())),
      ],
    );
  }

  void _previousPage() {
    if (currentPage > 1) {
      setState(() {
        currentPage--;
        fetchLogs();
      });
    }
  }

  void _nextPage() {
    if (currentPage < totalPages) {
      setState(() {
        currentPage++;
        fetchLogs();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Logs Applicatifs',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: true, // Centrer le titre dans la AppBar
        backgroundColor:
            Colors.lightBlue[100], // Couleur uniforme avec les autres pages
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(10),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DropdownButton<String>(
                        value: filterLevel,
                        hint: const Text('Filter by Level'),
                        items:
                            <String>["", 'info', 'error'].map((String? value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value ?? 'All'),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            filterLevel = newValue;
                            currentPage =
                                1; // Reset to first page on filter change
                            fetchLogs();
                          });
                        },
                      ),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: _previousPage,
                            child: const Text('Previous'),
                          ),
                          const SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: _nextPage,
                            child: const Text('Next'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('Log Level')),
                        DataColumn(label: Text('Message')),
                        DataColumn(label: Text('Date')),
                      ],
                      rows: logs.map((log) => _buildRow(log)).toList(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Page $currentPage of $totalPages'),
                ),
              ],
            ),
    );
  }
}
