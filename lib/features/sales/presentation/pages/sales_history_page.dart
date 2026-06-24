import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/sales_bloc.dart';
import '../../domain/entities/sale.dart';
import '../../../../core/utils/export_service.dart';
import '../../../shop/presentation/bloc/shop_bloc.dart';

class SalesHistoryPage extends StatefulWidget {
  const SalesHistoryPage({super.key});

  @override
  State<SalesHistoryPage> createState() => _SalesHistoryPageState();
}

class _SalesHistoryPageState extends State<SalesHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<SalesBloc>().add(LoadSalesEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF6C63FF);

    return Scaffold(
      appBar: AppBar(
        title: const Text('التقارير والمبيعات',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 28, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          BlocBuilder<SalesBloc, SalesState>(
            builder: (context, salesState) => PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (val) async {
                final shopState = context.read<ShopBloc>().state;
                final shopName = shopState is ShopLoaded ? shopState.shop.name : 'المتجر';
                if (val == 'csv') {
                  await ExportService.exportSalesCsv(salesState.sales);
                } else if (val == 'pdf') {
                  await ExportService.printSalesReport(
                    sales:        salesState.sales,
                    shopName:     shopName,
                    todayTotal:   salesState.todayTotal,
                    monthTotal:   salesState.monthTotal,
                    topProducts:  salesState.topProducts,
                  );
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'pdf',
                  child: Row(children: [
                    Icon(Icons.picture_as_pdf, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('طباعة / PDF'),
                  ])),
                const PopupMenuItem(value: 'csv',
                  child: Row(children: [
                    Icon(Icons.table_chart, size: 18, color: Colors.teal),
                    SizedBox(width: 8),
                    Text('تصدير CSV'),
                  ])),
              ],
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: primaryColor,
          tabs: const [
            Tab(icon: Icon(Icons.bar_chart), text: 'الإحصائيات'),
            Tab(icon: Icon(Icons.receipt_long), text: 'سجل الفواتير'),
          ],
        ),
      ),
      body: BlocBuilder<SalesBloc, SalesState>(
        builder: (context, state) {
          if (state.status == SalesStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          return TabBarView(
            controller: _tabController,
            children: [
              _buildStatsTab(state),
              _buildHistoryTab(context, state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsTab(SalesState state) {
    const primaryColor = Color(0xFF6C63FF);
    final today = state.sales.where((s) {
      final now = DateTime.now();
      return s.date.year == now.year &&
          s.date.month == now.month &&
          s.date.day == now.day;
    }).toList();

    final month = state.sales.where((s) {
      final now = DateTime.now();
      return s.date.year == now.year && s.date.month == now.month;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'مبيعات اليوم',
                  value:
                      'ج.م ${state.todayTotal.toStringAsFixed(2)}',
                  subtitle: '${state.todayCount} فاتورة',
                  icon: Icons.today,
                  color: const Color(0xFF6C63FF),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  title: 'مبيعات الشهر',
                  value:
                      'ج.م ${state.monthTotal.toStringAsFixed(2)}',
                  subtitle: '${month.length} فاتورة',
                  icon: Icons.calendar_month,
                  color: Colors.teal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'إجمالي الفواتير',
                  value: '${state.sales.length}',
                  subtitle: 'منذ البداية',
                  icon: Icons.receipt,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  title: 'متوسط الفاتورة',
                  value: state.sales.isEmpty
                      ? 'ج.م 0'
                      : 'ج.م ${(state.sales.fold(0.0, (s, e) => s + e.netTotal) / state.sales.length).toStringAsFixed(2)}',
                  subtitle: 'اليوم',
                  icon: Icons.trending_up,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Top products
          if (state.topProducts.isNotEmpty) ...[
            const Text('🔥 الأكثر مبيعاً',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Column(
                children: state.topProducts.entries
                    .toList()
                    .asMap()
                    .entries
                    .map((entry) {
                  final rank = entry.key + 1;
                  final name = entry.value.key;
                  final qty = entry.value.value.toInt();
                  final maxQty =
                      state.topProducts.values.first.toInt();
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: rank == 1
                                    ? Colors.amber
                                    : rank == 2
                                        ? Colors.grey[300]
                                        : Colors.brown[200],
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text('$rank',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: qty / maxQty,
                                      backgroundColor:
                                          Colors.grey[100],
                                      color: primaryColor,
                                      minHeight: 6,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text('$qty وحدة',
                                style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                      if (rank < state.topProducts.length)
                        Divider(
                            height: 1,
                            color: Colors.grey[100],
                            indent: 56),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],

          if (state.sales.isEmpty) ...[
            const SizedBox(height: 60),
            Center(
              child: Column(
                children: [
                  Icon(Icons.bar_chart, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text('لا توجد مبيعات بعد',
                      style: TextStyle(
                          fontSize: 16, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryTab(BuildContext context, SalesState state) {
    if (state.sales.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text('لا توجد فواتير مسجّلة',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: state.sales.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final sale = state.sales[index];
        return _buildSaleCard(context, sale);
      },
    );
  }

  Widget _buildSaleCard(BuildContext context, Sale sale) {
    final dateStr =
        DateFormat('dd/MM/yyyy – hh:mm a').format(sale.date);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: ExpansionTile(
        tilePadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.receipt, color: Colors.teal, size: 22),
        ),
        title: Text(
          'ج.م ${sale.netTotal.toStringAsFixed(2)}',
          style:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(dateStr,
            style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: _paymentColor(sale.paymentMethod)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: Text(
                sale.paymentMethod,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _paymentColor(sale.paymentMethod)),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.print_outlined,
                  color: Color(0xFF6C63FF), size: 20),
              tooltip: 'طباعة الفاتورة',
              onPressed: () async {
                final shopState = context.read<ShopBloc>().state;
                final shopName = shopState is ShopLoaded ? shopState.shop.name : 'المتجر';
                final shopPhone = shopState is ShopLoaded ? shopState.shop.phoneNumber : null;
                final shopAddress = shopState is ShopLoaded ? shopState.shop.addressLine1 : null;
                await ExportService.printInvoice(
                  sale: sale,
                  shopName: shopName,
                  shopPhone: shopPhone,
                  shopAddress: shopAddress,
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: Colors.red, size: 20),
              onPressed: () => _confirmDelete(context, sale.id),
            ),
          ],
        ),
        children: [
          ...sale.items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Text('${item.quantity}x ',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6C63FF))),
                    Expanded(child: Text(item.productName)),
                    Text(
                        'ج.م ${(item.quantity * item.unitPrice).toStringAsFixed(2)}',
                        style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              )),
          if (sale.discount > 0) ...[
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('خصم',
                    style: TextStyle(color: Colors.red[600])),
                Text('- ج.م ${sale.discount.toStringAsFixed(2)}',
                    style: TextStyle(color: Colors.red[600])),
              ],
            ),
          ],
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('الإجمالي',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('ج.م ${sale.netTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6C63FF))),
            ],
          ),
        ],
      ),
    );
  }

  Color _paymentColor(String method) {
    switch (method) {
      case 'بطاقة بنكية':
        return Colors.blue;
      case 'تحويل بنكي':
        return Colors.purple;
      case 'محفظة إلكترونية':
        return Colors.orange;
      default:
        return Colors.teal;
    }
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الفاتورة'),
        content: const Text('هل أنت متأكد من حذف هذه الفاتورة؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء')),
          TextButton(
            onPressed: () {
              context.read<SalesBloc>().add(DeleteSaleEvent(id));
              Navigator.pop(ctx);
            },
            child: const Text('حذف',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(value,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          Text(title,
              style: TextStyle(color: Colors.grey[500], fontSize: 11)),
          Text(subtitle,
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
