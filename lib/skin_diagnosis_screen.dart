import 'package:flutter/material.dart';

class SkinDiagnosisScreen extends StatefulWidget {
  const SkinDiagnosisScreen({Key? key}) : super(key: key);

  @override
  _SkinDiagnosisScreenState createState() => _SkinDiagnosisScreenState();
}

class _SkinDiagnosisScreenState extends State<SkinDiagnosisScreen> {
  bool _isLoading = false;
  int _currentStep = 0;

  // User responses
  final Map<String, dynamic> _responses = {};

  // Diagnosis results
  String _primaryDiagnosis = '';
  String _secondaryDiagnosis = '';
  double _confidenceScore = 0.0;
  List<Map<String, dynamic>> _recommendations = [];
  Map<String, dynamic> _skinAnalysis = {};

  // Questionnaire data
  final List<Map<String, dynamic>> _questions = [
    {
      'id': 'skin_type',
      'question': 'What is your skin type?',
      'type': 'single',
      'options': ['Oily', 'Dry', 'Combination', 'Normal', 'Sensitive']
    },
    {
      'id': 'age_group',
      'question': 'What is your age group?',
      'type': 'single',
      'options': ['Under 18', '18-25', '26-35', '36-45', '46-60', 'Over 60']
    },
    {
      'id': 'concern_duration',
      'question': 'How long have you had this skin concern?',
      'type': 'single',
      'options': ['Less than 1 week', '1-4 weeks', '1-3 months', '3-6 months', 'Over 6 months']
    },
    {
      'id': 'symptoms',
      'question': 'What symptoms are you experiencing?',
      'type': 'multiple',
      'options': ['Redness', 'Itching', 'Burning', 'Dryness', 'Oiliness', 'Flaking', 'Bumps/Acne', 'Dark spots', 'Rash', 'Swelling']
    },
    {
      'id': 'triggers',
      'question': 'Have you noticed any triggers?',
      'type': 'multiple',
      'options': ['Stress', 'Diet', 'Weather changes', 'New products', 'Sun exposure', 'Lack of sleep', 'Hormonal changes', 'None identified']
    },
    {
      'id': 'current_routine',
      'question': 'What is your current skincare routine?',
      'type': 'multiple',
      'options': ['Cleanser', 'Toner', 'Moisturizer', 'Sunscreen', 'Serums', 'Exfoliants', 'Masks', 'No routine']
    },
    {
      'id': 'allergies',
      'question': 'Do you have any known allergies?',
      'type': 'text',
      'hint': 'Enter any known allergies or "None"'
    },
    {
      'id': 'medications',
      'question': 'Are you currently taking any medications?',
      'type': 'text',
      'hint': 'Enter medications or "None"'
    },
    {
      'id': 'lifestyle',
      'question': 'Lifestyle factors:',
      'type': 'multiple',
      'options': ['Regular exercise', 'Balanced diet', 'Adequate sleep (7-8 hrs)', 'Drink 8+ glasses water', 'Smoke', 'Alcohol consumption', 'High stress']
    },
    {
      'id': 'previous_treatments',
      'question': 'Have you tried any treatments for this condition?',
      'type': 'text',
      'hint': 'Describe previous treatments or "None"'
    },
  ];

  void _analyzeResults() {
    setState(() {
      _isLoading = true;
    });

    // Simulate AI processing with advanced analysis
    Future.delayed(const Duration(seconds: 3), () {
      _performAdvancedAnalysis();
      setState(() {
        _isLoading = false;
      });
    });
  }

