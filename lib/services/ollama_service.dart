import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;

class OllamaService {
  final String baseUrl = 'http://localhost:11434';
  final String model = 'qwen2.5:1.5b';
  
  final Map<String, _CachedResponse> _cache = {};
  
  Future<String> generateResponse(String prompt) async {
    final cacheKey = prompt.trim().toLowerCase();
    
    if (_cache.containsKey(cacheKey)) {
      final cached = _cache[cacheKey]!;
      if (DateTime.now().difference(cached.time) < const Duration(minutes: 10)) {
        return cached.response;
      }
    }
    
    try {
      String systemPrompt = '''You are a school teacher for class 6 to 12 students.

STRICT RULES - FOLLOW EXACTLY:

1. Answer ONLY in simple and clear English
2. NEVER use LaTeX. No \\frac, no \\sqrt, no ^, no _
3. Write formulas in plain text only
   Example: Speed = Distance / Time
   Example: Area = π × r²
   Example: x = (-b ± √(b² - 4ac)) / (2a)
4. Always give COMPLETE answer, do not stop
5. Do NOT use hardcoded answers
6. Generate answer based on given question

FOR THEORY QUESTIONS (what is, define, explain):
   Definition: One line
   Formula: If applicable
   Final Answer: Short

FOR MATHS PROBLEMS (area, pythagoras, etc):
   Given: List values
   Formula: Write formula
   Solution: Step by step calculation
   Final Answer: Clear numeric answer

FOR FACTORIZATION:
   Step 1: Find factors
   Final Answer: (x + a)(x + b)

FOR DIRECT CALCULATION (add, subtract, pH):
   Give only the final numeric answer

FOR CHEMISTRY EQUATIONS:
   Use arrow →
   Example: 2H2 + O2 → 2H2O
   No extra explanation

IMPORTANT:
- Short, clear, complete
- Always end with: Final Answer
- Never stop mid-answer

Question: $prompt

Answer:''';
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/generate'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'model': model,
          'prompt': systemPrompt,
          'stream': false,
          'options': {
            'temperature': 0.1,
            'num_predict': 400,
            'num_ctx': 1024,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String answer = data['response'] ?? '';
        
        // Clean LaTeX
        answer = answer.replaceAll('\\[', '');
        answer = answer.replaceAll('\\]', '');
        answer = answer.replaceAll('\\(', '');
        answer = answer.replaceAll('\\)', '');
        answer = answer.replaceAll('\\frac', '');
        answer = answer.replaceAll('\\sqrt', '√');
        answer = answer.replaceAll('\\pm', '±');
        answer = answer.replaceAll('{', '(');
        answer = answer.replaceAll('}', ')');
        answer = answer.replaceAll('->', '→');
        answer = answer.replaceAll('^2', '²');
        
        // Chemistry subscripts
        answer = answer.replaceAll('H2', 'H₂');
        answer = answer.replaceAll('O2', 'O₂');
        answer = answer.replaceAll('Cl2', 'Cl₂');
        answer = answer.replaceAll('CO2', 'CO₂');
        answer = answer.replaceAll('H2O', 'H₂O');
        
        return answer;
      }
      
      return "Error: Please try again.";
      
    } catch (e) {
      return "Error: Check Ollama connection.";
    }
  }
  
  Future<String> generateResponseWithContext(String prompt, String context) async {
    return generateResponse(prompt);
  }
}

class _CachedResponse {
  final String response;
  final DateTime time;
  _CachedResponse(this.response, this.time);
}