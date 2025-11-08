import 'package:flutter/material.dart';
import 'dart:math';

class HairDiagnosisScreen extends StatefulWidget {
  const HairDiagnosisScreen({Key? key}) : super(key: key);
  @override
  _HairDiagnosisScreenState createState() => _HairDiagnosisScreenState();
}

class _HairDiagnosisScreenState extends State<HairDiagnosisScreen> with TickerProviderStateMixin {
  bool _isLoading = false;
  String _diagnosisResult = '';
  String _analysisSource = '';
  String _hairStage = '';
  List<String> _suggestions = [];
  Map<String, dynamic> _analysisData = {};
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _currentQuestionIndex = 0;
  PageController _pageController = PageController();
  late TabController _tabController;

  final List<Map<String, dynamic>> _healthQuestions = [
    { 'question': 'What is your age group?', 'icon': Icons.cake, 'type': 'choice', 'options': ['18-25', '26-35', '36-45', '46-55', '55+'], 'key': 'age_group' },
    { 'question': 'What is your gender?', 'icon': Icons.person, 'type': 'choice', 'options': ['Male', 'Female', 'Other'], 'key': 'gender' },
    { 'question': 'How often do you wash your hair?', 'icon': Icons.wash, 'type': 'choice', 'options': ['Daily', '2-3 times/week', 'Once a week', 'Rarely'], 'key': 'wash_frequency' },
    { 'question': 'Do you experience hair fall while combing?', 'icon': Icons.brush, 'type': 'scale', 'scale': ['Never', 'Rarely', 'Sometimes', 'Often', 'Always'], 'key': 'hairfall_combing' },
    { 'question': 'How would you rate your stress levels?', 'icon': Icons.psychology, 'type': 'scale', 'scale': ['Very Low', 'Low', 'Moderate', 'High', 'Very High'], 'key': 'stress_level' },
    { 'question': 'Do you have a family history of hair loss?', 'icon': Icons.family_restroom, 'type': 'boolean', 'key': 'family_history' },
    { 'question': 'How is your diet quality?', 'icon': Icons.restaurant, 'type': 'scale', 'scale': ['Poor', 'Fair', 'Good', 'Very Good', 'Excellent'], 'key': 'diet_quality' },
    { 'question': 'Do you use heat styling tools regularly?', 'icon': Icons.whatshot, 'type': 'boolean', 'key': 'heat_styling' },
    { 'question': 'How many hours do you sleep per night?', 'icon': Icons.bedtime, 'type': 'choice', 'options': ['Less than 5', '5-6', '6-7', '7-8', '8+'], 'key': 'sleep_hours' },
    { 'question': 'Do you smoke or consume alcohol regularly?', 'icon': Icons.smoke_free, 'type': 'choice', 'options': ['Neither', 'Smoke only', 'Alcohol only', 'Both'], 'key': 'habits' }
  ];

