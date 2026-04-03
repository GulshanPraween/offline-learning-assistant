import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class RagService {
  static Database? _database;
  static const String tableName = 'ncert_chunks';
  
  // ===== INITIALIZE DATABASE =====
  static Future<void> init() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/ncert_rag.db';
      
      _database = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE $tableName (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              content TEXT NOT NULL,
              subject TEXT NOT NULL,
              class_level TEXT NOT NULL,
              keywords TEXT
            )
          ''');
          
          // Create index for faster search
          await db.execute('CREATE INDEX idx_subject ON $tableName(subject)');
        },
      );
      
      // Check if database is empty
      final count = Sqflite.firstIntValue(
        await _database!.rawQuery('SELECT COUNT(*) FROM $tableName')
      );
      
      if (count == 0) {
        await _loadNcertData();
      }
      
      print('✅ RAG Service initialized');
    } catch (e) {
      print('❌ RAG Service init error: $e');
    }
  }
  
  // ===== LOAD NCERT DATA =====
  static Future<void> _loadNcertData() async {
    await _addMathsData();
    await _addScienceData();
    await _addComputerData();
    await _addEnglishData();
    await _addHistoryData();
    await _addGeographyData();
    
    print('✅ All NCERT data loaded');
  }
  
  // ===== MATHS DATA =====
  static Future<void> _addMathsData() async {
    final chunks = [
      {
        'content': 'Pythagoras theorem: In a right-angled triangle, the square of the hypotenuse equals the sum of squares of the other two sides. Formula: a² + b² = c². Example: If a = 3, b = 4, then c = 5.',
        'subject': 'maths',
        'class_level': '10',
        'keywords': 'pythagoras theorem right triangle hypotenuse formula a² b² c²'
      },
      {
        'content': 'Area of circle: A = π × r², where π = 3.14159. Example: If radius r = 7 cm, then area = 3.14159 × 49 = 153.94 cm².',
        'subject': 'maths',
        'class_level': '7',
        'keywords': 'circle area formula π r² radius'
      },
      {
        'content': 'Area of triangle: A = ½ × base × height. Example: base = 8 cm, height = 5 cm, area = 0.5 × 8 × 5 = 20 cm².',
        'subject': 'maths',
        'class_level': '7',
        'keywords': 'triangle area formula base height ½'
      },
      {
        'content': 'Area of rectangle: A = length × width. Perimeter of rectangle: P = 2 × (length + width). Example: length = 10 cm, width = 5 cm, area = 50 cm², perimeter = 30 cm.',
        'subject': 'maths',
        'class_level': '6',
        'keywords': 'rectangle area perimeter length width'
      },
      {
        'content': 'Area of square: A = side². Perimeter of square: P = 4 × side. Example: side = 7 cm, area = 49 cm², perimeter = 28 cm.',
        'subject': 'maths',
        'class_level': '6',
        'keywords': 'square area perimeter side'
      },
      {
        'content': 'LCM (Least Common Multiple): Smallest common multiple of two numbers. Example: LCM of 4 and 6 is 12. How to find: List multiples - 4:4,8,12,16; 6:6,12,18 → smallest common is 12.',
        'subject': 'maths',
        'class_level': '6',
        'keywords': 'lcm least common multiple multiples'
      },
      {
        'content': 'HCF (Highest Common Factor): Largest common factor of two numbers. Example: HCF of 12 and 18 is 6. Factors: 12:1,2,3,4,6,12; 18:1,2,3,6,9,18 → highest common is 6.',
        'subject': 'maths',
        'class_level': '6',
        'keywords': 'hcf gcd highest common factor'
      },
      {
        'content': 'Ratio: Comparison of two quantities. To simplify ratio, divide both numbers by their HCF. Example: Ratio 8:12 simplifies to 2:3 (divide both by 4).',
        'subject': 'maths',
        'class_level': '6',
        'keywords': 'ratio simplify comparison quantities'
      },
      {
        'content': 'Percentage: Part per hundred. Formula: (part/whole) × 100. Example: 25 out of 50 = (25/50) × 100 = 50%.',
        'subject': 'maths',
        'class_level': '7',
        'keywords': 'percentage percent part whole'
      },
      {
        'content': 'Addition: Adding two numbers. Example: 25 + 35 = 60. How to add: Align numbers by place value and add digit by digit.',
        'subject': 'maths',
        'class_level': '6',
        'keywords': 'addition plus sum add'
      },
      {
        'content': 'Subtraction: Taking away one number from another. Example: 50 - 20 = 30. How to subtract: Subtract smaller from larger.',
        'subject': 'maths',
        'class_level': '6',
        'keywords': 'subtraction minus difference subtract'
      },
      {
        'content': 'Multiplication: Repeated addition. Example: 12 × 8 = 96. How to multiply: Add the number repeatedly 12 + 12 + 12 + 12 + 12 + 12 + 12 + 12 = 96.',
        'subject': 'maths',
        'class_level': '6',
        'keywords': 'multiplication times product multiply'
      },
      {
        'content': 'Division: Splitting into equal parts. Example: 144 ÷ 12 = 12. How to divide: How many times does 12 go into 144? 12 × 12 = 144.',
        'subject': 'maths',
        'class_level': '6',
        'keywords': 'division divided quotient divide'
      },
    ];
    
    for (var chunk in chunks) {
      await _database!.insert(tableName, chunk);
    }
    print('✅ Maths data added (${chunks.length} chunks)');
  }
  
  // ===== SCIENCE DATA =====
  static Future<void> _addScienceData() async {
    final chunks = [
      {
        'content': 'Photosynthesis: Process by which plants make food using sunlight, water and carbon dioxide. Formula: 6CO₂ + 6H₂O → C₆H₁₂O₆ + 6O₂. Example: A leaf uses sunlight to produce glucose and oxygen.',
        'subject': 'science',
        'class_level': '7',
        'keywords': 'photosynthesis plants food sunlight water co2 oxygen glucose'
      },
      {
        'content': 'Human Heart: Muscular organ that pumps blood throughout body. Has 4 chambers - Right Atrium, Right Ventricle, Left Atrium, Left Ventricle. Beats 60-100 times per minute.',
        'subject': 'science',
        'class_level': '7',
        'keywords': 'heart chambers atrium ventricle blood pump'
      },
      {
        'content': 'Human Brain: Control center of body. Parts: Cerebrum (thinking, memory), Cerebellum (balance, coordination), Brainstem (breathing, heartbeat).',
        'subject': 'science',
        'class_level': '10',
        'keywords': 'brain cerebrum cerebellum brainstem thinking balance'
      },
      {
        'content': 'Lungs: Organs that help us breathe. Function: Inhale oxygen, exhale carbon dioxide. Normal rate: 12-20 breaths per minute.',
        'subject': 'science',
        'class_level': '7',
        'keywords': 'lungs breathing oxygen carbon dioxide'
      },
      {
        'content': 'Human Eye: Organ that detects light. Parts: Cornea (bends light), Pupil (controls light entry), Lens (focuses light), Retina (captures image).',
        'subject': 'science',
        'class_level': '8',
        'keywords': 'eye cornea pupil lens retina vision'
      },
      {
        'content': 'Cell: Basic structural and functional unit of life. Parts: Nucleus (control center), Mitochondria (power house), Cell Membrane (boundary).',
        'subject': 'science',
        'class_level': '8',
        'keywords': 'cell nucleus mitochondria membrane biology'
      },
      {
        'content': 'Reflection of Light: Bouncing back of light from a surface. Laws: 1) Angle of incidence = Angle of reflection, 2) Incident ray, reflected ray, normal lie in same plane.',
        'subject': 'science',
        'class_level': '8',
        'keywords': 'reflection light incidence angle mirror'
      },
      {
        'content': 'Series Circuit: Circuit where components connected end-to-end in single path. Properties: Same current everywhere. R_total = R₁ + R₂ + R₃. If one component fails, circuit breaks.',
        'subject': 'science',
        'class_level': '10',
        'keywords': 'series circuit current resistance total'
      },
      {
        'content': "Ohm's Law: Relationship between voltage, current and resistance. Formula: V = I × R. Voltage = Current × Resistance. Example: I = 2A, R = 5Ω, V = 10V.",
        'subject': 'science',
        'class_level': '10',
        'keywords': "ohm's law voltage current resistance v=i×r"
      },
      {
        'content': "Newton's First Law: Object at rest stays at rest, object in motion stays in motion unless acted by external force. Example: A book on table stays still until pushed.",
        'subject': 'science',
        'class_level': '9',
        'keywords': "newton first law inertia motion force"
      },
      {
        'content': "Newton's Second Law: Force equals mass times acceleration. Formula: F = m × a. Example: m = 2kg, a = 3m/s², F = 6N.",
        'subject': 'science',
        'class_level': '9',
        'keywords': "newton second law force mass acceleration f=ma"
      },
      {
        'content': "Newton's Third Law: Every action has equal and opposite reaction. Example: When you push wall, wall pushes you back.",
        'subject': 'science',
        'class_level': '9',
        'keywords': "newton third law action reaction"
      },
      {
        'content': 'Gravity: Force that attracts objects towards Earth. Formula: F = m × g, where g = 9.8 m/s². Example: 10kg object weighs 98N on Earth.',
        'subject': 'science',
        'class_level': '9',
        'keywords': 'gravity weight mass g force'
      },
    ];
    
    for (var chunk in chunks) {
      await _database!.insert(tableName, chunk);
    }
    print('✅ Science data added (${chunks.length} chunks)');
  }
  
  // ===== COMPUTER SCIENCE DATA =====
  static Future<void> _addComputerData() async {
    final chunks = [
      {
        'content': 'Java OOPs - 4 Pillars: 1) Encapsulation: Bundle data and methods, hide details using private. 2) Inheritance: Child inherits parent properties using extends. 3) Polymorphism: Same method different behaviors (overloading/overriding). 4) Abstraction: Hide implementation, show functionality using abstract classes and interfaces.',
        'subject': 'computer',
        'class_level': '11',
        'keywords': 'java oops encapsulation inheritance polymorphism abstraction pillars'
      },
    ];
    
    for (var chunk in chunks) {
      await _database!.insert(tableName, chunk);
    }
    print('✅ Computer data added');
  }
  
  // ===== ENGLISH DATA =====
  static Future<void> _addEnglishData() async {
    final chunks = [
      {
        'content': 'Noun: A word that names a person, place, thing, or idea. Types: Proper (John), Common (city), Collective (team), Abstract (love). Example: The dog is barking - dog is noun.',
        'subject': 'english',
        'class_level': '6',
        'keywords': 'noun naming word person place thing idea'
      },
      {
        'content': 'Verb: A word that describes an action, occurrence, or state of being. Example: She runs fast - runs is verb.',
        'subject': 'english',
        'class_level': '6',
        'keywords': 'verb action word doing word'
      },
      {
        'content': 'Adjective: A word that describes or modifies a noun. Example: The beautiful flower - beautiful is adjective.',
        'subject': 'english',
        'class_level': '6',
        'keywords': 'adjective describing word modifies noun'
      },
      {
        'content': 'Adverb: A word that modifies a verb, adjective, or another adverb. Example: She sings beautifully - beautifully is adverb.',
        'subject': 'english',
        'class_level': '6',
        'keywords': 'adverb modifies verb how when where'
      },
      {
        'content': 'Tense: Time of action. Three types: Past (ate), Present (eat), Future (will eat). Example: I eat now (present), I ate yesterday (past), I will eat tomorrow (future).',
        'subject': 'english',
        'class_level': '6',
        'keywords': 'tense past present future time action'
      },
    ];
    
    for (var chunk in chunks) {
      await _database!.insert(tableName, chunk);
    }
    print('✅ English data added');
  }
  
  // ===== HISTORY DATA =====
  static Future<void> _addHistoryData() async {
    final chunks = [
      {
        'content': 'Indian Independence: India gained freedom from British rule on August 15, 1947. Key leaders: Mahatma Gandhi, Jawaharlal Nehru, Sardar Patel. Key movements: Non-cooperation, Civil Disobedience, Quit India.',
        'subject': 'history',
        'class_level': '8',
        'keywords': 'indian independence 1947 gandhi nehru patel'
      },
      {
        'content': 'Mahatma Gandhi: Born October 2, 1869. Father of the Nation. Led India\'s freedom movement using non-violence (Ahimsa). Key movements: Non-cooperation (1920), Civil Disobedience (1930), Quit India (1942).',
        'subject': 'history',
        'class_level': '8',
        'keywords': 'gandhi mahatma father of nation ahimsa non-violence'
      },
    ];
    
    for (var chunk in chunks) {
      await _database!.insert(tableName, chunk);
    }
    print('✅ History data added');
  }
  
  // ===== GEOGRAPHY DATA =====
  static Future<void> _addGeographyData() async {
    final chunks = [
      {
        'content': 'Latitude: Horizontal lines running east-west, measuring north-south position. Equator is 0° latitude. Important latitudes: Tropic of Cancer (23.5°N), Tropic of Capricorn (23.5°S).',
        'subject': 'geography',
        'class_level': '9',
        'keywords': 'latitude equator tropic cancer capricorn'
      },
      {
        'content': 'Longitude: Vertical lines running north-south, measuring east-west position. Prime Meridian is 0° longitude (Greenwich, UK). 180° is International Date Line.',
        'subject': 'geography',
        'class_level': '9',
        'keywords': 'longitude prime meridian greenwich date line'
      },
    ];
    
    for (var chunk in chunks) {
      await _database!.insert(tableName, chunk);
    }
    print('✅ Geography data added');
  }
  
  // ===== SEARCH FUNCTION =====
  static Future<List<String>> search(String query, {int limit = 3}) async {
    if (_database == null) {
      await init();
    }
    
    try {
      final keywords = query.toLowerCase().split(' ');
      
      // Build search query
      String whereClause = '';
      List<String> whereArgs = [];
      
      for (var keyword in keywords) {
        if (keyword.length > 2) { // Ignore small words like 'is', 'a', 'of'
          if (whereClause.isNotEmpty) {
            whereClause += ' OR ';
          }
          whereClause += 'content LIKE ? OR keywords LIKE ?';
          whereArgs.add('%$keyword%');
          whereArgs.add('%$keyword%');
        }
      }
      
      if (whereClause.isEmpty) {
        return [];
      }
      
      final results = await _database!.query(
        tableName,
        where: whereClause,
        whereArgs: whereArgs,
        limit: limit,
      );
      
      return results.map((row) => row['content'] as String).toList();
      
    } catch (e) {
      print('❌ Search error: $e');
      return [];
    }
  }
  
  // ===== SEARCH BY SUBJECT =====
  static Future<List<String>> searchBySubject(String query, String subject, {int limit = 3}) async {
    if (_database == null) {
      await init();
    }
    
    try {
      final keywords = query.toLowerCase().split(' ');
      
      String whereClause = 'subject = ?';
      List<String> whereArgs = [subject];
      
      for (var keyword in keywords) {
        if (keyword.length > 2) {
          whereClause += ' AND (content LIKE ? OR keywords LIKE ?)';
          whereArgs.add('%$keyword%');
          whereArgs.add('%$keyword%');
        }
      }
      
      final results = await _database!.query(
        tableName,
        where: whereClause,
        whereArgs: whereArgs,
        limit: limit,
      );
      
      return results.map((row) => row['content'] as String).toList();
      
    } catch (e) {
      print('❌ Search by subject error: $e');
      return [];
    }
  }
  
  // ===== CLOSE DATABASE =====
  static Future<void> close() async {
    await _database?.close();
  }
}