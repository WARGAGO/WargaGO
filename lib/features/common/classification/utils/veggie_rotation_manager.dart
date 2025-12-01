import 'dart:async';
import 'package:wargago/core/enums/predict_class_enum.dart';

class VeggieRotationManager {
  List<String> _vegetables = ['🍅', '🌶️', '🥕', '🥬', '🧄', '🧅', '🥒'];
  int _currentVeggieIndex = 0;
  Timer? _veggieTimer;
  final Function()? _onUpdate;

  VeggieRotationManager({Function()? onUpdate}) : _onUpdate = onUpdate;

  String get currentVeggie => _vegetables[_currentVeggieIndex];

  void startRotation(PredictClass predictedClass) {
    switch (predictedClass) {
      case PredictClass.sayurAkar:
        _vegetables = ['🥕', '🥔'];
        break;
      case PredictClass.sayurBuah:
        _vegetables = ['🫑', "🍅", '🥒', "🎃", '🥭'];
        break;
      case PredictClass.sayurBunga:
        _vegetables = ['🥦'];
        break;
      case PredictClass.sayurDaun:
        _vegetables = ['🥬'];
        break;
      default:
        _vegetables = ['🍅', '🌶️', '🥕', '🥬', '🧄', '🧅', '🥒'];
    }

    _veggieTimer?.cancel();
    _currentVeggieIndex = _currentVeggieIndex >= _vegetables.length
        ? 0
        : _currentVeggieIndex;

    _veggieTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      _currentVeggieIndex = (_currentVeggieIndex + 1) % _vegetables.length;
      _onUpdate?.call();
    });
  }

  void stopRotation() {
    _veggieTimer?.cancel();
  }

  void dispose() {
    _veggieTimer?.cancel();
  }
}
