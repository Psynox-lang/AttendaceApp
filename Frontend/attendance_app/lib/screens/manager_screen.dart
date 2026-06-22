import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ManagerScreen extends StatefulWidget {
  const ManagerScreen({super.key});

  @override
  State<ManagerScreen> createState() =>
      _ManagerScreenState();
}

class _ManagerScreenState
    extends State<ManagerScreen> {

  Map<String, dynamic>? attendanceData;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadAttendance();
  }

  Future<void> loadAttendance() async {

    final data =
        await ApiService.getStatus();

    setState(() {
      attendanceData = data;
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
          "Manager Dashboard",
        ),
      ),

      body: Padding(
        padding:
            const EdgeInsets.all(16),

        child: Card(
          child: Padding(
            padding:
                const EdgeInsets.all(20),

            child: Column(
              mainAxisSize:
                  MainAxisSize.min,

              children: [

                const Text(
                  "Today's Attendance",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                    height: 20),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,
                  children: [

                    const Text(
                        "Check In"),

                    Text(
                      attendanceData?[
                                  "check_in"]
                              ?.toString()
                              .split(".")[0] ??
                          "--",
                    ),
                  ],
                ),

                const SizedBox(
                    height: 10),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,
                  children: [

                    const Text(
                        "Check Out"),

                    Text(
                      attendanceData?[
                                  "check_out"]
                              ?.toString()
                              .split(".")[0] ??
                          "--",
                    ),
                  ],
                ),

                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [

                  const Text("Approved"),

                Text(
                  attendanceData?["approved"] == true
                  ? "Yes"
                  : "No",
                ),
              ],
            ),

                const SizedBox(
                    height: 20),

                if (attendanceData?["approved"] != true)

  ElevatedButton(
    onPressed: () async {

      await ApiService
          .approveAttendance();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Attendance Approved",
          ),
        ),
      );

      await loadAttendance();
    },

    child: const Text(
      "APPROVE",
    ),
  )

else

  const Row(
    mainAxisAlignment:
        MainAxisAlignment.center,
    children: [

      Icon(
        Icons.check_circle,
        color: Colors.green,
      ),

      SizedBox(width: 10),

      Text(
        "Attendance Approved",
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}