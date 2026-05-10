import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../services/diabetes_predictor.dart';

/// نافذة عرض نتيجة التنبؤ - مشتركة بين الإدخال اليدوي ومن Excel
class ResultDialog extends StatelessWidget {
  final Patient patient;
  final PredictionResult result;
  final bool showPatientDetails;

  const ResultDialog({
    super.key,
    required this.patient,
    required this.result,
    this.showPatientDetails = true,
  });

  static void show(
    BuildContext context, {
    required Patient patient,
    required PredictionResult result,
    bool showPatientDetails = true,
  }) {
    showDialog(
      context: context,
      builder: (_) => ResultDialog(
        patient: patient,
        result: result,
        showPatientDetails: showPatientDetails,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    String advice;

    switch (result.riskLevel) {
      case 'Low':
        color = Colors.green;
        icon = Icons.check_circle;
        advice = 'الحالة جيدة. حافظ على نمط حياتك الصحي وممارسة الرياضة.';
        break;
      case 'Medium':
        color = Colors.orange;
        icon = Icons.warning_amber;
        advice =
            'يُنصح بمراجعة الطبيب وعمل فحوصات دورية وضبط نمط الغذاء والحركة.';
        break;
      default:
        color = Colors.red;
        icon = Icons.error;
        advice =
            'احتمال الإصابة مرتفع. يجب مراجعة طبيب مختص في أقرب وقت لإجراء الفحوصات اللازمة.';
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (patient.patientName.isNotEmpty)
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.teal.shade100,
                      child: const Icon(Icons.person, color: Colors.teal),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            patient.patientName,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          if (patient.patientId.isNotEmpty)
                            Text(
                              'الرقم: ${patient.patientId}',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.black54),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              if (patient.patientName.isNotEmpty) const SizedBox(height: 20),

              // النتيجة الكبيرة
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color, width: 2),
                ),
                child: Column(
                  children: [
                    Icon(icon, color: color, size: 50),
                    const SizedBox(height: 8),
                    const Text('احتمالية الإصابة بالسكري',
                        style: TextStyle(fontSize: 14)),
                    const SizedBox(height: 6),
                    Text(
                      result.riskLevelAr,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'بدقة ${(result.confidence * 100).toStringAsFixed(1)}%',
                      style: TextStyle(fontSize: 13, color: color),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              const Text('الاحتمالات لكل مستوى:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _probBar('ضعيفة', result.probabilities['Low']!, Colors.green),
              _probBar('متوسطة', result.probabilities['Medium']!,
                  Colors.orange),
              _probBar('مرتفعة', result.probabilities['High']!, Colors.red),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb_outline, color: color, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child:
                          Text(advice, style: const TextStyle(fontSize: 13)),
                    ),
                  ],
                ),
              ),

              if (showPatientDetails) ...[
                const SizedBox(height: 16),
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: const Text('عرض بيانات المريض',
                      style: TextStyle(fontSize: 13)),
                  children: [
                    _info('العمر', '${patient.age.toInt()} سنة'),
                    _info('الجنس', patient.gender == 'Male' ? 'ذكر' : 'أنثى'),
                    _info('الوزن', '${patient.weightKg} كجم'),
                    _info('الطول', '${patient.heightCm} سم'),
                    _info('الوزن المثالي',
                        '${patient.idealWeightKg.toStringAsFixed(1)} كجم'),
                    _info('BMI', patient.bmi.toStringAsFixed(1)),
                    _info('الجلوكوز',
                        '${patient.glucose.toStringAsFixed(1)} mg/dl'),
                    _info('ضغط الدم',
                        patient.bloodPressure.toStringAsFixed(1)),
                    _info('الأنسولين', patient.insulin.toStringAsFixed(1)),
                  ],
                ),
              ],
              const SizedBox(height: 8),

              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('إغلاق'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _probBar(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 13)),
              Text('${(value * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: color.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 13, color: Colors.black54)),
          Text(value,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
