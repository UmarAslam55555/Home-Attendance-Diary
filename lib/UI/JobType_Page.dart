import 'package:flutter/material.dart';
import 'package:home_attendance_system/Utils/JobTypeDbhelper.dart';

class JobTypeFormPage extends StatefulWidget {
  final int userId;

  const JobTypeFormPage({super.key, required this.userId});

  @override
  _JobTypeFormPageState createState() => _JobTypeFormPageState();
}

class _JobTypeFormPageState extends State<JobTypeFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _jobTypeController = TextEditingController();
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _jobTypes = [];
  List<Map<String, dynamic>> _filteredJobTypes = [];
  bool _isEditing = false;
  int? _editingJobId;

  @override
  void initState() {
    super.initState();
    _loadJobTypes();
  }

  Future<void> _loadJobTypes() async {
    final data = await JobTypeDatabaseHelper().getJobTypes(widget.userId);
    setState(() {
      _jobTypes = data;
      _filteredJobTypes = data;
    });
  }

  Future<void> _addOrEditJobType() async {
    if (_formKey.currentState!.validate()) {
      if (_isEditing && _editingJobId != null) {
        await JobTypeDatabaseHelper()
            .updateJobType(_editingJobId!, _jobTypeController.text);
        setState(() {
          _isEditing = false;
          _editingJobId = null;
        });
      } else {
        await JobTypeDatabaseHelper()
            .insertJobType(widget.userId, _jobTypeController.text);
      }
      _jobTypeController.clear();
      _loadJobTypes();
    }
  }

  void _filterJobTypes(String query) {
    setState(() {
      _filteredJobTypes = _jobTypes.where((jobType) {
        return jobType['name'].toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  void _startEditing(int jobId, String jobName) {
    setState(() {
      _isEditing = true;
      _editingJobId = jobId;
      _jobTypeController.text = jobName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Type Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _jobTypeController,
                      decoration: const InputDecoration(labelText: 'Job Type'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a job type';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addOrEditJobType,
                    child: Text(_isEditing ? 'Edit' : 'Submit'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _filteredJobTypes.isEmpty
                  ? const Center(
                      child: Text("No Jobs Created yet"),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 40,
                        ),
                        const Text(
                          "Job Types",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 22),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            labelText: 'Search',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(),
                            ),
                            suffixIcon: const Icon(Icons.search),
                          ),
                          onChanged: _filterJobTypes,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: ListView.builder(
                              itemCount: _filteredJobTypes.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  tileColor: Colors.deepPurple.withOpacity(.4),
                                  title: Text(_filteredJobTypes[index]['name']),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      _startEditing(
                                        _filteredJobTypes[index]['id'],
                                        _filteredJobTypes[index]['name'],
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
