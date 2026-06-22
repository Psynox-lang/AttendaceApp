import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'manager_screen.dart';
import 'history_screen.dart';

class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key});

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  Map<String, dynamic>? attendanceData;
  bool loading = true;
  Timer? timer;
  Duration workedDuration=Duration.zero;


  @override
  void initState() {
    super.initState();
    loadAttendance();
  }


  Future<void> loadAttendance() async {

  final data = await ApiService.getStatus();

  setState(() {
    attendanceData = data;
    loading = false;
  });

  if (data?["checked_in"] == true) {

    final checkInString = data?["check_in"];

    if (checkInString != null) {

      final now = DateTime.now();

      final parts = checkInString.split(":");

      final checkIn = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2].split(".")[0]),
      );

      if (data?["check_out"] != null) {

        final checkOutString = data?["check_out"];

        final outParts = checkOutString.split(":");

        final checkOut = DateTime(
          now.year,
          now.month,
          now.day,
          int.parse(outParts[0]),
          int.parse(outParts[1]),
          int.parse(outParts[2].split(".")[0]),
        );

        setState(() {
          workedDuration =
              checkOut.difference(checkIn);
        });

        stopTimer();

      } else {

        setState(() {
          workedDuration =
              now.difference(checkIn);
        });

        startTimer();
      }
    }

  } else {

    setState(() {
      workedDuration = Duration.zero;
    });

    stopTimer();
  }
}
  Future<void> downloadExcel() async {

  final url = Uri.parse(
    "http://192.168.0.85:8000/download-excel",
  );

  await launchUrl(url);
}

  
  void startTimer() {

  timer?.cancel();

  timer = Timer.periodic(
    const Duration(seconds: 1),
    (_) {

      if (attendanceData == null) return;

      final checkInString =
          attendanceData!["check_in"];

      if (checkInString == null) return;

      final now = DateTime.now();

      final parts = checkInString.split(":");

      final checkIn = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2].split(".")[0]),
      );

      setState(() {
        workedDuration =
            now.difference(checkIn);
      });
    },
  );
}
  
  

  void stopTimer() {
  timer?.cancel();
}
  String formatDuration(
    Duration duration) {

    String twoDigits(int n) =>
      n.toString().padLeft(2, '0');

      return
      "${twoDigits(duration.inHours)}:"
      "${twoDigits(duration.inMinutes.remainder(60))}:"
      "${twoDigits(duration.inSeconds.remainder(60))}";
    }

  @override
  Widget build(BuildContext context) {
    
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    final bool checkedIn = attendanceData?["checked_in"] == true;

    final bool checkedOut =attendanceData?["check_out"] != null;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

    appBar: AppBar(
  title: const Text("Attendance"),
  centerTitle: true,

  actions: [

    IconButton(
      icon: const Icon(
        Icons.download,
      ),
      onPressed: downloadExcel,
    ),

    IconButton(
      icon: const Icon(
        Icons.admin_panel_settings,
      ),
      onPressed: () {

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const ManagerScreen(),
          ),
        );
      },
    ),
    IconButton(
  icon: const Icon(
    Icons.history,
  ),

  onPressed: () {

    Navigator.push(
      context,

      MaterialPageRoute(
        builder: (_) =>
            const HistoryScreen(),
      ),
    );
  },
),

  ],
),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [

            const SizedBox(height: 20),

            Card(
              elevation: 4,

              child: Padding(
                padding: const EdgeInsets.all(24),

                child: Column(
                  children: [

                    const Text(
                      "Today's Attendance",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 25),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Check In",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                        attendanceData?["check_in"]
                        ?.toString()
                        .split(".")[0] ??
                        "--",
                      ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Check Out",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          attendanceData?["check_out"]
                          ?.toString().split(".")[0] ??
                          "--",
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Status",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          attendanceData?["checked_in"] ==
                                  true
                              ? "Present"
                              : "Not Checked In",
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    Text(
                      formatDuration(workedDuration),
                      style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      "Working Time",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),
            if (!checkedIn)

            ElevatedButton(
              onPressed: () async {

              await ApiService.checkIn();

              await loadAttendance();

              if (!mounted) return;

              ScaffoldMessenger.of(context)
              .showSnackBar(
              const SnackBar(
              content: Text(
              "Checked In Successfully",
            ),
          ),
        );
      },

    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(
        vertical: 16,
      ),
    ),

    child: const Text(
      "CHECK IN",
    ),
  ),

  if (checkedIn && !checkedOut)

  ElevatedButton(
    onPressed: () async {

      await ApiService.checkOut();

      await loadAttendance();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Checked Out Successfully",
          ),
        ),
      );
    },

    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(
        vertical: 16,
      ),
    ),

    child: const Text(
      "CHECK OUT",
    ),
  ),

if (checkedOut)

  const Column(
    children: [

      SizedBox(height: 10),

      Icon(
        Icons.check_circle,
        color: Colors.green,
        size: 50,
      ),

      SizedBox(height: 10),

      Text(
        "Attendance Completed",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  ),
  const SizedBox(height: 12),
if (checkedIn)
ElevatedButton(
  onPressed: () async {

    await ApiService.deleteToday();

    await loadAttendance();

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          "Attendance Deleted",
        ),
      ),
    );
  },

  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.red,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(
      vertical: 16,
    ),
  ),

  child: const Text(
    "DELETE RECORD",
  ),
),
          ],
        ),
      ),
    );
  }
  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

}