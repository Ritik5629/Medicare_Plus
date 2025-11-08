import 'package:flutter/material.dart';

class DailyTipsScreen extends StatefulWidget {
  const DailyTipsScreen({Key? key}) : super(key: key);

  @override
  _DailyTipsScreenState createState() => _DailyTipsScreenState();
}

class _DailyTipsScreenState extends State<DailyTipsScreen> {
  final List<Map<String, String>> _tips = [
    {
      'title': 'Stay Hydrated',
      'description': 'Drinking enough water helps maintain bodily functions, improves skin health, and boosts energy levels.',
      'icon': 'water_drop',
    },
    {
      'title': 'Eat More Fruits',
      'description': 'Fruits are packed with vitamins, minerals, and antioxidants that support overall health.',
      'icon': 'restaurant', // Changed from 'nutrition'
    },
    {
      'title': 'Get Moving',
      'description': 'Regular physical activity helps control weight, reduces risk of diseases, and improves mental health.',
      'icon': 'directions_run',
    },
    {
      'title': 'Quality Sleep',
      'description': 'Good sleep is essential for healing, repair, and maintaining a healthy immune system.',
      'icon': 'bedtime',
    },
    {
      'title': 'Reduce Stress',
      'description': 'Chronic stress can lead to health problems. Practice relaxation techniques like meditation.',
      'icon': 'spa', // Changed from 'self_improvement'
    },
    {
      'title': 'Limit Sugar',
      'description': 'Excessive sugar consumption is linked to obesity, type 2 diabetes, and heart disease.',
      'icon': 'no_food', // This is correct
    },
    {
      'title': 'Sun Protection',
      'description': 'Protect your skin from harmful UV rays by wearing sunscreen and protective clothing.',
      'icon': 'wb_sunny',
    },
    {
      'title': 'Regular Check-ups',
      'description': 'Preventive healthcare can detect problems early when they are easier to treat.',
      'icon': 'medical_services',
    },
  ];

  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextTip() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _tips.length;
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void _previousTip() {
    setState(() {
      _currentIndex = (_currentIndex - 1 + _tips.length) % _tips.length;
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Health Tips'),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _tips.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final tip = _tips[index];
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getIconData(tip['icon']!),
                            size: 80,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            tip['title']!,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            tip['description']!,
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _previousTip,
                  icon: const Icon(Icons.arrow_back),
                  iconSize: 32,
                ),
                Text(
                  '${_currentIndex + 1} / ${_tips.length}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: _nextTip,
                  icon: const Icon(Icons.arrow_forward),
                  iconSize: 32,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'water_drop':
        return Icons.water_drop;
      case 'restaurant': // Changed from 'nutrition'
        return Icons.restaurant;
      case 'directions_run':
        return Icons.directions_run;
      case 'bedtime':
        return Icons.bedtime;
      case 'spa': // Changed from 'self_improvement'
        return Icons.spa;
      case 'no_food':
        return Icons.no_food;
      case 'wb_sunny':
        return Icons.wb_sunny;
      case 'medical_services':
        return Icons.medical_services;
      default:
        return Icons.lightbulb;
    }
  }
}