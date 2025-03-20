
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiServices {
  static const String apiKey = 'AIzaSyCp5SjdmmbYpwKF6HrUZQvEA_HNvrzSmTA';

  static Future<Map<String, dynamic>> generateRecipe(
      List<Map<String, dynamic>> foods) async {
    final prompt = _buildPrompt(foods);
    final model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 1,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 8192,
        responseMimeType: 'text/plain',
      ),
    );

    final chat = model.startChat(history: [
      Content.multi([
        TextPart(
            'Kamu adalah AI ahli dalam dunia kuliner. '
            'Ketika pengguna menyebutkan nama makanan, berikan resep dalam format JSON dengan tambahan **emoji** agar lebih menarik. '
            'Gunakan format berikut:\n\n'
            '```json\n'
            '{\n'
            '  "nama_makanan": "🍛 <nama_makanan>",\n'
            '  "bahan": [\n'
            '    "🍚 <bahan 1>",\n'
            '    "🧄 <bahan 2>"\n'
            '  ],\n'
            '  "langkah": [\n'
            '    "1️⃣ <langkah 1>",\n'
            '    "2️⃣ <langkah 2>"\n'
            '  ]\n'
            '}\n'
            '```\n'
            '⚠️ **Jangan berikan teks tambahan di luar JSON!**'),
      ]),
    ]);

    try {
      final response = await chat.sendMessage(Content.text(prompt));
      final responseText =
          (response.candidates.first.content.parts.first as TextPart).text;

      print("Raw API Response: $responseText"); 

      if (responseText.isEmpty) {
        return {"error": "Respon kosong dari AI."};
      }


      final jsonMatch =
          RegExp(r'```json\n([\s\S]*?)\n```').firstMatch(responseText);

      if (jsonMatch != null) {
        return jsonDecode(jsonMatch.group(1)!);
      }


      return jsonDecode(responseText);
    } catch (e) {
      return {"error": "Gagal menghasilkan resep: $e"};
    }
  }

  static String _buildPrompt(List<Map<String, dynamic>> foods) {
    String foodList =
        foods.map((food) => "- ${food['nama_makanan']}").join("\n");
    return "Saya ingin membuat makanan berikut:\n$foodList\n"
        "Berikan resep lengkap dalam format JSON valid dengan format berikut:\n"
        "```json\n"
        "{\n"
        '  "nama_makanan": "🍛 <nama_makanan>",\n'
        '  "bahan": [\n'
        '    "🍚 <bahan 1>",\n'
        '    "🧄 <bahan 2>"\n'
        '  ],\n'
        '  "langkah": [\n'
        '    "1️⃣ <langkah 1>",\n'
        '    "2️⃣ <langkah 2>"\n'
        '  ]\n'
        "}\n"
        "```\n"
        "⚠️ **Jangan berikan teks tambahan di luar JSON!**";
  }
}
