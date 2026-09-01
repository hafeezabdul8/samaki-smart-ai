import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';
import '../services/language_provider.dart';

class UploadProductScreen extends StatefulWidget {
  const UploadProductScreen({super.key});

  @override
  State<UploadProductScreen> createState() => _UploadProductScreenState();
}

class _UploadProductScreenState extends State<UploadProductScreen> {
  final _priceCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  
  List<dynamic> _species = [];
  int? _selectedSpeciesId;
  File? _photo;
  String? _photoUrl;
  String _market = 'Malindi Market';
  bool _loading = true;
  bool _uploading = false;
  bool _submitting = false;

  final _markets = ['Malindi Market', 'Darajani Market', 'Mkokotoni Market', 'Nungwi Market', 'Mahonda Market'];

  @override
  void initState() {
    super.initState();
    _fetchSpecies();
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    _qtyCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchSpecies() async {
    try {
      final api = context.read<ApiService>();
      final alerts = await api.getAlerts();
      if (mounted) {
        setState(() {
          _species = alerts;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image == null) return;
    setState(() => _photo = File(image.path));
    await _uploadPhoto();
  }

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (photo == null) return;
    setState(() => _photo = File(photo.path));
    await _uploadPhoto();
  }

  Future<void> _uploadPhoto() async {
    if (_photo == null) return;
    setState(() => _uploading = true);
    try {
      final auth = context.read<AuthProvider>();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiService.baseUrl}/products/upload-photo/'),
      );
      request.headers['Authorization'] = 'Bearer ${auth.token}';
      request.files.add(await http.MultipartFile.fromPath('file', _photo!.path));
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      debugPrint('Photo upload status: ${response.statusCode}');
      debugPrint('Photo upload body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() => _photoUrl = data['url']);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Photo uploaded ✅'), backgroundColor: AppTheme.emeraldAccent),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Photo upload failed (${response.statusCode})'), backgroundColor: AppTheme.redAccent),
          );
        }
      }
    } catch (e) {
      debugPrint('Photo upload error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.redAccent),
        );
      }
    }
    setState(() => _uploading = false);
  }

  Future<void> _submit() async {
    if (_selectedSpeciesId == null || _photoUrl == null || _priceCtrl.text.isEmpty || _qtyCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _photoUrl == null ? 'Please upload a photo first' : 'Please fill all required fields',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppTheme.amberAccent,
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final api = context.read<ApiService>();
      final auth = context.read<AuthProvider>();
      api.token = auth.token;

      await api.createProduct(
        speciesId: _selectedSpeciesId!,
        photoUrl: _photoUrl!,
        pricePerKg: double.parse(_priceCtrl.text),
        quantityKg: double.parse(_qtyCtrl.text),
        market: _market,
        description: _descCtrl.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product published! 🎉'), backgroundColor: AppTheme.emeraldAccent),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('Submit error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: AppTheme.redAccent),
        );
      }
    }
    setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: AppTheme.primaryBg,
      appBar: AppBar(
        backgroundColor: AppTheme.cardBg,
        title: Text(lang.t('Upload Product', 'Weka Bidhaa'), style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.cyanAccent))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _uploading ? null : () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: AppTheme.cardBg,
                          builder: (ctx) => SafeArea(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.photo_library, color: AppTheme.cyanAccent),
                                  title: const Text('Gallery', style: TextStyle(color: Colors.white)),
                                  onTap: () { Navigator.pop(ctx); _pickImage(); },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.camera_alt, color: AppTheme.cyanAccent),
                                  title: const Text('Camera', style: TextStyle(color: Colors.white)),
                                  onTap: () { Navigator.pop(ctx); _takePhoto(); },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: AppTheme.cardBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: _uploading
                            ? const Center(child: CircularProgressIndicator(color: AppTheme.cyanAccent))
                            : _photo != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.file(_photo!, width: 200, height: 200, fit: BoxFit.cover),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_a_photo, color: Colors.grey.shade500, size: 48),
                                      const SizedBox(height: 8),
                                      Text(lang.t('Add Photo', 'Ongeza Picha'), style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
                                    ],
                                  ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(lang.t('Species', 'Aina ya Samaki'), style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedSpeciesId,
                        isExpanded: true,
                        dropdownColor: AppTheme.cardBg,
                        hint: Text(lang.t('Select Species', 'Chagua Samaki'), style: TextStyle(color: Colors.grey.shade600)),
                        style: const TextStyle(color: Colors.white),
                        items: _species.map((s) {
                          return DropdownMenuItem<int>(
                            value: s['id'],
                            child: Text('${s['name_en']} (${s['name_sw']})', style: const TextStyle(fontSize: 14)),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedSpeciesId = val),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(lang.t('Price per kg (TZS)', 'Bei kwa kilo (TZS)'), style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _priceCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDec('TZS 10,000', Icons.payments),
                  ),
                  const SizedBox(height: 16),

                  Text(lang.t('Quantity (kg)', 'Kiasi (kilo)'), style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _qtyCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDec('50', Icons.scale),
                  ),
                  const SizedBox(height: 16),

                  Text(lang.t('Market', 'Soko'), style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _market,
                        isExpanded: true,
                        dropdownColor: AppTheme.cardBg,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        items: _markets.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                        onChanged: (val) => setState(() => _market = val!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(lang.t('Description', 'Maelezo'), style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _descCtrl,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDec(lang.t('Fresh catch, good quality...', 'Samaki mbichi, ubora mzuri...'), Icons.description),
                  ),
                  const SizedBox(height: 24),

                  GestureDetector(
                    onTap: _submitting ? null : _submit,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppTheme.blueAccent, AppTheme.cyanAccent]),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: _submitting
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(lang.t('Publish Product', 'Chapisha Bidhaa'), style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  InputDecoration _inputDec(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade600),
      prefixIcon: Icon(icon, color: Colors.grey.shade500, size: 18),
      filled: true,
      fillColor: AppTheme.cardBg,
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