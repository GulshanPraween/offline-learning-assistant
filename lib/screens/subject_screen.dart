import 'package:flutter/material.dart';

class SubjectScreen extends StatelessWidget {
  const SubjectScreen({super.key});

  final List<Map<String, dynamic>> subjects = const [
    {"name": "Mathematics", "icon": Icons.calculate_rounded},
    {"name": "Science", "icon": Icons.science_rounded},
    {"name": "English", "icon": Icons.menu_book_rounded},
    {"name": "History", "icon": Icons.history_edu_rounded},
    {"name": "Geography", "icon": Icons.public_rounded},
    {"name": "Computer", "icon": Icons.computer_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A1929),
              Color(0xFF1A2A3A),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Decorative elements
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFFB74D).withOpacity(0.1),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isSmallScreen ? 20 : 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFB74D).withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.auto_stories_rounded,
                                size: 60,
                                color: Color(0xFFFFB74D),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "Select Subject",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFFB74D),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Choose what you want to learn",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Subjects Grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isSmallScreen ? 2 : 3,
                          childAspectRatio: 1.2,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                        ),
                        itemCount: subjects.length,
                        itemBuilder: (context, index) {
                          return TweenAnimationBuilder(
                            tween: Tween<double>(begin: 0, end: 1),
                            duration: Duration(milliseconds: 500 + (index * 100)),
                            builder: (context, double value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.scale(
                                  scale: value,
                                  child: _buildSubjectCard(
                                    context,
                                    subjects[index]["name"],
                                    subjects[index]["icon"],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectCard(BuildContext context, String name, IconData icon) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/chat', arguments: {
          "subject": name,
        });
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFFB74D).withOpacity(0.2),
              const Color(0xFFFFB74D).withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFFFB74D).withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: const Color(0xFFFFB74D),
            ),
            const SizedBox(height: 10),
            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}