  final Map<String, dynamic> _answers = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0); // Only 2 tabs now
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _submitQuestionnaire() {
    setState(() {
      _isLoading = true;
    });

    // Simulate processing time
    Future.delayed(const Duration(seconds: 2), () {
      _performQuestionnaireAnalysis();
      setState(() {
        _isLoading = false;
        _tabController.animateTo(1); // Go to results tab
      });
    });
  }

  void _performQuestionnaireAnalysis() {
    int riskScore = _calculateRiskScore();
    String riskLevel = _getRiskLevel(riskScore);

    // Generate diagnosis based on answers
    if (_answers['hairfall_combing'] == 'Often' || _answers['hairfall_combing'] == 'Always') {
      _hairStage = 'Advanced Hair Loss';
      _diagnosisResult = 'You are experiencing significant hair loss. This could be due to multiple factors including stress, genetics, or nutritional deficiencies.';
      _suggestions = [
        'Consult a dermatologist or trichologist immediately',
        'Reduce stress levels through meditation or exercise',
        'Improve diet with protein-rich foods',
        'Avoid tight hairstyles that pull on hair',
        'Use gentle hair care products'
      ];
    } else if (_answers['stress_level'] == 'High' || _answers['stress_level'] == 'Very High') {
      _hairStage = 'Early Stage Hair Loss';
      _diagnosisResult = 'High stress levels may be contributing to hair thinning. Stress can disrupt the hair growth cycle.';
      _suggestions = [
        'Practice stress management techniques daily',
        'Ensure adequate sleep (7-8 hours)',
        'Consider supplements like Biotin or Vitamin D',
        'Massage scalp to improve blood circulation',
        'Avoid excessive heat styling'
      ];
    } else if (_answers['family_history'] == true) {
      _hairStage = 'Genetic Hair Loss';
      _diagnosisResult = 'Your family history suggests genetic hair loss (androgenetic alopecia). This is a common cause of hair loss.';
      _suggestions = [
        'Consider FDA-approved treatments like Minoxidil',
        'Prescription medications may be effective',
        'Low-level laser therapy might help',
        'Hair transplantation is an option for advanced cases',
        'Early intervention is key to slowing progression'
      ];
    } else {
      _hairStage = 'Healthy Hair';
      _diagnosisResult = 'Your hair appears to be healthy based on your responses. Maintain your current hair care routine.';
      _suggestions = [
        'Continue your current hair care regimen',
        'Eat a balanced diet rich in vitamins and minerals',
        'Get regular trims to prevent split ends',
        'Protect hair from sun damage',
        'Stay hydrated for overall hair health'
      ];
    }

    _analysisSource = 'Questionnaire Analysis';
    _analysisData = {
      'Risk Score': riskScore.toString(),
      'Risk Level': riskLevel,
      'Hair Stage': _hairStage,
      'Key Factors': _getActiveRiskFactors(),
      'Protective Factors': _getProtectiveFactors()
    };
  }

  int _calculateRiskScore() {
    int score = 0;

    if (_answers['hairfall_combing'] == 'Often') score += 2;
    if (_answers['hairfall_combing'] == 'Always') score += 3;
    if (_answers['stress_level'] == 'High') score += 2;
    if (_answers['stress_level'] == 'Very High') score += 3;
    if (_answers['family_history'] == true) score += 3;
    if (_answers['diet_quality'] == 'Poor') score += 2;
    if (_answers['heat_styling'] == true) score += 1;
    if (_answers['sleep_hours'] == 'Less than 5') score += 2;
    if (_answers['habits'] == 'Both') score += 2;

    return score;
  }

  String _getRiskLevel(int score) {
    if (score <= 3) return 'Low';
    if (score <= 6) return 'Moderate';
    return 'High';
  }

  List<String> _getActiveRiskFactors() {
    List<String> factors = [];

    if (_answers['hairfall_combing'] == 'Often' || _answers['hairfall_combing'] == 'Always') {
      factors.add('Excessive hair fall');
    }
    if (_answers['stress_level'] == 'High' || _answers['stress_level'] == 'Very High') {
      factors.add('High stress levels');
    }
    if (_answers['family_history'] == true) {
      factors.add('Family history of hair loss');
    }
    if (_answers['diet_quality'] == 'Poor') {
      factors.add('Poor diet quality');
    }
    if (_answers['heat_styling'] == true) {
      factors.add('Regular heat styling');
    }
    if (_answers['sleep_hours'] == 'Less than 5') {
      factors.add('Insufficient sleep');
    }
    if (_answers['habits'] == 'Both' || _answers['habits'] == 'Smoke only') {
      factors.add('Smoking');
    }

    return factors;
  }

  List<String> _getProtectiveFactors() {
    List<String> factors = [];

    if (_answers['hairfall_combing'] == 'Never' || _answers['hairfall_combing'] == 'Rarely') {
      factors.add('Minimal hair fall');
    }
    if (_answers['stress_level'] == 'Very Low' || _answers['stress_level'] == 'Low') {
      factors.add('Low stress levels');
    }
    if (_answers['diet_quality'] == 'Good' || _answers['diet_quality'] == 'Very Good' || _answers['diet_quality'] == 'Excellent') {
      factors.add('Good diet quality');
    }
    if (_answers['heat_styling'] == false) {
      factors.add('No heat styling');
    }
    if (_answers['sleep_hours'] == '7-8' || _answers['sleep_hours'] == '8+') {
      factors.add('Adequate sleep');
    }
    if (_answers['habits'] == 'Neither') {
      factors.add('No smoking or alcohol');
    }

    return factors;
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _healthQuestions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildQuestionnaireTab() {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _healthQuestions.length,
            onPageChanged: (index) {
              setState(() {
                _currentQuestionIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return _buildQuestionCard(_healthQuestions[index]);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: _currentQuestionIndex > 0 ? _previousQuestion : null,
                child: const Text('Previous'),
              ),
              ElevatedButton(
                onPressed: _currentQuestionIndex < _healthQuestions.length - 1 ? _nextQuestion : _submitQuestionnaire,
                child: Text(_currentQuestionIndex < _healthQuestions.length - 1 ? 'Next' : 'Get Analysis'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_diagnosisResult.isNotEmpty) ...[
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
                          'Hair Health Analysis',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Text(
                      'Diagnosis: $_hairStage',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    Text(_diagnosisResult),
                    const SizedBox(height: 24),
                    const Text(
                      'Recommendations',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
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
            const SizedBox(height: 16),
            _buildAnalysisDataSection(),
            const SizedBox(height: 16),
            _buildDisclaimer(),
          ],
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(question['icon'], color: Colors.blue, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      question['question'],
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (question['type'] == 'choice')
                Column(
                  children: (question['options'] as List<String>).map((option) {
                    return _buildChoiceButton(option, option, question['key']);
                  }).toList(),
                )
              else if (question['type'] == 'scale')
                Column(
                  children: (question['scale'] as List<String>).map((option) {
                    int value = (question['scale'] as List<String>).indexOf(option);
                    return _buildScaleButton(option, value, question['key']);
                  }).toList(),
                )
              else if (question['type'] == 'boolean')
                  Row(
                    children: [
                      Expanded(
                        child: _buildChoiceButton('Yes', true, question['key']),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildChoiceButton('No', false, question['key']),
                      ),
                    ],
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceButton(String text, dynamic value, String key) {
    bool isSelected = _answers[key] == value;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _answers[key] = value;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.blue : Colors.white,
          foregroundColor: isSelected ? Colors.white : Colors.black,
          elevation: isSelected ? 3 : 1,
          side: BorderSide(color: Colors.blue.shade300),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(text, textAlign: TextAlign.center),
      ),
    );
  }

  Widget _buildScaleButton(String text, int value, String key) {
    bool isSelected = _answers[key] == value;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _answers[key] = value;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.blue : Colors.white,
          foregroundColor: isSelected ? Colors.white : Colors.black,
          elevation: isSelected ? 3 : 1,
          side: BorderSide(color: Colors.blue.shade300),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(text, textAlign: TextAlign.center),
      ),
    );
  }

  Widget _buildAnalysisDataSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.analytics, color: Colors.orange, size: 28),
                SizedBox(width: 12),
                Text(
                  'Analysis Details',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            ..._analysisData.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${entry.key}:',
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
    );
  }

  Widget _buildDisclaimer() {
    return Container(
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
              'This analysis is based on your questionnaire responses and is not a substitute for professional medical advice. Please consult a healthcare provider for accurate diagnosis and treatment.',
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF00838F),
        foregroundColor: Colors.white,
        title: const Text('Hair Health Diagnosis', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.quiz), text: 'Health Assessment'),
            Tab(icon: Icon(Icons.analytics), text: 'Results'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildQuestionnaireTab(),
          _buildResultsTab(),
        ],
      ),
    );
  }
}