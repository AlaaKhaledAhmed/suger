import 'dart:io';
import 'package:excel/excel.dart';
import '../models/patient.dart';

/// خدمة قراءة ملفات Excel وتحويلها إلى قائمة مرضى
class ExcelParser {
  static Future<List<Patient>> parseFile(String filePath) async {
    final bytes = await File(filePath).readAsBytes();
    final excel = Excel.decodeBytes(bytes);

    if (excel.tables.isEmpty) {
      throw Exception('الملف فارغ أو تالف');
    }

    final sheetName = excel.tables.keys.first;
    final sheet = excel.tables[sheetName]!;

    if (sheet.rows.length < 2) {
      throw Exception('الملف لا يحتوي على بيانات كافية');
    }

    int headerRowIndex = _findHeaderRow(sheet);
    int dataStartRow = headerRowIndex + 1;

    final columnMap = _buildColumnMap(sheet.rows[headerRowIndex]);

    final patients = <Patient>[];
    for (int i = dataStartRow; i < sheet.rows.length; i++) {
      final row = sheet.rows[i];
      if (_isRowEmpty(row)) continue;

      try {
        final values = row.map((cell) => cell?.value).toList();
        patients.add(Patient.fromRow(values, columnMap: columnMap));
      } catch (e) {
        continue;
      }
    }

    if (patients.isEmpty) {
      throw Exception('لم يتم العثور على بيانات صحيحة في الملف');
    }

    return patients;
  }

  static int _findHeaderRow(Sheet sheet) {
    final maxRowsToCheck = sheet.rows.length > 5 ? 5 : sheet.rows.length;
    for (int i = 0; i < maxRowsToCheck; i++) {
      final row = sheet.rows[i];
      for (final cell in row) {
        final v = cell?.value?.toString().toLowerCase().trim() ?? '';
        if (v == 'patient_id' ||
            v == 'age' ||
            v == 'glucose_mg_dl' ||
            v == 'bmi') {
          return i;
        }
      }
    }
    return 0;
  }

  static Map<String, int> _buildColumnMap(List<Data?> headerRow) {
    final map = <String, int>{};
    for (int i = 0; i < headerRow.length; i++) {
      final v = headerRow[i]?.value?.toString().toLowerCase().trim() ?? '';
      if (v.isNotEmpty) map[v] = i;
    }
    return map;
  }

  static bool _isRowEmpty(List<Data?> row) {
    for (final cell in row) {
      final v = cell?.value;
      if (v != null && v.toString().trim().isNotEmpty) return false;
    }
    return true;
  }
}
