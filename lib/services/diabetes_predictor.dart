import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../models/patient.dart';

/// خدمة تشغيل نموذج TensorFlow Lite للتنبؤ
class DiabetesPredictor {
  static final DiabetesPredictor _instance = DiabetesPredictor._internal();
  factory DiabetesPredictor() => _instance;
  DiabetesPredictor._internal();

  Interpreter? _interpreter;
  Map<String, dynamic>? _modelInfo;
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  /// تحميل النموذج وملف المعلومات من assets
  Future<void> loadModel() async {
    if (_isLoaded) return;
    try {
      _interpreter =
          await Interpreter.fromAsset('assets/model/diabetes_model.tflite');
      final infoString =
          await rootBundle.loadString('assets/model/model_info.json');
      _modelInfo = json.decode(infoString);
      _isLoaded = true;
    } catch (e) {
      rethrow;
    }
  }

  /// التنبؤ من بيانات مريض
  PredictionResult predict(Patient patient) {
    if (!_isLoaded || _interpreter == null || _modelInfo == null) {
      throw Exception('النموذج غير محمّل');
    }

    final genderEncoded = patient.gender == 'Male' ? 0.0 : 1.0;
    final activityEncoded = patient.physicalActivity == 'Low'
        ? 0.0
        : patient.physicalActivity == 'Medium'
            ? 1.0
            : 2.0;

    final features = <double>[
      patient.age,
      genderEncoded,
      patient.weightKg,
      patient.heightCm,
      patient.idealWeightKg,
      patient.bmi,
      patient.glucose,
      patient.bloodPressure,
      patient.insulin,
      patient.pregnancies.toDouble(),
      patient.familyHistory ? 1.0 : 0.0,
      activityEncoded,
      patient.diabetesPedigree,
    ];

    // تطبيع البيانات (StandardScaler)
    final means = (_modelInfo!['feature_means'] as List).cast<num>();
    final stds = (_modelInfo!['feature_stds'] as List).cast<num>();
    final normalized = List<double>.generate(
      features.length,
      (i) => (features[i] - means[i].toDouble()) / stds[i].toDouble(),
    );

    final input = [normalized];
    final output = List.filled(1 * 3, 0.0).reshape([1, 3]);

    _interpreter!.run(input, output);

    final probabilities = (output[0] as List).cast<double>();
    int predictedClass = 0;
    double maxProb = probabilities[0];
    for (int i = 1; i < probabilities.length; i++) {
      if (probabilities[i] > maxProb) {
        maxProb = probabilities[i];
        predictedClass = i;
      }
    }

    final labels = (_modelInfo!['labels'] as List).cast<String>();
    final labelsAr = (_modelInfo!['labels_ar'] as List).cast<String>();

    return PredictionResult(
      riskLevel: labels[predictedClass],
      riskLevelAr: labelsAr[predictedClass],
      confidence: maxProb,
      probabilities: {
        'Low': probabilities[0],
        'Medium': probabilities[1],
        'High': probabilities[2],
      },
    );
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isLoaded = false;
  }
}

class PredictionResult {
  final String riskLevel;
  final String riskLevelAr;
  final double confidence;
  final Map<String, double> probabilities;

  PredictionResult({
    required this.riskLevel,
    required this.riskLevelAr,
    required this.confidence,
    required this.probabilities,
  });
}
