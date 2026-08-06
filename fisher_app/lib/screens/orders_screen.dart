import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';
import '../services/language_provider.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<dynamic> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      final api = context.read<ApiService>();
      final auth = context.read<AuthProvider>();
      api.token = auth.token;
      final orders = await api.getOrders();
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

  Future<void> _updateStatus(int orderId, String status) async {
    try {
      final api = context.read<ApiService>();
      final auth = context.read<AuthProvider>();
      api.token = auth.token;
      await api.updateOrderStatus(orderId, status);
      _fetchOrders();
      if (mounted) {
        final lang = context.read<LanguageProvider>();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(status == 'accepted'
                ? lang.t('Order accepted!', 'Agizo limekubaliwa!')
                : lang.t('Order fulfilled!', 'Agizo limekamilika!')),
            backgroundColor: AppTheme.emeraldAccent,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final lang = context.read<LanguageProvider>();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(lang.t('Error updating order', 'Imeshindwa kusasisha agizo')),
            backgroundColor: AppTheme.redAccent,
          ),
        );
      }
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return AppTheme.amberAccent;
      case 'accepted':
        return AppTheme.blueAccent;
      case 'fulfilled':
        return AppTheme.emeraldAccent;
      case 'cancelled':
        return AppTheme.redAccent;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status, LanguageProvider lang) {
    switch (status) {
      case 'pending':
        return lang.t('PENDING', 'INASUBIRI');
      case 'accepted':
        return lang.t('ACCEPTED', 'IMEKUBALIWA');
      case 'fulfilled':
        return lang.t('FULFILLED', 'IMEKAMILIKA');
      case 'cancelled':
        return lang.t('CANCELLED', 'IMEFUTWA');
      default:
        return status.toUpperCase();
    }
  }

  String _getIcon(String? name) {
    if (name == null) return '🐟';
    if (name.contains('Tuna') || name.contains('Jodari')) return '🐟';
    if (name.contains('Parrot') || name.contains('Pono')) return '🐠';
    if (name.contains('Snapper') || name.contains('Changu')) return '🐡';
    if (name.contains('Sardine') || name.contains('Dagaa')) return '🐟';
    if (name.contains('King') || name.contains('Nguru')) return '🦈';
    if (name.contains('Octopus') || name.contains('Pweza')) return '🐙';
    if (name.contains('Rabbit') || name.contains('Tasi')) return '🐠';
    if (name.contains('Shrimp') || name.contains('Kamba')) return '🦐';
    return '🐟';
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final user = context.watch<AuthProvider>().user;
    final isFisherman = user?['role'] == 'fisherman';
    final pendingCount = _orders.where((o) => o['status'] == 'pending').length;

    return RefreshIndicator(
      onRefresh: _fetchOrders,
      color: AppTheme.cyanAccent,
      backgroundColor: AppTheme.cardBg,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppTheme.primaryBg,
            title: Text(
              lang.t('Demand Alerts', 'Tahadhari za Mahitaji'),
              style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.amberAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.amberAccent.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '$pendingCount ${lang.t('Pending', 'Inasubiri')}',
                  style: GoogleFonts.inter(
                    color: AppTheme.amberAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: _loading
                ? _buildShimmer()
                : _orders.isEmpty
                    ? SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('📋', style: TextStyle(fontSize: 64, color: Colors.grey.shade700)),
                              const SizedBox(height: 16),
                              Text(
                                lang.t('No orders yet', 'Hakuna maagizo bado'),
                                style: GoogleFonts.inter(
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                lang.t(
                                  'Hotel pre-orders will appear here',
                                  'Maagizo ya hoteli yataonekana hapa',
                                ),
                                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final order = _orders[index];
                            final status = order['status'];
                            final color = _statusColor(status);
                            final hasAcceptedBy = order['accepted_by_name'] != null;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              decoration: AppTheme.glassDecoration.copyWith(
                                border: Border.all(color: color.withValues(alpha: 0.3)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header: Order # and Status
                                    Row(
                                      children: [
                                        Text(
                                          _getIcon(order['species_name']),
                                          style: const TextStyle(fontSize: 36),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${lang.t('Order', 'Agizo')} #${order['id']}',
                                                style: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Text(
                                                order['species_name'] ?? 'Unknown',
                                                style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: color.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: color.withValues(alpha: 0.3)),
                                          ),
                                          child: Text(
                                            _statusLabel(status, lang),
                                            style: TextStyle(
                                              color: color,
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 14),

                                    // Buyer Info (visible to fishermen)
                                    if (isFisherman) ...[
                                      _sectionTitle(lang.t('🏨 Buyer Information', '🏨 Taarifa za Mnunuzi'), color),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.03),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                                        ),
                                        child: Column(
                                          children: [
                                            _infoRow(lang.t('Hotel', 'Hoteli'), order['buyer_hotel'] ?? order['buyer_name'] ?? '—', '🏨'),
                                            const SizedBox(height: 6),
                                            _infoRow(lang.t('Contact', 'Mawasiliano'), order['buyer_phone'] ?? '—', '📞'),
                                            const SizedBox(height: 6),
                                            _infoRow(lang.t('Location', 'Mahali'), order['buyer_location'] ?? '—', '📍'),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                    ],

                                    // Fisherman Info (visible to all, shows after acceptance)
                                    if (hasAcceptedBy) ...[
                                      _sectionTitle(lang.t('🎣 Accepted By', '🎣 Amekubaliwa Na'), AppTheme.emeraldAccent),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppTheme.emeraldAccent.withValues(alpha: 0.05),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: AppTheme.emeraldAccent.withValues(alpha: 0.2)),
                                        ),
                                        child: Column(
                                          children: [
                                            _infoRow(lang.t('Fisherman', 'Mvuvi'), order['accepted_by_name'] ?? '—', '👤'),
                                            const SizedBox(height: 6),
                                            _infoRow(lang.t('Contact', 'Mawasiliano'), order['accepted_by_phone'] ?? '—', '📞'),
                                            const SizedBox(height: 6),
                                            _infoRow(lang.t('Market', 'Soko'), order['accepted_by_market'] ?? '—', '🏪'),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                    ],

                                    // Order Details
                                    _sectionTitle(lang.t('📦 Order Details', '📦 Maelezo ya Agizo'), color),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.02),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          _detailChip('📦', '${order['quantity_kg']} kg', lang.t('Quantity', 'Kiasi')),
                                          _detailChip('📅', order['delivery_date'] ?? 'N/A', lang.t('Delivery', 'Uwasilishaji')),
                                          _detailChip(
                                            '💰',
                                            order['max_price_tzs'] != null
                                                ? 'TZS ${order['max_price_tzs']}'
                                                : lang.t('Market price', 'Bei ya soko'),
                                            lang.t('Max Price', 'Bei ya Juu'),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Action Buttons
                                    if (status == 'pending' && isFisherman) ...[
                                      const SizedBox(height: 14),
                                      GestureDetector(
                                        onTap: () => _updateStatus(order['id'], 'accepted'),
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [AppTheme.blueAccent, AppTheme.cyanAccent],
                                            ),
                                            borderRadius: BorderRadius.circular(14),
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppTheme.blueAccent.withValues(alpha: 0.3),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            lang.t('Accept Order', 'Kubali Agizo'),
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.inter(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],

                                    if (status == 'accepted' && isFisherman) ...[
                                      const SizedBox(height: 14),
                                      GestureDetector(
                                        onTap: () => _updateStatus(order['id'], 'fulfilled'),
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          decoration: BoxDecoration(
                                            color: AppTheme.emeraldAccent.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(14),
                                            border: Border.all(
                                              color: AppTheme.emeraldAccent.withValues(alpha: 0.3),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.check_circle, color: AppTheme.emeraldAccent, size: 18),
                                              const SizedBox(width: 8),
                                              Text(
                                                lang.t('Mark as Fulfilled', 'Weka kama Imekamilika'),
                                                style: GoogleFonts.inter(
                                                  color: AppTheme.emeraldAccent,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],

                                    // Delivered badge
                                    if (status == 'fulfilled') ...[
                                      const SizedBox(height: 14),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        decoration: BoxDecoration(
                                          color: AppTheme.emeraldAccent.withValues(alpha: 0.08),
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.check_circle, color: AppTheme.emeraldAccent, size: 20),
                                            const SizedBox(width: 8),
                                            Text(
                                              lang.t('Delivery Completed', 'Uwasilishaji Umekamilika'),
                                              style: GoogleFonts.inter(
                                                color: AppTheme.emeraldAccent,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                          childCount: _orders.length,
                        ),
                      ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade300,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value, String emoji) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 13)),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _detailChip(String emoji, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 9),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade800,
            highlightColor: Colors.grey.shade700,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ),
        childCount: 4,
      ),
    );
  }
}