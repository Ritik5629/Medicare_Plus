import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';
import 'theme_provider.dart';
import 'models.dart';
import 'profile_screen.dart' hide HairDiagnosisScreen, DentalCheckScreen;
import 'medicine_reminder_screen.dart';
import 'hair_diagnosis_screen.dart';
import 'dental_check_screen.dart';
import 'reports_screen.dart';
import 'appointment_screen.dart';
import 'health_suggestions_screen.dart';
import 'emergency_screen.dart';
import 'bmi_tracker_screen.dart';
import 'daily_tips_screen.dart';
import 'ai_chat_agent.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final User? user = FirebaseAuth.instance.currentUser;
  UserProfile? userProfile;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    if (user != null) {
      UserProfile? profile = await AuthService().getUserProfile(user!.uid);
      if (mounted) {
        setState(() {
          userProfile = profile;
        });
      }
    }
  }

  final List<Widget> _screens = [
    const DashboardScreen(),
    const MedicineReminderScreen(),
    const HealthCheckScreen(),
    const ReportsScreen(),
    const AppointmentScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1565C0),
                  const Color(0xFF1976D2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.medical_services_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'MediCare+',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          actions: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                onPressed: themeProvider.toggleTheme,
                tooltip: isDark ? 'Light Mode' : 'Dark Mode',
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.person_rounded, color: Colors.white, size: 22),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                ),
                tooltip: 'Profile',
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: _screens[_currentIndex],
          ),
          if (_currentIndex == 0) const AIChatAgent(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1565C0),
              const Color(0xFF1976D2),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white.withOpacity(0.7),
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 11,
            ),
            onTap: (index) {
              if (_currentIndex != index) {
                setState(() {
                  _currentIndex = index;
                });
              }
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded, size: 24),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.medication_rounded, size: 24),
                label: 'Medicine',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.health_and_safety_rounded, size: 24),
                label: 'Health',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.description_rounded, size: 24),
                label: 'Reports',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today_rounded, size: 24),
                label: 'Appointments',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String displayName = user?.displayName ?? 'Healthcare User';
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1565C0).withOpacity(0.05),
            Colors.white,
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeHeaderWithAI(displayName, isTablet),
            SizedBox(height: isTablet ? 32 : 24),

            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                'Quick Health Actions',
                style: TextStyle(
                  fontSize: isTablet ? 24 : 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade800,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            SizedBox(height: isTablet ? 20 : 16),

            _buildFeatureCardsGrid(isTablet),
            SizedBox(height: isTablet ? 32 : 24),

            _buildAIHealthCard(isTablet),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeaderWithAI(String displayName, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 28 : 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 18 : 14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.waving_hand_rounded,
                  color: Colors.white,
                  size: isTablet ? 36 : 28,
                ),
              ),
              SizedBox(width: isTablet ? 20 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 15,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displayName.split(' ')[0],
                      style: TextStyle(
                        fontSize: isTablet ? 26 : 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Your Smart Healthcare Assistant',
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 13,
                        color: Colors.white.withOpacity(0.85),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.smart_toy_rounded,
                  color: Colors.white,
                  size: isTablet ? 20 : 18,
                ),
                SizedBox(width: isTablet ? 12 : 8),
                Text(
                  'AI Assistant is ready to help you!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 14 : 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: isTablet ? 8 : 6),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.greenAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCardsGrid(bool isTablet) {
    final features = [
      _FeatureData('Hair Check', Icons.content_cut_rounded, const Color(0xFF8E24AA), 'Analyze hair health', () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HairDiagnosisScreen()))),
      _FeatureData('Skin Check', Icons.face_rounded, const Color(0xFFFF8F00), 'Monitor skin condition', () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SkinDiagnosisScreen()))),
      _FeatureData('Dental Check', Icons.sentiment_satisfied_rounded, const Color(0xFF1976D2), 'Oral health assessment', () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DentalCheckScreen()))),
      _FeatureData('BMI Tracker', Icons.fitness_center_rounded, const Color(0xFF388E3C), 'Track your fitness', () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BMITrackerScreen()))),
      _FeatureData('Health Tips', Icons.lightbulb_rounded, const Color(0xFFF57C00), 'Daily wellness advice', () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DailyTipsScreen()))),
      _FeatureData('Emergency', Icons.emergency_rounded, const Color(0xFFD32F2F), 'SOS alert system', () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EmergencyScreen()))),
    ];

    if (isTablet) {
      return Column(
        children: [
          Row(
            children: features.take(3).map((feature) =>
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _buildFeatureCard(feature, isTablet),
                  ),
                ),
            ).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: features.skip(3).map((feature) =>
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _buildFeatureCard(feature, isTablet),
                  ),
                ),
            ).toList(),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          Row(
            children: features.take(3).map((feature) =>
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _buildFeatureCard(feature, isTablet),
                  ),
                ),
            ).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: features.skip(3).map((feature) =>
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _buildFeatureCard(feature, isTablet),
                  ),
                ),
            ).toList(),
          ),
        ],
      );
    }
  }

  Widget _buildFeatureCard(_FeatureData feature, bool isTablet) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: feature.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(isTablet ? 20 : 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: feature.color.withOpacity(0.15)),
            boxShadow: [
              BoxShadow(
                color: feature.color.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 16 : 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [feature.color, feature.color.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: feature.color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  feature.icon,
                  size: isTablet ? 28 : 24,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: isTablet ? 14 : 10),
              Text(
                feature.title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: isTablet ? 15 : 13,
                  color: Colors.grey.shade800,
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: isTablet ? 6 : 4),
              Text(
                feature.subtitle,
                style: TextStyle(
                  fontSize: isTablet ? 12 : 10,
                  color: Colors.grey.shade600,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAIHealthCard(bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFF4CAF50), Colors.white],
          stops: [0.0, 0.02, 1.0],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 28 : 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isTablet ? 14 : 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4CAF50).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.psychology_rounded,
                    color: Colors.white,
                    size: isTablet ? 26 : 22,
                  ),
                ),
                SizedBox(width: isTablet ? 18 : 14),
                Expanded(
                  child: Text(
                    'AI Health Suggestions',
                    style: TextStyle(
                      fontSize: isTablet ? 22 : 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade800,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isTablet ? 16 : 12),
            Text(
              'Get personalized health recommendations based on your profile, medical history, and AI analysis.',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: isTablet ? 16 : 14,
                height: 1.5,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: isTablet ? 24 : 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: isTablet ? 18 : 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HealthSuggestionsScreen()),
                ),
                child: Text(
                  'View AI Suggestions',
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureData {
  final String title;
  final IconData icon;
  final Color color;
  final String subtitle;
  final VoidCallback onTap;

  _FeatureData(this.title, this.icon, this.color, this.subtitle, this.onTap);
}

class HealthCheckScreen extends StatelessWidget {
  const HealthCheckScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1565C0).withOpacity(0.05),
            Colors.white,
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(isTablet ? 24 : 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1565C0).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.health_and_safety_rounded,
                    color: Colors.white,
                    size: isTablet ? 36 : 30,
                  ),
                  SizedBox(width: isTablet ? 18 : 14),
                  Text(
                    'Health Check Center',
                    style: TextStyle(
                      fontSize: isTablet ? 26 : 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: isTablet ? 28 : 22),

            ..._buildHealthCheckCards(context, isTablet),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildHealthCheckCards(BuildContext context, bool isTablet) {
    final healthChecks = [
      _HealthCheckData('Hair Diagnosis', 'Check for hair issues and get recommendations', Icons.content_cut_rounded, const Color(0xFF8E24AA), () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HairDiagnosisScreen()))),
      _HealthCheckData('Skin Diagnosis', 'Analyze skin conditions and get care tips', Icons.face_rounded, const Color(0xFFFF8F00), () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SkinDiagnosisScreen()))),
      _HealthCheckData('Dental Check', 'Assess oral health and get dental advice', Icons.sentiment_satisfied_rounded, const Color(0xFF1976D2), () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DentalCheckScreen()))),
      _HealthCheckData('BMI Tracker', 'Calculate BMI and track your fitness', Icons.fitness_center_rounded, const Color(0xFF388E3C), () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BMITrackerScreen()))),
      _HealthCheckData('Daily Health Tips', 'Get new health tips every day', Icons.lightbulb_rounded, const Color(0xFFF57C00), () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DailyTipsScreen()))),
      _HealthCheckData('Emergency SOS', 'Send emergency alert to contacts', Icons.emergency_rounded, const Color(0xFFD32F2F), () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EmergencyScreen()))),
    ];

    return healthChecks.map((healthCheck) =>
        Padding(
          padding: EdgeInsets.only(bottom: isTablet ? 18 : 14),
          child: _buildHealthCheckCard(healthCheck, isTablet),
        ),
    ).toList();
  }

  Widget _buildHealthCheckCard(_HealthCheckData data, bool isTablet) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: data.onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: data.color.withOpacity(0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isTablet ? 16 : 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [data.color, data.color.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: data.color.withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    data.icon,
                    color: Colors.white,
                    size: isTablet ? 28 : 26,
                  ),
                ),
                SizedBox(width: isTablet ? 20 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: isTablet ? 18 : 16,
                          color: Colors.grey.shade800,
                          letterSpacing: 0.2,
                        ),
                      ),
                      SizedBox(height: isTablet ? 6 : 4),
                      Text(
                        data.subtitle,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: isTablet ? 14 : 13,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(isTablet ? 10 : 8),
                  decoration: BoxDecoration(
                    color: data.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: data.color,
                    size: isTablet ? 18 : 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HealthCheckData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _HealthCheckData(this.title, this.subtitle, this.icon, this.color, this.onTap);
}