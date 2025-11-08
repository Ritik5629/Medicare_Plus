import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';
import 'models.dart';

class HealthSuggestionsScreen extends StatefulWidget {
  const HealthSuggestionsScreen({Key? key}) : super(key: key);

  @override
  _HealthSuggestionsScreenState createState() => _HealthSuggestionsScreenState();
}

class _HealthSuggestionsScreenState extends State<HealthSuggestionsScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  UserProfile? _userProfile;
  List<MedicalReport> _reports = [];
  List<String> _suggestions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (user != null) {
      // Load user profile
      UserProfile? profile = await AuthService().getUserProfile(user!.uid);

      // Load medical reports
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('medicalReports')
          .get();

      List<MedicalReport> reports = snapshot.docs.map((doc) {
        return MedicalReport.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();

      // Generate suggestions
      List<String> suggestions = _generateSuggestions(profile, reports);

      setState(() {
        _userProfile = profile;
        _reports = reports;
        _suggestions = suggestions;
        _isLoading = false;
      });
    }
  }

  List<String> _generateSuggestions(UserProfile? profile, List<MedicalReport> reports) {
    List<String> suggestions = [];

    // Basic health suggestions
    suggestions.add('Drink at least 8 glasses of water daily');
    suggestions.add('Get 7-8 hours of sleep every night');
    suggestions.add('Exercise for at least 30 minutes daily');
    suggestions.add('Eat a balanced diet rich in fruits and vegetables');

    // Age-based suggestions
    if (profile != null) {
      if (profile.age > 50) {
        suggestions.add('Schedule regular health check-ups');
        suggestions.add('Monitor your blood pressure regularly');
      }

      if (profile.age > 40) {
        suggestions.add('Get regular cholesterol screenings');
      }

      if (profile.age < 18) {
        suggestions.add('Ensure adequate calcium intake for bone health');
      }
    }

    // Allergy-based suggestions
    if (profile?.allergies?.isNotEmpty == true) {
      suggestions.add('Always carry your allergy medication');
      suggestions.add('Inform healthcare providers about your allergies');
    }

    // Medical history-based suggestions
    if (profile?.medicalHistory?.toLowerCase().contains('diabetes') == true) {
      suggestions.add('Monitor your blood sugar levels regularly');
      suggestions.add('Follow a diabetic-friendly diet');
    }

    if (profile?.medicalHistory?.toLowerCase().contains('hypertension') == true) {
      suggestions.add('Reduce sodium intake');
      suggestions.add('Practice stress-reduction techniques');
    }

    // Report-based suggestions
    if (reports.isNotEmpty) {
      suggestions.add('Keep your medical reports organized');
      suggestions.add('Share relevant reports with your healthcare providers');
    }

    return suggestions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Suggestions'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Personalized Health Suggestions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Based on your profile, medical history, and reports',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ..._suggestions.map((suggestion) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.lightbulb,
                        color: Colors.amber,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          suggestion,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 24),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Health Tips',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTip(
                      'Stay Hydrated',
                      'Drinking enough water helps maintain bodily functions, improves skin health, and boosts energy levels.',
                    ),
                    const SizedBox(height: 12),
                    _buildTip(
                      'Regular Exercise',
                      'Physical activity helps control weight, reduces risk of diseases, and improves mental health.',
                    ),
                    const SizedBox(height: 12),
                    _buildTip(
                      'Balanced Diet',
                      'Eating a variety of foods ensures you get all necessary nutrients for optimal health.',
                    ),
                    const SizedBox(height: 12),
                    _buildTip(
                      'Quality Sleep',
                      'Good sleep is essential for healing, repair, and maintaining a healthy immune system.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}