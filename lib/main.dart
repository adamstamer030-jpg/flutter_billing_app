import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:billing_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'config/routes/app_routes.dart';
import 'core/data/hive_database.dart';
import 'core/localization/localization_provider.dart';
import 'core/service_locator.dart' as di;
import 'core/theme/app_theme.dart';
import 'features/billing/presentation/bloc/billing_bloc.dart';
import 'features/product/presentation/bloc/product_bloc.dart';
import 'features/shop/presentation/bloc/shop_bloc.dart';
import 'features/settings/presentation/bloc/printer_bloc.dart';
import 'features/settings/presentation/bloc/printer_event.dart';
import 'features/sales/presentation/bloc/sales_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveDatabase.init();
  await di.init();
  runApp(
    ChangeNotifierProvider(
      create: (_) => LocalizationProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final locProvider = context.watch<LocalizationProvider>();

    return MultiBlocProvider(
      providers: [
        BlocProvider<ProductBloc>(
            create: (_) => di.sl<ProductBloc>()..add(LoadProducts())),
        BlocProvider<ShopBloc>(
            create: (_) => di.sl<ShopBloc>()..add(LoadShopEvent())),
        BlocProvider<BillingBloc>(
            create: (_) => BillingBloc(getProductByBarcodeUseCase: di.sl())),
        BlocProvider<PrinterBloc>(
            create: (_) => di.sl<PrinterBloc>()..add(InitPrinterEvent())),
        BlocProvider<SalesBloc>(
            create: (_) => di.sl<SalesBloc>()..add(LoadSalesEvent())),
      ],
      child: MaterialApp.router(
        title: 'Billing App',
        theme: AppTheme.lightTheme,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
        locale: locProvider.locale,
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (context, child) => Directionality(
          textDirection: locProvider.locale.languageCode == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: child!,
        ),
      ),
    );
  }
}
