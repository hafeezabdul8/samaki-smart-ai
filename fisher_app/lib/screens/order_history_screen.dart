import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';
import '../services/language_provider.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<dynamic> _orders = [];
  bool _loading = true;
  String _period = 'all';

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => _loading = true);
    try {
      final api = context.read<ApiService>();
      final auth = context.read<AuthProvider>();
      api.token = auth.token;
      final orders = await api.getOrderHistory(_period);
      if (mounted) {
        setState(() {
          _orders = orders;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: AppTheme.primaryBg,
      appBar: AppBar(
        backgroundColor: AppTheme.cardBg,
        title: Text(
          lang.t('Order History', 'Historia ya Maagizo'),
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white),
        ),
        actions: [
          // Filter dropdown
          DropdownButton<String>(
            value: _period,
            dropdownColor: AppTheme.cardBg,
            underline: const SizedBox(),
            icon: const Icon(Icons.filter_list, color: Colors.grey),
            items: [
              DropdownMenuItem(value: 'all', child: Text(lang.t('All', 'Zote'), style: const TextStyle(color: Colors.white))),
              DropdownMenuItem(value: 'daily', child: Text(lang.t('Daily', 'Leo'), style: const TextStyle(color: Colors.white))),
              DropdownMenuItem(value: 'monthly', child: Text(lang.t('Monthly', 'Mwezi'), style: const TextStyle(color: Colors.white))),
              DropdownMenuItem(value: 'yearly', child: Text(lang.t('Yearly', 'Mwaka'), style: const TextStyle(color: Colors.white))),
            ],
            onChanged: (val) {
              setState(() => _period = val!);
              _fetchOrders();
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.cyanAccent))
          : _orders.isEmpty
              ? Center(
                  child: Text(
                    lang.t('No order history', 'Hakuna historia ya maagizo'),
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    final isFulfilled = order['status'] == 'fulfilled';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: AppTheme.glassDecoration,
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: (isFulfilled ? AppTheme.emeraldAccent : AppTheme.redAccent).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isFulfilled ? Icons.check_circle : Icons.cancel,
                              color: isFulfilled ? AppTheme.emeraldAccent : AppTheme.redAccent,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${order['species_name'] ?? ''} • ${order['quantity_kg']}kg',
                                  style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 14),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  order['delivery_date'] ?? '',
                                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                                ),
                                Text(
                                  'TZS ${order['max_price_tzs'] ?? 0}',
                                  style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppTheme.cyanAccent, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            isFulfilled ? '✅' : '❌',
                            style: const TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}