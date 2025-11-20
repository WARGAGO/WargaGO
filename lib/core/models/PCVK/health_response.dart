class HealthModelResponse {
  final String status;
  final String device;
  final int numClasses;
  final List<String> classNames;
  final List<String> availableModels;

  HealthModelResponse({
    required this.status,
    required this.device,
    required this.numClasses,
    required this.classNames,
    required this.availableModels,
  });

  factory HealthModelResponse.fromJson(Map<String, dynamic> json) {
    return HealthModelResponse(
      status: json['status'] as String,
      device: json['device'] as String,
      numClasses: json['num_classes'] as int,
      classNames: List<String>.from(json['class_names'] as List),
      availableModels: List<String>.from(json['available_models'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'device': device,
      'num_classes': numClasses,
      'class_names': classNames,
      'available_models': availableModels,
    };
  }

  @override
  String toString() {
    return 'ModelResponse(status: $status, device: $device, numClasses: $numClasses, classNames: $classNames, availableModels: $availableModels)';
  }
}
