// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:home_attendance_system/UI/JobType_Page.dart';
import 'package:home_attendance_system/Utils/Constants.dart';
import 'package:home_attendance_system/Utils/JobTypeDbhelper.dart';
import 'package:home_attendance_system/Utils/StaffDbhelper.dart';

class StaffManagementPage extends StatefulWidget {
  final int userId;

  const StaffManagementPage({super.key, required this.userId});

  @override
  _StaffManagementPageState createState() => _StaffManagementPageState();
}

class _StaffManagementPageState extends State<StaffManagementPage> {
  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _jobController = TextEditingController();
  final _timingFromController = TextEditingController();
  final _timingToController = TextEditingController();
  final _perHourSalaryController = TextEditingController();
  final _perMonthSalaryController = TextEditingController();

  List<Map<String, dynamic>> _staff = [];
  List<Map<String, dynamic>> _filteredStaff = [];
  List<Map<String, dynamic>> _jobs = [];

  bool _isEditing = false;
  int? _editingStaffId;

  @override
  void initState() {
    super.initState();
    _loadStaff();
    _loadJobs();
  }

  Future<void> _loadStaff() async {
    final data = await StaffDatabaseHelper().getStaff(widget.userId);
    setState(() {
      _staff = data;
      _filteredStaff = data;
    });
  }

  Future<void> _loadJobs() async {
    final data = await JobTypeDatabaseHelper().getJobTypes(widget.userId);
    setState(() {
      _jobs = data;
    });

    // Check if jobs list is empty
    if (_jobs.isEmpty) {
      // Show dialog
      showDialog(
        context: context,
        barrierDismissible:
            false, // Dialog cannot be dismissed by tapping outside
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('No Jobs Created'),
            content: const Text('Please add a job first, then add staff.'),
            actions: <Widget>[
              Container(
                color: Colors.deepPurple,
                child: TextButton(
                  onPressed: () {
                    // Close dialog
                    Navigator.of(context).pop();
                    // Navigate to job type form page
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            JobTypeFormPage(userId: widget.userId),
                      ),
                    );
                  },
                  child: const Text(
                    'Yes',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  String _getJobName(int jobId) {
    final job = _jobs.firstWhere((job) => job['id'] == jobId,
        orElse: () => {'name': 'Unknown'});
    return job != null ? job['name'] : 'Unknown';
  }

  Future<void> _addOrEditStaff() async {
    if (_formKey.currentState!.validate()) {
      TimeOfDay timeFrom =
          parseTimeStringToTimeOfDay(_timingFromController.text);
      TimeOfDay timeto = parseTimeStringToTimeOfDay(_timingToController.text);
      final timingFrom = TimeOfDay.fromDateTime(
          DateTime(2000, 1, 1, timeFrom.hour, timeFrom.minute));
      final timingTo = TimeOfDay.fromDateTime(
          DateTime(2000, 1, 1, timeto.hour, timeto.minute));

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

      final staff = {
        'name': _nameController.text,
        'phone': _phoneController.text,
        'city': _cityController.text,
        'job_id': int.parse(_jobController.text),
        'timing_from': _timingFromController.text,
        'timing_to': _timingToController.text,
        'per_hour_salary': double.parse(_perHourSalaryController.text),
        'per_month_salary': double.parse(_perMonthSalaryController.text),
      };

      if (_isEditing && _editingStaffId != null) {
        await StaffDatabaseHelper().updateStaff(_editingStaffId!, staff);
        setState(() {
          _isEditing = false;
          _editingStaffId = null;
        });
      } else {
        await StaffDatabaseHelper().insertStaff(widget.userId, staff);
      }

      _clearForm();
      _loadStaff();
    }
  }

  void _filterStaff(String query) {
    setState(() {
      _filteredStaff = _staff.where((staff) {
        return staff['name'].toLowerCase().contains(query.toLowerCase()) ||
            staff['phone'].toLowerCase().contains(query.toLowerCase()) ||
            staff['city'].toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  void _startEditing(int staffId, Map<String, dynamic> staff) {
    setState(() {
      _isEditing = true;
      _editingStaffId = staffId;

      _nameController.text = staff['name'];
      _phoneController.text = staff['phone'];
      _cityController.text = staff['city'];
      _jobController.text = staff['job_id'].toString();
      _timingFromController.text = staff['timing_from'];
      _timingToController.text = staff['timing_to'];
      _perHourSalaryController.text = staff['per_hour_salary'].toString();
      _perMonthSalaryController.text = staff['per_month_salary'].toString();
    });
  }

  void _clearForm() {
    _nameController.clear();
    _phoneController.clear();
    _cityController.clear();
    _jobController.clear();
    _timingFromController.clear();
    _timingToController.clear();
    _perHourSalaryController.clear();
    _perMonthSalaryController.clear();
  }

  Future<void> _selectTime(
      TextEditingController controller, bool timefrom) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: timefrom ? 9 : 18, minute: 0),
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Management'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Phone'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a phone number';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(labelText: 'City'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a city';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField(
                    value: _jobController.text.isNotEmpty
                        ? int.parse(_jobController.text)
                        : null,
                    items: _jobs.map((job) {
                      return DropdownMenuItem(
                        value: job['id'],
                        child: Text(job['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _jobController.text = value.toString();
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Job'),
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a job';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _timingFromController,
                    decoration: const InputDecoration(labelText: 'Timing From'),
                    readOnly: true,
                    onTap: () => _selectTime(_timingFromController, true),
                  ),
                  TextFormField(
                    controller: _timingToController,
                    decoration: const InputDecoration(labelText: 'Timing To'),
                    readOnly: true,
                    onTap: () => _selectTime(_timingToController, false),
                  ),
                  TextFormField(
                    controller: _perHourSalaryController,
                    decoration:
                        const InputDecoration(labelText: 'Per Hour Salary'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter per hour salary';
                      }
                      final double? salary = double.tryParse(value);
                      if (salary == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _perMonthSalaryController,
                    decoration:
                        const InputDecoration(labelText: 'Per Month Salary'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter per hour salary';
                      }
                      final double? salary = double.tryParse(value);
                      if (salary == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _addOrEditStaff,
                    child: Text(_isEditing ? 'Edit' : 'Submit'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _filteredStaff.isEmpty
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
                    onChanged: _filterStaff,
                  ),
            const SizedBox(height: 16),
            _filteredStaff.isEmpty
                ? const Center(
                    child: Text("No Staff Created yet"),
                  )
                : Column(
                    children: _filteredStaff.map((staff) {
                      return Card(
                        color: Colors.deepPurple.withOpacity(.5),
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Name: ${staff['name']}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text('Phone: ${staff['phone']}'),
                              const SizedBox(height: 8),
                              Text('City: ${staff['city']}'),
                              const SizedBox(height: 8),
                              Text('Job: ${_getJobName(staff['job_id'])}'),
                              const SizedBox(height: 8),
                              Text('Timing From: ${staff['timing_from']}'),
                              const SizedBox(height: 8),
                              Text('Timing To: ${staff['timing_to']}'),
                              const SizedBox(height: 8),
                              Text(
                                  'Per Hour Salary: ${staff['per_hour_salary']}'),
                              const SizedBox(height: 8),
                              Text(
                                  'Per Month Salary: ${staff['per_month_salary']}'),
                              const SizedBox(height: 16),
                              Align(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    _startEditing(staff['id'], staff);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }
}
