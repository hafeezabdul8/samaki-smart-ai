import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';
import '../services/language_provider.dart';

class PaymentScreen extends StatefulWidget {
  final int orderId;
  final bool isFisherman; // true = approve/reject, false = pay/upload receipt
  const PaymentScreen({super.key, required this.orderId, required this.isFisherman});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  Map<String, dynamic>? _payment;
  Map<String, dynamic>? _delivery;
  Map<String, dynamic>? _order;
  bool _loading = true;
  final ImagePicker _picker = ImagePicker();

  // Delivery form controllers
  final _deliveryNameCtrl = TextEditingController();
  final _deliveryPhoneCtrl = TextEditingController();
  final _deliveryTimeCtrl = TextEditingController();
  final _deliveryAreaCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  @override
  void dispose() {
    _deliveryNameCtrl.dispose();
    _deliveryPhoneCtrl.dispose();
    _deliveryTimeCtrl.dispose();
    _deliveryAreaCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchDetails() async {
    try {
      final api = context.read<ApiService>();
      final auth = context.read<AuthProvider>();
      api.token = auth.token;
      final details = await api.getOrderDetails(widget.orderId);
      if (mounted) {
        setState(() {
          _order = details['order'];
          _payment = details['payment'];
          _delivery = details['delivery'];
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _generatePayment() async {
    try {
      final api = context.read<ApiService>();
      final auth = context.read<AuthProvider>();
      api.token = auth.token;
      final payment = await api.generatePayment(widget.orderId);
      setState(() => _payment = payment);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.redAccent),
        );
      }
    }
  }

  Future<void> _uploadReceipt() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image == null) return;

    try {
      final api = context.read<ApiService>();
      final auth = context.read<AuthProvider>();
      api.token = auth.token;
      final payment = await api.uploadReceipt(widget.orderId, File(image.path));
      setState(() => _payment = payment);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receipt uploaded ✅'), backgroundColor: AppTheme.emeraldAccent),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e'), backgroundColor: AppTheme.redAccent),
        );
      }
    }
  }

  Future<void> _approvePayment() async {
    try {
      final api = context.read<ApiService>();
      final auth = context.read<AuthProvider>();
      api.token = auth.token;
      final payment = await api.approvePayment(widget.orderId);
      setState(() => _payment = payment);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment approved ✅'), backgroundColor: AppTheme.emeraldAccent),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.redAccent),
        );
      }
    }
  }

  Future<void> _rejectPayment() async {
    try {
      final api = context.read<ApiService>();
      final auth = context.read<AuthProvider>();
      api.token = auth.token;
      final payment = await api.rejectPayment(widget.orderId);
      setState(() => _payment = payment);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment rejected'), backgroundColor: AppTheme.redAccent),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.redAccent),
        );
      }
    }
  }

  Future<void> _assignDelivery() async {
    if (_deliveryNameCtrl.text.isEmpty || _deliveryPhoneCtrl.text.isEmpty ||
        _deliveryTimeCtrl.text.isEmpty || _deliveryAreaCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all delivery fields'), backgroundColor: AppTheme.amberAccent),
      );
      return;
    }

    try {
      final api = context.read<ApiService>();
      final auth = context.read<AuthProvider>();
      api.token = auth.token;
      final delivery = await api.assignDelivery(
        widget.orderId,
        deliveryPersonName: _deliveryNameCtrl.text,
        deliveryPersonPhone: _deliveryPhoneCtrl.text,
        estimatedTime: _deliveryTimeCtrl.text,
        meetingArea: _deliveryAreaCtrl.text,
      );
      setState(() => _delivery = delivery);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Delivery assigned 🚚'), backgroundColor: AppTheme.emeraldAccent),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.redAccent),
        );
      }
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
          widget.isFisherman ? lang.t('Payment & Delivery', 'Malipo na Usafirishaji') : lang.t('Payment', 'Malipo'),
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.cyanAccent))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Info
                  Container(
                    decoration: AppTheme.glassDecoration,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('📦 ${lang.t('Order', 'Agizo')} #${widget.orderId}', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 16)),
                        const SizedBox(height: 8),
                        Text('${_order?['species_name'] ?? ''} • ${_order?['quantity_kg'] ?? ''} kg', style: TextStyle(color: Colors.grey.shade400)),
                        const SizedBox(height: 4),
                        Text('TZS ${_order?['max_price_tzs'] ?? 0}', style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: AppTheme.cyanAccent, fontSize: 20)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Payment Section
                  Container(
                    decoration: AppTheme.glassDecoration,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('💳 ${lang.t('Payment', 'Malipo')}', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 16)),
                        const SizedBox(height: 12),

                        if (_payment == null && !widget.isFisherman) ...[
                          ElevatedButton(
                            onPressed: _generatePayment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.blueAccent,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(lang.t('Generate Control Number', 'Tengeneza Namba ya Malipo'), style: const TextStyle(color: Colors.white)),
                          ),
                        ],

                        if (_payment != null) ...[
                          _infoRow('🔢', lang.t('Control Number', 'Namba ya Malipo'), _payment!['control_number'] ?? ''),
                          const SizedBox(height: 8),
                          _infoRow('💰', lang.t('Amount', 'Kiasi'), 'TZS ${_payment!['amount_tzs']}'),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(_payment!['status']).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _payment!['status']?.toUpperCase() ?? '',
                              style: TextStyle(color: _getStatusColor(_payment!['status']), fontSize: 10, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],

                        // Receipt display
                        if (_payment != null && _payment!['receipt_url'] != null) ...[
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              _payment!['receipt_url'],
                              height: 200,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 200,
                                color: Colors.grey.shade800,
                                child: const Icon(Icons.receipt, color: Colors.grey, size: 40),
                              ),
                            ),
                          ),
                        ],

                        // Actions
                        if (!widget.isFisherman && _payment != null && _payment!['status'] == 'pending') ...[
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _uploadReceipt,
                            icon: const Icon(Icons.upload),
                            label: Text(lang.t('Upload Receipt', 'Pakia Risiti')),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.cyanAccent,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],

                        if (widget.isFisherman && _payment != null && _payment!['status'] == 'paid') ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _approvePayment,
                                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.emeraldAccent, padding: const EdgeInsets.symmetric(vertical: 14)),
                                  child: Text(lang.t('Approve', 'Idhinisha'), style: const TextStyle(color: Colors.white)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _rejectPayment,
                                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.redAccent, padding: const EdgeInsets.symmetric(vertical: 14)),
                                  child: Text(lang.t('Reject', 'Kataa'), style: const TextStyle(color: Colors.white)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Delivery Section
                  Container(
                    decoration: AppTheme.glassDecoration,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('🚚 ${lang.t('Delivery', 'Usafirishaji')}', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 16)),
                        const SizedBox(height: 12),

                        if (_delivery != null) ...[
                          _infoRow('👤', lang.t('Delivery Person', 'Mtoaji'), _delivery!['delivery_person_name'] ?? ''),
                          const SizedBox(height: 8),
                          _infoRow('📞', lang.t('Phone', 'Simu'), _delivery!['delivery_person_phone'] ?? ''),
                          const SizedBox(height: 8),
                          _infoRow('⏰', lang.t('Time', 'Muda'), _delivery!['estimated_time'] ?? ''),
                          const SizedBox(height: 8),
                          _infoRow('📍', lang.t('Meeting Area', 'Eneo la Kukutana'), _delivery!['meeting_area'] ?? ''),
                        ],

                        // Fisherman assigns delivery after payment approved
                        if (widget.isFisherman && _delivery == null && _payment != null && _payment!['status'] == 'approved') ...[
                          const SizedBox(height: 12),
                          TextField(
                            controller: _deliveryNameCtrl,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDec(lang.t('Delivery Person Name', 'Jina la Mtoaji'), Icons.person),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _deliveryPhoneCtrl,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDec(lang.t('Delivery Person Phone', 'Simu ya Mtoaji'), Icons.phone),
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _deliveryTimeCtrl,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDec(lang.t('Estimated Time (e.g. 45 min)', 'Muda (mf. dakika 45)'), Icons.timer),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _deliveryAreaCtrl,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDec(lang.t('Meeting Area', 'Eneo la Kukutana'), Icons.location_on),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _assignDelivery,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.blueAccent,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(lang.t('Assign Delivery', 'Weka Mtoaji'), style: const TextStyle(color: Colors.white)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved': return AppTheme.emeraldAccent;
      case 'paid': return AppTheme.blueAccent;
      case 'rejected': return AppTheme.redAccent;
      default: return AppTheme.amberAccent;
    }
  }

  Widget _infoRow(String emoji, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Expanded(
          child: Text.rich(
            TextSpan(
              text: '$label: ',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              children: [
                TextSpan(
                  text: value,
                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDec(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade600),
      prefixIcon: Icon(icon, color: Colors.grey.shade500, size: 18),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.03),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.cyanAccent),
      ),
    );
  }
}