import 'dart:convert';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../constants/api_constants.dart';

class AIService {
  late final GenerativeModel _model;

  AIService() {
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: ApiConstants.geminiApiKey,
    );
  }

  /// Recomenda um filme com base no prompt do usuário
  /// Retorna um Map com 'title' (String) e 'year' (int, opcional), 'reason' (String)
  Future<Map<String, dynamic>> recommendMovie(String userPrompt) async {
    try {
      final prompt =
          '''
      Atue como um especialista em cinema. O usuário vai descrever o que quer assistir.
      Sua tarefa é encontrar O MELHOR filme que corresponda à descrição.
      
      Regras:
      1. Retorne APENAS um JSON válido. Sem markdown, sem aspas extras fora do JSON.
      2. O JSON deve ter as chaves: "title" (título original ou em inglês para busca na API), "year" (ano de lançamento, int), "reason" (uma frase curta explicando pq escolheu esse filme, em pt-BR).
      3. Se o pedido for vago, escolha um filme popular e aclamado que se encaixe.
      4. Se o pedido for impossível ou ofensivo, retorne um JSON com "error": "mensagem de erro amigável".
      
      Pedido do usuário: "$userPrompt"
      ''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      final responseText = response.text;
      if (responseText == null) throw 'Sem resposta da IA';

      // Limpa possíveis marcações de código markdown (```json ... ```)
      final cleanJson = responseText
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      return jsonDecode(cleanJson) as Map<String, dynamic>;
    } catch (e) {
      // Falha no pacote? Tenta via HTTP direto (fallback robusto)
      try {
        return await _recommendMovieRawHttp(userPrompt);
      } catch (httpError) {
        // Se ambos falharem, tenta listar modelos para debug
        String debugInfo = '';
        try {
          final availableModels = await _listAvailableModels();
          if (availableModels.isNotEmpty) {
            debugInfo =
                '\n\nModelos disponíveis: ${availableModels.join(', ')}';
          } else {
            debugInfo =
                '\n\nNão consegui listar modelos (verifique sua API Key).';
          }
        } catch (_) {}

        throw 'Erro no pacote: $e\nErro HTTP: $httpError$debugInfo';
      }
    }
  }

  /// Fallback: Chama API via HTTP direto (bypassing package)
  Future<Map<String, dynamic>> _recommendMovieRawHttp(String userPrompt) async {
    final client = HttpClient();
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${ApiConstants.geminiApiKey}',
    );

    final prompt =
        '''
      Atue como um especialista em cinema. 
      Regras:
      1. Retorne APENAS um JSON válido : {"title": "Nome do Filme", "year": 2000, "reason": "Motivo"}.
      3. Se pedido vago, escolha um popular.
      
      Pedido: "$userPrompt"
    ''';

    final request = await client.postUrl(uri);
    request.headers.contentType = ContentType.json;
    request.write(
      jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt},
            ],
          },
        ],
      }),
    );

    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();

    if (response.statusCode != 200) {
      throw 'API HTTP Error: ${response.statusCode} - $body';
    }

    final json = jsonDecode(body);
    final text = json['candidates']?[0]?['content']?['parts']?[0]?['text'];

    if (text == null) throw 'Sem resposta da API Raw';

    final cleanJson = (text as String)
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    return jsonDecode(cleanJson);
  }

  /// Lista modelos disponíveis usando API REST direta (para debug)
  Future<List<String>> _listAvailableModels() async {
    try {
      final client = HttpClient();
      final uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models?key=${ApiConstants.geminiApiKey}',
      );

      final request = await client.getUrl(uri);
      final response = await request.close();

      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final json = jsonDecode(body);
        final models = (json['models'] as List)
            .map((m) => m['name'] as String)
            .toList();
        return models
            .where((m) => m.contains('gemini'))
            .toList(); // Filtra apenas gemini
      }
    } catch (_) {}
    return [];
  }
}
