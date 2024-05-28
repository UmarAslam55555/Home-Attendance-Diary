import 'package:flutter/material.dart';
import 'package:home_attendance_system/Utils/AttendanceDbHelper.dart';
import 'package:home_attendance_system/Utils/Constants.dart';
import 'package:home_attendance_system/Utils/StaffDbhelper.dart';

class StaffSalaryPage extends StatefulWidget {
  final int userId;

  const StaffSalaryPage({super.key, required this.userId});

  @override
  _StaffSalaryPageState createState() => _StaffSalaryPageState();
}

class _StaffSalaryPageState extends State<StaffSalaryPage> {
  List<Map<String, dynamic>> _staff = [];
  List<Map<String, dynamic>> _attendance = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final staffData = await StaffDatabaseHelper().getStaff(widget.userId);
    final attendanceData =
        await AttendanceDatabaseHelper().getAttendance(widget.userId);
    setState(() {
      _staff = staffData;
      _attendance = attendanceData;
    });
  }

  double _calculateSalary(int staffId, int month, int year) {
    // Get the attendance records for the specified staff member, month, and year
    List<Map<String, dynamic>> staffAttendance =
        _attendance.where((attendance) {
      DateTime date = DateTime.parse(attendance['date']);
      return attendance['staff_id'] == staffId &&
          date.month == month &&
          date.year == year &&
          attendance['status'] == 'Present';
    }).toList();

    // Calculate total working hours for the month
    double totalWorkingHours = 0;
    for (var attendance in staffAttendance) {
      TimeOfDay checkIN =
          parseTimeStringToTimeOfDay(attendance['checkin_time']);
      TimeOfDay checkOut =
          parseTimeStringToTimeOfDay(attendance['checkout_time']);
      DateTime checkInTime = DateTime(2000, 1, 1, checkIN.hour, checkIN.minute);
      DateTime checkOutTime =
          DateTime(2000, 1, 1, checkOut.hour, checkOut.minute);
      totalWorkingHours +=
          checkOutTime.difference(checkInTime).inHours.toDouble();
    }

    // Assuming an hourly rate of $10
    double hourlyRate = 10.0;
    // Calculate total salary for the month
    double totalSalary = totalWorkingHours * hourlyRate;

    return totalSalary;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Salary'),
      ),
      body: ListView.builder(
        itemCount: _staff.length,
        itemBuilder: (context, index) {
          final staffName = _staff[index]['name'];
          List<int> yearsWorked = [];
          // Determine all the years in which the staff member worked
          for (var attendance in _attendance) {
            DateTime date = DateTime.parse(attendance['date']);
            if (attendance['staff_id'] == _staff[index]['id'] &&
                attendance['status'] == 'Present' &&
                !yearsWorked.contains(date.year)) {
              yearsWorked.add(date.year);
            }
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Staff: $staffName',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                      fontSize: 24),
                ),
              ),
              for (var year in yearsWorked)
                Builder(builder: (context) {
                  int noOfRows = 0;
                  List months = [];
                  for (int i = 1; i <= 12; i++) {
                    final salary =
                        _calculateSalary(_staff[index]['id'], i, year);
                    if (salary > 0) {
                      noOfRows++;
                      months.add(i);
                    }
                  }
                  return DataTable(
                    columns: const [
                      DataColumn(
                          label: Text(
                        'Month',
                        style: TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold),
                      )),
                      DataColumn(
                          label: Text(
                        'Year',
                        style: TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold),
                      )),
                      DataColumn(
                          label: Text(
                        'Total Salary',
                        style: TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold),
                      )),
                    ],
                    rows: List<DataRow>.generate(noOfRows, (i) {
                      final month = months[i];
                      final salary =
                          _calculateSalary(_staff[index]['id'], month, year);
                      if (salary > 0) {
                        return DataRow(
                          cells: [
                            DataCell(Text(month.toString())),
                            DataCell(Text(year.toString())),
                            DataCell(Text(salary.toStringAsFixed(2))),
                          ],
                        );
                      } else {
                        return const DataRow(
                          cells: [
                            DataCell(Text('')),
                            DataCell(Text('')),
                            DataCell(Text('')),
                          ],
                        );
                      }
                    }),
                  );
                }),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}
