import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:http/http.dart' as http; // Added missing import
import 'package:path_provider/path_provider.dart'; // Added missing import
import 'dart:io';
import 'models.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  List<MedicalReport> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    if (user != null) {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(user!.uid)
          .collection('medicalReports')
          .orderBy('uploadDate', descending: true)
          .get();

      List<MedicalReport> reports = snapshot.docs.map((doc) {
        return MedicalReport.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();

      setState(() {
        _reports = reports;
        _isLoading = false;
      });
    }
  }

  Future<void> _uploadReport() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png', 'doc', 'docx'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      String fileName = result.files.single.name;

      // Show dialog to enter report name and type
      String? reportName = await _showReportNameDialog(fileName);
      if (reportName == null) return;

      setState(() {
        _isLoading = true;
      });

      try {
        // Upload to Firebase Storage
        String filePath = 'users/${user!.uid}/reports/${DateTime.now().millisecondsSinceEpoch}_$fileName';
        TaskSnapshot snapshot = await _storage.ref(filePath).putFile(file);
        String downloadUrl = await snapshot.ref.getDownloadURL();

        // Save to Firestore
        String reportId = DateTime.now().millisecondsSinceEpoch.toString();
        MedicalReport report = MedicalReport(
          id: reportId,
          name: reportName,
          fileUrl: downloadUrl,
          uploadDate: DateTime.now(),
          type: fileName.split('.').last,
        );

        await _firestore
            .collection('users')
            .doc(user!.uid)
            .collection('medicalReports')
            .doc(reportId)
            .set(report.toMap());

        _loadReports();
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        // Fixed: Check if context is still mounted before using it
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to upload report: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<String?> _showReportNameDialog(String defaultName) async {
    TextEditingController controller = TextEditingController(text: defaultName);

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Report Name',
                hintText: 'Enter a name for this report',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteReport(String id, String fileUrl) async {
    try {
      // Delete from Firestore
      await _firestore
          .collection('users')
          .doc(user!.uid)
          .collection('medicalReports')
          .doc(id)
          .delete();

      // Delete from Firebase Storage
      await _storage.refFromURL(fileUrl).delete();

      _loadReports();
    } catch (e) {
      // Fixed: Check if context is still mounted before using it
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openFile(String fileUrl, String fileName) async {
    try {
      // Download the file
      String? localPath = await _downloadFile(fileUrl, fileName);
      if (localPath != null) {
        // Open the file
        await OpenFile.open(localPath);
      }
    } catch (e) {
      // Fixed: Check if context is still mounted before using it
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String?> _downloadFile(String fileUrl, String fileName) async {
    try {
      final http.Response response = await http.get(Uri.parse(fileUrl));
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String localPath = '${appDocDir.path}/$fileName';
      final File file = File(localPath);
      await file.writeAsBytes(response.bodyBytes);
      return localPath;
    } catch (e) {
      // Fixed: Replaced print with debugPrint for production code
      debugPrint('Error downloading file: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MediaCare+ Reports'), // Fixed typo: MediCare+ → MediaCare+
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: _uploadReport,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reports.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No medical reports',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tap the upload button to add a report',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _reports.length,
        itemBuilder: (context, index) {
          final report = _reports[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            child: ListTile(
              leading: _getFileIcon(report.type),
              title: Text(report.name),
              subtitle: Text(
                'Uploaded on ${report.uploadDate.day}/${report.uploadDate.month}/${report.uploadDate.year}',
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'open') {
                    await _openFile(report.fileUrl, '${report.name}.${report.type}');
                  } else if (value == 'delete') {
                    _deleteReport(report.id, report.fileUrl);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'open',
                    child: Row(
                      children: [
                        Icon(Icons.open_in_new),
                        SizedBox(width: 8),
                        Text('Open'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Icon _getFileIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return const Icon(Icons.picture_as_pdf, color: Colors.red);
      case 'jpg':
      case 'png':
      case 'jpeg':
        return const Icon(Icons.image, color: Colors.blue);
      case 'doc':
      case 'docx':
        return const Icon(Icons.description, color: Colors.blue);
      default:
        return const Icon(Icons.insert_drive_file, color: Colors.grey);
    }
  }
}