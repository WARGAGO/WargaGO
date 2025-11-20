class ModelsModelResponse {
  final bool loaded;
  final String? architecture;
  final String? hiddenLayers;
  final double dropout;
  final List<String>? features;

  ModelsModelResponse({
    required this.loaded,
    this.architecture,
    this.hiddenLayers,
    this.dropout = 0,
    this.features,
  });

  factory ModelsModelResponse.fromJson(Map<String, dynamic> json) {
    return ModelsModelResponse(
      loaded: json['loaded'] as bool,
      architecture: json['architecture'] as String?,
      hiddenLayers: json['hidden_layers'] as String?,
      dropout: json['dropout'],
      features: json['features'] != null
          ? List<String>.from(json['features'] as List)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
