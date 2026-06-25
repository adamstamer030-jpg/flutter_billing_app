import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:app_settings/app_settings.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../shop/presentation/bloc/shop_bloc.dart';
import '../../../sales/presentation/bloc/sales_bloc.dart';
import '../bloc/printer_bloc.dart';
import '../bloc/printer_event.dart';
import '../bloc/printer_state.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<PrinterBloc>().add(InitPrinterEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left,
              size: 28, color: Theme.of(context).primaryColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Section
            Container(
              width: double.infinity,
              color: Colors.white,
              padding:
                  const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              child: BlocBuilder<ShopBloc, ShopState>(
                builder: (context, state) {
                  String shopName = 'المتجر';
                  String initials = 'م';
                  if (state is ShopLoaded && state.shop.name.isNotEmpty) {
                    shopName = state.shop.name;
                    final parts = shopName.split(' ');
                    initials = parts
                        .take(2)
                        .map((p) => p.isNotEmpty ? p[0].toUpperCase() : '')
                        .join('');
                    if (initials.isEmpty) initials = 'م';
                  }
                  return Column(
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor
                                    .withOpacity(0.2),
                                blurRadius: 15,
                                spreadRadius: 5,
                              )
                            ]),
                        alignment: Alignment.center,
                        child: Text(initials,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -1)),
                      ),
                      const SizedBox(height: 16),
                      Text(shopName.toUpperCase(),
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      // Quick Stats
                      BlocBuilder<SalesBloc, SalesState>(
                        builder: (context, salesState) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildStatChip(
                                  '${salesState.todayCount} فاتورة اليوم',
                                  Icons.today,
                                  Colors.teal),
                              const SizedBox(width: 8),
                              _buildStatChip(
                                  'ج.م ${salesState.todayTotal.toStringAsFixed(0)}',
                                  Icons.attach_money,
                                  AppTheme.primaryColor),
                            ],
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Language Section
            _buildSectionHeader('اللغة / Language'),
            _buildListGroup(
              children: [
                Consumer<LocalizationProvider>(
                  builder: (context, locProvider, _) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.language, color: AppTheme.primaryColor, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(child: Text('اللغة / Language',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(value: 'ar', label: Text('ع', style: TextStyle(fontSize: 16))),
                            ButtonSegment(value: 'en', label: Text('EN', style: TextStyle(fontSize: 12))),
                          ],
                          selected: {locProvider.locale.languageCode},
                          onSelectionChanged: (val) =>
                            locProvider.setLocale(Locale(val.first)),
                          style: ButtonStyle(
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Reports Section
            _buildSectionHeader('التقارير'),
            _buildListGroup(
              children: [
                _buildListItem(
                  icon: Icons.bar_chart,
                  iconColor: Colors.teal,
                  title: 'المبيعات والتقارير',
                  subtitle: 'سجل الفواتير، إحصائيات، أكثر المنتجات مبيعاً',
                  onTap: () => context.push('/sales'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Management Section
            _buildSectionHeader('الإدارة'),
            _buildListGroup(
              children: [
                _buildListItem(
                  icon: Icons.qr_code_scanner,
                  title: 'المنتجات',
                  subtitle: 'إدارة المخزون والباركود',
                  onTap: () => context.push('/products'),
                ),
                _buildDivider(),
                _buildListItem(
                  icon: Icons.storefront,
                  title: 'بيانات المتجر',
                  subtitle: 'تعديل بيانات النشاط التجاري',
                  onTap: () => context.push('/shop'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Hardware Section
            _buildSectionHeader('الأجهزة'),
            BlocConsumer<PrinterBloc, PrinterState>(
              listener: (context, state) {
                if (state.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(state.errorMessage!),
                      backgroundColor: Colors.red));
                } else if (state.status == PrinterStatus.connected) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('تم الاتصال بالطابعة'),
                      backgroundColor: Colors.green));
                }
              },
              builder: (context, state) {
                return _buildListGroup(
                  children: [
                    _buildListItem(
                      icon: Icons.print,
                      title: 'جهاز الطباعة',
                      subtitleWidget: Row(
                        children: [
                          Text(
                            state.connectedMac != null
                                ? (state.connectedName ?? 'Printer connected')
                                : 'لا توجد طابعة متصلة',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[500]),
                          ),
                          if (state.connectedMac != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                  color: Colors.teal[100],
                                  borderRadius: BorderRadius.circular(10),
                                  border:
                                      Border.all(color: Colors.teal[200]!)),
                              child: Text(
                                'متصل',
                                style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal[700]),
                              ),
                            ),
                          ]
                        ],
                      ),
                      trailingWidget: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (state.status == PrinterStatus.scanning ||
                              state.status == PrinterStatus.connecting)
                            const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2))
                          else
                            IconButton(
                              icon: const Icon(Icons.refresh),
                              onPressed: () => context
                                  .read<PrinterBloc>()
                                  .add(RefreshPrinterEvent()),
                              color: AppTheme.primaryColor,
                            ),
                          IconButton(
                            icon: const Icon(Icons.settings),
                            onPressed: () {
                              AppSettings.openAppSettings(
                                  type: AppSettingsType.bluetooth);
                            },
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),

            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Text(
                "لتوصيل جهاز جديد، اضغط على أيقونة الإعدادات لإقران الجهاز في إعدادات البلوتوث، ثم ارجع واضغط تحديث.",
                style: TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[500]),
              ),
            ),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.2),
        ),
      ),
    );
  }

  Widget _buildListGroup({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return Divider(
        height: 1, thickness: 1, color: Colors.grey[50], indent: 64);
  }

  Widget _buildListItem({
    required IconData icon,
    Color? iconColor,
    required String title,
    String? subtitle,
    Widget? subtitleWidget,
    Widget? trailingWidget,
    IconData? trailingIcon = Icons.chevron_right,
    VoidCallback? onTap,
  }) {
    final color = iconColor ?? AppTheme.primaryColor;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey[500])),
                  ],
                  if (subtitleWidget != null) ...[
                    const SizedBox(height: 4),
                    subtitleWidget,
                  ]
                ],
              ),
            ),
            if (trailingWidget != null)
              trailingWidget
            else if (trailingIcon != null)
              Icon(trailingIcon, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }
}
