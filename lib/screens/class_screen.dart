import 'dart:ui';
import 'package:flutter/material.dart';

class ClassScreen extends StatefulWidget {
  const ClassScreen({super.key});

  @override
  State<ClassScreen> createState() => _ClassScreenState();
}

class _ClassScreenState extends State<ClassScreen> with TickerProviderStateMixin {
  String? selectedClass;
  String? selectedSubject;
  
  late AnimationController _buttonController;
  late Animation<double> _buttonAnimation;

  final List<String> classes = [
    "Class 6",
    "Class 7", 
    "Class 8",
    "Class 9",
    "Class 10",
    "Class 11",
    "Class 12",
  ];

  final List<String> subjects = [
    "Mathematics",
    "Science",
    "English",
    "Social Studies",
    "Physics",
    "Chemistry",
    "Biology",
    "Computer Science",
  ];

  @override
  void initState() {
    super.initState();
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _buttonAnimation = Tween<double>(begin: 1, end: 1.1).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _buttonController.dispose();
    super.dispose();
  }

  void goToChat() {
    if (selectedClass != null && selectedSubject != null) {
      _buttonController.forward().then((_) {
        _buttonController.reverse();
        Navigator.pushNamed(
          context,
          '/chat',
          arguments: {
            "class": selectedClass,
            "subject": selectedSubject,
          },
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please select class and subject"),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.red.shade400,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0A1929), // Navy Blue
              const Color(0xFF1A2A3A), // Lighter Navy
              const Color(0xFF0A1929), // Navy Blue
            ],
          ),
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFB74D).withOpacity(0.1), // Gold with opacity
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.03),
                ),
              ),
            ),
            
            // Main Content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isSmallScreen ? 20 : 40),
                  child: Container(
                    width: isSmallScreen ? double.infinity : 600,
                    padding: EdgeInsets.all(isSmallScreen ? 20 : 40),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: const Color(0xFFFFB74D).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Header Section
                        TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 800),
                          builder: (context, double value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: Column(
                                  children: [
                                    // Logo
                                    Container(
                                      padding: const EdgeInsets.all(15),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFB74D).withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.school_rounded,
                                        size: 50,
                                        color: Color(0xFFFFB74D),
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    // Title
                                    const Text(
                                      "Welcome Back!",
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFFFB74D),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    // Subtitle
                                    Text(
                                      "Select your class and subject",
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 14 : 16,
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 40),

                        // Class Dropdown
                        TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 500),
                          builder: (context, double value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Label
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.class_rounded,
                                          color: const Color(0xFFFFB74D),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Select Class",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white.withOpacity(0.9),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    // Dropdown
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                          color: const Color(0xFFFFB74D).withOpacity(0.3),
                                        ),
                                      ),
                                      child: DropdownButtonFormField<String>(
                                        value: selectedClass,
                                        dropdownColor: const Color(0xFF1A2A3A),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 15,
                                          ),
                                        ),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                        icon: const Icon(
                                          Icons.arrow_drop_down_rounded,
                                          color: Color(0xFFFFB74D),
                                        ),
                                        hint: Text(
                                          "Choose your class",
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.5),
                                          ),
                                        ),
                                        items: classes.map((cls) {
                                          return DropdownMenuItem(
                                            value: cls,
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.grade_rounded,
                                                  color: const Color(0xFFFFB74D),
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 10),
                                                Text(cls),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            selectedClass = value;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 25),

                        // Subject Dropdown
                        TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 600),
                          builder: (context, double value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Label
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.subject_rounded,
                                          color: const Color(0xFFFFB74D),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Select Subject",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white.withOpacity(0.9),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    // Dropdown
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                          color: const Color(0xFFFFB74D).withOpacity(0.3),
                                        ),
                                      ),
                                      child: DropdownButtonFormField<String>(
                                        value: selectedSubject,
                                        dropdownColor: const Color(0xFF1A2A3A),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 15,
                                          ),
                                        ),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                        icon: const Icon(
                                          Icons.arrow_drop_down_rounded,
                                          color: Color(0xFFFFB74D),
                                        ),
                                        hint: Text(
                                          "Choose your subject",
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.5),
                                          ),
                                        ),
                                        items: subjects.map((sub) {
                                          return DropdownMenuItem(
                                            value: sub,
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.menu_book_rounded,
                                                  color: const Color(0xFFFFB74D),
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 10),
                                                Text(sub),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            selectedSubject = value;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 40),

                        // Start Learning Button
                        ScaleTransition(
                          scale: _buttonAnimation,
                          child: Container(
                            width: double.infinity,
                            height: isSmallScreen ? 55 : 65,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFFFB74D), // Gold
                                  Color(0xFFFFA726), // Darker Gold
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFFB74D).withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: goToChat,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Start Learning",
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 16 : 18,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF0A1929), // Navy Blue
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Color(0xFF0A1929), // Navy Blue
                                    size: 24,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Tip Text
                        Text(
                          "💡 Select both class and subject to continue",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: isSmallScreen ? 12 : 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
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