  void _performAdvancedAnalysis() {
    // Advanced analysis logic based on responses
    final symptoms = _responses['symptoms'] as List<String>? ?? [];
    final skinType = _responses['skin_type'] ?? '';
    final triggers = _responses['triggers'] as List<String>? ?? [];
    final duration = _responses['concern_duration'] ?? '';

    // Analyze skin condition
    if (symptoms.contains('Bumps/Acne') && symptoms.contains('Oiliness')) {
      _primaryDiagnosis = 'Acne Vulgaris';
      _confidenceScore = 0.87;
      _secondaryDiagnosis = 'Possible sebaceous hyperplasia';

      _recommendations = [
        {
          'category': 'Cleansing',
          'title': 'Use Salicylic Acid Cleanser',
          'description': 'Apply twice daily to help unclog pores and reduce inflammation',
          'priority': 'High'
        },
        {
          'category': 'Treatment',
          'title': 'Benzoyl Peroxide Spot Treatment',
          'description': 'Apply to affected areas once daily, start with 2.5% concentration',
          'priority': 'High'
        },
        {
          'category': 'Moisturizing',
          'title': 'Non-comedogenic Moisturizer',
          'description': 'Use oil-free, lightweight formula to maintain hydration',
          'priority': 'Medium'
        },
        {
          'category': 'Protection',
          'title': 'Broad Spectrum SPF 30+',
          'description': 'Essential daily protection, choose oil-free formulation',
          'priority': 'High'
        },
        {
          'category': 'Lifestyle',
          'title': 'Dietary Modifications',
          'description': 'Reduce dairy and high-glycemic foods, increase water intake',
          'priority': 'Medium'
        }
      ];

      _skinAnalysis = {
        'severity': 'Moderate',
        'affected_areas': 'T-zone primarily',
        'inflammation_level': 'Mild to Moderate',
        'pore_condition': 'Enlarged and congested',
        'texture': 'Uneven with active lesions',
        'hydration': 'Adequate but imbalanced'
      };
    } else if (symptoms.contains('Redness') && symptoms.contains('Itching')) {
      _primaryDiagnosis = 'Eczema (Atopic Dermatitis)';
      _confidenceScore = 0.82;
      _secondaryDiagnosis = 'Contact dermatitis (possible)';

      _recommendations = [
        {
          'category': 'Cleansing',
          'title': 'Gentle, Fragrance-Free Cleanser',
          'description': 'Use mild, soap-free cleanser to avoid irritation',
          'priority': 'High'
        },
        {
          'category': 'Treatment',
          'title': 'Ceramide-Rich Repair Cream',
          'description': 'Apply multiple times daily to restore skin barrier',
          'priority': 'High'
        },
        {
          'category': 'Medication',
          'title': 'Consider Hydrocortisone 1%',
          'description': 'For flare-ups, apply thin layer (consult doctor for prolonged use)',
          'priority': 'High'
        },
        {
          'category': 'Protection',
          'title': 'Mineral Sunscreen SPF 50',
          'description': 'Use zinc oxide or titanium dioxide based formulas',
          'priority': 'Medium'
        },
        {
          'category': 'Lifestyle',
          'title': 'Trigger Avoidance',
          'description': 'Identify and avoid triggers (harsh soaps, wool, stress)',
          'priority': 'High'
        }
      ];

      _skinAnalysis = {
        'severity': 'Moderate',
        'affected_areas': 'Multiple sites',
        'inflammation_level': 'Moderate',
        'barrier_function': 'Compromised',
        'texture': 'Rough with visible irritation',
        'hydration': 'Severely compromised'
      };
    } else if (symptoms.contains('Dryness') && symptoms.contains('Flaking')) {
      _primaryDiagnosis = 'Xerosis (Dry Skin)';
      _confidenceScore = 0.90;
      _secondaryDiagnosis = 'Possible dehydration or barrier dysfunction';

      _recommendations = [
        {
          'category': 'Cleansing',
          'title': 'Cream-Based Cleanser',
          'description': 'Use hydrating, non-foaming cleanser once daily',
          'priority': 'High'
        },
        {
          'category': 'Hydration',
          'title': 'Hyaluronic Acid Serum',
          'description': 'Apply on damp skin before moisturizer',
          'priority': 'High'
        },
        {
          'category': 'Moisturizing',
          'title': 'Rich Emollient Cream',
          'description': 'Use thick cream with ceramides and peptides twice daily',
          'priority': 'High'
        },
        {
          'category': 'Treatment',
          'title': 'Overnight Sleeping Mask',
          'description': 'Apply occlusive layer before bed to lock in moisture',
          'priority': 'Medium'
        },
        {
          'category': 'Lifestyle',
          'title': 'Environmental Adjustments',
          'description': 'Use humidifier, avoid hot water, increase water intake',
          'priority': 'Medium'
        }
      ];

      _skinAnalysis = {
        'severity': 'Mild to Moderate',
        'affected_areas': 'Widespread',
        'inflammation_level': 'Minimal',
        'barrier_function': 'Weakened',
        'texture': 'Rough with visible flaking',
        'hydration': 'Poor'
      };
    } else {
      _primaryDiagnosis = 'General Skin Concern';
      _confidenceScore = 0.75;
      _secondaryDiagnosis = 'Further evaluation recommended';

      _recommendations = [
        {
          'category': 'Basic Care',
          'title': 'Establish Core Routine',
          'description': 'Cleanser, moisturizer, and sunscreen daily',
          'priority': 'High'
        },
        {
          'category': 'Consultation',
          'title': 'Professional Evaluation',
          'description': 'Consult dermatologist for accurate diagnosis',
          'priority': 'High'
        }
      ];

      _skinAnalysis = {
        'severity': 'Unknown',
        'recommendation': 'Professional consultation needed'
      };
    }
  }

