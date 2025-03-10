import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../widgets/custom_date_picker.dart';
import '../widgets/input_field.dart';

class ReportScamScreen extends StatefulWidget {
  const ReportScamScreen({super.key});

  @override
  State<ReportScamScreen> createState() => _ReportScamScreenState();
}

class _ReportScamScreenState extends State<ReportScamScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _contactInfoController = TextEditingController();
  final TextEditingController _scamDateController = TextEditingController();
  String? scamType;
  int? _selectedDay;
  String? _selectedMonth;
  int? _selectedYear;
  List<PlatformFile>? _selectedFiles;

  final List<int> _days = List<int>.generate(31, (i) => i + 1);
  final List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  final List<int> _years = List<int>.generate(15, (i) => 2011 + i);

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4'],
      withData: true,
    );

    if (result != null) {
      setState(() {
        _selectedFiles = result.files
            .where((file) => file.size <= 10 * 1024 * 1024)
            .toList(); // Limit to 10MB
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Report a Scam"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Scam Type
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: "Scam Type"),
                  items: const [
                    DropdownMenuItem(
                        value: "Phishing", child: Text("Phishing")),
                    DropdownMenuItem(
                        value: "Fake UPI", child: Text("Fake UPI")),
                    DropdownMenuItem(
                        value: "Loan Fraud", child: Text("Loan Fraud")),
                    DropdownMenuItem(value: "Other", child: Text("Other")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      scamType = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please select a scam type";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Description
                CustomTextField(
                  hintText: "Description",
                  controller: _descriptionController,
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter a description";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Scam Date
                const Text(
                  "Date of Scam",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                CustomDatePicker(
                  hintText: "Date of Birth (Required)",
                  controller: _scamDateController,
                ),
                const SizedBox(height: 16),

                // Contact Information
                CustomTextField(
                  hintText: "Contact Information",
                  controller: _contactInfoController,
                  keyboardType: TextInputType.phone,
                  isPhone: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your contact information";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // File Upload
                ElevatedButton(
                  onPressed: _pickFiles,
                  child: const Text("Upload Files (Max 10MB each)"),
                ),
                const SizedBox(height: 16),

                // Display selected files
                if (_selectedFiles != null && _selectedFiles!.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _selectedFiles!.map((file) {
                      return Text(file.name);
                    }).toList(),
                  ),
                const SizedBox(height: 16),

                // Submit Button
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Get.snackbar("Success",
                          "Scam reported successfully with date: ${_scamDateController.text}");
                    }
                  },
                  child: const Text("Submit"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
