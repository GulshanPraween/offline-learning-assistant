import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';
import 'dart:async';
import '../services/ollama_service.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> messages = [];
  
  // Voice Recognition
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _isAvailable = false;
  
  // Text to Speech
  late FlutterTts _flutterTts;
  
  // Voice toggle variable
  bool _isVoiceOn = false;
  
  // Ollama variables
  final OllamaService _ollamaService = OllamaService();
  bool _useAIForUnknown = true;
  
  // States
  bool _isTyping = false;
  bool _isProcessing = false;
  
  // Animation Controllers
  late AnimationController _bgPulseController;
  
  // Track last message
  String _lastProcessedMessage = "";
  
  // Current subject for background
  String _currentSubject = "general";
  
  // Timer for effects
  late Timer _effectTimer;
  int _currentEffectIndex = 0;
  
  // Cache for instant responses
  final Map<String, _CachedAnswer> _answerCache = {};
  
  // Visual effects per subject
  final List<Map<String, dynamic>> _visualEffects = [
    {"subject": "biology", "primaryColor": const Color(0xFFFF6B6B), "secondaryColor": const Color(0xFF4ECDC4), "accentColor": const Color(0xFFFFE66D), "pattern": Icons.spa, "name": "Biology"},
    {"subject": "physics", "primaryColor": const Color(0xFF4A90E2), "secondaryColor": const Color(0xFF6A5ACD), "accentColor": const Color(0xFFFFD93D), "pattern": Icons.bolt, "name": "Physics"},
    {"subject": "chemistry", "primaryColor": const Color(0xFFFF8C42), "secondaryColor": const Color(0xFFFF5733), "accentColor": const Color(0xFF36D1DC), "pattern": Icons.science, "name": "Chemistry"},
    {"subject": "math", "primaryColor": const Color(0xFF36D1DC), "secondaryColor": const Color(0xFF5B86E5), "accentColor": const Color(0xFFFFB347), "pattern": Icons.calculate, "name": "Math"},
    {"subject": "computer", "primaryColor": const Color(0xFF4A90E2), "secondaryColor": const Color(0xFF6A5ACD), "accentColor": const Color(0xFFFFD93D), "pattern": Icons.computer, "name": "Computer Science"},
    {"subject": "english", "primaryColor": const Color(0xFFFFB347), "secondaryColor": const Color(0xFFFF8C42), "accentColor": const Color(0xFFFF6B6B), "pattern": Icons.book, "name": "English"},
    {"subject": "history", "primaryColor": const Color(0xFF9B59B6), "secondaryColor": const Color(0xFF8E44AD), "accentColor": const Color(0xFFF1C40F), "pattern": Icons.history, "name": "History"},
    {"subject": "geography", "primaryColor": const Color(0xFF3498DB), "secondaryColor": const Color(0xFF2980B9), "accentColor": const Color(0xFF2ECC71), "pattern": Icons.public, "name": "Geography"},
    {"subject": "general", "primaryColor": const Color(0xFF9B59B6), "secondaryColor": const Color(0xFF3498DB), "accentColor": const Color(0xFFF1C40F), "pattern": Icons.school, "name": "Learning Hub"},
  ];

  Map<String, dynamic> get currentEffect {
    return _visualEffects.firstWhere(
      (e) => e["subject"] == _currentSubject,
      orElse: () => _visualEffects.last,
    );
  }

  // ===== HELPER FUNCTIONS =====
  List<double> _extractNumbers(String text) {
    RegExp regex = RegExp(r'(\d+\.?\d*)');
    Iterable<Match> matches = regex.allMatches(text);
    return matches.map((m) => double.parse(m.group(1)!)).toList();
  }

  // ===== MATHEMATICS ANSWERS =====
  String _getMathAnswer(String question) {
    String q = question.toLowerCase();
    List<double> nums = _extractNumbers(q);
    
    // Circle Area
    if (q.contains("circle") && q.contains("area")) {
      if (nums.isNotEmpty) {
        double r = nums.first;
        double area = pi * r * r;
        return "📐 **Circle Area**\n\n**Definition:** Area of circle is the space enclosed by its boundary.\n**Formula:** A = π × r²\n**Given:** r = $r cm\n**Calculation:** A = 3.14159 × ${r * r}\n**Result:** ${area.toStringAsFixed(2)} cm²";
      }
      return "📐 **Circle Area**\n\n**Definition:** Area of circle is the space enclosed by its boundary.\n**Formula:** A = π × r²\n**Example:** r = 7 cm → A = 3.14 × 49 = 153.94 cm²";
    }
    
    // Triangle Area
    if ((q.contains("triangle") || q.contains("tri")) && q.contains("area")) {
      if (nums.length >= 2) {
        double base = nums[0], height = nums[1];
        double area = 0.5 * base * height;
        return "🔺 **Triangle Area**\n\n**Definition:** Area of triangle is half of base times height.\n**Formula:** A = ½ × base × height\n**Given:** base = $base cm, height = $height cm\n**Calculation:** A = 0.5 × $base × $height\n**Result:** ${area.toStringAsFixed(2)} cm²";
      }
      return "🔺 **Triangle Area**\n\n**Definition:** Area of triangle is half of base times height.\n**Formula:** A = ½ × base × height\n**Example:** base = 8 cm, height = 5 cm → A = 0.5 × 8 × 5 = 20 cm²";
    }
    
    // Rectangle Area
    if ((q.contains("rectangle") || q.contains("rect")) && q.contains("area")) {
      if (nums.length >= 2) {
        double length = nums[0], width = nums[1];
        double area = length * width;
        return "📏 **Rectangle Area**\n\n**Definition:** Area of rectangle is length times width.\n**Formula:** A = length × width\n**Given:** length = $length cm, width = $width cm\n**Calculation:** A = $length × $width\n**Result:** ${area.toStringAsFixed(2)} cm²";
      }
      return "📏 **Rectangle Area**\n\n**Definition:** Area of rectangle is length times width.\n**Formula:** A = length × width\n**Example:** length = 10 cm, width = 5 cm → A = 50 cm²";
    }
    
    // Square Area
    if (q.contains("square") && q.contains("area")) {
      if (nums.isNotEmpty) {
        double side = nums.first;
        double area = side * side;
        return "⬛ **Square Area**\n\n**Definition:** Area of square is side squared.\n**Formula:** A = side²\n**Given:** side = $side cm\n**Calculation:** A = $side × $side\n**Result:** ${area.toStringAsFixed(2)} cm²";
      }
      return "⬛ **Square Area**\n\n**Definition:** Area of square is side squared.\n**Formula:** A = side²\n**Example:** side = 7 cm → A = 49 cm²";
    }
    
    // Pythagoras Theorem
    if (q.contains("pythagoras") || q.contains("pythagorean")) {
      if (nums.length >= 2) {
        double a = nums[0], b = nums[1];
        double c = sqrt(a*a + b*b);
        return "📐 **Pythagoras Theorem**\n\n**Definition:** In a right triangle, square of hypotenuse equals sum of squares of other two sides.\n**Formula:** a² + b² = c²\n**Given:** a = $a, b = $b\n**Calculation:** $a² + $b² = ${a*a} + ${b*b} = ${a*a + b*b}\n**Result:** c = √${a*a + b*b} = ${c.toStringAsFixed(2)}";
      }
      return "📐 **Pythagoras Theorem**\n\n**Definition:** In a right triangle, a² + b² = c²\n**Formula:** a² + b² = c²\n**Example:** a = 3, b = 4 → c² = 9 + 16 = 25 → c = 5";
    }
    
    return "";
  }

  // ===== PHYSICS ANSWERS =====
  String _getPhysicsAnswer(String question) {
    String q = question.toLowerCase();
    
    if (q.contains("reflection") || q.contains("reflection of light")) {
      return "💡 **Reflection of Light**\n\n**Definition:** Bouncing back of light from a surface.\n**Laws:**\n• ∠i = ∠r (Angle of incidence = Angle of reflection)\n• Incident, reflected, normal in same plane\n**Example:** Light hitting mirror at 30° reflects at 30°";
    }
    
    if (q.contains("series circuit")) {
      return "⚡ **Series Circuit**\n\n**Definition:** Circuit where components connected end-to-end in single path.\n**Properties:**\n• Same current everywhere\n• R_total = R₁ + R₂ + R₃\n**Example:** R₁=2Ω, R₂=3Ω → R_total = 5Ω";
    }
    
    if (q.contains("parallel circuit")) {
      return "⚡ **Parallel Circuit**\n\n**Definition:** Circuit where components connected across same voltage.\n**Properties:**\n• Voltage same across all\n• 1/R = 1/R₁ + 1/R₂\n**Example:** R₁=2Ω, R₂=3Ω → 1/R = 1/2 + 1/3 = 5/6 → R = 1.2Ω";
    }
    
    if (q.contains("ohm") || q.contains("ohm's law")) {
      return "⚡ **Ohm's Law**\n\n**Definition:** Voltage across conductor is directly proportional to current.\n**Formula:** V = I × R\n**Where:** V = Voltage, I = Current, R = Resistance\n**Example:** I = 2A, R = 5Ω → V = 10V";
    }
    
    if (q.contains("newton") && q.contains("first")) {
      return "⚡ **Newton's First Law**\n\n**Definition:** Object at rest stays at rest, object in motion stays in motion unless acted by external force.\n**Example:** A book on table stays still until pushed.";
    }
    
    if (q.contains("newton") && q.contains("second")) {
      return "⚡ **Newton's Second Law**\n\n**Definition:** Force equals mass times acceleration.\n**Formula:** F = m × a\n**Example:** m = 2kg, a = 3m/s² → F = 6N";
    }
    
    if (q.contains("newton") && q.contains("third")) {
      return "⚡ **Newton's Third Law**\n\n**Definition:** Every action has equal and opposite reaction.\n**Example:** When you push wall, wall pushes you back.";
    }
    
    if (q.contains("gravity")) {
      return "🌍 **Gravity**\n\n**Definition:** Force that attracts objects towards Earth.\n**Formula:** F = m × g (g = 9.8 m/s²)\n**Example:** 10kg object weighs 98N on Earth.";
    }
    
    return "";
  }

  // ===== BIOLOGY ANSWERS =====
  String _getBiologyAnswer(String question) {
    String q = question.toLowerCase();
    
    if (q.contains("photosynthesis")) {
      return "🌿 **Photosynthesis**\n\n**Definition:** Process by which plants make food using sunlight, water and CO₂.\n**Formula:** 6CO₂ + 6H₂O → C₆H₁₂O₆ + 6O₂\n**Example:** A leaf uses sunlight to produce glucose and oxygen.";
    }
    
    if (q.contains("heart") && q.contains("human")) {
      return "❤️ **Human Heart**\n\n**Definition:** Muscular organ that pumps blood throughout body.\n**Structure:** 4 chambers - RA, RV, LA, LV\n**Function:** Beats 60-100 times/min, pumps 5-6L blood/min\n**Example:** During exercise, heart beats faster to supply more oxygen.";
    }
    
    if (q.contains("brain")) {
      return "🧠 **Human Brain**\n\n**Definition:** Control center of body that processes thoughts and movements.\n**Parts:**\n• Cerebrum: Thinking & Memory\n• Cerebellum: Balance & Coordination\n• Brainstem: Breathing & Heartbeat\n**Example:** Brain helps you read and understand this!";
    }
    
    if (q.contains("lungs")) {
      return "🫁 **Lungs**\n\n**Definition:** Organs that help us breathe by exchanging gases.\n**Function:** Inhale O₂, exhale CO₂, 12-20 breaths/min\n**Example:** When you run, lungs work faster to get more oxygen.";
    }
    
    if (q.contains("eye")) {
      return "👁️ **Human Eye**\n\n**Definition:** Organ that detects light and enables vision.\n**Parts:**\n• Cornea: Bends light\n• Pupil: Controls light entry\n• Lens: Focuses light\n• Retina: Captures image\n**Example:** Pupil shrinks in bright light.";
    }
    
    if (q.contains("cell")) {
      return "🔬 **Cell**\n\n**Definition:** Basic structural and functional unit of life.\n**Parts:**\n• Nucleus: Control center\n• Mitochondria: Power house\n• Cell Membrane: Boundary\n**Example:** Human body has trillions of cells.";
    }
    
    return "";
  }

  // ===== CHEMISTRY ANSWERS =====
  String _getChemistryAnswer(String question) {
    String q = question.toLowerCase();
    
    if (q.contains("atom")) {
      return "⚛️ **Atom**\n\n**Definition:** Smallest unit of matter that retains chemical properties.\n**Structure:**\n• Protons (+ charge) in nucleus\n• Neutrons (neutral) in nucleus\n• Electrons (- charge) orbiting nucleus\n**Example:** Hydrogen atom has 1 proton, 1 electron.";
    }
    
    if (q.contains("molecule")) {
      return "🧪 **Molecule**\n\n**Definition:** Group of atoms bonded together.\n**Example:** Water molecule (H₂O) has 2 hydrogen + 1 oxygen atoms.";
    }
    
    if (q.contains("acid")) {
      return "🧪 **Acid**\n\n**Definition:** Substance that donates H⁺ ions in water.\n**Properties:** Sour taste, pH < 7, turns blue litmus red.\n**Example:** HCl (Hydrochloric acid) in stomach.";
    }
    
    if (q.contains("base")) {
      return "🧪 **Base**\n\n**Definition:** Substance that accepts H⁺ ions or donates OH⁻ ions.\n**Properties:** Bitter taste, slippery, pH > 7, turns red litmus blue.\n**Example:** NaOH (Sodium hydroxide).";
    }
    
    if (q.contains("periodic table")) {
      return "📊 **Periodic Table**\n\n**Definition:** Arrangement of elements by atomic number.\n**Groups:** Vertical columns (1-18) - similar properties.\n**Periods:** Horizontal rows (1-7) - properties change gradually.\n**Example:** Group 1 - Alkali metals (Na, K).";
    }
    
    return "";
  }

  // ===== COMPUTER SCIENCE ANSWERS =====
  String _getComputerAnswer(String question) {
    String q = question.toLowerCase();
    
    if (q.contains("java") && q.contains("oops") || q.contains("java oop")) {
      return "☕ **Java OOPs - 4 Pillars**\n\n" +
             "**1. Encapsulation**\n" +
             "• Bundle data & methods\n" +
             "• Hide details using private\n" +
             "Example: class Student { private String name; }\n\n" +
             
             "**2. Inheritance**\n" +
             "• Child inherits parent properties\n" +
             "• Uses 'extends' keyword\n" +
             "Example: class Dog extends Animal { }\n\n" +
             
             "**3. Polymorphism**\n" +
             "• Same method, different behaviors\n" +
             "• Method Overloading & Overriding\n" +
             "Example: add(int a, int b) and add(int a, int b, int c)\n\n" +
             
             "**4. Abstraction**\n" +
             "• Hide implementation, show functionality\n" +
             "• Abstract classes & Interfaces\n" +
             "Example: abstract class Shape { abstract void draw(); }";
    }
    
    if (q.contains("java") && q.contains("encapsulation")) {
      return "🔒 **Java Encapsulation**\n\n**Definition:** Wrapping data and methods together, hiding internal details.\n**Implementation:** Use private variables and public getters/setters.\n**Example:**\nclass Student {\n  private String name;\n  public void setName(String n) { name = n; }\n  public String getName() { return name; }\n}";
    }
    
    if (q.contains("java") && q.contains("inheritance")) {
      return "👨‍👦 **Java Inheritance**\n\n**Definition:** Child class acquires properties of parent class.\n**Keyword:** extends\n**Example:**\nclass Animal { void eat() { } }\nclass Dog extends Animal { void bark() { } }";
    }
    
    if (q.contains("java") && q.contains("polymorphism")) {
      return "🔄 **Java Polymorphism**\n\n**Definition:** Same method name with different behaviors.\n**Types:**\n• Compile-time (Method Overloading)\n• Runtime (Method Overriding)\n**Example:**\nint add(int a, int b) { return a+b; }\nint add(int a, int b, int c) { return a+b+c; }";
    }
    
    if (q.contains("java") && q.contains("abstraction")) {
      return "🎭 **Java Abstraction**\n\n**Definition:** Hiding implementation details, showing only functionality.\n**Ways:**\n• Abstract classes (0-100%)\n• Interfaces (100%)\n**Example:**\nabstract class Shape {\n  abstract void draw();\n}\nclass Circle extends Shape {\n  void draw() { System.out.println(\"Circle\"); }\n}";
    }
    
    return "";
  }

  // ===== ENGLISH ANSWERS =====
  String _getEnglishAnswer(String question) {
    String q = question.toLowerCase();
    
    if (q.contains("noun")) {
      return "📝 **Noun**\n\n**Definition:** A word that names a person, place, thing, or idea.\n**Types:** Proper (John), Common (city), Collective (team), Abstract (love).\n**Example:** 'The **dog** is barking.' - dog is noun.";
    }
    
    if (q.contains("verb")) {
      return "📝 **Verb**\n\n**Definition:** A word that describes an action, occurrence, or state of being.\n**Example:** 'She **runs** fast.' - runs is verb.";
    }
    
    if (q.contains("adjective")) {
      return "📝 **Adjective**\n\n**Definition:** A word that describes or modifies a noun.\n**Example:** 'The **beautiful** flower.' - beautiful is adjective.";
    }
    
    if (q.contains("adverb")) {
      return "📝 **Adverb**\n\n**Definition:** A word that modifies a verb, adjective, or another adverb.\n**Example:** 'She sings **beautifully**.' - beautifully is adverb.";
    }
    
    if (q.contains("tense")) {
      return "📝 **Tense**\n\n**Definition:** Time of action - Past, Present, Future.\n**Example:**\n• Present: I **eat**\n• Past: I **ate**\n• Future: I **will eat**";
    }
    
    return "";
  }

  // ===== HISTORY ANSWERS =====
  String _getHistoryAnswer(String question) {
    String q = question.toLowerCase();
    
    if (q.contains("indian independence")) {
      return "📜 **Indian Independence**\n\n**Date:** August 15, 1947\n**Key Leaders:** Mahatma Gandhi, Jawaharlal Nehru, Sardar Patel\n**Key Event:** India gained freedom from British rule after 200 years.";
    }
    
    if (q.contains("gandhi")) {
      return "📜 **Mahatma Gandhi**\n\n**Born:** October 2, 1869\n**Role:** Father of the Nation, led India's freedom movement.\n**Key Movements:** Non-cooperation, Civil Disobedience, Quit India.\n**Principle:** Ahimsa (Non-violence).";
    }
    
    if (q.contains("world war") && q.contains("1")) {
      return "📜 **World War I**\n\n**Period:** 1914-1918\n**Cause:** Assassination of Archduke Franz Ferdinand.\n**Allies:** UK, France, Russia, US vs **Central:** Germany, Austria-Hungary.\n**Result:** Allies won, Treaty of Versailles.";
    }
    
    if (q.contains("world war") && q.contains("2")) {
      return "📜 **World War II**\n\n**Period:** 1939-1945\n**Cause:** Hitler's invasion of Poland.\n**Allies:** UK, US, Soviet Union vs **Axis:** Germany, Italy, Japan.\n**Result:** Allies won, atomic bombs on Hiroshima & Nagasaki.";
    }
    
    return "";
  }

  // ===== GEOGRAPHY ANSWERS =====
  String _getGeographyAnswer(String question) {
    String q = question.toLowerCase();
    
    if (q.contains("latitude")) {
      return "🌍 **Latitude**\n\n**Definition:** Horizontal lines running east-west, measuring north-south position.\n**Equator:** 0° latitude.\n**Example:** Tropic of Cancer (23.5°N), Tropic of Capricorn (23.5°S).";
    }
    
    if (q.contains("longitude")) {
      return "🌍 **Longitude**\n\n**Definition:** Vertical lines running north-south, measuring east-west position.\n**Prime Meridian:** 0° longitude (Greenwich, UK).\n**Example:** 180° is International Date Line.";
    }
    
    if (q.contains("river") && q.contains("ganga")) {
      return "🌊 **River Ganga**\n\n**Origin:** Gangotri Glacier, Uttarakhand\n**Length:** 2,525 km\n**Mouth:** Bay of Bengal\n**Significance:** Holiest river for Hindus.";
    }
    
    if (q.contains("him") && q.contains("alaya")) {
      return "⛰️ **Himalayas**\n\n**Location:** Northern India, Nepal, Bhutan\n**Highest Peak:** Mount Everest (8,848 m)\n**Significance:** Source of major rivers, climate regulator.";
    }
    
    return "";
  }

  // ===== MAIN ANSWER FUNCTION =====
  String _getAnswer(String question) {
    String q = question.toLowerCase().trim();
    
    // Check cache first
    if (_answerCache.containsKey(q)) {
      return _answerCache[q]!.answer;
    }
    
    String answer = "";
    
    // Subject detection
    if (q.contains("circle") || q.contains("triangle") || q.contains("rectangle") || 
        q.contains("square") || q.contains("pythagoras") || q.contains("area") ||
        q.contains("math") || q.contains("mathematics")) {
      answer = _getMathAnswer(question);
      if (answer.isNotEmpty) {
        _answerCache[q] = _CachedAnswer(answer, DateTime.now());
        return answer;
      }
    }
    
    if (q.contains("reflection") || q.contains("circuit") || q.contains("ohm") || 
        q.contains("newton") || q.contains("gravity") || q.contains("physics") ||
        q.contains("light") || q.contains("electricity")) {
      answer = _getPhysicsAnswer(question);
      if (answer.isNotEmpty) {
        _answerCache[q] = _CachedAnswer(answer, DateTime.now());
        return answer;
      }
    }
    
    if (q.contains("brain") || q.contains("heart") || q.contains("lungs") || 
        q.contains("eye") || q.contains("cell") || q.contains("photosynthesis") ||
        q.contains("biology")) {
      answer = _getBiologyAnswer(question);
      if (answer.isNotEmpty) {
        _answerCache[q] = _CachedAnswer(answer, DateTime.now());
        return answer;
      }
    }
    
    if (q.contains("atom") || q.contains("molecule") || q.contains("acid") || 
        q.contains("base") || q.contains("periodic") || q.contains("chemistry")) {
      answer = _getChemistryAnswer(question);
      if (answer.isNotEmpty) {
        _answerCache[q] = _CachedAnswer(answer, DateTime.now());
        return answer;
      }
    }
    
    if (q.contains("java") || q.contains("oops") || q.contains("encapsulation") ||
        q.contains("inheritance") || q.contains("polymorphism") || q.contains("abstraction") ||
        q.contains("computer") || q.contains("programming")) {
      answer = _getComputerAnswer(question);
      if (answer.isNotEmpty) {
        _answerCache[q] = _CachedAnswer(answer, DateTime.now());
        return answer;
      }
    }
    
    if (q.contains("noun") || q.contains("verb") || q.contains("adjective") || 
        q.contains("adverb") || q.contains("tense") || q.contains("grammar") ||
        q.contains("english")) {
      answer = _getEnglishAnswer(question);
      if (answer.isNotEmpty) {
        _answerCache[q] = _CachedAnswer(answer, DateTime.now());
        return answer;
      }
    }
    
    if (q.contains("indian") || q.contains("gandhi") || q.contains("world war") || 
        q.contains("history") || q.contains("independence")) {
      answer = _getHistoryAnswer(question);
      if (answer.isNotEmpty) {
        _answerCache[q] = _CachedAnswer(answer, DateTime.now());
        return answer;
      }
    }
    
    if (q.contains("latitude") || q.contains("longitude") || q.contains("river") || 
        q.contains("mountain") || q.contains("geography") || q.contains("him") && q.contains("alaya")) {
      answer = _getGeographyAnswer(question);
      if (answer.isNotEmpty) {
        _answerCache[q] = _CachedAnswer(answer, DateTime.now());
        return answer;
      }
    }
    
    // Greetings
    if (q.contains("hello") || q.contains("hi")) {
      answer = "👋 Hello! I'm your learning assistant. Ask me about Math, Physics, Biology, Chemistry, Computer Science, English, History, or Geography!";
      _answerCache[q] = _CachedAnswer(answer, DateTime.now());
      return answer;
    }
    if (q.contains("thank")) {
      answer = "😊 You're welcome! Feel free to ask more questions!";
      _answerCache[q] = _CachedAnswer(answer, DateTime.now());
      return answer;
    }
    
    return "🤔 Let me think...";
  }

  @override
  void initState() {
    super.initState();
    
    _bgPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _effectTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) setState(() => _currentEffectIndex = (_currentEffectIndex + 1) % 100);
    });
    
    _speech = stt.SpeechToText();
    _initSpeech();
    _flutterTts = FlutterTts();
    _initTts();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addBotMessage("✨ Hi! I'm your learning assistant.How can i help you?");
    });
  }

  void _initSpeech() async {
    _isAvailable = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (_isListening) {
            setState(() => _isListening = false);
            if (_textController.text.trim().isNotEmpty && 
                _textController.text != _lastProcessedMessage) {
              _sendMessage();
            }
          }
        }
      },
      onError: (error) {
        setState(() => _isListening = false);
        _addBotMessage("🎤 Microphone access needed. Please type.");
      },
    );
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
  }

  void _addBotMessage(String text) {
    if (text.isEmpty) return;
    setState(() => messages.add({"sender": "bot", "text": text}));
    if (_isVoiceOn) _speak(text);
    _scrollToBottom();
  }

  void _addUserMessage(String text) {
    if (text.isEmpty) return;
    setState(() => messages.add({"sender": "user", "text": text}));
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _speak(String text) async {
    if (!_isVoiceOn) return;
    try {
      String cleanText = text.replaceAll(RegExp(r'[^\w\s.,!?]'), '');
      await _flutterTts.speak(cleanText);
    } catch (e) {
      print('TTS Error: $e');
    }
  }

  void _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      if (_textController.text.trim().isNotEmpty && 
          _textController.text != _lastProcessedMessage) {
        _sendMessage();
      }
    } else {
      if (!_isAvailable) {
        _addBotMessage("🎤 Microphone not available.");
        return;
      }
      setState(() {
        _isListening = true;
        _textController.clear();
      });
      await _speech.listen(
        onResult: (result) => setState(() => _textController.text = result.recognizedWords),
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 2),
      );
    }
  }

  Future<void> _sendMessage() async {
    String userMessage = _textController.text.trim();
    if (userMessage.isEmpty || _isProcessing) return;
    
    _lastProcessedMessage = userMessage;
    _textController.clear();
    
    // Subject detection for background
    if (userMessage.toLowerCase().contains("java") || userMessage.toLowerCase().contains("computer")) {
      setState(() => _currentSubject = "computer");
    } else if (userMessage.toLowerCase().contains("circle") || userMessage.toLowerCase().contains("triangle") ||
               userMessage.toLowerCase().contains("math")) {
      setState(() => _currentSubject = "math");
    } else if (userMessage.toLowerCase().contains("reflection") || userMessage.toLowerCase().contains("circuit") ||
               userMessage.toLowerCase().contains("physics")) {
      setState(() => _currentSubject = "physics");
    } else if (userMessage.toLowerCase().contains("brain") || userMessage.toLowerCase().contains("heart") ||
               userMessage.toLowerCase().contains("biology")) {
      setState(() => _currentSubject = "biology");
    } else if (userMessage.toLowerCase().contains("atom") || userMessage.toLowerCase().contains("acid") ||
               userMessage.toLowerCase().contains("chemistry")) {
      setState(() => _currentSubject = "chemistry");
    } else if (userMessage.toLowerCase().contains("noun") || userMessage.toLowerCase().contains("verb") ||
               userMessage.toLowerCase().contains("english")) {
      setState(() => _currentSubject = "english");
    } else if (userMessage.toLowerCase().contains("gandhi") || userMessage.toLowerCase().contains("history") ||
               userMessage.toLowerCase().contains("indian") || userMessage.toLowerCase().contains("world war")) {
      setState(() => _currentSubject = "history");
    } else if (userMessage.toLowerCase().contains("latitude") || userMessage.toLowerCase().contains("river") ||
               userMessage.toLowerCase().contains("geography") || userMessage.toLowerCase().contains("mountain")) {
      setState(() => _currentSubject = "geography");
    } else {
      setState(() => _currentSubject = "general");
    }
    
    setState(() {
      _isProcessing = true;
      _addUserMessage(userMessage);
      _isTyping = true;
    });
    
    // Try hardcoded answer first (instant)
    String botReply = _getAnswer(userMessage);
    
    // If not found, use AI (fast - 2-4 seconds)
    if (botReply == "🤔 Let me think..." && _useAIForUnknown) {
      try {
        String aiReply = await _ollamaService.generateResponse(userMessage);
        if (aiReply.isNotEmpty && !aiReply.contains("⚠️")) {
          botReply = aiReply;
        }
      } catch (e) {
        botReply = "⚠️ AI busy, please try again.";
      }
    }
    
    setState(() {
      _isTyping = false;
      _isProcessing = false;
    });
    
    _addBotMessage(botReply);
  }

  @override
  void dispose() {
    _bgPulseController.dispose();
    _effectTimer.cancel();
    _speech.stop();
    _flutterTts.stop();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final selectedClass = args?["class"] ?? "Class 8";
    final selectedSubject = args?["subject"] ?? "English";
    final effect = currentEffect;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(selectedClass, style: const TextStyle(fontSize: 12, color: Colors.white70)),
            Text(selectedSubject, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        actions: [
          AnimatedBuilder(
            animation: _bgPulseController,
            builder: (context, child) {
              return Container(
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isVoiceOn 
                        ? [effect["primaryColor"], effect["secondaryColor"]]
                        : [Colors.grey.shade600, Colors.grey.shade800],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: _isVoiceOn ? [BoxShadow(color: effect["primaryColor"].withOpacity(0.5), blurRadius: 20)] : null,
                ),
                child: IconButton(
                  icon: Icon(_isVoiceOn ? Icons.volume_up : Icons.volume_off, color: Colors.white),
                  onPressed: () => setState(() => _isVoiceOn = !_isVoiceOn),
                ),
              );
            },
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  effect["primaryColor"].withOpacity(0.2),
                  effect["secondaryColor"].withOpacity(0.1),
                  const Color(0xFF0A1929),
                ],
              ),
            ),
          ),
          
          Column(
            children: [
              const SizedBox(height: kToolbarHeight + 10),
              
              // Subject header
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: effect["primaryColor"].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: effect["accentColor"].withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(effect["pattern"], color: effect["accentColor"], size: 20),
                    const SizedBox(width: 8),
                    Text(effect["name"], style: const TextStyle(color: Colors.white, fontSize: 14)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: effect["accentColor"].withOpacity(0.2), shape: BoxShape.circle),
                      child: Icon(Icons.star, color: effect["accentColor"], size: 12),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 10),
              
              // Chat messages
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isTyping && index == messages.length) {
                      return _buildTypingIndicator(effect);
                    }
                    bool isUser = messages[index]["sender"] == "user";
                    return _buildMessageBubble(messages[index]["text"] ?? "", isUser, effect);
                  },
                ),
              ),
              
              // Input area - IMPROVED VISIBILITY
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, effect["primaryColor"].withOpacity(0.15), effect["secondaryColor"].withOpacity(0.25)],
                  ),
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    if (_isListening)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [effect["primaryColor"], effect["secondaryColor"]]),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: effect["primaryColor"].withOpacity(0.5),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            "🎤 Listening... Speak now",
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    
                    Row(
                      children: [
                        // Mic button
                        GestureDetector(
                          onTap: _toggleListening,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 55,
                            height: 55,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _isListening 
                                    ? [Colors.red.shade400, Colors.red.shade600]
                                    : [effect["primaryColor"], effect["secondaryColor"]],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (_isListening ? Colors.red : effect["primaryColor"]).withOpacity(0.5),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              _isListening ? Icons.mic : Icons.mic_none,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // Text field - IMPROVED VISIBILITY
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95), // Almost white background
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: _isListening 
                                    ? effect["primaryColor"] 
                                    : Colors.white.withOpacity(0.5),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _textController,
                              style: const TextStyle(color: Colors.black87, fontSize: 16), // Black text
                              enabled: !_isProcessing,
                              decoration: InputDecoration(
                                hintText: _isListening 
                                    ? "I'm listening..." 
                                    : "Ask anything...",
                                hintStyle: TextStyle(
                                  color: _isListening 
                                      ? effect["primaryColor"].withOpacity(0.7)
                                      : Colors.grey.shade600,
                                  fontSize: 15,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                prefixIcon: _isListening
                                    ? Icon(Icons.graphic_eq, color: effect["primaryColor"], size: 24)
                                    : null,
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // Send button
                        GestureDetector(
                          onTap: (_isProcessing || _textController.text.isEmpty) ? null : _sendMessage,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: (_isProcessing || _textController.text.isEmpty)
                                    ? [Colors.grey.shade400, Colors.grey.shade600]
                                    : [effect["primaryColor"], effect["secondaryColor"]],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                if (!_isProcessing && _textController.text.isNotEmpty)
                                  BoxShadow(
                                    color: effect["primaryColor"].withOpacity(0.5),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                  ),
                              ],
                            ),
                            child: Icon(
                              _isProcessing ? Icons.hourglass_empty : Icons.send,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser, Map<String, dynamic> effect) {
    String cleanText = text.replaceAll('**', '');
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            Container(
              margin: const EdgeInsets.only(right: 8, top: 4),
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [effect["primaryColor"], effect["secondaryColor"]],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: effect["primaryColor"].withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Icon(Icons.auto_awesome, size: 20, color: Colors.white),
            ),
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: isUser
                    ? LinearGradient(
                        colors: [effect["primaryColor"], effect["secondaryColor"]],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: [
                          const Color(0xFF1E2A3A).withOpacity(0.95),
                          const Color(0xFF0A1929).withOpacity(0.95),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 5),
                  bottomRight: Radius.circular(isUser ? 5 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isUser ? effect["primaryColor"] : effect["accentColor"]).withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: !isUser
                    ? Border.all(
                        color: effect["accentColor"].withOpacity(0.3),
                        width: 1,
                      )
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isUser)
                    Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: effect["accentColor"].withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome, size: 12, color: effect["accentColor"]),
                          const SizedBox(width: 4),
                          Text(
                            effect["name"],
                            style: TextStyle(
                              color: effect["accentColor"],
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  Text(
                    cleanText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Time stamp
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (isUser)
            Container(
              margin: const EdgeInsets.only(left: 8, top: 4),
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey, Color(0xFF2C3E50)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Icon(Icons.person, size: 20, color: Colors.white),
            ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(Map<String, dynamic> effect) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 8, top: 4),
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [effect["primaryColor"], effect["secondaryColor"]],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: effect["primaryColor"].withOpacity(0.3),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Icon(Icons.auto_awesome, size: 18, color: Colors.white),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1E2A3A).withOpacity(0.95),
                  const Color(0xFF0A1929).withOpacity(0.95),
                ],
              ),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: effect["accentColor"].withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: effect["primaryColor"].withOpacity(0.2),
                  blurRadius: 15,
                ),
              ],
            ),
            child: Row(
              children: List.generate(3, (index) {
                return AnimatedBuilder(
                  animation: _bgPulseController,
                  builder: (context, child) {
                    return Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            effect["accentColor"].withOpacity(0.4 + index * 0.2),
                            effect["primaryColor"].withOpacity(0.6 + index * 0.1),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: effect["accentColor"].withOpacity(0.3),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _CachedAnswer {
  final String answer;
  final DateTime time;
  _CachedAnswer(this.answer, this.time);
}