  Widget _buildQuestionWidget(Map<String, dynamic> question) {
    final questionId = question['id'];
    final questionType = question['type'];

    switch (questionType) {
      case 'single':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question['question'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...List.generate(
              question['options'].length,
                  (index) => RadioListTile<String>(
                title: Text(question['options'][index]),
                value: question['options'][index],
                groupValue: _responses[questionId],
                onChanged: (value) {
                  setState(() {
                    _responses[questionId] = value;
                  });
                },
              ),
            ),
          ],
        );

      case 'multiple':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question['question'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...List.generate(
              question['options'].length,
                  (index) {
                final option = question['options'][index];
                final selected = (_responses[questionId] as List<String>? ?? []).contains(option);
                return CheckboxListTile(
                  title: Text(option),
                  value: selected,
                  onChanged: (value) {
                    setState(() {
                      if (_responses[questionId] == null) {
                        _responses[questionId] = <String>[];
                      }
                      if (value == true) {
                        (_responses[questionId] as List<String>).add(option);
                      } else {
                        (_responses[questionId] as List<String>).remove(option);
                      }
                    });
                  },
                );
              },
            ),
          ],
        );

      case 'text':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question['question'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: question['hint'],
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) {
                _responses[questionId] = value;
              },
            ),
          ],
        );

      default:
        return const SizedBox();
    }
  }

  Widget _buildResultsView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Diagnosis Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.medical_services, color: Colors.blue, size: 28),
                      const SizedBox(width: 12),
                      const Text(
                        'Diagnosis',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Text(
                    'Primary: $_primaryDiagnosis',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Secondary: $_secondaryDiagnosis',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Confidence: ', style: TextStyle(fontSize: 16)),
                      Text(
                        '${(_confidenceScore * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: _confidenceScore,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                    minHeight: 8,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Skin Analysis Card
          if (_skinAnalysis.isNotEmpty)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.analytics, color: Colors.orange, size: 28),
                        const SizedBox(width: 12),
                        const Text(
                          'Detailed Analysis',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    ..._skinAnalysis.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                '${entry.key.replaceAll('_', ' ').toUpperCase()}:',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(entry.value.toString()),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Recommendations
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lightbulb, color: Colors.amber, size: 28),
                      const SizedBox(width: 12),
                      const Text(
                        'Treatment Plan',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  ..._recommendations.map((rec) {
                    Color priorityColor = rec['priority'] == 'High'
                        ? Colors.red
                        : rec['priority'] == 'Medium'
                        ? Colors.orange
                        : Colors.blue;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                rec['category'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: priorityColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: priorityColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  rec['priority'],
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: priorityColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            rec['title'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            rec['description'],
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Disclaimer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber, color: Colors.amber),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'This is an AI-assisted analysis and not a replacement for professional medical advice. Please consult a dermatologist for accurate diagnosis and treatment.',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _currentStep = 0;
                      _responses.clear();
                      _primaryDiagnosis = '';
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('New Analysis'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Share or save report
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Share Report'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Skin Diagnosis')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              const Text(
                'Analyzing your skin...',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'This may take a few moments',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    if (_primaryDiagnosis.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Analysis Results'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildResultsView(),
        ),
      );
    }

    final totalSteps = _questions.length; // Only questions now

    return Scaffold(
      appBar: AppBar(
        title: const Text('Skin Diagnosis'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_currentStep + 1) / totalSteps,
            backgroundColor: Colors.grey.shade200,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Progress indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Step ${_currentStep + 1} of $totalSteps',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Text(
                  '${((_currentStep + 1) / totalSteps * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: _buildQuestionWidget(_questions[_currentStep]),
              ),
            ),

            // Navigation buttons
            const SizedBox(height: 16),
            Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _currentStep--;
                        });
                      },
                      child: const Text('Previous'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentStep < _questions.length - 1) {
                        setState(() {
                          _currentStep++;
                        });
                      } else {
                        _analyzeResults();
                      }
                    },
                    child: Text(_currentStep == _questions.length - 1 ? 'Get Analysis' : 'Next'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}