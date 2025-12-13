import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  GenerativeModel? _model;

  /// Initialize Gemini model with API key from .env
  void initialize() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];

    if (kDebugMode) {
      print('🔧 Initializing Gemini Service...');
      print('API Key exists: ${apiKey != null && apiKey.isNotEmpty}');
    }

    if (apiKey == null || apiKey.isEmpty || apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
      throw Exception(
        'Gemini API Key tidak ditemukan! Silakan set GEMINI_API_KEY di file .env'
      );
    }

    // List of model names to try (from most specific to most general)
    final modelNames = [
      'gemini-2.5-flash',
      'gemini-2.5-flash-lite'
    ];

    Exception? lastError;

    for (final modelName in modelNames) {
      try {
        if (kDebugMode) {
          print('Trying model: $modelName');
        }

        _model = GenerativeModel(
          model: modelName,
          apiKey: apiKey,
        );

        if (kDebugMode) {
          print('✅ Successfully initialized with model: $modelName');
        }
        return; // Success!

      } catch (e) {
        if (kDebugMode) {
          print('❌ Failed with $modelName: $e');
        }
        lastError = e as Exception;
        continue;
      }
    }

    // If we get here, all models failed
    throw Exception(
      'Gagal initialize Gemini dengan semua model yang dicoba. '
      'Last error: $lastError'
    );
  }

  /// Get recipe recommendations from PHOTO (Gemini Vision)
  /// With automatic retry mechanism and model fallback for server overload (503)
  Future<VegetableRecipeResponse> getRecipeRecommendationsFromPhoto({
    required String imagePath,
    required String vegetableName,
    int recipeCount = 3,
    int maxRetries = 3,
  }) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Gemini API Key tidak ditemukan!');
    }

    // List of models to try (fallback mechanism)
    final modelNames = [
      'gemini-2.5-flash',       // Primary model
      'gemini-2.5-flash-lite',  // Fallback model (lighter, less overloaded)
    ];

    Exception? lastError;

    // Try each model
    for (int modelIndex = 0; modelIndex < modelNames.length; modelIndex++) {
      final modelName = modelNames[modelIndex];

      if (kDebugMode) {
        if (modelIndex == 0) {
          print('🎯 Using primary model: $modelName');
        } else {
          print('🔄 Fallback to alternative model: $modelName');
        }
      }

      // Retry mechanism for current model
      for (int attempt = 1; attempt <= maxRetries; attempt++) {
        try {
          if (kDebugMode) {
            print('🔍 Model: $modelName - Attempt $attempt/$maxRetries for $vegetableName');
            print('📷 Analyzing photo: $imagePath');
          }

          // Create vision model
          final model = GenerativeModel(
            model: modelName,
            apiKey: apiKey,
          );

          // Read image file
          final imageFile = File(imagePath);
          final imageBytes = await imageFile.readAsBytes();

          // Build prompt
          final prompt = _buildVisionRecipePrompt(vegetableName, recipeCount);

          // Create content
          final content = [
            Content.multi([
              TextPart(prompt),
              DataPart('image/jpeg', imageBytes),
            ])
          ];

          if (kDebugMode) {
            print('📤 Sending photo to Gemini Vision ($modelName)...');
          }

          final response = await model.generateContent(content);

          if (kDebugMode) {
            print('📥 Response received from $modelName');
          }

          if (response.text == null || response.text!.isEmpty) {
            throw Exception('Empty response from Gemini Vision');
          }

          if (kDebugMode) {
            print('✅ Success with $modelName on attempt $attempt!');
          }

          return VegetableRecipeResponse(
            vegetableName: vegetableName,
            recipes: _parseRecipeResponse(response.text!),
            rawResponse: response.text!,
          );

        } catch (e) {
          lastError = e as Exception;

          if (kDebugMode) {
            print('❌ Model $modelName - Attempt $attempt failed: $e');
          }

          // Check if it's a 503 error (server overloaded)
          final errorMessage = e.toString().toLowerCase();
          final isServerOverloaded = errorMessage.contains('503') ||
                                     errorMessage.contains('overloaded') ||
                                     errorMessage.contains('unavailable');

          // If server overloaded
          if (isServerOverloaded) {
            if (kDebugMode) {
              print('⚠️  Server overloaded detected for model: $modelName');
            }

            // If this is the last model and last attempt, throw error
            if (modelIndex >= modelNames.length - 1 && attempt >= maxRetries) {
              if (kDebugMode) {
                print('❌ All models exhausted. Giving up.');
              }
              break;
            }

            // If we have more attempts for this model, retry with backoff
            if (attempt < maxRetries) {
              final waitTime = Duration(seconds: attempt * 2);
              if (kDebugMode) {
                print('⏳ Waiting ${waitTime.inSeconds}s before retry with same model...');
              }
              await Future.delayed(waitTime);
              continue; // Try again with same model
            }

            // If we exhausted retries for this model, try next model
            if (modelIndex < modelNames.length - 1) {
              if (kDebugMode) {
                print('🔄 Switching to fallback model...');
              }
              break; // Break inner loop to try next model
            }
          } else {
            // If it's not a 503 error, throw immediately
            if (kDebugMode) {
              print('❌ Non-503 error, not retrying: $e');
            }
            throw Exception('Error analisis foto dengan Gemini Vision: $e');
          }
        }
      }
    }

    // If we exhausted all models and retries
    throw Exception(
      'Gagal setelah mencoba semua model. Server Gemini sedang sangat sibuk. '
      'Silakan coba lagi dalam beberapa menit. Error: $lastError'
    );
  }

  /// Get recipe recommendations based on vegetable name (Text-only)
  /// With automatic retry mechanism and model fallback for server overload (503)
  Future<VegetableRecipeResponse> getRecipeRecommendations({
    required String vegetableName,
    int recipeCount = 3,
    int maxRetries = 3,
  }) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Gemini API Key tidak ditemukan!');
    }

    // List of models to try (fallback mechanism)
    final modelNames = [
      'gemini-2.5-flash',       // Primary model
      'gemini-2.5-flash-lite',  // Fallback model (lighter, less overloaded)
    ];

    Exception? lastError;

    // Try each model with retry mechanism
    for (int modelIndex = 0; modelIndex < modelNames.length; modelIndex++) {
      final modelName = modelNames[modelIndex];

      if (kDebugMode) {
        if (modelIndex == 0) {
          print('🎯 Using primary model: $modelName');
        } else {
          print('🔄 Fallback to alternative model: $modelName');
        }
      }

      // Retry mechanism for each model
      for (int attempt = 1; attempt <= maxRetries; attempt++) {
        try {
          if (kDebugMode) {
            print('🔍 Model: $modelName - Attempt $attempt/$maxRetries for $vegetableName');
          }

          // Create new model for each attempt
          final model = GenerativeModel(
            model: modelName,
            apiKey: apiKey,
          );

          final prompt = _buildRecipePrompt(vegetableName, recipeCount);
          final content = [Content.text(prompt)];

          if (kDebugMode) {
            print('📤 Sending request to Gemini ($modelName)...');
          }

          final response = await model.generateContent(content);

          if (kDebugMode) {
            print('📥 Response received from $modelName');
          }

          if (response.text == null || response.text!.isEmpty) {
            throw Exception('Empty response from Gemini');
          }

          if (kDebugMode) {
            print('✅ Success with model: $modelName on attempt $attempt');
          }

          // Success! Save this model for future use
          _model = model;

          return VegetableRecipeResponse(
            vegetableName: vegetableName,
            recipes: _parseRecipeResponse(response.text!),
            rawResponse: response.text!,
          );

        } on GenerativeAIException catch (e) {
          if (kDebugMode) {
            print('❌ Model $modelName - Attempt $attempt failed: ${e.message}');
          }

          // Check if it's quota exceeded error
          if (e.message.contains('quota exceeded') || e.message.contains('Quota exceeded')) {
            if (kDebugMode) {
              print('⚠️  Model $modelName has quota exceeded, trying next model...');
            }
            lastError = Exception('Quota exceeded: ${e.message}');
            break; // Skip to next model (no retry for quota)
          }

          // Check if it's a 503 error (server overloaded)
          final isServerOverloaded = e.message.contains('503') ||
                                     e.message.toLowerCase().contains('overloaded') ||
                                     e.message.toLowerCase().contains('unavailable');

          if (isServerOverloaded) {
            if (kDebugMode) {
              print('⚠️  Server overloaded detected for model: $modelName');
            }

            // If this is the last model and last attempt, throw error
            if (modelIndex >= modelNames.length - 1 && attempt >= maxRetries) {
              if (kDebugMode) {
                print('❌ All models exhausted. Giving up.');
              }
              lastError = Exception('Server overloaded: ${e.message}');
              break;
            }

            // If we have more attempts for this model, retry with backoff
            if (attempt < maxRetries) {
              final waitTime = Duration(seconds: attempt * 2); // Exponential backoff

              if (kDebugMode) {
                print('⏳ Waiting ${waitTime.inSeconds}s before retry with same model...');
              }

              await Future.delayed(waitTime);
              lastError = Exception('Server overloaded: ${e.message}');
              continue; // Try again with same model
            }

            // If we exhausted retries for this model, try next model
            if (modelIndex < modelNames.length - 1) {
              if (kDebugMode) {
                print('🔄 Switching to fallback model...');
              }
              lastError = Exception('Server overloaded: ${e.message}');
              break; // Try next model
            }
          }

          lastError = Exception('Gemini API Error: ${e.message}');

          // If last attempt or not server error, try next model
          if (attempt >= maxRetries || !isServerOverloaded) {
            break; // Try next model
          }

        } catch (e) {
          if (kDebugMode) {
            print('❌ Model $modelName - Attempt $attempt error: $e');
          }

          // Check if it's a 503 error in general exception
          final errorMessage = e.toString().toLowerCase();
          final isServerOverloaded = errorMessage.contains('503') ||
                                     errorMessage.contains('overloaded') ||
                                     errorMessage.contains('unavailable');

          if (isServerOverloaded) {
            if (kDebugMode) {
              print('⚠️  Server overloaded detected');
            }

            // If this is the last model and last attempt
            if (modelIndex >= modelNames.length - 1 && attempt >= maxRetries) {
              lastError = Exception('$e');
              break;
            }

            // If we have more attempts for this model, retry
            if (attempt < maxRetries) {
              final waitTime = Duration(seconds: attempt * 2);

              if (kDebugMode) {
                print('⏳ Waiting ${waitTime.inSeconds}s before retry...');
              }

              await Future.delayed(waitTime);
              lastError = Exception('$e');
              continue; // Try again
            }

            // Try next model
            if (modelIndex < modelNames.length - 1) {
              if (kDebugMode) {
                print('🔄 Switching to fallback model...');
              }
              lastError = Exception('$e');
              break;
            }
          }

          lastError = Exception('$e');

          // If last attempt, try next model
          if (attempt >= maxRetries) {
            break;
          }
        }
      }
    }

    // All models and retries failed
    throw lastError ?? Exception('Semua model gagal. Server Gemini sedang sangat sibuk. Silakan coba lagi nanti.');
  }

  String _buildVisionRecipePrompt(String vegetableName, int recipeCount) {
    return '''
Analisis foto sayuran ini (${vegetableName}) dan berikan $recipeCount rekomendasi resep masakan Indonesia.

PENTING: Perhatikan kondisi sayuran di foto:
- Tingkat kesegaran (segar/layu)
- Tingkat kematangan
- Ukuran dan bentuk
- Kualitas visual

Berikan rekomendasi resep yang COCOK dengan kondisi sayuran di foto ini.

Format response harus PERSIS seperti ini (gunakan ### sebagai separator antar resep):

NAMA_RESEP: [nama resep]
DESKRIPSI: [deskripsi singkat 1-2 kalimat, sebutkan kenapa cocok dengan kondisi sayuran di foto]
TINGKAT_KESULITAN: [Mudah/Sedang/Sulit]
WAKTU_MEMASAK: [estimasi dalam menit, contoh: 30 menit]
PORSI: [jumlah porsi, contoh: 4 porsi]

BAHAN:
- [bahan 1]
- [bahan 2]
- [dst...]

LANGKAH:
1. [langkah 1]
2. [langkah 2]
3. [dst...]

TIPS:
- [tip 1]
- [tip 2]
- [tip khusus berdasarkan kondisi sayuran di foto]

###

[Resep berikutnya dengan format yang sama...]

Pastikan:
1. Resep disesuaikan dengan kondisi sayuran di foto
2. Jika sayuran sangat segar → resep yang menonjolkan kesegaran (salad, tumis cepat)
3. Jika sayuran kurang segar → resep yang dimasak lama (sup, rebusan, kukus)
4. Sebutkan tips khusus sesuai kondisi sayuran
5. HARUS menggunakan format di atas PERSIS, jangan ada variasi format
''';
  }

  String _buildRecipePrompt(String vegetableName, int recipeCount) {
    return '''
Berikan $recipeCount rekomendasi resep masakan Indonesia yang cocok menggunakan $vegetableName.

Format response harus PERSIS seperti ini (gunakan ### sebagai separator antar resep):

NAMA_RESEP: [nama resep]
DESKRIPSI: [deskripsi singkat 1-2 kalimat]
TINGKAT_KESULITAN: [Mudah/Sedang/Sulit]
WAKTU_MEMASAK: [estimasi dalam menit, contoh: 30 menit]
PORSI: [jumlah porsi, contoh: 4 porsi]

BAHAN:
- [bahan 1]
- [bahan 2]
- [dst...]

LANGKAH:
1. [langkah 1]
2. [langkah 2]
3. [dst...]

TIPS:
- [tip 1]
- [tip 2]

###

[Resep berikutnya dengan format yang sama...]

Pastikan:
1. Semua resep menggunakan $vegetableName sebagai bahan utama
2. Resep mudah dipraktikkan untuk masyarakat Indonesia
3. Bahan-bahan mudah didapat
4. Langkah-langkah jelas dan detail
5. HARUS menggunakan format di atas PERSIS, jangan ada variasi format
''';
  }

  List<RecipeRecommendation> _parseRecipeResponse(String response) {
    try {
      final recipes = <RecipeRecommendation>[];
      final recipeSections = response.split('###').where((s) => s.trim().isNotEmpty).toList();

      for (final section in recipeSections) {
        try {
          final recipe = _parseRecipeSection(section.trim());
          if (recipe != null) {
            recipes.add(recipe);
          }
        } catch (e) {
          // Skip jika gagal parse satu resep
          continue;
        }
      }

      return recipes;
    } catch (e) {
      throw Exception('Error parsing recipe response: $e');
    }
  }

  RecipeRecommendation? _parseRecipeSection(String section) {
    try {
      String? name;
      String? description;
      String? difficulty;
      String? cookingTime;
      String? servings;
      List<String> ingredients = [];
      List<String> steps = [];
      List<String> tips = [];

      // Parse setiap line
      final lines = section.split('\n').where((l) => l.trim().isNotEmpty).toList();
      String currentSection = '';

      for (var line in lines) {
        line = line.trim();

        if (line.startsWith('NAMA_RESEP:')) {
          name = line.replaceFirst('NAMA_RESEP:', '').trim();
        } else if (line.startsWith('DESKRIPSI:')) {
          description = line.replaceFirst('DESKRIPSI:', '').trim();
        } else if (line.startsWith('TINGKAT_KESULITAN:')) {
          difficulty = line.replaceFirst('TINGKAT_KESULITAN:', '').trim();
        } else if (line.startsWith('WAKTU_MEMASAK:')) {
          cookingTime = line.replaceFirst('WAKTU_MEMASAK:', '').trim();
        } else if (line.startsWith('PORSI:')) {
          servings = line.replaceFirst('PORSI:', '').trim();
        } else if (line == 'BAHAN:') {
          currentSection = 'BAHAN';
        } else if (line == 'LANGKAH:') {
          currentSection = 'LANGKAH';
        } else if (line == 'TIPS:') {
          currentSection = 'TIPS';
        } else if (currentSection == 'BAHAN' && line.startsWith('-')) {
          ingredients.add(line.substring(1).trim());
        } else if (currentSection == 'LANGKAH' && RegExp(r'^\d+\.').hasMatch(line)) {
          steps.add(line.replaceFirst(RegExp(r'^\d+\.\s*'), '').trim());
        } else if (currentSection == 'TIPS' && line.startsWith('-')) {
          tips.add(line.substring(1).trim());
        }
      }

      // Validasi minimal data
      if (name == null || name.isEmpty) return null;
      if (ingredients.isEmpty) return null;
      if (steps.isEmpty) return null;

      return RecipeRecommendation(
        name: name,
        description: description ?? '',
        difficulty: difficulty ?? 'Sedang',
        cookingTime: cookingTime ?? '30 menit',
        servings: servings ?? '4 porsi',
        ingredients: ingredients,
        steps: steps,
        tips: tips,
      );
    } catch (e) {
      return null;
    }
  }
}

