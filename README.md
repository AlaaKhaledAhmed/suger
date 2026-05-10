# 🩺 تطبيق التنبؤ بمرض السكري | Diabetes Prediction App

تطبيق Flutter للتنبؤ بمستوى خطر الإصابة بمرض السكري باستخدام نموذج TensorFlow Lite مدرّب مسبقاً.

يدعم التطبيق **طريقتين للإدخال**:
1. **إدخال يدوي** لفحص حالة واحدة
2. **رفع ملف Excel** لفحص عدة مرضى دفعة واحدة

---

## 📱 فكرة التطبيق

عند فتح التطبيق، يظهر للمستخدم خياران:

### 🔹 الخيار 1: إدخال بيانات مريض يدوياً
شاشة بنموذج كامل يدخل فيها المستخدم بيانات مريض واحد (الاسم، العمر، الوزن، الجلوكوز، إلخ) ثم يضغط "تحليل النتيجة" → تظهر النافذة بمستوى الخطر.

### 🔹 الخيار 2: رفع ملف Excel
- يختار المستخدم ملف `.xlsx` من جهازه
- يقرأ التطبيق الملف ويعرض بيانات جميع المرضى في **جدول قابل للتمرير**
- يضغط المستخدم على أي صف → يقوم النموذج بالتنبؤ فوراً

في كلتا الحالتين تظهر **نفس النافذة** بـ:
- 🟢 ضعيفة / 🟡 متوسطة / 🔴 مرتفعة
- نسبة الدقة + احتمالات كل مستوى + نصيحة طبية

---

## ❓ ما الفرق بين ملف التدريب وملف المستخدم؟

هذا سؤال مهم. النموذج يمر بمرحلتين:

### المرحلة 1️⃣: التدريب (تمت مرة واحدة عند بناء النموذج)
- ملف Excel كبير (500 مريض) **مع** عمود التشخيص (`risk_level`)
- يُغذّى لـ Python ويتعلم النموذج الأنماط
- ينتج ملف `diabetes_model.tflite` (11 KB)
- ✅ هذه المرحلة منتهية، النموذج جاهز

### المرحلة 2️⃣: الاستخدام (في التطبيق)
- المستخدم يدخل بيانات مريض **بدون** تشخيص
- النموذج المدرّب يتنبأ بالتشخيص

> 💡 **الملف العيني** `diabetes_patients_data.xlsx` (في `assets/sample/`) هو نفسه ملف التدريب — موجود لتجربة الميزة الثانية فقط (رفع Excel). يمكنك أيضاً استخدامه كقالب لإنشاء ملفك الخاص.

---

## 🧠 الخوارزمية المستخدمة

### نوع النموذج: **شبكة عصبية متعددة الطبقات (MLP - Multi-Layer Perceptron)**

```
المدخلات: 13 ميزة طبية
        ↓
Dense (64) + ReLU + Dropout 30%
        ↓
Dense (32) + ReLU + Dropout 20%
        ↓
Dense (16) + ReLU
        ↓
Dense (3) + Softmax
        ↓
المخرج: [P(Low), P(Medium), P(High)]
```

### تفاصيل التدريب:

| الخاصية | القيمة |
|---------|--------|
| Optimizer | Adam (lr=0.001) |
| Loss | Sparse Categorical Crossentropy |
| Epochs | 100 (مع Early Stopping) |
| Batch Size | 32 |
| Train/Test Split | 80% / 20% |
| Normalization | StandardScaler |
| عدد المعاملات | 3,555 |
| حجم النموذج | 11 KB |
| دقة الاختبار | 81% |

### ⚙️ تقنيات التحسين:
- **Dropout** لمنع الـ Overfitting
- **Early Stopping** لإيقاف التدريب تلقائياً عند توقف التحسن
- **ReduceLROnPlateau** لتقليل معدل التعلم
- **StandardScaler** لتطبيع البيانات

### 📊 الميزات الـ 13 المستخدمة:

| # | الميزة | الوصف |
|---|--------|--------|
| 1 | age | العمر |
| 2 | gender | الجنس (ذكر=0، أنثى=1) |
| 3 | weight_kg | الوزن |
| 4 | height_cm | الطول |
| 5 | ideal_weight_kg | الوزن المثالي |
| 6 | bmi | مؤشر كتلة الجسم |
| 7 | glucose_mg_dl | الجلوكوز |
| 8 | blood_pressure | ضغط الدم |
| 9 | insulin | الأنسولين |
| 10 | pregnancies | عدد مرات الحمل |
| 11 | family_history | تاريخ عائلي (0/1) |
| 12 | physical_activity | النشاط البدني (0/1/2) |
| 13 | diabetes_pedigree | المؤشر الوراثي |

### 🔁 خط أنابيب التنبؤ:

