import 'package:flutter/material.dart';
import 'package:home_attendance_system/UI/JobType_Page.dart';
import 'package:home_attendance_system/UI/StaffAttendance_Page.dart';
import 'package:home_attendance_system/UI/StaffManagement_Page.dart';
import 'package:home_attendance_system/UI/StaffSalary_Page.dart';
import 'package:home_attendance_system/Utils/Constants.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50), // full width
              ),
              onPressed: () {
                // Navigate to Staff Management page
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            StaffManagementPage(userId: currentUser!.id ?? 0)));
              },
              child: const Text('Staff Management'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50), // full width
              ),
              onPressed: () {
                // Navigate to Staff Attendance page
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            StaffAttendancePage(userId: currentUser!.id ?? 0)));
              },
              child: const Text('Staff Attendance'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50), // full width
              ),
              onPressed: () {
                // Navigate to Staff Salary page
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            StaffSalaryPage(userId: currentUser!.id ?? 0)));
              },
              child: const Text('Staff Salary'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50), // full width
              ),
              onPressed: () {
                // Navigate to Job Type Form page
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            JobTypeFormPage(userId: currentUser!.id ?? 0)));
              },
              child: const Text('Job Type Form'),
            ),
          ],
        ),
      ),
    );
  }
}
