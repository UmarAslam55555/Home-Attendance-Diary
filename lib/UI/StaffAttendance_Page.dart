// ignore_for_file: unnecessary_null_comparison

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:home_attendance_system/UI/StaffManagement_Page.dart';
import 'package:home_attendance_system/Utils/AttendanceDbHelper.dart';
import 'package:home_attendance_system/Utils/Constants.dart';
import 'package:home_attendance_system/Utils/StaffDbhelper.dart';
import 'package:intl/intl.dart';

class StaffAttendancePage extends StatefulWidget {
  final int userId;

  const StaffAttendancePage({super.key, required this.userId});

  @override
  _StaffAttendancePageState createState() => _StaffAttendancePageState();
}

class _StaffAttendancePageState extends State<StaffAttendancePage> {
  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();

  int? _selectedStaffId;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _checkinTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _checkoutTime = const TimeOfDay(hour: 18, minute: 0);
  String _status = 'Present';

  List<Map<String, dynamic>> _staff = [];
  List<Map<String, dynamic>> _attendance = [];
  List<Map<String, dynamic>> _filteredAttendance = [];

  bool _isEditing = false;
  int? _editingAttendanceId;

  @override
  void initState() {
    super.initState();
    _loadStaff();
    _loadAttendance();
  }

  Future<void> _loadStaff() async {
    final data = await StaffDatabaseHelper().getStaff(widget.userId);
    setState(() {
      _staff = data;
    });

    // Check if staff list is empty
    if (_staff.isEmpty) {
      // Show dialog
      showDialog(
        context: context,
        barrierDismissible:
            false, // Dialog cannot be dismissed by tapping outside
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('No Staff Members Found'),
            content:
                const Text('Please add a staff member, then mark attendance'),
            actions: <Widget>[
              Container(
                color: Colors.deepPurple,
                child: TextButton(
                  onPressed: () {
                    // Close dialog
                    Navigator.of(context).pop();
                    // Navigate to staff page
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            StaffManagementPage(userId: widget.userId),
                      ),
                    );
                  },
                  child: const Text(
                    'Ok',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              // TextButton(
              //   onPressed: () {
              //     // Close dialog
              //     Navigator.of(context).pop();
              //   },
              //   child: const Text('No'),
              // ),
            ],
          );
        },
      );
    }
  }

  Future<void> _loadAttendance() async {
    final data = await AttendanceDatabaseHelper().getAttendance(widget.userId);
    setState(() {
      _attendance = data;
      _filteredAttendance = data;
    });
  }

  Future<void> _addOrEditAttendance() async {
    if (_formKey.currentState!.validate()) {
      final timingFrom = TimeOfDay.fromDateTime(
          DateTime(2000, 1, 1, _checkinTime.hour, _checkinTime.minute));
      final timingTo = TimeOfDay.fromDateTime(
          DateTime(2000, 1, 1, _checkoutTime.hour, _checkoutTime.minute));

      if (timingFrom.hour > timingTo.hour ||
          (timingFrom.hour == timingTo.hour &&
              timingFrom.minute >= timingTo.minute)) {
        // Start time is greater than or equal to end time
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Invalid Timing'),
            content: const Text('Start time must be before end time.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return; // Return from the function without further execution
      }

      final attendance = {
        'user_id': widget.userId,
        'staff_id': _selectedStaffId,
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'checkin_time': _checkinTime.format(context),
        'checkout_time': _checkoutTime.format(context),
        'status': _status,
      };

      if (_isEditing && _editingAttendanceId != null) {
        await AttendanceDatabaseHelper()
            .updateAttendance(_editingAttendanceId!, attendance);
        setState(() {
          _isEditing = false;
          _editingAttendanceId = null;
        });
      } else {
        await AttendanceDatabaseHelper().insertAttendance(attendance);
      }

      _clearForm();
      _loadAttendance();
    }
  }

  void _filterAttendance(String query) {
    setState(() {
      _filteredAttendance = _attendance.where((attendance) {
        final staff = _staff.firstWhere(
            (staff) => staff['id'] == attendance['staff_id'],
            orElse: () => {'name': 'Unknown', 'date': '', 'status': ''});
        return (staff['name'].toLowerCase().contains(query.toLowerCase()) ||
            attendance['date'].toLowerCase().contains(query.toLowerCase()) ||
            attendance['status'].toLowerCase().contains(query.toLowerCase()));
      }).toList();
    });
  }

  void _startEditing(int attendanceId, Map<String, dynamic> attendance) {
    log(attendance['checkin_time'].toString());
    setState(() {
      _isEditing = true;
      _editingAttendanceId = attendanceId;

      _selectedStaffId = attendance['staff_id'];
      _selectedDate = DateTime.parse(attendance['date']);
      _checkinTime = parseTimeStringToTimeOfDay(attendance['checkin_time']);
      _checkoutTime = parseTimeStringToTimeOfDay(attendance['checkout_time']);
      _status = attendance['status'];
    });
  }

  void _clearForm() {
    setState(() {
      _selectedStaffId = null;
      _selectedDate = DateTime.now();
      _checkinTime = const TimeOfDay(hour: 9, minute: 0);
      _checkoutTime = const TimeOfDay(hour: 18, minute: 0);
      _status = 'Present';
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isCheckin) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isCheckin ? _checkinTime : _checkoutTime,
    );
    if (picked != null) {
      setState(() {
        if (isCheckin) {
          _checkinTime = picked;
        } else {
          _checkoutTime = picked;
        }
      });
    }
  }

  String _getStaffName(int staffId) {
    final staff = _staff.firstWhere((staff) => staff['id'] == staffId,
        orElse: () => {'name': 'Unknown'});
    //changes
    return staff != null ? staff['name'] : 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Attendance'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField(
                    value: _selectedStaffId,
                    items: _staff.map((staff) {
                      return DropdownMenuItem(
                        value: staff['id'],
                        child: Text(staff['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStaffId = value as int?;
                      });
                    },
                    decoration:
                        const InputDecoration(labelText: 'Select Staff'),
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a staff';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: TextEditingController(
                        text: DateFormat('yyyy-MM-dd').format(_selectedDate)),
                    readOnly: true,
                    decoration:
                        const InputDecoration(labelText: 'Date of Attendance'),
                    onTap: () => _selectDate(context),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: TextEditingController(
                        text: _checkinTime.format(context)),
                    readOnly: true,
                    decoration:
                        const InputDecoration(labelText: 'Check-in Time'),
                    onTap: () => _selectTime(context, true),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: TextEditingController(
                        text: _checkoutTime.format(context)),
                    readOnly: true,
                    decoration:
                        const InputDecoration(labelText: 'Check-out Time'),
                    onTap: () => _selectTime(context, false),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile(
                          title: const Text('Present'),
                          value: 'Present',
                          groupValue: _status,
                          onChanged: (value) {
                            setState(() {
                              _status = value.toString();
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile(
                          title: const Text('Absent'),
                          value: 'Absent',
                          groupValue: _status,
                          onChanged: (value) {
                            setState(() {
                              _status = value.toString();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _addOrEditAttendance,
                    child: Text(_isEditing ? 'Edit' : 'Submit'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _filteredAttendance.isEmpty
                ? const SizedBox()
                : TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: const BorderSide(),
                      ),
                      labelText: 'Search',
                      suffixIcon: const Icon(Icons.search),
                    ),
                    onChanged: _filterAttendance,
                  ),
            const SizedBox(height: 16),
            _filteredAttendance.isEmpty
                ? const Center(
                    child: Text("No Attendance Records yet"),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: _filteredAttendance.map((attendance) {
                        return Card(
                          color: Colors.deepPurple.withOpacity(.5),
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Staff: ${_getStaffName(attendance['staff_id'])}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Text('Date: ${attendance['date']}'),
                                const SizedBox(height: 8),
                                Text(
                                    'Check-in Time: ${attendance['checkin_time']}'),
                                const SizedBox(height: 8),
                                Text(
                                    'Check-out Time: ${attendance['checkout_time']}'),
                                const SizedBox(height: 8),
                                Text('Status: ${attendance['status']}'),
                                const SizedBox(height: 16),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      _startEditing(
                                          attendance['id'], attendance);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
