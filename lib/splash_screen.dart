import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _particleController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _gradientController;

  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;
  late Animation<double> _logoRotation;
  late Animation<double> _logoPulse;
  late Animation<double> _particleAnimation;
  late Animation<double> _gradientAnimation;
  late Animation<Color?> _glowColor;

  final List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 8000),
      vsync: this,
    );

    _gradientController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Create enhanced animations
    _logoAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _textAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    _logoRotation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    _logoPulse = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _particleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.linear),
    );

    _gradientAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _gradientController, curve: Curves.easeInOut),
    );

    _glowColor = ColorTween(
      begin: Colors.teal.withOpacity(0.3),
      end: Colors.cyan.withOpacity(0.8),
    ).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Generate particles
    _generateParticles();

    // Start animations
    _startAnimations();

    // Navigate after 3 seconds (keeping your original logic)
    _navigateToNext();
  }

  void _generateParticles() {
    final random = math.Random();
    for (int i = 0; i < 40; i++) {
      _particles.add(Particle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 3 + 1,
        speed: random.nextDouble() * 0.02 + 0.005,
        opacity: random.nextDouble() * 0.7 + 0.3,
      ));
    }
  }

  void _startAnimations() {
    _logoController.forward();
    _gradientController.forward();
    _rotationController.repeat();
    _pulseController.repeat(reverse: true);
    _particleController.repeat();

    Future.delayed(const Duration(milliseconds: 500), () {
      _textController.forward();
    });
  }

  _navigateToNext() async {
    // Wait for 3 seconds to show the splash screen (keeping your original timing)
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // Check if user is already logged in (keeping your original logic)
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Navigate to home screen
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      // Navigate to login screen
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _particleController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    _gradientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _logoAnimation,
          _textAnimation,
          _particleAnimation,
          _gradientAnimation,
          _logoPulse,
          _logoRotation,
          _glowColor,
        ]),
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(Colors.teal.shade400, Colors.blue.shade400, _gradientAnimation.value)!,
                  Color.lerp(Colors.teal.shade700, Colors.indigo.shade600, _gradientAnimation.value)!,
                  Color.lerp(Colors.teal.shade900, Colors.indigo.shade900, _gradientAnimation.value)!,
                ],
              ),
            ),
            child: Stack(
              children: [
                // Animated Particles Background
                ...List.generate(_particles.length, (index) {
                  final particle = _particles[index];
                  return AnimatedBuilder(
                    animation: _particleAnimation,
                    builder: (context, child) {
                      final progress = (_particleAnimation.value + particle.speed * index) % 1.0;
                      return Positioned(
                        left: MediaQuery.of(context).size.width * particle.x,
                        top: MediaQuery.of(context).size.height * ((particle.y + progress) % 1.0),
                        child: Container(
                          width: particle.size,
                          height: particle.size,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(particle.opacity * 0.4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.cyan.withOpacity(0.3),
                                blurRadius: particle.size * 1.5,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),

                // Main Content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Enhanced Animated Logo Container
                      FadeTransition(
                        opacity: _logoAnimation,
                        child: ScaleTransition(
                          scale: _logoAnimation,
                          child: Transform.scale(
                            scale: _logoPulse.value,
                            child: Transform.rotate(
                              angle: _logoRotation.value * 0.1,
                              child: Container(
                                width: 150,
                                height: 150,
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(
                                    colors: [
                                      Colors.white,
                                      Colors.white.withOpacity(0.9),
                                      Colors.cyan.withOpacity(0.1),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: _glowColor.value ?? Colors.teal.withOpacity(0.3),
                                      blurRadius: 30,
                                      spreadRadius: 5,
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    // Rotating border ring
                                    Positioned.fill(
                                      child: Transform.rotate(
                                        angle: _logoRotation.value,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.cyan.withOpacity(0.6),
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Logo content
                                    ClipOval(
                                      child: FittedBox(
                                        fit: BoxFit.contain,
                                        child: Image.asset(
                                          'assets/logo.png',
                                          errorBuilder: (context, error, stackTrace) {
                                            return Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Icon(
                                                  Icons.medical_services,
                                                  size: 80,
                                                  color: Colors.teal.shade600,
                                                ),
                                                Transform.scale(
                                                  scale: 0.5,
                                                  child: Icon(
                                                    Icons.favorite,
                                                    size: 40,
                                                    color: Colors.red.withOpacity(0.8),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Enhanced Animated App Name
                      FadeTransition(
                        opacity: _textAnimation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.5),
                            end: Offset.zero,
                          ).animate(_textAnimation),
                          child: ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [
                                Colors.white,
                                Colors.cyan.shade200,
                                Colors.white,
                              ],
                            ).createShader(bounds),
                            child: const Text(
                              'MediCare+',
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.5,
                                shadows: [
                                  Shadow(
                                    color: Colors.cyan,
                                    blurRadius: 15,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Enhanced Animated Welcome Text
                      FadeTransition(
                        opacity: _textAnimation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.5),
                            end: Offset.zero,
                          ).animate(_textAnimation),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.1),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: const Text(
                              'Welcome to MediCare+',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Enhanced Animated Tagline
                      FadeTransition(
                        opacity: _textAnimation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.5),
                            end: Offset.zero,
                          ).animate(_textAnimation),
                          child: const Text(
                            'Your Smart Healthcare Assistant',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 60),

                      // Loading Animation
                      FadeTransition(
                        opacity: _textAnimation,
                        child: Column(
                          children: [
                            Container(
                              width: 200,
                              height: 3,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white.withOpacity(0.2),
                              ),
                              child: AnimatedBuilder(
                                animation: _gradientController,
                                builder: (context, child) {
                                  return LinearProgressIndicator(
                                    value: _gradientAnimation.value,
                                    backgroundColor: Colors.transparent,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.cyan.withOpacity(0.8),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              "Loading Healthcare Services...",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.7),
                                fontWeight: FontWeight.w300,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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