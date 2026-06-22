import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() =>
      _HistoryScreenState();
}

class _HistoryScreenState
    extends State<HistoryScreen> {

  List<dynamic> attendanceList = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {

    final data =
        await ApiService.getAttendanceHistory();

    setState(() {
      attendanceList = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    if (loading) {
      return const Scaffold(
        body: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Attendance History",
        ),
      ),

      body: ListView.builder(
        itemCount: attendanceList.length,

        itemBuilder: (context, index) {

          final attendance =
              attendanceList[index];

          return Card(
            margin:
                const EdgeInsets.all(8),

            child: ListTile(

              leading: const Icon(
                Icons.calendar_today,
              ),

              title: Text(
                attendance["date"]
                    .toString(),
              ),

              subtitle: Text(
                "In: ${attendance["check_in"]?.toString().split(".")[0] ?? "--"}"
                "\n"
                "Out: ${attendance["check_out"]?.toString().split(".")[0] ?? "--"}",
              ),

              trailing: attendance[
                          "approved"] ==
                      true
                  ? const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    )
                  : const Icon(
                      Icons.pending,
                      color: Colors.orange,
                    ),
            ),
          );
        },
      ),
    );
  }
}