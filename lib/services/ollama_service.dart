import 'dart:convert';
import 'package:http/http.dart' as http;

class OllamaService {
  final String baseUrl = 'http://localhost:11434';
  final String model = 'tinyllama';  // Fastest model
  
  // Cache for instant responses
  final Map<String, _CachedResponse> _cache = {};
  
  Future<String> generateResponse(String prompt) async {
    final cacheKey = prompt.trim().toLowerCase();
    
    // 🔥 CHECK CACHE FIRST (instant response)
    if (_cache.containsKey(cacheKey)) {
      final cached = _cache[cacheKey]!;
      if (DateTime.now().difference(cached.time) < const Duration(minutes: 5)) {
        print('⚡ CACHE HIT');
        return cached.response;
      }
    }
    
    try {
      print('🤔 AI thinking...');
      
      // 🔥 OPTIMIZED FOR SPEED
      final response = await http.post(
        Uri.parse('$baseUrl/api/generate'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'model': model,
          'prompt': "Answer in 3-4 lines: $prompt",  // Short prompt = fast
          'stream': false,
          'options': {
            'temperature': 0.2,        // Low = fast
            'num_predict': 150,         // Enough for complete answer
            'num_ctx': 1024,            // Small context = fast
            'top_k': 40,
            'top_p': 0.9,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String answer = data['response'] ?? '';
        
        // Clean up answer
        answer = answer.trim();
        if (answer.isEmpty) answer = "🤔 I'm thinking...";
        
        // 🔥 STORE IN CACHE
        _cache[cacheKey] = _CachedResponse(answer, DateTime.now());
        
        return answer;
      }
      
      return '❌ Error ${response.statusCode}';
      
    } catch (e) {
      print('⚠️ Error: $e');
      return '🤔 Please try again.';
    }
  }
}

class _CachedResponse {
  final String response;
  final DateTime time;
  _CachedResponse(this.response, this.time);
}