import 'package:flutter/material.dart';

class DentalCheckScreen extends StatefulWidget {
  const DentalCheckScreen({Key? key}) : super(key: key);

  @override
  _DentalCheckScreenState createState() => _DentalCheckScreenState();
}

class _DentalCheckScreenState extends State<DentalCheckScreen> {
  bool _isLoading = false;
  String _diagnosisResult = '';
  List<String> _suggestions = [];

  // 10 built-in questions about dental health
  final List<String> _questions = [
    'Do you have tooth pain?',
    'Do your gums bleed when brushing?',
    'Do you have bad breath?',
    'Do you have sensitive teeth?',
    'Do you have visible cavities?',
    'Do you smoke or use tobacco?',
    'Do you often eat sugary foods or drinks?',
    'Do you grind your teeth at night?',
    'Do you have any loose teeth?',
    'Have you noticed any changes in your bite?'
  ];

  final Map<String, bool> _answers = {};
  final Map<String, bool> _checkBoxAnswers = {
    'I brush twice daily': false,
    'I floss daily': false,
    'I use mouthwash': false,
  };

  void _getAnalysis() async {
    // Check if all radio questions are answered
    if (_answers.length < _questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please answer all questions before analysis')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;

      // Base diagnosis from radio button answers
      if (_answers['Do you have tooth pain?'] == true ||
          _answers['Do you have visible cavities?'] == true) {
        _diagnosisResult = 'You may have cavities or other dental issues.';
        _suggestions = [
          'Schedule a dental appointment soon',
          'Use toothpaste for sensitive teeth',
          'Avoid very hot or cold foods',
          'Rinse with warm salt water'
        ];
      } else if (_answers['Do your gums bleed when brushing?'] == true) {
        _diagnosisResult = 'You may have gingivitis (gum inflammation).';
        _suggestions = [
          'Brush and floss gently but thoroughly',
          'Use an antiseptic mouthwash',
          'Schedule a dental cleaning',
          'Replace your toothbrush every 3-4 months'
        ];
      } else if (_answers['Do you have bad breath?'] == true) {
        _diagnosisResult = 'You may have halitosis (bad breath).';
        _suggestions = [
          'Brush your tongue or use a tongue scraper',
          'Stay hydrated by drinking plenty of water',
          'Chew sugar-free gum',
          'Visit your dentist for a check-up'
        ];
      } else if (_answers['Do you grind your teeth at night?'] == true) {
        _diagnosisResult = 'You may be grinding your teeth (bruxism).';
        _suggestions = [
          'Consider wearing a night guard',
          'Reduce stress before bedtime',
          'Avoid caffeine and alcohol in the evening',
          'Consult your dentist for treatment options'
        ];
      } else {
        _diagnosisResult = 'Your oral health appears to be good.';
        _suggestions = [
          'Continue your current oral hygiene routine',
          'Visit your dentist for regular check-ups',
          'Maintain a healthy diet',
          'Avoid tobacco products'
        ];
      }

      // Consider checkbox answers
      if (_checkBoxAnswers.containsValue(false)) {
        _suggestions.add('Try to maintain a consistent oral care routine with brushing, flossing, and mouthwash.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dental Check'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Oral Health Analysis',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Answer the questions below to get your dental health analysis',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Questionnaire Section
            const Text(
              'Answer the following questions about your oral health:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Questions in a card format
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: _questions.map((question) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          question,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<bool>(
                                title: const Text('Yes'),
                                value: true,
                                groupValue: _answers[question],
                                onChanged: (value) {
                                  setState(() {
                                    _answers[question] = value!;
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<bool>(
                                title: const Text('No'),
                                value: false,
                                groupValue: _answers[question],
                                onChanged: (value) {
                                  setState(() {
                                    _answers[question] = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Checkbox Section for habits
            const Text(
              'Your Daily Oral Care Habits:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: _checkBoxAnswers.keys.map((habit) {
                    return CheckboxListTile(
                      title: Text(habit),
                      value: _checkBoxAnswers[habit],
                      onChanged: (val) {
                        setState(() {
                          _checkBoxAnswers[habit] = val!;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Analysis Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _getAnalysis,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Get Analysis', style: TextStyle(fontSize: 16)),
              ),
            ),

            const SizedBox(height: 24),

            // Results Section
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_diagnosisResult.isNotEmpty) ...[
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Diagnosis Result', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(_diagnosisResult),
                      const SizedBox(height: 16),
                      const Text('Recommendations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ..._suggestions.map((suggestion) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green, size: 20),
                            const SizedBox(width: 8),
                            Expanded(child: Text(suggestion)),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}