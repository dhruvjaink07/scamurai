import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../widgets/input_field.dart';
import '../widgets/custom_date_picker.dart';

class ReportScamScreen extends StatefulWidget {
  const ReportScamScreen({super.key});

  @override
  State<ReportScamScreen> createState() => _ReportScamScreenState();
}

class _ReportScamScreenState extends State<ReportScamScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _contactInfoController = TextEditingController();
  String? _scamType;
  DateTime? _selectedScamDate;
  List<PlatformFile>? _selectedFiles;

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

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedScamDate = date;
    });
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
                // Scam Type Dropdown
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
                      _scamType = value;
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

                // Description Input
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

                // Scam Date Picker (Using Updated CustomDatePicker)
                CustomDatePicker(
                  hintText: "Date of Scam (YYYY-MM-DD)",
                  onDateSelected: _onDateSelected,
                ),
                const SizedBox(height: 16),

                // Contact Information Input
                CustomTextField(
                  hintText: "Contact Information",
                  controller: _contactInfoController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your contact information";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // File Upload Button
                ElevatedButton(
                  onPressed: _pickFiles,
                  child: const Text("Upload Files (Max 10MB each)"),
                ),
                const SizedBox(height: 16),

                // Display Selected Files
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
                      if (_selectedScamDate == null) {
                        Get.snackbar("Error", "Please select the scam date.");
                        return;
                      }
                      // Process the form data
                      Get.snackbar("Success", "Scam reported successfully!");
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
