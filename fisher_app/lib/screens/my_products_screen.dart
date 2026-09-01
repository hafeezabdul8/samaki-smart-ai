import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';
import '../services/language_provider.dart';

class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({super.key});

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  List<dynamic> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final api = context.read<ApiService>();
      final auth = context.read<AuthProvider>();
      api.token = auth.token;
      final products = await api.getMyProducts();
      if (mounted) {
        setState(() {
          _products = products;
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

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: AppTheme.primaryBg,
          title: Text(
            lang.t('My Products', 'Bidhaa Zangu'),
            style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(12),
          sliver: _loading
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: AppTheme.cyanAccent)),
                )
              : _products.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('🐟', style: TextStyle(fontSize: 48, color: Colors.grey.shade700)),
                            const SizedBox(height: 12),
                            Text(
                              lang.t('No products yet', 'Hakuna bidhaa bado'),
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              lang.t('Tap "Sell" to upload your catch', 'Gusa "Uza" kuweka samaki wako'),
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = _products[index];
                          final statusColor = product['status'] == 'available'
                              ? AppTheme.emeraldAccent
                              : product['status'] == 'reserved'
                                  ? AppTheme.amberAccent
                                  : Colors.grey;
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: AppTheme.glassDecoration,
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    bottomLeft: Radius.circular(20),
                                  ),
                                  child: Image.network(
                                    product['photo_url'] ?? '',
                                    width: 90,
                                    height: 90,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 90,
                                      height: 90,
                                      color: Colors.grey.shade800,
                                      child: const Icon(Icons.image, color: Colors.grey, size: 30),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product['species_name'] ?? '',
                                        style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 14),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${product['quantity_kg']} kg • ${product['market']}',
                                        style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'TZS ${product['price_per_kg']}/kg',
                                        style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: AppTheme.cyanAccent, fontSize: 15),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    product['status']?.toUpperCase() ?? '',
                                    style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.w700),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                            ),
                          );
                        },
                        childCount: _products.length,
                      ),
                    ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
      ],
    );
  }
}