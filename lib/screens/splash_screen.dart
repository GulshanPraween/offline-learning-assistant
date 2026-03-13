import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _bookController;
  late AnimationController _buttonController;
  late AnimationController _sparkleController1;
  late AnimationController _sparkleController2;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _bookOpenAnimation;
  late Animation<double> _buttonPulseAnimation;
  
  final Random _random = Random();
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _bookController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _sparkleController1 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _sparkleController2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _floatAnimation = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _bookController, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(begin: -0.02, end: 0.02).animate(
      CurvedAnimation(parent: _bookController, curve: Curves.easeInOut),
    );

    _bookOpenAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _bookController, curve: Curves.easeInOut),
    );

    _buttonPulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _bookController.dispose();
    _buttonController.dispose();
    _sparkleController1.dispose();
    _sparkleController2.dispose();
    super.dispose();
  }

  void goToNextPage() {
    Navigator.pushReplacementNamed(context, '/class');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    
    return Scaffold(
      body: GestureDetector(
        onTap: goToNextPage,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF2C1A4D), // Dark Purple
                const Color(0xFF4A2B6E), // Medium Purple
                const Color(0xFF6B3F8C), // Light Purple
                const Color(0xFF8A5DB0), // Lavender
              ],
              stops: const [0.1, 0.4, 0.7, 0.9],
            ),
          ),
          child: Stack(
            children: [
              // ✨ SPARKLES - BIG BOLD FLOATING
              ...List.generate(40, (index) {
                final randomX = (index * 13) % 100 / 100;
                final randomY = (index * 17) % 100 / 100;
                final randomDelay = index * 0.1;
                final randomSize = 10 + (index % 15);
                final randomOpacity = 0.3 + (index % 7) * 0.1;
                
                final List<IconData> sparkleIcons = [
                  Icons.star,
                  Icons.star_border,
                  Icons.star_half,
                  Icons.auto_awesome,
                  Icons.auto_awesome_mosaic,
                  Icons.auto_awesome_motion,
                  Icons.wb_sunny,
                  Icons.circle,
                ];
                
                final List<Color> sparkleColors = [
                  Colors.yellow,
                  Colors.amber,
                  Colors.orange,
                  Colors.pink,
                  Colors.cyan,
                  Colors.lightBlue,
                  Colors.white,
                  Colors.purple.shade200,
                ];
                
                return AnimatedBuilder(
                  animation: index % 2 == 0 ? _sparkleController1 : _sparkleController2,
                  builder: (context, child) {
                    return Positioned(
                      top: size.height * randomY + (sin((_sparkleController1.value + randomDelay) * 2 * pi) * 20),
                      left: size.width * randomX + (cos((_sparkleController2.value + randomDelay) * 2 * pi) * 20),
                      child: Transform.scale(
                        scale: 0.8 + (0.5 * (index % 2 == 0 ? _sparkleController1.value : _sparkleController2.value)),
                        child: Opacity(
                          opacity: randomOpacity * (index % 2 == 0 ? _sparkleController1.value : _sparkleController2.value),
                          child: Icon(
                            sparkleIcons[index % sparkleIcons.length],
                            color: sparkleColors[index % sparkleColors.length],
                            size: randomSize.toDouble(),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),

              // ✨ FLOATING CIRCLES
              ...List.generate(15, (index) {
                final randomX = (index * 23) % 100 / 100;
                final randomY = (index * 29) % 100 / 100;
                final randomSize = 30 + (index * 10);
                
                return AnimatedBuilder(
                  animation: index % 2 == 0 ? _sparkleController1 : _sparkleController2,
                  builder: (context, child) {
                    return Positioned(
                      top: size.height * randomY + (sin((_sparkleController1.value + index) * 3) * 15),
                      left: size.width * randomX + (cos((_sparkleController2.value + index) * 3) * 15),
                      child: Container(
                        width: randomSize.toDouble(),
                        height: randomSize.toDouble(),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.03),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),

              // MAIN CONTENT
              Center(
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // SMART LEARNING TEXT - BOLD
                        SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [
                                    Colors.yellow,
                                    Colors.white,
                                    Colors.amber,
                                  ],
                                ).createShader(bounds),
                                child: const Text(
                                  'SMART',
                                  style: TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 6,
                                    shadows: [
                                      Shadow(
                                        color: Colors.purple,
                                        blurRadius: 25,
                                        offset: Offset(3, 3),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Text(
                                'LEARNING',
                                style: TextStyle(
                                  fontSize: 52,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 5,
                                  shadows: [
                                    Shadow(
                                      color: Colors.purple,
                                      blurRadius: 25,
                                      offset: Offset(3, 3),
                                    ),
                                    Shadow(
                                      color: Colors.amber,
                                      blurRadius: 15,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: isSmallScreen ? 20 : 25),
                        
                        // 📚 3D OPEN BOOK WITH VISIBLE ICONS
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: AnimatedBuilder(
                              animation: Listenable.merge([_floatAnimation, _rotateAnimation, _bookOpenAnimation]),
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(0, _floatAnimation.value),
                                  child: Transform.rotate(
                                    angle: _rotateAnimation.value,
                                    child: Container(
                                      width: isSmallScreen ? size.width * 0.45 : size.width * 0.3,
                                      height: isSmallScreen ? size.width * 0.45 : size.width * 0.3,
                                      decoration: BoxDecoration(
                                        gradient: RadialGradient(
                                          colors: [
                                            Colors.purple.shade300,
                                            Colors.purple.shade500,
                                            Colors.purple.shade700,
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.purple.withOpacity(0.5),
                                            blurRadius: 30,
                                            spreadRadius: 5,
                                          ),
                                          BoxShadow(
                                            color: Colors.amber.withOpacity(0.3),
                                            blurRadius: 40,
                                            spreadRadius: 8,
                                          ),
                                        ],
                                      ),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          // Left page
                                          Transform.translate(
                                            offset: Offset(-18 * _bookOpenAnimation.value, 0),
                                            child: Container(
                                              width: isSmallScreen ? size.width * 0.2 : size.width * 0.14,
                                              height: isSmallScreen ? size.width * 0.26 : size.width * 0.18,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: const BorderRadius.only(
                                                  topLeft: Radius.circular(15),
                                                  bottomLeft: Radius.circular(15),
                                                  topRight: Radius.circular(8),
                                                  bottomRight: Radius.circular(8),
                                                ),
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Colors.black26,
                                                    blurRadius: 8,
                                                    offset: Offset(3, 3),
                                                  ),
                                                ],
                                              ),
                                              child: Stack(
                                                children: [
                                                  // Page lines
                                                  Positioned(
                                                    left: 10,
                                                    top: 12,
                                                    child: Container(
                                                      width: 30,
                                                      height: 4,
                                                      color: Colors.purple.withOpacity(0.4),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    left: 10,
                                                    top: 28,
                                                    child: Container(
                                                      width: 25,
                                                      height: 4,
                                                      color: Colors.purple.withOpacity(0.4),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    left: 10,
                                                    top: 44,
                                                    child: Container(
                                                      width: 20,
                                                      height: 4,
                                                      color: Colors.purple.withOpacity(0.4),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    left: 10,
                                                    top: 60,
                                                    child: Container(
                                                      width: 15,
                                                      height: 4,
                                                      color: Colors.purple.withOpacity(0.4),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    left: 10,
                                                    top: 76,
                                                    child: Container(
                                                      width: 10,
                                                      height: 4,
                                                      color: Colors.purple.withOpacity(0.4),
                                                    ),
                                                  ),
                                                  
                                                  // MATH SYMBOLS - BIG VISIBLE
                                                  Positioned(
                                                    right: 5,
                                                    top: 5,
                                                    child: Text('+', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple.shade700)),
                                                  ),
                                                  Positioned(
                                                    left: 25,
                                                    top: 15,
                                                    child: Text('−', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple.shade700)),
                                                  ),
                                                  Positioned(
                                                    right: 15,
                                                    top: 30,
                                                    child: Text('×', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple.shade700)),
                                                  ),
                                                  Positioned(
                                                    left: 30,
                                                    top: 40,
                                                    child: Text('÷', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple.shade700)),
                                                  ),
                                                  Positioned(
                                                    right: 25,
                                                    top: 55,
                                                    child: Text('=', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple.shade700)),
                                                  ),
                                                  Positioned(
                                                    left: 15,
                                                    top: 65,
                                                    child: Text('π', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple.shade700)),
                                                  ),
                                                  Positioned(
                                                    right: 8,
                                                    top: 80,
                                                    child: Text('√', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple.shade700)),
                                                  ),
                                                  Positioned(
                                                    left: 35,
                                                    top: 90,
                                                    child: Text('∞', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple.shade700)),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          
                                          // Right page
                                          Transform.translate(
                                            offset: Offset(18 * _bookOpenAnimation.value, 0),
                                            child: Container(
                                              width: isSmallScreen ? size.width * 0.2 : size.width * 0.14,
                                              height: isSmallScreen ? size.width * 0.26 : size.width * 0.18,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: const BorderRadius.only(
                                                  topRight: Radius.circular(15),
                                                  bottomRight: Radius.circular(15),
                                                  topLeft: Radius.circular(8),
                                                  bottomLeft: Radius.circular(8),
                                                ),
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Colors.black26,
                                                    blurRadius: 8,
                                                    offset: Offset(-3, 3),
                                                  ),
                                                ],
                                              ),
                                              child: Stack(
                                                children: [
                                                  // Page lines
                                                  Positioned(
                                                    right: 10,
                                                    top: 12,
                                                    child: Container(
                                                      width: 30,
                                                      height: 4,
                                                      color: Colors.purple.withOpacity(0.4),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    right: 10,
                                                    top: 28,
                                                    child: Container(
                                                      width: 25,
                                                      height: 4,
                                                      color: Colors.purple.withOpacity(0.4),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    right: 10,
                                                    top: 44,
                                                    child: Container(
                                                      width: 20,
                                                      height: 4,
                                                      color: Colors.purple.withOpacity(0.4),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    right: 10,
                                                    top: 60,
                                                    child: Container(
                                                      width: 15,
                                                      height: 4,
                                                      color: Colors.purple.withOpacity(0.4),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    right: 10,
                                                    top: 76,
                                                    child: Container(
                                                      width: 10,
                                                      height: 4,
                                                      color: Colors.purple.withOpacity(0.4),
                                                    ),
                                                  ),
                                                  
                                                  // SCIENCE SYMBOLS - BIG VISIBLE
                                                  Positioned(
                                                    left: 5,
                                                    top: 5,
                                                    child: Text('⚛️', style: TextStyle(fontSize: 18)),
                                                  ),
                                                  Positioned(
                                                    right: 25,
                                                    top: 15,
                                                    child: Text('🔬', style: TextStyle(fontSize: 18)),
                                                  ),
                                                  Positioned(
                                                    left: 20,
                                                    top: 30,
                                                    child: Text('🧪', style: TextStyle(fontSize: 18)),
                                                  ),
                                                  Positioned(
                                                    right: 15,
                                                    top: 45,
                                                    child: Text('⚡', style: TextStyle(fontSize: 18)),
                                                  ),
                                                  Positioned(
                                                    left: 30,
                                                    top: 60,
                                                    child: Text('💡', style: TextStyle(fontSize: 18)),
                                                  ),
                                                  Positioned(
                                                    right: 8,
                                                    top: 75,
                                                    child: Text('🧬', style: TextStyle(fontSize: 18)),
                                                  ),
                                                  
                                                  // ENGLISH SYMBOLS - BIG VISIBLE
                                                  Positioned(
                                                    left: 40,
                                                    top: 85,
                                                    child: Text('📖', style: TextStyle(fontSize: 18)),
                                                  ),
                                                  Positioned(
                                                    right: 30,
                                                    top: 90,
                                                    child: Text('✍️', style: TextStyle(fontSize: 18)),
                                                  ),
                                                  Positioned(
                                                    left: 10,
                                                    top: 100,
                                                    child: Text('📝', style: TextStyle(fontSize: 18)),
                                                  ),
                                                  Positioned(
                                                    right: 12,
                                                    top: 105,
                                                    child: Text('🔤', style: TextStyle(fontSize: 18)),
                                                  ),
                                                  
                                                  // SST SYMBOLS - BIG VISIBLE
                                                  Positioned(
                                                    left: 45,
                                                    top: 20,
                                                    child: Text('🌍', style: TextStyle(fontSize: 18)),
                                                  ),
                                                  Positioned(
                                                    right: 40,
                                                    top: 35,
                                                    child: Text('🗺️', style: TextStyle(fontSize: 18)),
                                                  ),
                                                  Positioned(
                                                    left: 15,
                                                    top: 50,
                                                    child: Text('🏛️', style: TextStyle(fontSize: 18)),
                                                  ),
                                                  Positioned(
                                                    right: 20,
                                                    top: 65,
                                                    child: Text('📜', style: TextStyle(fontSize: 18)),
                                                  ),
                                                  Positioned(
                                                    left: 35,
                                                    top: 75,
                                                    child: Text('👑', style: TextStyle(fontSize: 18)),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          
                                          // Book spine
                                          Container(
                                            width: isSmallScreen ? size.width * 0.04 : size.width * 0.025,
                                            height: isSmallScreen ? size.width * 0.26 : size.width * 0.18,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.purple.shade800,
                                                  Colors.purple.shade900,
                                                ],
                                              ),
                                              borderRadius: BorderRadius.circular(3),
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Colors.black26,
                                                  blurRadius: 4,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        
                        SizedBox(height: isSmallScreen ? 10 : 12), // KAM KIA
                        
                        // BUTTON - UPAR KRO
                        AnimatedBuilder(
                          animation: _buttonPulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _buttonPulseAnimation.value,
                              child: GestureDetector(
                                onTap: goToNextPage,
                                child: Container(
                                  width: isSmallScreen ? 65 : 75,
                                  height: isSmallScreen ? 65 : 75,
                                  decoration: BoxDecoration(
                                    gradient: const RadialGradient(
                                      colors: [
                                        Colors.yellow,
                                        Colors.amber,
                                        Colors.orange,
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.yellow.withOpacity(0.8),
                                        blurRadius: 30,
                                        spreadRadius: 5,
                                      ),
                                      BoxShadow(
                                        color: Colors.amber.withOpacity(0.5),
                                        blurRadius: 40,
                                        spreadRadius: 10,
                                      ),
                                    ],
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Color(0xFF2C1A4D),
                                    size: 35,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        
                        SizedBox(height: isSmallScreen ? 12 : 15), // KAM KIA
                        
                        // TAP TEXT
                        Text(
                          '✨ tap to begin ✨',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            color: Colors.yellow.withOpacity(0.9),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                            shadows: [
                              Shadow(
                                color: Colors.purple,
                                blurRadius: 15,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}