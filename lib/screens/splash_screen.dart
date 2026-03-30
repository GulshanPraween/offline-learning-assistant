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

    _floatAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _bookController, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(begin: -0.03, end: 0.03).animate(
      CurvedAnimation(parent: _bookController, curve: Curves.easeInOut),
    );

    _bookOpenAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _bookController, curve: Curves.easeInOut),
    );

    _buttonPulseAnimation = Tween<double>(begin: 0.9, end: 1.2).animate(
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
              colors: const [
                Color(0xFF2C1A4D),
                Color(0xFF4A2B6E),
                Color(0xFF6B3F8C),
                Color(0xFF8A5DB0),
              ],
              stops: [0.1, 0.4, 0.7, 0.9],
            ),
          ),
          child: Stack(
            children: [
              // Background sparkles
              ...List.generate(40, (index) {
                final randomX = (index * 13) % 100 / 100;
                final randomY = (index * 17) % 100 / 100;
                final randomDelay = index * 0.1;
                final randomSize = 10 + (index % 15);
                final randomOpacity = 0.2 + (index % 6) * 0.1;
                
                final List<IconData> sparkleIcons = const [
                  Icons.star,
                  Icons.star_border,
                  Icons.auto_awesome,
                  Icons.wb_sunny,
                ];
                
                final List<Color> sparkleColors = const [
                  Colors.yellow,
                  Colors.amber,
                  Colors.orange,
                  Colors.pink,
                  Colors.cyan,
                  Colors.white,
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

              // Main Content
              Center(
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // SMART LEARNING TEXT
                        SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: const [
                                    Colors.yellow,
                                    Colors.white,
                                    Colors.amber,
                                  ],
                                ).createShader(bounds),
                                child: Text(
                                  'SMART',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 40 : 48,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 6,
                                    shadows: const [
                                      Shadow(
                                        color: Colors.purple,
                                        blurRadius: 25,
                                        offset: Offset(3, 3),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Text(
                                'LEARNING',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 44 : 52,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 5,
                                  shadows: const [
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
                        
                        SizedBox(height: isSmallScreen ? 25 : 35),
                        
                        // Book with Sparkles - BADA KAR DIYA
                        SizedBox(
                          height: isSmallScreen ? 200 : 280,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Book Sparkles - DISTANCE BADHA DIYA
                              ...List.generate(8, (index) {
                                final angle = (index * 45 * pi / 180) + (_sparkleController1.value * 2 * pi);
                                final distance = isSmallScreen ? 80 : 120;  // 🔥 PEHLE 50/70 THA, AB 80/120
                                final x = cos(angle) * distance;
                                final y = sin(angle) * distance;
                                
                                return AnimatedBuilder(
                                  animation: _sparkleController1,
                                  builder: (context, child) {
                                    return Positioned(
                                      left: (isSmallScreen ? 100 : 140) + x,
                                      top: (isSmallScreen ? 100 : 140) + y,
                                      child: Opacity(
                                        opacity: 0.5 + (sin(_sparkleController1.value * 2 * pi + index) * 0.3),
                                        child: Transform.scale(
                                          scale: 0.8 + (sin(_sparkleController2.value * 2 * pi + index) * 0.2),
                                          child: Icon(
                                            Icons.auto_awesome,
                                            color: Colors.yellow,
                                            size: isSmallScreen ? 16 : 20,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }),
                              
                              // Main Book - CIRCLE BADA KAR DIYA
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
                                            width: isSmallScreen ? 200 : 280,     // 🔥 PEHLE 140/180 THA, AB 200/280
                                            height: isSmallScreen ? 200 : 280,    // 🔥 PEHLE 140/180 THA, AB 200/280
                                            decoration: BoxDecoration(
                                              gradient: RadialGradient(
                                                colors: [
                                                  Colors.purple.shade300,
                                                  Colors.purple.shade500,
                                                  Colors.purple.shade700,
                                                ],
                                              ),
                                              shape: BoxShape.circle,
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Colors.purple,
                                                  blurRadius: 40,
                                                  spreadRadius: 8,
                                                ),
                                                BoxShadow(
                                                  color: Colors.amber,
                                                  blurRadius: 50,
                                                  spreadRadius: 10,
                                                ),
                                              ],
                                            ),
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                // Left Page - BADA KAR DIYA
                                                Transform.translate(
                                                  offset: Offset(-15 * _bookOpenAnimation.value, 0),
                                                  child: Container(
                                                    width: isSmallScreen ? 90 : 130,     // 🔥 PEHLE 60/80 THA, AB 90/130
                                                    height: isSmallScreen ? 110 : 160,   // 🔥 PEHLE 75/100 THA, AB 110/160
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: const BorderRadius.only(
                                                        topLeft: Radius.circular(15),
                                                        bottomLeft: Radius.circular(15),
                                                        topRight: Radius.circular(5),
                                                        bottomRight: Radius.circular(5),
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
                                                        Positioned(
                                                          left: 8,
                                                          top: 15,
                                                          child: Container(
                                                            width: 30,
                                                            height: 3,
                                                            color: Colors.purple.withOpacity(0.3),
                                                          ),
                                                        ),
                                                        Positioned(
                                                          left: 8,
                                                          top: 35,
                                                          child: Container(
                                                            width: 25,
                                                            height: 3,
                                                            color: Colors.purple.withOpacity(0.3),
                                                          ),
                                                        ),
                                                        Positioned(
                                                          left: 8,
                                                          top: 55,
                                                          child: Container(
                                                            width: 20,
                                                            height: 3,
                                                            color: Colors.purple.withOpacity(0.3),
                                                          ),
                                                        ),
                                                        Positioned(
                                                          left: 8,
                                                          top: 75,
                                                          child: Container(
                                                            width: 15,
                                                            height: 3,
                                                            color: Colors.purple.withOpacity(0.3),
                                                          ),
                                                        ),
                                                        Positioned(
                                                          left: 8,
                                                          top: 95,
                                                          child: Container(
                                                            width: 10,
                                                            height: 3,
                                                            color: Colors.purple.withOpacity(0.3),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                
                                                // Right Page - BADA KAR DIYA
                                                Transform.translate(
                                                  offset: Offset(15 * _bookOpenAnimation.value, 0),
                                                  child: Container(
                                                    width: isSmallScreen ? 90 : 130,     // 🔥 PEHLE 60/80 THA, AB 90/130
                                                    height: isSmallScreen ? 110 : 160,   // 🔥 PEHLE 75/100 THA, AB 110/160
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: const BorderRadius.only(
                                                        topRight: Radius.circular(15),
                                                        bottomRight: Radius.circular(15),
                                                        topLeft: Radius.circular(5),
                                                        bottomLeft: Radius.circular(5),
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
                                                        Positioned(
                                                          right: 8,
                                                          top: 15,
                                                          child: Container(
                                                            width: 30,
                                                            height: 3,
                                                            color: Colors.purple.withOpacity(0.3),
                                                          ),
                                                        ),
                                                        Positioned(
                                                          right: 8,
                                                          top: 35,
                                                          child: Container(
                                                            width: 25,
                                                            height: 3,
                                                            color: Colors.purple.withOpacity(0.3),
                                                          ),
                                                        ),
                                                        Positioned(
                                                          right: 8,
                                                          top: 55,
                                                          child: Container(
                                                            width: 20,
                                                            height: 3,
                                                            color: Colors.purple.withOpacity(0.3),
                                                          ),
                                                        ),
                                                        Positioned(
                                                          right: 8,
                                                          top: 75,
                                                          child: Container(
                                                            width: 15,
                                                            height: 3,
                                                            color: Colors.purple.withOpacity(0.3),
                                                          ),
                                                        ),
                                                        Positioned(
                                                          right: 8,
                                                          top: 95,
                                                          child: Container(
                                                            width: 10,
                                                            height: 3,
                                                            color: Colors.purple.withOpacity(0.3),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                
                                                // Book Spine
                                                Container(
                                                  width: isSmallScreen ? 12 : 15,
                                                  height: isSmallScreen ? 110 : 160,
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        Colors.purple.shade800,
                                                        Colors.purple.shade900,
                                                      ],
                                                    ),
                                                    borderRadius: BorderRadius.circular(3),
                                                  ),
                                                ),
                                                
                                                // Bookmark
                                                Positioned(
                                                  top: -5,
                                                  child: Container(
                                                    width: 6,
                                                    height: 22,
                                                    decoration: BoxDecoration(
                                                      gradient: const LinearGradient(
                                                        colors: [
                                                          Colors.amber,
                                                          Colors.orange,
                                                        ],
                                                      ),
                                                      borderRadius: BorderRadius.circular(3),
                                                      boxShadow: const [
                                                        BoxShadow(
                                                          color: Colors.amber,
                                                          blurRadius: 10,
                                                        ),
                                                      ],
                                                    ),
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
                            ],
                          ),
                        ),
                        
                        SizedBox(height: isSmallScreen ? 30 : 40),
                        
                        // BUTTON - SAME VISIBILITY, THODA BADA
                        AnimatedBuilder(
                          animation: _buttonPulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _buttonPulseAnimation.value,
                              child: GestureDetector(
                                onTap: goToNextPage,
                                child: Container(
                                  width: isSmallScreen ? 75 : 90,     // 🔥 PEHLE 70/85 THA, AB 75/90
                                  height: isSmallScreen ? 75 : 90,    // 🔥 PEHLE 70/85 THA, AB 75/90
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
                                        blurRadius: isSmallScreen ? 25 : 35,
                                        spreadRadius: isSmallScreen ? 4 : 6,
                                      ),
                                      BoxShadow(
                                        color: Colors.amber.withOpacity(0.6),
                                        blurRadius: isSmallScreen ? 35 : 45,
                                        spreadRadius: isSmallScreen ? 6 : 9,
                                      ),
                                    ],
                                    border: Border.all(
                                      color: Colors.white,
                                      width: isSmallScreen ? 2 : 3,
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
                        
                        SizedBox(height: isSmallScreen ? 20 : 25),
                        
                        // Tap Text
                        Text(
                          '✨ tap to begin ✨',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            color: Colors.yellow.withOpacity(0.9),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                            shadows: const [
                              Shadow(
                                color: Colors.purple,
                                blurRadius: 15,
                              ),
                            ],
                          ),
                        ),
                        
                        // Extra bottom padding
                        SizedBox(height: isSmallScreen ? 25 : 30),
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