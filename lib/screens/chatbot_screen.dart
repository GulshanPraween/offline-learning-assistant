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
  
  // Multiple Animation Controllers for complex effects
  late AnimationController _bgParticleController;
  late AnimationController _bgWaveController;
  late AnimationController _bgGlowController;
  late AnimationController _bgFloatController;
  late AnimationController _bgRotateController;
  late AnimationController _bgPulseController;
  
  // Track last message
  String _lastProcessedMessage = "";
  
  // Current subject for background
  String _currentSubject = "general";
  
  // Timer for effects
  late Timer _effectTimer;
  int _currentEffectIndex = 0;
  
  // List of stunning visual effects per subject
  final List<Map<String, dynamic>> _visualEffects = [
    {
      "subject": "biology", 
      "primaryColor": const Color(0xFFFF6B6B),
      "secondaryColor": const Color(0xFF4ECDC4),
      "accentColor": const Color(0xFFFFE66D),
      "particles": "🧬🧫🔬🧪🦠🧠❤️👁️",
      "pattern": Icons.spa,
      "name": "Life Sciences"
    },
    {
      "subject": "physics", 
      "primaryColor": const Color(0xFF4A90E2),
      "secondaryColor": const Color(0xFF6A5ACD),
      "accentColor": const Color(0xFFFFD93D),
      "particles": "⚡💡🔭🧲⚛️🌊🎯🔋",
      "pattern": Icons.bolt,
      "name": "Physics World"
    },
    {
      "subject": "chemistry", 
      "primaryColor": const Color(0xFFFF8C42),
      "secondaryColor": const Color(0xFFFF5733),
      "accentColor": const Color(0xFF36D1DC),
      "particles": "🧪⚗️🧫🔬🧬💊🔥💧",
      "pattern": Icons.science,
      "name": "Chemistry Lab"
    },
    {
      "subject": "math", 
      "primaryColor": const Color(0xFF36D1DC),
      "secondaryColor": const Color(0xFF5B86E5),
      "accentColor": const Color(0xFFFFB347),
      "particles": "📐📏➗✖️➕➖🔢∞",
      "pattern": Icons.calculate,
      "name": "Mathematics"
    },
    {
      "subject": "general", 
      "primaryColor": const Color(0xFF9B59B6),
      "secondaryColor": const Color(0xFF3498DB),
      "accentColor": const Color(0xFFF1C40F),
      "particles": "📚🎓✨💫⭐🌟⚡💡",
      "pattern": Icons.school,
      "name": "Learning Hub"
    },
  ];

  Map<String, dynamic> get currentEffect {
    return _visualEffects.firstWhere(
      (e) => e["subject"] == _currentSubject,
      orElse: () => _visualEffects.last,
    );
  }

  String _calculateCircleArea(String question) {
    String q = question.toLowerCase();
    
    if (q.contains("definition") || q.contains("what is") || 
        q.contains("explain") || q.contains("meaning")) {
      return "⚪ AREA OF CIRCLE - DEFINITION\n\n"
             "📖 The area of a circle is the region covered by the circle in a 2D plane. It is the space occupied inside the circle's boundary.\n\n"
             "📐 Formula: A = πr²\n\n"
             "📝 Where:\n"
             "  • π (pi) = 3.14159...\n"
             "  • r = radius of circle\n\n"
             "💡 Example: If radius = 7 cm\n"
             "  A = π × 7² = 3.14 × 49 = 153.86 cm²\n\n"
             "📚 NCERT Mathematics Class 7, Chapter 11";
    }
    
    double? r;
    
    RegExp regex1 = RegExp(r'r\s*=\s*(\d+\.?\d*)');
    var match1 = regex1.firstMatch(q);
    if (match1 != null) {
      r = double.parse(match1.group(1)!);
    }
    
    RegExp regex2 = RegExp(r'radius\s*=\s*(\d+\.?\d*)');
    var match2 = regex2.firstMatch(q);
    if (match2 != null) {
      r = double.parse(match2.group(1)!);
    }
    
    RegExp regex3 = RegExp(r'(?:r|radius)\s+(\d+\.?\d*)');
    var match3 = regex3.firstMatch(q);
    if (match3 != null) {
      r = double.parse(match3.group(1)!);
    }
    
    if (r == null) {
      return "⚪ AREA OF CIRCLE\n\n"
             "📖 A = πr²\n\n"
             "💡 Example: r = 7 cm → 153.86 cm²\n\n"
             "🔍 Try: 'area of circle r=10'";
    }
    
    double pi = 3.14159;
    double area = pi * r * r;
    
    return "⚪ CIRCLE AREA CALCULATION\n\n"
           "📊 INPUT:\n"
           "  • Radius = $r cm\n"
           "  • π = 3.14159\n\n"
           "📐 FORMULA:\n"
           "  A = πr²\n"
           "  A = 3.14159 × ${r}²\n"
           "  A = 3.14159 × ${r * r}\n\n"
           "✅ RESULT:\n"
           "  **A = ${area.toStringAsFixed(2)} cm²**\n\n"
           "📚 NCERT Mathematics Class 7";
  }

  @override
  void initState() {
    super.initState();
    
    // Multiple animation controllers for rich effects
    _bgParticleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    
    _bgWaveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    
    _bgGlowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    
    _bgFloatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
    
    _bgRotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
    
    _bgPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    // Visual effects timer
    _effectTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          _currentEffectIndex = (_currentEffectIndex + 1) % 100;
        });
      }
    });
    
    _speech = stt.SpeechToText();
    _initSpeech();
    
    _flutterTts = FlutterTts();
    _initTts();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addBotMessage("✨ Welcome to your AI Learning Studio! What would you like to explore today?");
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
        _addBotMessage("🎤 Microphone access needed. Please type your question.");
      },
    );
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
  }

  Future<void> _speak(String text) async {
    try {
      String cleanText = text.replaceAll(RegExp(r'[^\w\s.,!?]'), '');
      await _flutterTts.speak(cleanText);
    } catch (e) {
      print('TTS Error: $e');
    }
  }

  void _addBotMessage(String text) {
    if (text.isEmpty) return;
    
    setState(() {
      messages.add({"sender": "bot", "text": text});
    });
    
    if (_isVoiceOn) {
      _speak(text);
    }
    
    _scrollToBottom();
  }

  void _addUserMessage(String text) {
    if (text.isEmpty) return;
    
    setState(() {
      messages.add({"sender": "user", "text": text});
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      }
    });
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
        _addBotMessage("🎤 Please enable microphone access.");
        return;
      }
      
      setState(() {
        _isListening = true;
        _isProcessing = false;
        _textController.clear();
      });
      
      await _speech.listen(
        onResult: (result) {
          setState(() {
            _textController.text = result.recognizedWords;
          });
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 2),
        localeId: "en_US",
        cancelOnError: false,
        partialResults: true,
      );
    }
  }

  Future<void> _sendMessage() async {
    String userMessage = _textController.text.trim();
    
    if (userMessage.isEmpty || _isProcessing) return;
    if (userMessage == _lastProcessedMessage) return;
    
    _lastProcessedMessage = userMessage;
    _textController.clear();
    
    _detectSubject(userMessage);
    
    setState(() {
      _isProcessing = true;
      _addUserMessage(userMessage);
    });
    
    setState(() => _isTyping = true);
    await Future.delayed(const Duration(milliseconds: 600));
    
    String botReply = _getAnswer(userMessage);
    
    if (_useAIForUnknown && 
        (botReply.contains("SORRY, I DON'T KNOW THAT") || 
         botReply.length < 30)) {
      
      try {
        setState(() {
          messages.add({"sender": "bot", "text": "🧠 Analyzing..."});
        });
        _scrollToBottom();
        
        String aiReply = await _ollamaService.generateResponse(userMessage);
        
        if (aiReply.isNotEmpty && !aiReply.contains("⚠️")) {
          botReply = aiReply;
        }
      } catch (e) {
        print('AI Error: $e');
      }
    }
    
    setState(() {
      _isTyping = false;
      _isProcessing = false;
    });
    
    _addBotMessage(botReply);
  }

  void _detectSubject(String question) {
    String q = question.toLowerCase();
    
    if (q.contains("cell") || q.contains("photosynthesis") || q.contains("human") || 
        q.contains("body") || q.contains("brain") || q.contains("dna") || 
        q.contains("biology") || q.contains("heart") || q.contains("lungs") ||
        q.contains("eye") || q.contains("kidney") || q.contains("liver")) {
      setState(() => _currentSubject = "biology");
    }
    else if (q.contains("pythagoras") || q.contains("circle") || q.contains("triangle") || 
             q.contains("square") || q.contains("rectangle") || q.contains("volume") || 
             q.contains("math") || q.contains("algebra") || q.contains("geometry") ||
             q.contains("calculus") || q.contains("trigonometry")) {
      setState(() => _currentSubject = "math");
    }
    else if (q.contains("newton") || q.contains("force") || q.contains("gravity") || 
             q.contains("motion") || q.contains("physics") || q.contains("energy") || 
             q.contains("electricity") || q.contains("magnetism") || q.contains("light") ||
             q.contains("reflection") || q.contains("refraction") || q.contains("sound") ||
             q.contains("circuit") || q.contains("series") || q.contains("parallel") ||
             q.contains("voltage") || q.contains("current") || q.contains("resistance") ||
             q.contains("ohm")) {
      setState(() => _currentSubject = "physics");
    }
    else if (q.contains("atom") || q.contains("molecule") || q.contains("chemical") || 
             q.contains("reaction") || q.contains("acid") || q.contains("base") || 
             q.contains("periodic") || q.contains("chemistry") || q.contains("compound") ||
             q.contains("element") || q.contains("bond") || q.contains("periodic classification")) {
      setState(() => _currentSubject = "chemistry");
    }
    else {
      setState(() => _currentSubject = "general");
    }
  }

  String _getAnswer(String question) {
    String q = question.toLowerCase().trim();

    // Mathematics
    if ((q.contains("area") || q.contains("find area")) && 
        (q.contains("circle") || q.contains("circl"))) {
      return _calculateCircleArea(question);
    }
    
    if (q.contains("pythagoras") || q.contains("pythagorean")) {
      return "📐 PYTHAGORAS THEOREM\n\n"
             "📖 In a right triangle, a² + b² = c²\n\n"
             "💡 Example: a=3, b=4 → c²=25 → c=5\n\n"
             "📚 NCERT Class 10";
    }
    
    if (q.contains("area of triangle") || q.contains("triangle area")) {
      return "🔺 TRIANGLE AREA\n\n"
             "📖 A = ½ × base × height\n\n"
             "💡 base=8, height=5 → A=20 cm²\n\n"
             "📚 NCERT Class 7";
    }

    // Physics
    if (q.contains("reflection") || q.contains("reflection of light")) {
      return "💡 LIGHT REFLECTION\n\n"
             "📖 ∠i = ∠r\n\n"
             "📝 Laws:\n"
             "  1. Angle of incidence = Angle of reflection\n"
             "  2. Incident, reflected, normal in same plane\n\n"
             "📚 NCERT Class 7";
    }
    
    if (q.contains("series circuit")) {
      return "⚡ SERIES CIRCUIT\n\n"
             "📖 Same current flows everywhere\n\n"
             "📝 R_total = R₁ + R₂ + R₃\n\n"
             "📚 NCERT Class 10";
    }

    // Biology
    if (q.contains("human brain") || q.contains("brain")) {
      return "🧠 HUMAN BRAIN\n\n"
             "📖 Cerebrum → Thinking & Memory\n"
             "📖 Cerebellum → Balance & Coordination\n"
             "📖 Brainstem → Breathing & Heartbeat\n\n"
             "📚 NCERT Class 10";
    }
    
    if (q.contains("heart") || q.contains("human heart")) {
      return "❤️ HUMAN HEART\n\n"
             "📖 4 Chambers: RA, RV, LA, LV\n"
             "📖 72 beats/minute average\n\n"
             "📚 NCERT Class 7";
    }

    // Greetings
    if (q.contains("hello") || q.contains("hi")) {
      return "👋 Hello! Ready to learn something amazing today?";
    }
    if (q.contains("thank")) {
      return "😊 You're welcome! Keep exploring!";
    }
    if (q.contains("bye")) {
      return "👋 See you soon! Come back with more questions!";
    }

    // Default
    return "🤔 Let me think...";
  }

  @override
  void dispose() {
    _bgParticleController.dispose();
    _bgWaveController.dispose();
    _bgGlowController.dispose();
    _bgFloatController.dispose();
    _bgRotateController.dispose();
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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              selectedClass,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w300,
                color: Colors.white70,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              selectedSubject,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        actions: [
          // Voice Toggle with cinematic effect
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
                  boxShadow: [
                    if (_isVoiceOn)
                      BoxShadow(
                        color: effect["primaryColor"].withOpacity(0.5),
                        blurRadius: 15 + _bgPulseController.value * 10,
                        spreadRadius: 2 + _bgPulseController.value * 3,
                      ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    _isVoiceOn ? Icons.volume_up : Icons.volume_off,
                    color: Colors.white,
                    size: 22,
                  ),
                  onPressed: () {
                    setState(() => _isVoiceOn = !_isVoiceOn);
                    if (!_isVoiceOn) _flutterTts.stop();
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(_isVoiceOn ? Icons.volume_up : Icons.volume_off, 
                                 color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              _isVoiceOn ? "Voice Assistant ON" : "Voice OFF",
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        duration: const Duration(seconds: 1),
                        backgroundColor: _isVoiceOn ? effect["primaryColor"] : Colors.grey.shade700,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                    );
                  },
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
          // ===== CINEMATIC BACKGROUND =====
          AnimatedBuilder(
            animation: Listenable.merge([
              _bgParticleController, _bgWaveController, _bgGlowController,
              _bgFloatController, _bgRotateController, _bgPulseController
            ]),
            builder: (context, child) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(
                      0.5 + sin(_bgWaveController.value * 2 * pi) * 0.1,
                      0.5 + cos(_bgGlowController.value * 2 * pi) * 0.1,
                    ),
                    radius: 1.5 + sin(_bgPulseController.value * 2 * pi) * 0.2,
                    colors: [
                      effect["primaryColor"].withOpacity(0.3),
                      effect["secondaryColor"].withOpacity(0.2),
                      const Color(0xFF0A1929),
                      const Color(0xFF0A1929),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // ===== FLOATING 3D ORBS =====
                    ...List.generate(8, (index) {
                      final angle = (index * 45 + _bgRotateController.value * 360) * pi / 180;
                      final radius = size.width * 0.4;
                      final x = size.width / 2 + cos(angle) * radius * 0.8;
                      final y = size.height / 2 + sin(angle * 1.5) * radius * 0.4;
                      
                      return Positioned(
                        left: x - 40,
                        top: y - 40,
                        child: Transform.scale(
                          scale: 0.8 + sin(_bgPulseController.value * 2 * pi + index) * 0.2,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  effect["accentColor"].withOpacity(0.15),
                                  effect["primaryColor"].withOpacity(0.05),
                                  Colors.transparent,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: effect["accentColor"].withOpacity(0.1),
                                  blurRadius: 30,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    
                    // ===== FLOATING EMOJI PARTICLES =====
                    ...List.generate(15, (index) {
                      final floatY = sin(_bgFloatController.value * 2 * pi + index) * 30;
                      final driftX = cos(_bgParticleController.value * 2 * pi + index) * 40;
                      final randomX = (index * 73) % size.width;
                      final randomY = (index * 47) % size.height;
                      
                      return Positioned(
                        left: randomX + driftX,
                        top: randomY + floatY,
                        child: Opacity(
                          opacity: 0.15 + sin(_bgGlowController.value * 2 * pi + index) * 0.05,
                          child: Transform.rotate(
                            angle: _bgRotateController.value * 2 * pi,
                            child: Text(
                              effect["particles"][index % effect["particles"].length],
                              style: TextStyle(
                                fontSize: 24 + sin(_bgPulseController.value * 2 * pi + index) * 8,
                                color: effect["accentColor"].withOpacity(0.2),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    
                    // ===== WAVES =====
                    Positioned(
                      bottom: -50,
                      left: -50,
                      right: -50,
                      child: Transform.rotate(
                        angle: sin(_bgWaveController.value * 2 * pi) * 0.05,
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                effect["primaryColor"].withOpacity(0.1),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // ===== CENTER GLOW =====
                    Positioned(
                      top: size.height * 0.3,
                      left: size.width * 0.3,
                      child: AnimatedBuilder(
                        animation: _bgPulseController,
                        builder: (context, child) {
                          return Container(
                            width: size.width * 0.4,
                            height: size.width * 0.4,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  effect["accentColor"].withOpacity(0.1),
                                  effect["primaryColor"].withOpacity(0.05),
                                  Colors.transparent,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: effect["accentColor"].withOpacity(0.1),
                                  blurRadius: 50 + _bgPulseController.value * 30,
                                  spreadRadius: 20,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          // ===== MAIN CONTENT =====
          Column(
            children: [
              const SizedBox(height: kToolbarHeight + 20),
              
              // ===== SUBJECT HEADER =====
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      effect["primaryColor"].withOpacity(0.2),
                      effect["secondaryColor"].withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: effect["accentColor"].withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: effect["primaryColor"].withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      effect["pattern"],
                      color: effect["accentColor"],
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      effect["name"],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: effect["accentColor"].withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        effect["particles"][_currentEffectIndex % effect["particles"].length],
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 10),
              
              // ===== CHAT MESSAGES =====
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isTyping && index == messages.length) {
                      return _buildTypingIndicator(effect);
                    }
                    
                    bool isUser = messages[index]["sender"] == "user";
                    return _buildMessageBubble(
                      messages[index]["text"] ?? "",
                      isUser,
                      effect,
                    );
                  },
                ),
              ),
              
              // ===== CINEMATIC INPUT AREA =====
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      effect["primaryColor"].withOpacity(0.15),
                      effect["secondaryColor"].withOpacity(0.2),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: effect["primaryColor"].withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    if (_isListening)
                      AnimatedBuilder(
                        animation: _bgPulseController,
                        builder: (context, child) {
                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  effect["primaryColor"],
                                  effect["secondaryColor"],
                                ],
                              ),
                              borderRadius: BorderRadius.circular(40),
                              boxShadow: [
                                BoxShadow(
                                  color: effect["primaryColor"].withOpacity(0.5),
                                  blurRadius: 20 + _bgPulseController.value * 15,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.graphic_eq, color: Colors.white, size: 28),
                                const SizedBox(width: 12),
                                Text(
                                  "🎤 Listening... Speak now",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    
                    Row(
                      children: [
                        // MIC BUTTON
                        GestureDetector(
                          onTap: _toggleListening,
                          child: AnimatedBuilder(
                            animation: _bgPulseController,
                            builder: (context, child) {
                              return Container(
                                width: 65,
                                height: 65,
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
                                      blurRadius: _isListening ? 25 : 15 + _bgPulseController.value * 10,
                                      spreadRadius: _isListening ? 8 : 3,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _isListening ? Icons.mic : Icons.mic_none,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              );
                            },
                          ),
                        ),
                        
                        const SizedBox(width: 15),
                        
                        // TEXT FIELD
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.1),
                                  Colors.white.withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(40),
                              border: Border.all(
                                color: _isListening 
                                    ? effect["primaryColor"].withOpacity(0.8)
                                    : Colors.white.withOpacity(0.2),
                                width: _isListening ? 2 : 1,
                              ),
                            ),
                            child: TextField(
                              controller: _textController,
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                              enabled: !_isProcessing,
                              decoration: InputDecoration(
                                hintText: _isListening 
                                    ? "I'm listening..." 
                                   : "Ask anything...",
                                hintStyle: TextStyle(
                                  color: _isListening 
                                      ? effect["primaryColor"].withOpacity(0.7)
                                      : Colors.white.withOpacity(0.4),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                                prefixIcon: _isListening
                                    ? Icon(Icons.graphic_eq, color: effect["primaryColor"])
                                    : null,
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 15),
                        
                        // SEND BUTTON
                        GestureDetector(
                          onTap: (_isProcessing || _textController.text.isEmpty) ? null : _sendMessage,
                          child: AnimatedBuilder(
                            animation: _bgPulseController,
                            builder: (context, child) {
                              return Container(
                                width: 55,
                                height: 55,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: (_isProcessing || _textController.text.isEmpty)
                                        ? [Colors.grey.shade600, Colors.grey.shade800]
                                        : [effect["primaryColor"], effect["secondaryColor"]],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    if (!_isProcessing && _textController.text.isNotEmpty)
                                      BoxShadow(
                                        color: effect["primaryColor"].withOpacity(0.5),
                                        blurRadius: 15 + _bgPulseController.value * 10,
                                        spreadRadius: 3,
                                      ),
                                  ],
                                ),
                                child: Icon(
                                  _isProcessing ? Icons.hourglass_empty : Icons.send_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              );
                            },
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

  // ===== ATTRACTIVE MESSAGE BUBBLE =====
  Widget _buildMessageBubble(String text, bool isUser, Map<String, dynamic> effect) {
    String cleanText = text.replaceAll('**', '');
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser)
            // BOT AVATAR
            Container(
              margin: const EdgeInsets.only(right: 8, bottom: 8),
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [effect["primaryColor"], effect["secondaryColor"]],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: effect["primaryColor"].withOpacity(0.5),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.auto_awesome, size: 24, color: Colors.white),
              ),
            ),
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(18),
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
                  topLeft: const Radius.circular(25),
                  topRight: const Radius.circular(25),
                  bottomLeft: Radius.circular(isUser ? 25 : 8),
                  bottomRight: Radius.circular(isUser ? 8 : 25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isUser ? effect["primaryColor"] : effect["accentColor"]).withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
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
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: effect["accentColor"].withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome, size: 14, color: effect["accentColor"]),
                          const SizedBox(width: 5),
                          Text(
                            "AI Learning Assistant",
                            style: TextStyle(
                              color: effect["accentColor"],
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Message content with formatting
                  ..._buildFormattedText(cleanText, isUser, effect),
                  
                  const SizedBox(height: 8),
                  
                  // Time stamp
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 10,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (isUser)
            // USER AVATAR
            Container(
              margin: const EdgeInsets.only(left: 8, bottom: 8),
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.grey, Color(0xFF2C3E50)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.person, size: 24, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  // ===== STYLISH TEXT FORMATTING =====
  List<Widget> _buildFormattedText(String text, bool isUser, Map<String, dynamic> effect) {
    List<Widget> widgets = [];
    List<String> lines = text.split('\n');
    
    for (String line in lines) {
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 6));
        continue;
      }
      
      // Headers with emoji
      if (line.contains('📖') || line.contains('📝') || line.contains('📚') ||
          line.contains('⚪') || line.contains('🔺') || line.contains('💡') ||
          line.contains('🧠') || line.contains('❤️') || line.contains('⚡')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Text(
              line,
              style: TextStyle(
                color: isUser ? Colors.white : effect["accentColor"],
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        );
      }
      // Bullet points
      else if (line.contains('•') || line.contains('·') || line.contains('  •')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 3, bottom: 3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: TextStyle(color: effect["accentColor"], fontSize: 16)),
                Expanded(
                  child: Text(
                    line.replaceAll('•', '').replaceAll('·', '').trim(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      // Formula/calculation blocks
      else if (line.contains('=') || line.contains('×') || line.contains('π') || line.contains('r²')) {
        widgets.add(
          Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUser 
                  ? Colors.white.withOpacity(0.15) 
                  : effect["primaryColor"].withOpacity(0.15),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: effect["accentColor"].withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              line,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace',
              ),
            ),
          ),
        );
      }
      // Numbers/Results
      else if (line.contains('✅') || line.contains('**') || line.contains('RESULT:')) {
        widgets.add(
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  effect["accentColor"].withOpacity(0.2),
                  effect["primaryColor"].withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              line.replaceAll('**', ''),
              style: TextStyle(
                color: effect["accentColor"],
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }
      // Regular text
      else {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              line,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                height: 1.3,
              ),
            ),
          ),
        );
      }
    }
    
    return widgets;
  }

  // ===== CINEMATIC TYPING INDICATOR =====
  Widget _buildTypingIndicator(Map<String, dynamic> effect) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [effect["primaryColor"], effect["secondaryColor"]],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: effect["primaryColor"].withOpacity(0.3),
                  blurRadius: 15,
                ),
              ],
            ),
            child: const Icon(Icons.auto_awesome, size: 22, color: Colors.white),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1E2A3A).withOpacity(0.95),
                  const Color(0xFF0A1929).withOpacity(0.95),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: effect["accentColor"].withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: effect["primaryColor"].withOpacity(0.2),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Row(
              children: List.generate(3, (index) {
                return AnimatedBuilder(
                  animation: _bgPulseController,
                  builder: (context, child) {
                    return Container(
                      width: 12,
                      height: 12,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            effect["accentColor"].withOpacity(0.5 + index * 0.2),
                            effect["primaryColor"].withOpacity(0.7 + index * 0.1),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: effect["accentColor"].withOpacity(0.3),
                            blurRadius: 5 + _bgPulseController.value * 3,
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