```
بيانات المريض (يدوي أو من Excel)
        ↓
1. ترميز المتغيرات النصية
        ↓
2. حساب القيم المشتقة (BMI، الوزن المثالي)
        ↓
3. تطبيع البيانات (mean/std من model_info.json)
        ↓
4. تشغيل نموذج TFLite
        ↓
5. Softmax → احتمالات
        ↓
6. argmax → الفئة النهائية
```

---

## 📂 هيكل المشروع

```
new_app/
├── pubspec.yaml
├── README.md
├── assets/
│   ├── model/
│   │   ├── diabetes_model.tflite     ← النموذج (11 KB)
│   │   └── model_info.json           ← قيم mean/std + labels
│   └── sample/
│       └── diabetes_patients_data.xlsx  ← ملف عينة 500 مريض
└── lib/
    ├── main.dart                     ← نقطة الدخول
    ├── models/
    │   └── patient.dart              ← كلاس بيانات المريض
    ├── services/
    │   ├── diabetes_predictor.dart   ← خدمة TFLite
    │   └── excel_parser.dart         ← قراءة Excel
    ├── widgets/
    │   └── result_dialog.dart        ← نافذة النتيجة المشتركة
    └── screens/
        ├── home_screen.dart          ← الخياران
        ├── manual_input_screen.dart  ← إدخال يدوي
        └── patients_table_screen.dart ← جدول من Excel
```

---

## 🚀 آلية التشغيل

### المتطلبات:
- Flutter SDK 3.10+
- Android Studio أو VS Code
- جهاز Android (API 21+) أو iOS (12.0+)

### الخطوة 1️⃣: فك ضغط المشروع

```bash
unzip new_app.zip -d /Users/alaakhaled/StudioProjects/
```

### الخطوة 2️⃣: تثبيت التبعيات

```bash
cd /Users/alaakhaled/StudioProjects/new_app
flutter pub get
```

### الخطوة 3️⃣: إعداد Android (مهم!)

افتح `android/app/build.gradle` وأضف داخل `android { ... }`:

```gradle
android {
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }

    aaptOptions {
        noCompress 'tflite'
    }
}
```

### الخطوة 4️⃣: إعداد iOS

افتح `ios/Podfile` وعدّل:
```ruby
platform :ios, '12.0'
```
ثم:
```bash
cd ios && pod install && cd ..
```

### الخطوة 5️⃣: صلاحيات الملفات

**Android** - في `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

**iOS** - في `ios/Runner/Info.plist`:
```xml
<key>NSDocumentsFolderUsageDescription</key>
<string>للوصول لملفات Excel</string>
```

### الخطوة 6️⃣: التشغيل

```bash
flutter run
```

---

## 📋 تنسيق ملف Excel المتوقع

| العمود | النوع | مثال |
|--------|------|------|
| patient_id | نص | P0001 |
| patient_name | نص | أحمد محمد |
| age | رقم | 45 |
| gender | نص | Male / Female |
| weight_kg | رقم | 75.5 |
| height_cm | رقم | 170 |
| glucose_mg_dl | رقم | 110 |
| blood_pressure | رقم | 80 |
| insulin | رقم | 90 |
| pregnancies | رقم صحيح | 0 |
| family_history | 0 أو 1 | 1 |
| physical_activity | نص | Low / Medium / High |
| diabetes_pedigree | رقم | 0.5 |

> ✅ ملف عينة جاهز في `assets/sample/diabetes_patients_data.xlsx`

> 💡 الأعمدة `bmi` و `ideal_weight_kg` اختيارية (تُحسب تلقائياً)

---

## 📦 المكتبات المستخدمة

| المكتبة | الإصدار | الاستخدام |
|---------|---------|-----------|
| tflite_flutter | ^0.11.0 | تشغيل نموذج TFLite |
| file_picker | ^8.0.0 | اختيار ملفات |
| excel | ^4.0.2 | قراءة Excel |
| flutter_localizations | SDK | اللغة العربية |

---

## 🔧 استكشاف الأخطاء

| المشكلة | الحل |
|---------|------|
| `Could not load model` | أضف `noCompress 'tflite'` في build.gradle |
| `Permission denied` | أضف صلاحيات الملفات |
| `MinSdkVersion error` | غيّر `minSdkVersion` إلى 21 |
| `Pod install failed` | احذف `ios/Pods` و `Podfile.lock` ثم أعد |

---

## ⚠️ تنبيه طبي

> هذا التطبيق **للأغراض التعليمية والبحثية فقط**. النتائج لا تُغني عن الاستشارة الطبية المتخصصة.

---

## 📈 لتحسين دقة النموذج

- استخدم بيانات حقيقية مثل Pima Indians Diabetes Dataset
- زِد عدد العينات (آلاف المرضى)
- جرّب Random Forest أو XGBoost ثم حوّل النتيجة
- أضف ميزات إضافية (HbA1c، الكوليسترول...)

---

**تم بمساعدة Claude AI** 🤖
