import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';
import 'models.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _medicalHistoryController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _registrationError;
  String _selectedGender = 'Not specified';

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  final List<String> _genders = ['Not specified', 'Male', 'Female', 'Other'];
  final List<Particle> _particles = [];

  late AnimationController _animationController;
  late AnimationController _particleController;
  late AnimationController _glowController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _particleAnimation;
  late Animation<Color?> _glowColor;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _slideAnimation = Tween<double>(begin: 80.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _particleController,
        curve: Curves.linear,
      ),
    );

    _glowColor = ColorTween(
      begin: const Color(0xFF4CAF50),
      end: const Color(0xFF2196F3),
    ).animate(
      CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOut,
      ),
    );

    _generateParticles();
    _animationController.forward();
    _particleController.repeat();
    _glowController.repeat(reverse: true);
  }

  void _generateParticles() {
    final random = math.Random();
    for (int i = 0; i < 15; i++) {
      _particles.add(Particle(
        x: random.nextDouble(),
        y: random.nextDouble() + 1,
        size: random.nextDouble() * 4 + 2,
        speed: random.nextDouble() * 0.015 + 0.005,
        opacity: random.nextDouble() * 0.5 + 0.3,
      ));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _medicalHistoryController.dispose();
    _allergiesController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _animationController.dispose();
    _particleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _nameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _medicalHistoryController.clear();
    _allergiesController.clear();
  }

  Future<void> _register() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _registrationError = null;
      _isLoading = true;
    });

    try {
      // Split the comma-separated allergies string into a list (keeping your original logic)
      final List<String> allergiesList = _allergiesController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final profile = UserProfile(
        name: _nameController.text.trim(),
        age: 0, // Age will be added in profile screen
        gender: _selectedGender, // Pass the selected gender
        medicalHistory: _medicalHistoryController.text.trim(), // Pass the medical history
        allergies: allergiesList, // Pass the allergies list
      );

      await _authService.registerWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        profile,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _clearForm();

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Registration Successful! Please login with your new account."),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);

    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        String errorMessage;
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = "This email is already registered. Please login.";
            break;
          case 'weak-password':
            errorMessage = "The password provided is too weak.";
            break;
          case 'invalid-email':
            errorMessage = "The email address is not valid.";
            break;
          default:
            errorMessage = "Registration failed: ${e.message}";
        }
        _registrationError = errorMessage;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _registrationError = "An unexpected error occurred: ${e.toString()}";
      });
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 16),
      prefixIcon: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade400, Colors.teal.shade600],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.9),
      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      floatingLabelBehavior: FloatingLabelBehavior.never,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: Colors.green.shade400, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: Colors.red.shade400, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: Colors.red.shade600, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_fadeAnimation, _slideAnimation, _particleAnimation, _glowColor]),
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topRight,
                radius: 1.5,
                colors: [
                  const Color(0xFF2E7D32),
                  const Color(0xFF388E3C),
                  const Color(0xFF1B5E20),
                  const Color(0xFF0D47A1),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Floating particles
                ...List.generate(_particles.length, (index) {
                  final particle = _particles[index];
                  return AnimatedBuilder(
                    animation: _particleAnimation,
                    builder: (context, child) {
                      final progress = (_particleAnimation.value + particle.speed * index) % 1.0;
                      final yPos = ((particle.y - progress) % 1.2);

                      if (yPos > 1.0) return const SizedBox.shrink();

                      return Positioned(
                        left: MediaQuery.of(context).size.width *
                            (particle.x + math.sin(progress * math.pi * 2) * 0.05),
                        top: MediaQuery.of(context).size.height * yPos,
                        child: Container(
                          width: particle.size,
                          height: particle.size,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(particle.opacity),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.3),
                                blurRadius: particle.size * 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),

                // Main content
                SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                      child: Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 400),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withOpacity(0.95),
                                    Colors.green.shade50.withOpacity(0.9),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 25,
                                    offset: const Offset(0, 15),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      // Enhanced logo with glow
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          gradient: RadialGradient(
                                            colors: [
                                              Colors.white,
                                              Colors.green.shade50,
                                            ],
                                          ),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: _glowColor.value?.withOpacity(0.6) ?? Colors.green.withOpacity(0.6),
                                              blurRadius: 25,
                                              spreadRadius: 5,
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.person_add_rounded,
                                          size: 40,
                                          color: Colors.green.shade700,
                                        ),
                                      ),
                                      const SizedBox(height: 24),

                                      // Title with gradient
                                      ShaderMask(
                                        shaderCallback: (bounds) => LinearGradient(
                                          colors: [
                                            Colors.green.shade700,
                                            Colors.teal.shade600,
                                          ],
                                        ).createShader(bounds),
                                        child: const Text(
                                          "Join MediCare+",
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Create your healthcare account",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey.shade600,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 32),

                                      // Full Name field
                                      TextFormField(
                                        controller: _nameController,
                                        focusNode: _nameFocusNode,
                                        decoration: _inputDecoration("Full Name", Icons.person_outline_rounded),
                                        style: const TextStyle(fontSize: 16),
                                        validator: (val) => val!.trim().isEmpty ? "Please enter your name" : null,
                                        textInputAction: TextInputAction.next,
                                        onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_emailFocusNode),
                                      ),
                                      const SizedBox(height: 20),

                                      // Email field
                                      TextFormField(
                                        controller: _emailController,
                                        focusNode: _emailFocusNode,
                                        decoration: _inputDecoration("Email Address", Icons.email_rounded),
                                        keyboardType: TextInputType.emailAddress,
                                        style: const TextStyle(fontSize: 16),
                                        validator: (val) {
                                          if (val!.trim().isEmpty) return "Please enter your email";
                                          if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+").hasMatch(val)) {
                                            return "Please enter a valid email";
                                          }
                                          return null;
                                        },
                                        textInputAction: TextInputAction.next,
                                        onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocusNode),
                                      ),
                                      const SizedBox(height: 20),

                                      // Password field
                                      TextFormField(
                                        controller: _passwordController,
                                        focusNode: _passwordFocusNode,
                                        decoration: _inputDecoration(
                                          "Password",
                                          Icons.lock_outline_rounded,
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscurePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                              color: Colors.green.shade600,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _obscurePassword = !_obscurePassword;
                                              });
                                            },
                                          ),
                                        ),
                                        obscureText: _obscurePassword,
                                        style: const TextStyle(fontSize: 16),
                                        validator: (val) => val!.length < 6 ? "Password must be at least 6 characters" : null,
                                        textInputAction: TextInputAction.next,
                                        onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_confirmPasswordFocusNode),
                                      ),
                                      const SizedBox(height: 20),

                                      // Confirm Password field
                                      TextFormField(
                                        controller: _confirmPasswordController,
                                        focusNode: _confirmPasswordFocusNode,
                                        decoration: _inputDecoration(
                                          "Confirm Password",
                                          Icons.lock_person_rounded,
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscureConfirmPassword ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                              color: Colors.green.shade600,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _obscureConfirmPassword = !_obscureConfirmPassword;
                                              });
                                            },
                                          ),
                                        ),
                                        obscureText: _obscureConfirmPassword,
                                        style: const TextStyle(fontSize: 16),
                                        validator: (val) {
                                          if (val!.isEmpty) return "Please confirm your password";
                                          if (val != _passwordController.text) return "Passwords do not match";
                                          return null;
                                        },
                                        textInputAction: TextInputAction.done,
                                        onFieldSubmitted: (_) => _isLoading ? null : _register(),
                                      ),
                                      const SizedBox(height: 20),

                                      // Gender dropdown
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          color: Colors.white.withOpacity(0.9),
                                        ),
                                        child: DropdownButtonFormField<String>(
                                          value: _selectedGender,
                                          decoration: _inputDecoration("Gender", Icons.wc_rounded),
                                          style: const TextStyle(fontSize: 16, color: Colors.black87),
                                          items: _genders.map((String gender) {
                                            return DropdownMenuItem<String>(
                                              value: gender,
                                              child: Text(gender),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              _selectedGender = newValue!;
                                            });
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 20),

                                      // Medical History field
                                      TextFormField(
                                        controller: _medicalHistoryController,
                                        maxLines: 3,
                                        style: const TextStyle(fontSize: 16),
                                        decoration: _inputDecoration("Medical History (Optional)", Icons.medical_information_rounded),
                                      ),
                                      const SizedBox(height: 20),

                                      // Allergies field
                                      TextFormField(
                                        controller: _allergiesController,
                                        decoration: _inputDecoration("Allergies (comma-separated, Optional)", Icons.warning_rounded),
                                        maxLines: 2,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      const SizedBox(height: 24),

                                      // Error message
                                      if (_registrationError != null)
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 20.0),
                                          child: Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.red.shade50,
                                                  Colors.red.shade100,
                                                ],
                                              ),
                                              borderRadius: BorderRadius.circular(16),
                                              border: Border.all(color: Colors.red.shade200),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(Icons.error_rounded, color: Colors.red.shade700),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    _registrationError!,
                                                    style: TextStyle(
                                                      color: Colors.red.shade700,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                      // Register button
                                      Container(
                                        height: 56,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.green.shade500,
                                              Colors.teal.shade600,
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.green.withOpacity(0.4),
                                              blurRadius: 15,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                          ),
                                          onPressed: _isLoading ? null : _register,
                                          child: _isLoading
                                              ? Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              const Text(
                                                "Creating Account...",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          )
                                              : const Text(
                                            "Create Account",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),

                                      // Login link
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: Colors.grey.shade200),
                                          color: Colors.grey.shade50,
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Text(
                                              "Already have an account?",
                                              style: TextStyle(fontSize: 15),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                if (!_isLoading) {
                                                  Navigator.pushReplacementNamed(context, '/login');
                                                }
                                              },
                                              child: Text(
                                                "Login Now",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green.shade700,
                                                  fontSize: 15.5,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class Particle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}