/// Response model untuk rekomendasi resep
class VegetableRecipeResponse {
  final String vegetableName;
  final List<RecipeRecommendation> recipes;
  final String rawResponse;

  VegetableRecipeResponse({
    required this.vegetableName,
    required this.recipes,
    required this.rawResponse,
  });

  bool get hasRecipes => recipes.isNotEmpty;
}

/// Model untuk satu resep
class RecipeRecommendation {
  final String name;
  final String description;
  final String difficulty;
  final String cookingTime;
  final String servings;
  final List<String> ingredients;
  final List<String> steps;
  final List<String> tips;
  final String source; // "AI Generated" atau "Cookpad", "Yummy", dll
  final bool aiGenerated; // true jika dari Gemini AI
  final String? referenceUrl; // URL ke resep asli jika ada

  RecipeRecommendation({
    required this.name,
    required this.description,
    required this.difficulty,
    required this.cookingTime,
    required this.servings,
    required this.ingredients,
    required this.steps,
    required this.tips,
    this.source = 'Gemini AI',
    this.aiGenerated = true,
    this.referenceUrl,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'difficulty': difficulty,
    'cookingTime': cookingTime,
    'servings': servings,
    'ingredients': ingredients,
    'steps': steps,
    'tips': tips,
    'source': source,
    'aiGenerated': aiGenerated,
    'referenceUrl': referenceUrl,
  };
}

