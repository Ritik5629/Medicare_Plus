import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String _errorMessage = "";

  late AnimationController _animationController;
  late AnimationController _particleController;
  late AnimationController _glowController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _particleAnimation;
  late Animation<Color?> _glowColor;

  final List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
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
      begin: const Color(0xFF00E5FF),
      end: const Color(0xFF7C4DFF),
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
    for (int i = 0; i < 20; i++) {
      _particles.add(Particle(
        x: random.nextDouble(),
        y: random.nextDouble() + 1,
        size: random.nextDouble() * 3 + 1,
        speed: random.nextDouble() * 0.02 + 0.005,
        opacity: random.nextDouble() * 0.6 + 0.2,
      ));
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _particleController.dispose();
    _glowController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    // Hide keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    try {
      // Sign in the user (keeping your original logic)
      final User? user = await AuthService().signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      // Check if user is not null (keeping your original logic)
      if (user != null) {
        // Wait for authentication state to stabilize
        await Future.delayed(const Duration(seconds: 1));

        // Double-check that user is still authenticated
        if (FirebaseAuth.instance.currentUser != null) {
          // Clear any existing routes and navigate to home
          if (mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
          }
        } else {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _errorMessage = "Authentication failed. Please try again.";
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = "Login failed. Please check your credentials.";
          });
        }
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        if (e.code == 'user-not-found') {
          _errorMessage = "No user found with this email. Please register first.";
        } else if (e.code == 'wrong-password') {
          _errorMessage = "Incorrect password. Please try again.";
        } else if (e.code == 'invalid-email') {
          _errorMessage = "Invalid email address.";
        } else if (e.code == 'user-disabled') {
          _errorMessage = "This account has been disabled.";
        } else {
          _errorMessage = e.message ?? "An unexpected error occurred.";
        }
      });
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = "An error occurred: ${e.toString().replaceAll("Exception: ", "")}";
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
            colors: [Colors.cyan.shade400, Colors.blue.shade600],
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
        borderSide: BorderSide(color: Colors.cyan.shade400, width: 2),
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
                center: Alignment.topLeft,
                radius: 1.5,
                colors: [
                  const Color(0xFF1E3C72),
                  const Color(0xFF2A5298),
                  const Color(0xFF0F4C75),
                  const Color(0xFF16213E),
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
                        left: MediaQuery.of(context).size.width * particle.x,
                        top: MediaQuery.of(context).size.height * yPos,
                        child: Container(
                          width: particle.size,
                          height: particle.size,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(particle.opacity),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.cyan.withOpacity(0.3),
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
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Transform.translate(
                      offset: Offset(0, _slideAnimation.value),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: Card(
                            elevation: 25,
                            shadowColor: Colors.black.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            color: Colors.white.withOpacity(0.95),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withOpacity(0.9),
                                    Colors.blue.shade50.withOpacity(0.8),
                                  ],
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Enhanced logo with glow effect
                                      Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          gradient: RadialGradient(
                                            colors: [
                                              Colors.white,
                                              Colors.cyan.shade50,
                                            ],
                                          ),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: _glowColor.value?.withOpacity(0.6) ?? Colors.cyan.withOpacity(0.6),
                                              blurRadius: 30,
                                              spreadRadius: 5,
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.medical_services_rounded,
                                          size: 50,
                                          color: Colors.cyan.shade700,
                                        ),
                                      ),
                                      const SizedBox(height: 32),

                                      // Welcome text with gradient
                                      ShaderMask(
                                        shaderCallback: (bounds) => LinearGradient(
                                          colors: [
                                            Colors.cyan.shade700,
                                            Colors.blue.shade800,
                                          ],
                                        ).createShader(bounds),
                                        child: const Text(
                                          "Welcome Back",
                                          style: TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Sign in to continue to MediCare+",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      const SizedBox(height: 40),

                                      // Enhanced email field
                                      TextFormField(
                                        controller: _emailController,
                                        decoration: _inputDecoration("Email Address", Icons.email_rounded),
                                        keyboardType: TextInputType.emailAddress,
                                        style: const TextStyle(fontSize: 16),
                                        validator: (value) {
                                          if (value!.isEmpty) return "Enter your email";
                                          if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+").hasMatch(value)) {
                                            return "Please enter a valid email";
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 24),

                                      // Enhanced password field
                                      TextFormField(
                                        controller: _passwordController,
                                        obscureText: _obscurePassword,
                                        style: const TextStyle(fontSize: 16),
                                        decoration: _inputDecoration(
                                          "Password",
                                          Icons.lock_rounded,
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscurePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                              color: Colors.cyan.shade600,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _obscurePassword = !_obscurePassword;
                                              });
                                            },
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value!.isEmpty) return "Enter your password";
                                          if (value.length < 6) return "Password must be at least 6 characters";
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 16),

                                      // Forgot password
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton(
                                          onPressed: () {
                                            // Optional: implement reset later
                                          },
                                          child: Text(
                                            "Forgot Password?",
                                            style: TextStyle(
                                              color: Colors.cyan.shade700,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Error message
                                      if (_errorMessage.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 20),
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
                                                Icon(
                                                  Icons.error_rounded,
                                                  color: Colors.red.shade600,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    _errorMessage,
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
                                      const SizedBox(height: 16),

                                      // Enhanced login button
                                      Container(
                                        width: double.infinity,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.cyan.shade500,
                                              Colors.blue.shade600,
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.cyan.withOpacity(0.4),
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
                                          onPressed: _isLoading ? null : _signIn,
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
                                                "Signing In...",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          )
                                              : const Text(
                                            "Sign In",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 32),

                                      // Registration link
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
                                            Text(
                                              "Don't have an account?",
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 15,
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => const RegisterScreen(),
                                                  ),
                                                );
                                              },
                                              child: Text(
                                                "Register Now",
                                                style: TextStyle(
                                                  color: Colors.cyan.shade700,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
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