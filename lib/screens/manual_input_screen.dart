import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../services/diabetes_predictor.dart';
import '../widgets/result_dialog.dart';

class ManualInputScreen extends StatefulWidget {
  const ManualInputScreen({super.key});

  @override
  State<ManualInputScreen> createState() => _ManualInputScreenState();
}

class _ManualInputScreenState extends State<ManualInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _predictor = DiabetesPredictor();

  final _nameController = TextEditingController();
  final _ageController = TextEditingController(text: '35');
  final _weightController = TextEditingController(text: '75');
  final _heightController = TextEditingController(text: '170');
  final _glucoseController = TextEditingController(text: '100');
  final _bpController = TextEditingController(text: '70');
  final _insulinController = TextEditingController(text: '80');
  final _pregnanciesController = TextEditingController(text: '0');
  final _pedigreeController = TextEditingController(text: '0.5');

  String _gender = 'Male';
  String _activity = 'Medium';
  bool _familyHistory = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _glucoseController.dispose();
    _bpController.dispose();
    _insulinController.dispose();
    _pregnanciesController.dispose();
    _pedigreeController.dispose();
    super.dispose();
  }

  void _predict() {
    if (!_formKey.currentState!.validate()) return;

    final patient = Patient.create(
      patientName: _nameController.text.trim(),
      age: double.parse(_ageController.text),
      gender: _gender,
      weightKg: double.parse(_weightController.text),
      heightCm: double.parse(_heightController.text),
      glucose: double.parse(_glucoseController.text),
      bloodPressure: double.parse(_bpController.text),
      insulin: double.parse(_insulinController.text),
      pregnancies: int.parse(_pregnanciesController.text),
      familyHistory: _familyHistory,
      physicalActivity: _activity,
      diabetesPedigree: double.parse(_pedigreeController.text),
    );

    final result = _predictor.predict(patient);
    ResultDialog.show(context, patient: patient, result: result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدخال يدوي'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSection('البيانات الشخصية', Icons.person, [
                  _buildField(_nameController, 'اسم المريض', Icons.badge,
                      required: false),
                  _buildField(_ageController, 'العمر (سنة)', Icons.cake,
                      isNumeric: true),
                  _buildDropdown(
                    'الجنس',
                    _gender,
                    const [
                      DropdownMenuItem(value: 'Male', child: Text('ذكر')),
                      DropdownMenuItem(value: 'Female', child: Text('أنثى')),
                    ],
                    (val) => setState(() => _gender = val!),
                    Icons.wc,
                  ),
                ]),
                const SizedBox(height: 16),
                _buildSection('القياسات الجسمانية', Icons.monitor_weight, [
                  _buildField(_weightController, 'الوزن (كجم)', Icons.scale,
                      isNumeric: true),
                  _buildField(_heightController, 'الطول (سم)', Icons.height,
                      isNumeric: true),
                ]),
                const SizedBox(height: 16),
                _buildSection('التحاليل الطبية', Icons.bloodtype, [
                  _buildField(
                      _glucoseController, 'الجلوكوز (mg/dl)', Icons.water_drop,
                      isNumeric: true),
                  _buildField(_bpController, 'ضغط الدم', Icons.favorite,
                      isNumeric: true),
                  _buildField(_insulinController, 'الأنسولين',
                      Icons.medical_services,
                      isNumeric: true),
                ]),
                const SizedBox(height: 16),
                _buildSection('عوامل الخطر', Icons.warning_amber, [
                  if (_gender == 'Female')
                    _buildField(_pregnanciesController, 'عدد مرات الحمل',
                        Icons.child_care,
                        isNumeric: true),
                  _buildField(_pedigreeController, 'مؤشر السكري الوراثي',
                      Icons.family_restroom,
                      isNumeric: true),
                  _buildDropdown(
                    'مستوى النشاط البدني',
                    _activity,
                    const [
                      DropdownMenuItem(value: 'Low', child: Text('منخفض')),
                      DropdownMenuItem(value: 'Medium', child: Text('متوسط')),
                      DropdownMenuItem(value: 'High', child: Text('عالي')),
                    ],
                    (val) => setState(() => _activity = val!),
                    Icons.directions_run,
                  ),
                  SwitchListTile(
                    title: const Text('تاريخ عائلي للسكري'),
                    secondary: const Icon(Icons.people),
                    value: _familyHistory,
                    onChanged: (val) => setState(() => _familyHistory = val),
                    activeColor: Colors.teal,
                  ),
                ]),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _predict,
                  icon: const Icon(Icons.analytics),
                  label: const Text('تحليل النتيجة',
                      style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.teal),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumeric = false,
    bool required = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        validator: (value) {
          if (!required) return null;
          if (value == null || value.isEmpty) return 'هذا الحقل مطلوب';
          if (isNumeric && double.tryParse(value) == null) {
            return 'يجب إدخال رقم صحيح';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdown<T>(
    String label,
    T value,
    List<DropdownMenuItem<T>> items,
    void Function(T?) onChanged,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: DropdownButtonFormField<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
    );
  }
}
