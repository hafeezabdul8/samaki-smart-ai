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

  Future<void> _showEditDialog(dynamic product) async {
    final priceCtrl = TextEditingController(text: product['price_per_kg']?.toString() ?? '');
    final qtyCtrl = TextEditingController(text: product['quantity_kg']?.toString() ?? '');

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: Text('Edit Product', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Price per kg (TZS)',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.cyanAccent)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: qtyCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Quantity (kg)',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.cyanAccent)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final api = context.read<ApiService>();
                final auth = context.read<AuthProvider>();
                api.token = auth.token;
                await api.updateProduct(
                  product['id'],
                  pricePerKg: double.parse(priceCtrl.text),
                  quantityKg: double.parse(qtyCtrl.text),
                );
                _fetchProducts();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Product updated ✅'), backgroundColor: AppTheme.emeraldAccent),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Update failed: $e'), backgroundColor: AppTheme.redAccent),
                  );
                }
              }
            },
            child: const Text('Save', style: TextStyle(color: AppTheme.cyanAccent, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog(dynamic product) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: Text('Delete Product', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        content: Text(
          'Are you sure you want to delete this product?',
          style: TextStyle(color: Colors.grey.shade400),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final api = context.read<ApiService>();
                final auth = context.read<AuthProvider>();
                api.token = auth.token;
                await api.deleteProduct(product['id']);
                _fetchProducts();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Product deleted 🗑️'), backgroundColor: AppTheme.redAccent),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Delete failed: $e'), backgroundColor: AppTheme.redAccent),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: AppTheme.redAccent, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
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
                              lang.t('Tap + to upload your catch', 'Gusa + kuweka samaki wako'),
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
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.network(
                                    product['photo_url'] ?? '',
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 80,
                                      height: 80,
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
                                // Status + Actions
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: statusColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        product['status']?.toUpperCase() ?? '',
                                        style: TextStyle(color: statusColor, fontSize: 8, fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    if (product['status'] == 'available')
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, color: AppTheme.cyanAccent, size: 18),
                                            onPressed: () => _showEditDialog(product),
                                            visualDensity: VisualDensity.compact,
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: AppTheme.redAccent, size: 18),
                                            onPressed: () => _showDeleteDialog(product),
                                            visualDensity: VisualDensity.compact,
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
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