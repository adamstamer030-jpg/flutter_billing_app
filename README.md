# 🛒 Mobile POS & Billing App

تطبيق نقطة بيع وفوترة متكامل يعمل بدون إنترنت، مبني بـ Flutter لمحلات البيع بالتجزئة الصغيرة والمتوسطة.

---

## ✨ المميزات الرئيسية

### 📦 إدارة المنتجات
- إضافة وتعديل وحذف المنتجات
- ربط كل منتج بباركود أو QR Code
- إدارة الكميات والمخزون
- بحث سريع بالاسم أو الباركود
- **تصدير قائمة المنتجات كـ CSV**
- **استيراد منتجات من ملف CSV** (إضافة جماعية)

### 🧾 نظام الكاشير والفوترة
- مسح الباركود بالكاميرا مباشرة
- إضافة منتجات يدوياً أو بالمسح
- حساب الإجمالي والخصم تلقائياً
- دعم طرق دفع متعددة (نقدي، بطاقة، تحويل، محفظة)
- إصدار فاتورة فورية عند إتمام الطلب

### 🖨️ الطباعة والتصدير
- **طباعة الفواتير PDF** مع بيانات المتجر الكاملة
- **طباعة حرارية** عبر Bluetooth مباشرة على الطابعة
- **تصدير تقرير المبيعات PDF** (إحصائيات + قائمة الفواتير)
- **تصدير المبيعات CSV** لمراجعتها في Excel

### 📊 التقارير والإحصائيات
- إجمالي مبيعات اليوم والشهر
- عدد الفواتير ومتوسط قيمة الفاتورة
- أكثر المنتجات مبيعاً
- سجل كامل بكل الفواتير مع تفاصيل كل طلب
- **طباعة وتصدير التقارير مباشرة**

### ⚙️ الإعدادات
- بيانات المتجر (الاسم، العنوان، الهاتف) تظهر على الفواتير
- إعداد الطابعة الحرارية البلوتوث
- دعم كامل للغة العربية واتجاه RTL

---

## 🛠 التقنيات المستخدمة

| الجانب | التقنية |
|---|---|
| Framework | Flutter (SDK ≥ 3.1.0) |
| State Management | flutter_bloc |
| Dependency Injection | get_it |
| Navigation | go_router |
| Local Database | Hive + hive_flutter |
| Data Modeling | json_serializable + equatable |
| Barcode Scanning | mobile_scanner |
| Bluetooth Printing | print_bluetooth_thermal |
| PDF Generation | pdf + printing |
| CSV Export/Import | csv |
| File Sharing | share_plus |

---

## 📁 هيكل المشروع

```
lib/
├── core/
│   ├── data/           # Hive initialization
│   ├── error/          # Failure models
│   ├── theme/          # UI theme & typography
│   ├── utils/
│   │   ├── export_service.dart   # PDF, CSV export/import
│   │   └── printer_helper.dart   # Bluetooth thermal printing
│   └── widgets/        # Reusable widgets
│
└── features/
    ├── billing/        # Cart, Checkout, Invoice
    ├── product/        # Product management + CSV
    ├── sales/          # Sales history + Reports + PDF
    ├── settings/       # Printer + App settings
    └── shop/           # Shop details
```

---

## 🚀 تشغيل المشروع

```bash
# 1. تحميل الـ dependencies
flutter pub get

# 2. توليد كود الـ Hive adapters
dart run build_runner build --delete-conflicting-outputs

# 3. تشغيل التطبيق
flutter run
```

---

## 📋 متطلبات التشغيل

- Flutter SDK `^3.1.0` أو أحدث
- Android 6.0 (API 23) أو أعلى
- صلاحيات: الكاميرا، Bluetooth، التخزين
- طابعة حرارية Bluetooth (اختياري)
