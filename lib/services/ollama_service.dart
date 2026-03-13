import 'dart:convert';
import 'package:http/http.dart' as http;

class OllamaService {
  final String baseUrl = 'http://localhost:11434';
  //final String model = 'llama3.2'; 
  final String model = 'qwen2.5:1.5b';// ya jo bhi model ho 
  
  Future<String> generateResponse(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/generate'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'model': model,
          'prompt': "You are a helpful learning assistant for students. Answer this question: $prompt",
          'stream': false,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['response'] ?? 'No response';
      }
      return 'Error: ${response.statusCode}';
    } catch (e) {
      return '⚠️ AI offline. Please check Ollama.';
    }
  }
}