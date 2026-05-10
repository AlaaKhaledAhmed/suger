import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../services/diabetes_predictor.dart';
import '../widgets/result_dialog.dart';

class PatientsTableScreen extends StatefulWidget {
  final List<Patient> patients;
  const PatientsTableScreen({super.key, required this.patients});

  @override
  State<PatientsTableScreen> createState() => _PatientsTableScreenState();
}

class _PatientsTableScreenState extends State<PatientsTableScreen> {
  final _predictor = DiabetesPredictor();
  String _searchQuery = '';

  List<Patient> get _filteredPatients {
    if (_searchQuery.isEmpty) return widget.patients;
    final q = _searchQuery.toLowerCase();
    return widget.patients
        .where((p) =>
            p.patientName.toLowerCase().contains(q) ||
            p.patientId.toLowerCase().contains(q))
        .toList();
  }

  void _onPatientTap(Patient patient) {
    final result = _predictor.predict(patient);
    ResultDialog.show(context, patient: patient, result: result);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredPatients;
    return Scaffold(
      appBar: AppBar(
        title: Text('قائمة المرضى (${filtered.length})'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'ابحث باسم المريض أو الرقم...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.touch_app, color: Colors.teal, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'اضغط على أي مريض للتنبؤ باحتمال إصابته بالسكري',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text('لا توجد نتائج',
                        style: TextStyle(color: Colors.grey)),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(
                            Colors.teal.shade100),
                        headingTextStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                        showCheckboxColumn: false,
                        columns: const [
                          DataColumn(label: Text('الرقم')),
                          DataColumn(label: Text('الاسم')),
                          DataColumn(label: Text('العمر'), numeric: true),
                          DataColumn(label: Text('الجنس')),
                          DataColumn(label: Text('الوزن'), numeric: true),
                          DataColumn(label: Text('الطول'), numeric: true),
                          DataColumn(label: Text('BMI'), numeric: true),
                          DataColumn(label: Text('جلوكوز'), numeric: true),
                          DataColumn(label: Text('ضغط'), numeric: true),
                          DataColumn(label: Text('أنسولين'), numeric: true),
                          DataColumn(label: Text('عائلي')),
                          DataColumn(label: Text('نشاط')),
                        ],
                        rows: filtered.map((p) {
                          return DataRow(
                            onSelectChanged: (_) => _onPatientTap(p),
                            cells: [
                              DataCell(Text(p.patientId)),
                              DataCell(Text(p.patientName)),
                              DataCell(Text(p.age.toInt().toString())),
                              DataCell(
                                  Text(p.gender == 'Male' ? 'ذكر' : 'أنثى')),
                              DataCell(Text(p.weightKg.toStringAsFixed(1))),
                              DataCell(Text(p.heightCm.toStringAsFixed(1))),
                              DataCell(Text(p.bmi.toStringAsFixed(1))),
                              DataCell(Text(p.glucose.toStringAsFixed(1))),
                              DataCell(
                                  Text(p.bloodPressure.toStringAsFixed(1))),
                              DataCell(Text(p.insulin.toStringAsFixed(1))),
                              DataCell(Text(p.familyHistory ? 'نعم' : 'لا')),
                              DataCell(Text(_activityAr(p.physicalActivity))),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  String _activityAr(String s) {
    switch (s) {
      case 'Low':
        return 'منخفض';
      case 'Medium':
        return 'متوسط';
      case 'High':
        return 'عالي';
      default:
        return s;
    }
  }
}
