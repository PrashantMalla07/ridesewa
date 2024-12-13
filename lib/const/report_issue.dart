import 'package:flutter/material.dart';

class ReportIssuePage extends StatefulWidget {
  const ReportIssuePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ReportIssuePageState createState() => _ReportIssuePageState();
}

class _ReportIssuePageState extends State<ReportIssuePage> {
  final _formKey = GlobalKey<FormState>();
  String _issueCategory = 'App Bug';
  // ignore: unused_field
  String _issueDescription = '';
  // ignore: unused_field
  String _additionalDetails = '';

  // Function to handle form submission
  void _submitIssue() {
    if (_formKey.currentState?.validate() ?? false) {
      // Logic for submitting the issue (e.g., sending it to a backend or email)
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Issue reported successfully!')));
      
      // Clear the form after submission
      _formKey.currentState?.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report an Issue'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              // Issue Category Dropdown
              DropdownButtonFormField<String>(
                value: _issueCategory,
                onChanged: (value) {
                  setState(() {
                    _issueCategory = value ?? 'App Bug';
                  });
                },
                items: <String>['App Bug', 'Payment Issue', 'Account Issue', 'Other']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Issue Category',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              
              // Issue Description Text Field
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Describe the Issue',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please describe the issue';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _issueDescription = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Additional Details Text Field
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Additional Details (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onChanged: (value) {
                  setState(() {
                    _additionalDetails = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Submit Button
              ElevatedButton(
                onPressed: _submitIssue,
                child: const Text('Submit Issue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
