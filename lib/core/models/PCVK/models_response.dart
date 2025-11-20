class ModelsModel {
  final String name;
  final bool loaded;
  final String? architecture;
  final String? hiddenLayers;
  final double dropout;
  final List<String>? features;

  ModelsModel({
    required this.name,
    required this.loaded,
    this.architecture,
    this.hiddenLayers,
    this.dropout = 0,
    this.features,
  });

  factory ModelsModel.fromJson(Map<String, dynamic> json) {
    return ModelsModel(
      name: json['name'] ?? '',
      loaded: json['loaded'] as bool,
      architecture: json['architecture'] as String?,
      hiddenLayers: json['hidden_layers'] as String?,
      dropout: json['dropout'] != null
          ? (json['dropout'] is String
                ? 0.0
                : (json['dropout'] as num).toDouble())
          : 0.0,
      features: json['features'] != null
          ? List<String>.from(json['features'] as List)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'loaded': loaded,
      'architecture': architecture,
      'hidden_layers': hiddenLayers,
      'dropout': dropout,
      'features': features,
    };
  }

  @override
  String toString() {
    return 'ModelDetail(loaded: $loaded, architecture: $architecture, hiddenLayers: $hiddenLayers, dropout: $dropout, features: $features)';
  }
}

class ModelsModelResponse {
  final List<String> availableModels;
  final int totalModels;
  final Map<String, ModelsModel> models;

  ModelsModelResponse({
    required this.availableModels,
    required this.totalModels,
    required this.models,
  });

  factory ModelsModelResponse.fromJson(Map<String, dynamic> json) {
    final modelsMap = <String, ModelsModel>{};
    final modelsData = json['models'] as Map<String, dynamic>;

    modelsData.forEach((key, value) {
      final modelJson = value as Map<String, dynamic>;
      modelJson['name'] = key;
      modelsMap[key] = ModelsModel.fromJson(modelJson);
    });

    return ModelsModelResponse(
      availableModels: List<String>.from(json['available_models'] as List),
      totalModels: json['total_models'] as int,
      models: modelsMap,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'available_models': availableModels,
      'total_models': totalModels,
      'models': models.map((key, value) => MapEntry(key, value.toJson())),
    };
  }

  @override
  String toString() {
    return 'ModelsModelResponse(availableModels: $availableModels, totalModels: $totalModels, models: $models)';
  }
}
