import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';
import '../services/auth_provider.dart';
import '../services/api_service.dart';
import '../services/language_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool _isLogin = true;
  bool _showPassword = false;
  bool _isForgotPassword = false;
  int _forgotStep = 0;
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _securityQuestionCtrl = TextEditingController();
  final _securityAnswerCtrl = TextEditingController();
  final _forgotUsernameCtrl = TextEditingController();
  final _forgotAnswerCtrl = TextEditingController();
  final _forgotNewPasswordCtrl = TextEditingController();
  String _role = 'fisherman';
  String? _forgotQuestion;
  String _forgotError = '';
  bool _forgotLoading = false;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _phoneCtrl.dispose();
    _securityQuestionCtrl.dispose();
    _securityAnswerCtrl.dispose();
    _forgotUsernameCtrl.dispose();
    _forgotAnswerCtrl.dispose();
    _forgotNewPasswordCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    final api = context.read<ApiService>();
    final lang = context.read<LanguageProvider>();
    try {
      if (_isLogin) {
        await auth.login(_usernameCtrl.text, _passwordCtrl.text);
        
        try {
          final messaging = FirebaseMessaging.instance;
          final fcmToken = await messaging.getToken();
          if (fcmToken != null) {
            api.token = auth.token;
            await api.registerDeviceToken(fcmToken);
            debugPrint('FCM token registered: $fcmToken');
          }
        } catch (e) {
          debugPrint('FCM registration failed: $e');
        }
      } else {
        await auth.register(
          _usernameCtrl.text,
          _phoneCtrl.text,
          _passwordCtrl.text,
          _role,
          securityQuestion: _securityQuestionCtrl.text,
          securityAnswer: _securityAnswerCtrl.text,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(lang.t('Registration successful! Please sign in.', 'Usajili umefanikiwa! Tafadhali ingia.')),
            backgroundColor: AppTheme.emeraldAccent,
          ),
        );
        setState(() => _isLogin = true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lang.t('Login failed. Check credentials.', 'Kuingia kumeshindwa. Angalia taarifa.')),
          backgroundColor: AppTheme.redAccent,
        ),
      );
    }
  }

  Future<void> _fetchSecurityQuestion() async {
    setState(() => _forgotLoading = true);
    _forgotError = '';
    try {
      final res = await http.post(
        Uri.parse('${ApiService.baseUrl}/forgot-password/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': _forgotUsernameCtrl.text.trim()}),
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 200) {
        setState(() {
          _forgotQuestion = data['security_question'];
          _forgotStep = 1;
        });
      } else {
        setState(() => _forgotError = data['error'] ?? 'User not found');
      }
    } catch (e) {
      setState(() => _forgotError = 'Network error. Try again.');
    }
    setState(() => _forgotLoading = false);
  }

  Future<void> _resetPassword() async {
    setState(() => _forgotLoading = true);
    _forgotError = '';
    try {
      final res = await http.post(
        Uri.parse('${ApiService.baseUrl}/reset-password/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _forgotUsernameCtrl.text.trim(),
          'answer': _forgotAnswerCtrl.text.trim(),
          'new_password': _forgotNewPasswordCtrl.text.trim(),
        }),
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 200) {
        setState(() => _forgotStep = 2);
      } else {
        setState(() => _forgotError = data['error'] ?? 'Reset failed');
      }
    } catch (e) {
      setState(() => _forgotError = 'Network error. Try again.');
    }
    setState(() => _forgotLoading = false);
  }

  void _resetForgot() {
    _forgotStep = 0;
    _forgotQuestion = null;
    _forgotError = '';
    _forgotUsernameCtrl.clear();
    _forgotAnswerCtrl.clear();
    _forgotNewPasswordCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0a0f1e), Color(0xFF0d1321)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () => lang.toggle(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🇹🇿', style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Text(
                                lang.locale.languageCode == 'en' ? 'EN' : 'SW',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.blueAccent, AppTheme.cyanAccent],
                        ),
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.blueAccent.withValues(alpha: 0.3),
                            blurRadius: 40,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.waves, color: Colors.white, size: 48),
                    ),
                    const SizedBox(height: 24),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Colors.white, Color(0xFF93C5FD)],
                      ).createShader(bounds),
                      child: Text(
                        lang.t('Samaki Smart AI', 'Samaki Smart AI'),
                        style: GoogleFonts.inter(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      lang.t("Empowering Zanzibar's Fisherfolk", 'Kuwasaidia Wavuvi wa Zanzibar'),
                      style: GoogleFonts.inter(color: Colors.blueGrey.shade300, fontSize: 14),
                    ),
                    const SizedBox(height: 40),
                    Container(
                      decoration: AppTheme.glassDecoration,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          if (!_isForgotPassword) ...[
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.03),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.all(4),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => setState(() => _isLogin = true),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        decoration: BoxDecoration(
                                          color: _isLogin ? AppTheme.blueAccent : Colors.transparent,
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: Text(
                                          lang.t('Sign In', 'Ingia'),
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w600,
                                            color: _isLogin ? Colors.white : Colors.grey.shade500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => setState(() => _isLogin = false),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        decoration: BoxDecoration(
                                          color: !_isLogin ? const Color(0xFF7C3AED) : Colors.transparent,
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: Text(
                                          lang.t('Register', 'Jiandikishe'),
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w600,
                                            color: !_isLogin ? Colors.white : Colors.grey.shade500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          if (_isForgotPassword) ...[
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_back, color: Colors.grey),
                                  onPressed: () {
                                    setState(() {
                                      _isForgotPassword = false;
                                      _resetForgot();
                                    });
                                  },
                                ),
                                Text(
                                  lang.t('Reset Password', 'Badilisha Nywila'),
                                  style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 18),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (_forgotError.isNotEmpty) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.redAccent.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppTheme.redAccent.withValues(alpha: 0.3)),
                                ),
                                child: Text(_forgotError, style: TextStyle(color: AppTheme.redAccent, fontSize: 12)),
                              ),
                              const SizedBox(height: 12),
                            ],
                            if (_forgotStep == 0) ...[
                              TextField(
                                controller: _forgotUsernameCtrl,
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputDecoration(lang.t('Username', 'Jina la mtumiaji'), Icons.person, null),
                              ),
                              const SizedBox(height: 16),
                              GestureDetector(
                                onTap: _forgotLoading ? null : _fetchSecurityQuestion,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(colors: [AppTheme.amberAccent, Colors.orangeAccent]),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Center(
                                    child: _forgotLoading
                                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                        : Text(lang.t('Next', 'Endelea'), style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700)),
                                  ),
                                ),
                              ),
                            ],
                            if (_forgotStep == 1) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.amberAccent.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppTheme.amberAccent.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  _forgotQuestion ?? '',
                                  style: TextStyle(color: AppTheme.amberAccent, fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _forgotAnswerCtrl,
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputDecoration(lang.t('Your Answer', 'Jibu Lako'), Icons.help_outline, null),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _forgotNewPasswordCtrl,
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputDecoration(lang.t('New Password', 'Nywila Mpya'), Icons.lock, null),
                                obscureText: true,
                              ),
                              const SizedBox(height: 16),
                              GestureDetector(
                                onTap: _forgotLoading ? null : _resetPassword,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(colors: [AppTheme.amberAccent, Colors.orangeAccent]),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Center(
                                    child: _forgotLoading
                                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                        : Text(lang.t('Reset Password', 'Badilisha Nywila'), style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700)),
                                  ),
                                ),
                              ),
                            ],
                            if (_forgotStep == 2) ...[
                              const Icon(Icons.check_circle, color: AppTheme.emeraldAccent, size: 64),
                              const SizedBox(height: 16),
                              Text(
                                lang.t('Password Reset!', 'Nywila Imebadilishwa!'),
                                style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 18),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                lang.t('You can now login with your new password.', 'Sasa unaweza kuingia na nywila yako mpya.'),
                                style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isForgotPassword = false;
                                    _resetForgot();
                                  });
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(colors: [AppTheme.blueAccent, AppTheme.cyanAccent]),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Center(
                                    child: Text(lang.t('Back to Login', 'Rudi Kuingia'), style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700)),
                                  ),
                                ),
                              ),
                            ],
                          ] else ...[
                            TextField(
                              controller: _usernameCtrl,
                              style: const TextStyle(color: Colors.white),
                              decoration: _inputDecoration(lang.t('Username', 'Jina la mtumiaji'), Icons.person, null),
                            ),
                            if (!_isLogin) ...[
                              const SizedBox(height: 16),
                              TextField(
                                controller: _phoneCtrl,
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputDecoration(lang.t('Phone (10 digits)', 'Simu (tarakimu 10)'), Icons.phone, null),
                                keyboardType: TextInputType.phone,
                                maxLength: 10,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              ),
                            ],
                            const SizedBox(height: 16),
                            TextField(
                              controller: _passwordCtrl,
                              style: const TextStyle(color: Colors.white),
                              decoration: _inputDecoration(
                                lang.t('Password', 'Nywila'),
                                Icons.lock,
                                IconButton(
                                  icon: Icon(
                                    _showPassword ? Icons.visibility_off : Icons.visibility,
                                    color: Colors.grey.shade500,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(() => _showPassword = !_showPassword),
                                ),
                              ),
                              obscureText: !_showPassword,
                            ),
                            if (!_isLogin) ...[
                              const SizedBox(height: 16),
                              TextField(
                                controller: _securityQuestionCtrl,
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputDecoration(lang.t("Security Question (e.g. Mother's maiden name)", "Swali la Usalama (mf. Jina la mama)"), Icons.security, null),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _securityAnswerCtrl,
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputDecoration(lang.t('Security Answer', 'Jibu la Usalama'), Icons.help_outline, null),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0d1321),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _role,
                                    dropdownColor: AppTheme.cardBg,
                                    style: const TextStyle(color: Colors.white),
                                    items: [
                                      DropdownMenuItem(
                                        value: 'fisherman',
                                        child: Text(lang.t('🎣 Fisherman', '🎣 Mvuvi')),
                                      ),
                                      DropdownMenuItem(
                                        value: 'hotel_buyer',
                                        child: Text(lang.t('🏨 Hotel Buyer', '🏨 Mnunuzi wa Hoteli')),
                                      ),
                                    ],
                                    onChanged: (val) => setState(() => _role = val!),
                                  ),
                                ),
                              ),
                            ],
                            if (_isLogin) ...[
                              const SizedBox(height: 4),
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isForgotPassword = true;
                                      _resetForgot();
                                    });
                                  },
                                  child: Text(
                                    lang.t('Forgot Password?', 'Umesahau Nywila?'),
                                    style: TextStyle(color: AppTheme.cyanAccent, fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                            Consumer<AuthProvider>(
                              builder: (context, auth, _) {
                                return GestureDetector(
                                  onTap: auth.loading ? null : _submit,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: _isLogin
                                            ? [AppTheme.blueAccent, AppTheme.cyanAccent]
                                            : [const Color(0xFF7C3AED), const Color(0xFF9333EA)],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: auth.loading
                                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                        : Text(
                                            _isLogin ? lang.t('Sign In', 'Ingia') : lang.t('Create Account', 'Fungua Akaunti'),
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16),
                                          ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('© 2026 Samaki Smart AI • SUZA', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon, Widget? suffix) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade600),
      prefixIcon: Icon(icon, color: Colors.grey.shade500, size: 20),
      suffixIcon: suffix,
      counterText: '',
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.03),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppTheme.cyanAccent),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}