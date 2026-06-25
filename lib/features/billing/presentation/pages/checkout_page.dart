import 'package:billing_app/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

import '../../../shop/presentation/bloc/shop_bloc.dart';
import '../../../sales/presentation/bloc/sales_bloc.dart';
import '../bloc/billing_bloc.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _discountController = TextEditingController();
  bool _isPercentage = false;

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  void _showDiscountDialog(BuildContext context) {
    final billingState = context.read<BillingBloc>().state;
    _discountController.text = billingState.discountValue > 0
        ? billingState.discountValue.toStringAsFixed(0)
        : '';
    _isPercentage = billingState.discountIsPercentage;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('تطبيق خصم',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          setDialogState(() => _isPercentage = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: !_isPercentage
                              ? const Color(0xFF6C63FF)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'قيمة ثابتة (ج.م)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: !_isPercentage
                                ? Colors.white
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          setDialogState(() => _isPercentage = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _isPercentage
                              ? const Color(0xFF6C63FF)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'نسبة مئوية (%)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _isPercentage
                                ? Colors.white
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _discountController,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: _isPercentage ? 'مثال: 10' : 'مثال: 5.00',
                  suffix: Text(_isPercentage ? '%' : 'ج.م'),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                context
                    .read<BillingBloc>()
                    .add(ApplyDiscountEvent(0, isPercentage: false));
                Navigator.pop(ctx);
              },
              child: const Text('إزالة الخصم',
                  style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
              onPressed: () {
                final value =
                    double.tryParse(_discountController.text) ?? 0;
                context.read<BillingBloc>().add(
                      ApplyDiscountEvent(value, isPercentage: _isPercentage),
                    );
                Navigator.pop(ctx);
              },
              child: const Text('تطبيق'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentMethodDialog(BuildContext context) {
    final methods = ['نقداً', 'بطاقة بنكية', 'تحويل بنكي', 'محفظة إلكترونية'];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('طريقة الدفع',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: methods
              .map((method) => BlocBuilder<BillingBloc, BillingState>(
                    builder: (context, state) => ListTile(
                      leading: Radio<String>(
                        value: method,
                        groupValue: state.paymentMethod,
                        activeColor: const Color(0xFF6C63FF),
                        onChanged: (val) {
                          if (val != null) {
                            context
                                .read<BillingBloc>()
                                .add(SetPaymentMethodEvent(val));
                            Navigator.pop(ctx);
                          }
                        },
                      ),
                      title: Text(method),
                      onTap: () {
                        context
                            .read<BillingBloc>()
                            .add(SetPaymentMethodEvent(method));
                        Navigator.pop(ctx);
                      },
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFFE5E5EA);
    const primaryColor = Color(0xFF6C63FF);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        context.read<BillingBloc>().add(ClearCartEvent());
        context.go('/');
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الدفع',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left, size: 28, color: primaryColor),
            onPressed: () {
              context.read<BillingBloc>().add(ClearCartEvent());
              context.go('/');
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.discount_outlined, color: primaryColor),
              tooltip: 'خصم',
              onPressed: () => _showDiscountDialog(context),
            ),
            IconButton(
              icon:
                  const Icon(Icons.payment_outlined, color: primaryColor),
              tooltip: 'طريقة الدفع',
              onPressed: () => _showPaymentMethodDialog(context),
            ),
          ],
        ),
        body: BlocConsumer<BillingBloc, BillingState>(
          listener: (context, state) {
            if (state.printSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('تمت الطباعة بنجاح'),
                  backgroundColor: Colors.green));
            }
            if (state.saleConfirmed) {
              context.read<SalesBloc>().add(LoadSalesEvent());
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('✅ تم تسجيل الفاتورة بنجاح'),
                  backgroundColor: Colors.teal));
              context.read<BillingBloc>().add(ClearCartEvent());
              context.go('/');
            }
          },
          builder: (context, billingState) {
            return BlocBuilder<ShopBloc, ShopState>(
              builder: (context, shopState) {
                String upiId = '';
                String shopName = 'Shop';

                if (shopState is ShopLoaded) {
                  upiId = shopState.shop.upiId;
                  shopName = shopState.shop.name;
                }

                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Column(
                          children: [
                            // Items Table
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Table(
                                  border: const TableBorder(
                                    horizontalInside:
                                        BorderSide(color: borderColor),
                                    bottom: BorderSide(color: borderColor),
                                  ),
                                  children: [
                                    TableRow(
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF8FAFC),
                                        border: Border(
                                            bottom:
                                                BorderSide(color: borderColor)),
                                      ),
                                      children: [
                                        _buildHeaderCell(
                                            'اسم المنتج', TextAlign.right),
                                        _buildHeaderCell(
                                            'السعر', TextAlign.right),
                                        _buildHeaderCell(
                                            'الإجمالي', TextAlign.right),
                                      ],
                                    ),
                                    ...billingState.cartItems.map((item) {
                                      return TableRow(
                                        children: [
                                          _buildDataCell(
                                            '${item.quantity} x ${item.product.name}',
                                            TextAlign.left,
                                          ),
                                          _buildDataCell(
                                              'ج.م ${item.product.price.toStringAsFixed(2)}',
                                              TextAlign.right,
                                              isSubtitle: true),
                                          _buildDataCell(
                                              'ج.م ${item.total.toStringAsFixed(2)}',
                                              TextAlign.right,
                                              isBold: true),
                                        ],
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Discount & Payment Method row
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInfoTile(
                                    icon: Icons.discount_outlined,
                                    label: 'الخصم',
                                    value: billingState.discountAmount > 0
                                        ? '- ج.م ${billingState.discountAmount.toStringAsFixed(2)}'
                                        : 'لا يوجد',
                                    onTap: () =>
                                        _showDiscountDialog(context),
                                    color: billingState.discountAmount > 0
                                        ? Colors.red[700]!
                                        : Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildInfoTile(
                                    icon: Icons.payment_outlined,
                                    label: 'الدفع',
                                    value: billingState.paymentMethod,
                                    onTap: () =>
                                        _showPaymentMethodDialog(context),
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 120),
                          ],
                        ),
                      ),
                    ),

                    // Bottom Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.97),
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 12,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                            child: Column(
                              children: [
                                if (upiId.isNotEmpty) ...[
                                  const Text('امسح للدفع',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: 140,
                                    height: 140,
                                    child: PrettyQrView.data(
                                      data:
                                          'upi://pay?pa=$upiId&pn=$shopName&am=${billingState.netAmount.toStringAsFixed(2)}&cu=INR',
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                                // Summary
                                if (billingState.discountAmount > 0)
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('المجموع الفرعي',
                                          style: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 13)),
                                      Text(
                                          'ج.م ${billingState.totalAmount.toStringAsFixed(2)}',
                                          style: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 13)),
                                    ],
                                  ),
                                if (billingState.discountAmount > 0)
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('الخصم',
                                          style: TextStyle(
                                              color: Colors.red[600],
                                              fontSize: 13)),
                                      Text(
                                          '- ج.م ${billingState.discountAmount.toStringAsFixed(2)}',
                                          style: TextStyle(
                                              color: Colors.red[600],
                                              fontSize: 13)),
                                    ],
                                  ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('الإجمالي الكلي',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[600],
                                            letterSpacing: 1)),
                                    Text(
                                      'ج.م ${billingState.netAmount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0F172A)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Buttons
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: billingState.isPrinting
                                        ? null
                                        : () {
                                            if (shopState is ShopLoaded) {
                                              context.read<BillingBloc>().add(
                                                  PrintReceiptEvent(
                                                      shopName:
                                                          shopState.shop.name,
                                                      address1: shopState
                                                          .shop.addressLine1,
                                                      address2: shopState
                                                          .shop.addressLine2,
                                                      phone: shopState
                                                          .shop.phoneNumber,
                                                      footer: shopState
                                                          .shop.footerText));
                                            }
                                          },
                                    icon: billingState.isPrinting
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2))
                                        : const Icon(Icons.print_outlined),
                                    label: const Text('طباعة'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: primaryColor,
                                      side: const BorderSide(
                                          color: primaryColor),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 2,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      if (shopState is ShopLoaded) {
                                        context.read<BillingBloc>().add(
                                            ConfirmSaleEvent(
                                                shopName:
                                                    shopState.shop.name,
                                                address1: shopState
                                                    .shop.addressLine1,
                                                address2: shopState
                                                    .shop.addressLine2,
                                                phone: shopState
                                                    .shop.phoneNumber,
                                                footer: shopState
                                                    .shop.footerText));
                                      } else {
                                        context.read<BillingBloc>().add(
                                            const ConfirmSaleEvent(
                                                shopName: '',
                                                address1: '',
                                                address2: '',
                                                phone: '',
                                                footer: ''));
                                      }
                                    },
                                    icon: const Icon(Icons.check_circle),
                                    label: const Text('تأكيد البيع'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E5EA)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style:
                          TextStyle(fontSize: 10, color: Colors.grey[500])),
                  Text(value,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: color)),
                ],
              ),
            ),
            Icon(Icons.edit_outlined, size: 14, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text, TextAlign align) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Text(
        text.toUpperCase(),
        textAlign: align,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildDataCell(String text, TextAlign align,
      {bool isBold = false, bool isSubtitle = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: isSubtitle ? 12 : 14,
          fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          color: isSubtitle ? Colors.grey[500] : Colors.black87,
        ),
      ),
    );
  }
}
