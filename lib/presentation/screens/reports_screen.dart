import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:scamurai/data/services/appwrite_report_service.dart';
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
  PlatformFile? _selectedFile;
  bool _isLoading = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  String _formatDate(String date) {
    final DateTime parsedDate = DateTime.parse(date);
    return "${parsedDate.day.toString().padLeft(2, '0')}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.year}";
  }

  Future<void> _submitReport() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final formattedDate = _formatDate(_scamDateController.text);
      final reportService = AppwriteReportService();

      await reportService.saveReports(
        userId: "user-id", // Replace with actual user ID
        scamType: scamType!,
        description: _descriptionController.text,
        contact: _contactInfoController.text,
        scamDate: formattedDate,
        file: _selectedFile,
      );

      setState(() {
        _isLoading = false;
        _descriptionController.clear();
        _contactInfoController.clear();
        _scamDateController.clear();
        scamType = null;
        _selectedFile = null;
      });

      Get.snackbar(
          "Success", "Scam reported successfully with date: $formattedDate");
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
                  hintText: "Date of Scam (Required)",
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
                  onPressed: _pickFile,
                  child: const Text("Upload File (Max 10MB)"),
                ),
                const SizedBox(height: 16),

                // Display selected file
                if (_selectedFile != null) Text(_selectedFile!.name),
                const SizedBox(height: 16),

                // Submit Button
                _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.blueAccent),
                      ))
                    : ElevatedButton(
                        onPressed: _submitReport,
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
