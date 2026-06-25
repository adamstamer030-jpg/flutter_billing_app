import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class AppStrings {
  // Home Page
  static const String scannedItems = 'العناصر الممسوحة';
  static const String itemsTotal = 'عنصر إجمالي';
  static const String totalPrice = 'إجمالي السعر';
  static const String listEmpty = 'القائمة فارغة';
  static const String emptyDescription = 'سيظهر الأشياء الممسوحة هنا عند ضغط الكاميرا أعلاه';
  static const String reviewOrder = AppLocalizations.of(context)!.reviewOrder;
  static const String cameraOff = AppLocalizations.of(context)!.cameraOff;
  static const String cameraOffDescription = 'قم بتشغيل الكاميرا لبدء مسح الرموز الشريطية والعناصر تلقائياً';
  static const String turnOnCamera = AppLocalizations.of(context)!.turnOnCamera;
  
  // Products Page
  static const String addProduct = 'إضافة منتج';
  static const String scanBarcode = 'مسح الباركود';
  static const String productName = 'اسم المنتج';
  static const String productNameHint = 'مثال: أرز بسمتي';
  static const String price = 'السعر';
  static const String priceHint = '0.00';
  static const String barcode = 'الباركود';
  static const String barcodeHint = 'امسح أو أدخل الباركود';
  static const String tapToScan = 'اضغط للمسح';
  static const String products = 'المنتجات';
  static const String editProduct = 'تعديل المنتج';
  static const String deleteProduct = 'حذف المنتج';
  static const String confirmDelete = 'هل تريد حذف هذا المنتج؟';
  static const String cancel = 'إلغاء';
  static const String delete = 'حذف';
  
  // Shop Details
  static const String shopDetails = 'تفاصيل المتجر';
  static const String shopName = 'اسم المتجر';
  static const String shopNameHint = 'أدخل اسم متجرك';
  static const String shopAddress = 'عنوان المتجر';
  static const String shopAddressHint = 'أدخل عنوان المتجر';
  static const String shopPhone = 'رقم الهاتف';
  static const String shopPhoneHint = '+20xxxxxxxxx';
  static const String shopTaxId = 'رقم الضريبة';
  static const String shopTaxIdHint = 'أدخل رقم الضريبة';
  static const String save = 'حفظ';
  
  // Checkout
  static const String checkout = 'الدفع';
  static const String subtotal = 'المجموع الفرعي';
  static const String tax = 'الضريبة';
  static const String total = 'الإجمالي';
  static const String paymentMethod = 'طريقة الدفع';
  static const String cash = 'نقداً';
  static const String card = 'بطاقة';
  static const String completePayment = 'إتمام الدفع';
  static const String printReceipt = 'طباعة الإيصال';
  
  // Settings
  static const String settings = 'الإعدادات';
  static const String printerSettings = 'إعدادات الطابعة';
  static const String connectPrinter = 'توصيل الطابعة';
  static const String language = 'اللغة';
  static const String arabic = 'العربية';
  static const String english = 'English';
  static const String about = 'عن التطبيق';
  static const String version = 'الإصدار';
  
  // Messages
  static const String success = 'نجح';
  static const String error = 'خطأ';
  static const String saved = 'تم الحفظ بنجاح';
  static const String deleted = 'تم الحذف بنجاح';
  static const String required = 'هذا الحقل مطلوب';
  static const String invalidPrice = 'يرجى إدخال سعر صحيح';
  static const String noInternet = 'لا توجد اتصال بالإنترنت';
}
