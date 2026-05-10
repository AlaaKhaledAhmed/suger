/// نموذج بيانات المريض
class Patient {
  final String patientId;
  final String patientName;
  final double age;
  final String gender;
  final double weightKg;
  final double heightCm;
  final double idealWeightKg;
  final double bmi;
  final double glucose;
  final double bloodPressure;
  final double insulin;
  final int pregnancies;
  final bool familyHistory;
  final String physicalActivity;
  final double diabetesPedigree;

  Patient({
    required this.patientId,
    required this.patientName,
    required this.age,
    required this.gender,
    required this.weightKg,
    required this.heightCm,
    required this.idealWeightKg,
    required this.bmi,
    required this.glucose,
    required this.bloodPressure,
    required this.insulin,
    required this.pregnancies,
    required this.familyHistory,
    required this.physicalActivity,
    required this.diabetesPedigree,
  });

  /// إنشاء Patient مع حساب BMI و idealWeight تلقائياً
  factory Patient.create({
    String patientId = '',
    String patientName = '',
    required double age,
    required String gender,
    required double weightKg,
    required double heightCm,
    required double glucose,
    required double bloodPressure,
    required double insulin,
    required int pregnancies,
    required bool familyHistory,
    required String physicalActivity,
    required double diabetesPedigree,
  }) {
    final hM = heightCm / 100;
    final bmi = hM > 0 ? weightKg / (hM * hM) : 0.0;
    final idealWeight = gender == 'Male'
        ? (heightCm - 100) * 0.9
        : (heightCm - 100) * 0.85;

    return Patient(
      patientId: patientId,
      patientName: patientName,
      age: age,
      gender: gender,
      weightKg: weightKg,
      heightCm: heightCm,
      idealWeightKg: idealWeight,
      bmi: bmi,
      glucose: glucose,
      bloodPressure: bloodPressure,
      insulin: insulin,
      pregnancies: pregnancies,
      familyHistory: familyHistory,
      physicalActivity: physicalActivity,
      diabetesPedigree: diabetesPedigree,
    );
  }

  static double _toDouble(dynamic v, {double defaultVal = 0}) {
    if (v == null) return defaultVal;
    if (v is num) return v.toDouble();
    final s = v.toString().trim();
    if (s.isEmpty) return defaultVal;
    return double.tryParse(s) ?? defaultVal;
  }

  static int _toInt(dynamic v, {int defaultVal = 0}) {
    if (v == null) return defaultVal;
    if (v is num) return v.toInt();
    final s = v.toString().trim();
    if (s.isEmpty) return defaultVal;
    return int.tryParse(s) ?? defaultVal;
  }

  static String _toString(dynamic v, {String defaultVal = ''}) {
    if (v == null) return defaultVal;
    return v.toString().trim();
  }

  /// إنشاء Patient من صف في Excel
  factory Patient.fromRow(List<dynamic> row, {Map<String, int>? columnMap}) {
    columnMap ??= {
      'patient_id': 0,
      'patient_name': 1,
      'age': 2,
      'gender': 3,
      'weight_kg': 4,
      'height_cm': 5,
      'ideal_weight_kg': 6,
      'bmi': 7,
      'glucose_mg_dl': 8,
      'blood_pressure': 9,
      'insulin': 10,
      'pregnancies': 11,
      'family_history': 12,
      'physical_activity': 13,
      'diabetes_pedigree': 14,
    };

    dynamic getCell(String key) {
      final idx = columnMap![key];
      if (idx == null || idx >= row.length) return null;
      return row[idx];
    }

    final weight = _toDouble(getCell('weight_kg'));
    final height = _toDouble(getCell('height_cm'), defaultVal: 170);
    final gender = _toString(getCell('gender'), defaultVal: 'Male');

    var idealWeight = _toDouble(getCell('ideal_weight_kg'));
    if (idealWeight == 0 && height > 0) {
      idealWeight = gender == 'Male'
          ? (height - 100) * 0.9
          : (height - 100) * 0.85;
    }

    var bmi = _toDouble(getCell('bmi'));
    if (bmi == 0 && height > 0 && weight > 0) {
      final hM = height / 100;
      bmi = weight / (hM * hM);
    }

    final fhRaw = getCell('family_history');
    bool familyHistory = false;
    if (fhRaw != null) {
      final s = fhRaw.toString().toLowerCase().trim();
      familyHistory = s == '1' || s == 'true' || s == 'yes' || s == 'نعم';
    }

    return Patient(
      patientId: _toString(getCell('patient_id')),
      patientName: _toString(getCell('patient_name')),
      age: _toDouble(getCell('age')),
      gender: gender,
      weightKg: weight,
      heightCm: height,
      idealWeightKg: idealWeight,
      bmi: bmi,
      glucose: _toDouble(getCell('glucose_mg_dl')),
      bloodPressure: _toDouble(getCell('blood_pressure')),
      insulin: _toDouble(getCell('insulin')),
      pregnancies: _toInt(getCell('pregnancies')),
      familyHistory: familyHistory,
      physicalActivity:
          _toString(getCell('physical_activity'), defaultVal: 'Medium'),
      diabetesPedigree: _toDouble(getCell('diabetes_pedigree')),
    );
  }
}
