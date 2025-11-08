import 'package:flutter/material.dart';

class BMITrackerScreen extends StatefulWidget {
  const BMITrackerScreen({Key? key}) : super(key: key);

  @override
  _BMITrackerScreenState createState() => _BMITrackerScreenState();
}

class _BMITrackerScreenState extends State<BMITrackerScreen> {
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  double _bmi = 0;
  String _bmiCategory = '';
  String _bmiMessage = '';
  bool _calculated = false;

  void _calculateBMI() {
    if (_heightController.text.isNotEmpty && _weightController.text.isNotEmpty) {
      double height = double.parse(_heightController.text) / 100; // Convert cm to meters
      double weight = double.parse(_weightController.text);

      setState(() {
        _bmi = weight / (height * height);
        _calculated = true;

        if (_bmi < 18.5) {
          _bmiCategory = 'Underweight';
          _bmiMessage = 'You are underweight. Consider consulting a healthcare provider for advice.';
        } else if (_bmi >= 18.5 && _bmi < 25) {
          _bmiCategory = 'Normal weight';
          _bmiMessage = 'Congratulations! You are in the healthy weight range.';
        } else if (_bmi >= 25 && _bmi < 30) {
          _bmiCategory = 'Overweight';
          _bmiMessage = 'You are overweight. Consider making lifestyle changes.';
        } else {
          _bmiCategory = 'Obese';
          _bmiMessage = 'You are in the obese range. Please consult a healthcare provider.';
        }
      });
    }
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI Tracker'),
      ),
      body: SingleChildScrollView(
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
                  children: [
                    const Text(
                      'Calculate Your BMI',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _heightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Height (cm)',
                        prefixIcon: Icon(Icons.height),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Weight (kg)',
                        prefixIcon: Icon(Icons.monitor_weight),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _calculateBMI,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Calculate BMI',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_calculated) ...[
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Your BMI Result',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _bmi.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: _getBMIColor(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _bmiCategory,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _getBMIColor(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _bmiMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            const Text(
              'BMI Categories',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildBMIRow('Underweight', '< 18.5', Colors.blue),
                    const Divider(),
                    _buildBMIRow('Normal weight', '18.5 - 24.9', Colors.green),
                    const Divider(),
                    _buildBMIRow('Overweight', '25 - 29.9', Colors.orange),
                    const Divider(),
                    _buildBMIRow('Obese', '≥ 30', Colors.red),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Health Tips',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
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
                    _buildTip('Eat a balanced diet with plenty of fruits and vegetables'),
                    const SizedBox(height: 8),
                    _buildTip('Engage in regular physical activity (at least 150 minutes per week)'),
                    const SizedBox(height: 8),
                    _buildTip('Limit processed foods and sugary drinks'),
                    const SizedBox(height: 8),
                    _buildTip('Get enough sleep (7-8 hours per night)'),
                    const SizedBox(height: 8),
                    _buildTip('Stay hydrated by drinking plenty of water'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBMIColor() {
    if (_bmi < 18.5) {
      return Colors.blue;
    } else if (_bmi >= 18.5 && _bmi < 25) {
      return Colors.green;
    } else if (_bmi >= 25 && _bmi < 30) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Widget _buildBMIRow(String category, String range, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Text(
              category,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              range,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String tip) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(tip),
        ),
      ],
    );
  }
}