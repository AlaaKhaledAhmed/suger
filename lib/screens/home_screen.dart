import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../services/diabetes_predictor.dart';
import '../services/excel_parser.dart';
import 'manual_input_screen.dart';
import 'patients_table_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
//home
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _predictor = DiabetesPredictor();
  bool _modelLoading = true;
  bool _parsing = false;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      await _predictor.loadModel();
    } catch (e) {
      if (mounted) _showError('فشل تحميل النموذج: $e');
    }
    if (mounted) setState(() => _modelLoading = false);
  }

  Future<void> _pickExcelFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );
      if (result == null || result.files.single.path == null) return;

      setState(() => _parsing = true);
      final filePath = result.files.single.path!;
      final patients = await ExcelParser.parseFile(filePath);

      if (!mounted) return;
      setState(() => _parsing = false);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PatientsTableScreen(patients: patients),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _parsing = false);
        _showError('خطأ في قراءة الملف: $e');
      }
    }
  }

  void _openManualInput() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ManualInputScreen()),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التنبؤ بمرض السكري'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.teal.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.medical_services,
                      size: 65, color: Colors.teal),
                ),
                const SizedBox(height: 20),
                const Text(
                  'تطبيق التنبؤ بمرض السكري',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'اختر طريقة الإدخال المناسبة لك',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // حالات التحميل
                if (_modelLoading)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('جاري تحميل النموذج...'),
                      ],
                    ),
                  )
                else if (_parsing)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('جاري قراءة الملف...'),
                      ],
                    ),
                  )
                else ...[
                  // الخيار 1: إدخال يدوي
                  _buildOptionCard(
                    icon: Icons.edit_note,
                    title: 'إدخال بيانات مريض يدوياً',
                    subtitle: 'لفحص حالة واحدة بإدخال البيانات يدوياً',
                    color: Colors.blue,
                    onTap: _openManualInput,
                  ),
                  const SizedBox(height: 16),

                  // الخيار 2: ملف Excel
                  _buildOptionCard(
                    icon: Icons.upload_file,
                    title: 'رفع ملف Excel',
                    subtitle:
                        'لفحص عدة مرضى من قاعدة بيانات (ملف .xlsx)',
                    color: Colors.teal,
                    onTap: _pickExcelFile,
                  ),
                  const SizedBox(height: 24),

                  // ملاحظة
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.amber.shade300),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, color: Colors.amber),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'هذا التطبيق للأغراض التعليمية فقط. النتائج لا تُغني عن استشارة الطبيب.',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_back_ios, size: 16, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
