import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';
import '../services/language_provider.dart';

class ChatScreen extends StatefulWidget {
  final int orderId;
  final String otherPartyName;
  const ChatScreen({super.key, required this.orderId, required this.otherPartyName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageCtrl = TextEditingController();
  final _scrollController = ScrollController();
  List<dynamic> _messages = [];
  List<dynamic> _media = [];
  bool _loading = true;
  bool _sending = false;
  bool _uploading = false;
  Timer? _pollTimer;
  int? _currentUserId;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _currentUserId = auth.user?['id'];
    _fetchMessages();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _fetchMessages());
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    _scrollController.dispose();
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchMessages() async {
    try {
      final auth = context.read<AuthProvider>();
      final token = auth.token;
      
      if (token == null) {
        debugPrint('No token available');
        return;
      }

      final res = await http.get(
        Uri.parse('${ApiService.baseUrl}/chat/orders/${widget.orderId}/messages/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (mounted) {
          setState(() {
            _messages = data['messages'] ?? [];
            _media = data['media'] ?? [];
            _loading = false;
          });
        }
      } else {
        debugPrint('Fetch messages failed: ${res.statusCode} - ${res.body}');
        if (mounted) setState(() => _loading = false);
      }
    } catch (e) {
      debugPrint('Fetch error: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageCtrl.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);
    _messageCtrl.clear();
    
    try {
      final auth = context.read<AuthProvider>();
      final token = auth.token;
      
      final res = await http.post(
        Uri.parse('${ApiService.baseUrl}/chat/orders/${widget.orderId}/send/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'message': text}),
      );
      
      if (res.statusCode == 201) {
        await _fetchMessages();
        _scrollToBottom();
      } else {
        debugPrint('Send failed: ${res.statusCode} - ${res.body}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Send failed (${res.statusCode})'),
              backgroundColor: AppTheme.redAccent,
            ),
          );
        }
        // Restore text
        _messageCtrl.text = text;
      }
    } catch (e) {
      debugPrint('Send error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.redAccent),
        );
      }
      _messageCtrl.text = text;
    }
    setState(() => _sending = false);
  }

  Future<void> _pickAndUploadImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image == null) return;
    await _uploadFile(File(image.path), 'image');
  }

  Future<void> _takeAndUploadPhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (photo == null) return;
    await _uploadFile(File(photo.path), 'image');
  }

  Future<void> _uploadFile(File file, String type) async {
    setState(() => _uploading = true);
    try {
      final auth = context.read<AuthProvider>();
      final token = auth.token;
      
      debugPrint('Uploading with token: ${token?.substring(0, 20)}...');
      
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiService.baseUrl}/chat/orders/${widget.orderId}/media/'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['media_type'] = type;
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      debugPrint('Upload response: ${response.statusCode}');
      debugPrint('Upload body: ${response.body}');
      
      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image uploaded! ✅'),
              backgroundColor: AppTheme.emeraldAccent,
              duration: Duration(seconds: 2),
            ),
          );
        }
        await _fetchMessages();
        _scrollToBottom();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Upload failed (${response.statusCode}). Please re-login.'),
              backgroundColor: AppTheme.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Upload error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload error: $e'), backgroundColor: AppTheme.redAccent),
        );
      }
    }
    setState(() => _uploading = false);
  }

  String _getMediaUrl(String fileUrl) {
    if (fileUrl.startsWith('http://') || fileUrl.startsWith('https://')) {
      return fileUrl;
    }
    final rootUrl = ApiService.baseUrl.replaceAll('/api/auth', '');
    return '$rootUrl$fileUrl';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: AppTheme.primaryBg,
      appBar: AppBar(
        backgroundColor: AppTheme.cardBg,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppTheme.blueAccent, AppTheme.cyanAccent]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  widget.otherPartyName.isNotEmpty ? widget.otherPartyName[0].toUpperCase() : '?',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.otherPartyName, style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 14)),
                  Text(lang.t('Order #${widget.orderId}', 'Agizo #${widget.orderId}'), style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.cyanAccent))
          : Column(
              children: [
                Expanded(
                  child: _messages.isEmpty && _media.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('💬', style: TextStyle(fontSize: 48, color: Colors.grey.shade700)),
                              const SizedBox(height: 12),
                              Text(
                                lang.t('No messages yet', 'Hakuna ujumbe bado'),
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                lang.t('Start the conversation!', 'Anzisha mazungumzo!'),
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                          itemCount: _messages.length + _media.length,
                          itemBuilder: (context, index) {
                            if (index < _media.length) {
                              final media = _media[index];
                              final isMe = media['uploader'] == _currentUserId;
                              return Align(
                                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.cardBg,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          _getMediaUrl(media['file_url'] ?? ''),
                                          width: 180,
                                          height: 180,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child, progress) {
                                            if (progress == null) return child;
                                            return Container(
                                              width: 180,
                                              height: 180,
                                              color: Colors.grey.shade800,
                                              child: const Center(
                                                child: CircularProgressIndicator(color: AppTheme.cyanAccent, strokeWidth: 2),
                                              ),
                                            );
                                          },
                                          errorBuilder: (_, __, ___) {
                                            return Container(
                                              width: 180,
                                              height: 180,
                                              color: Colors.grey.shade800,
                                              child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 40),
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        media['uploader_name'] ?? '',
                                        style: TextStyle(color: Colors.grey.shade500, fontSize: 9),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            
                            final msgIndex = index - _media.length;
                            final msg = _messages[msgIndex];
                            final isMe = msg['sender'] == _currentUserId;
                            return _buildMessageBubble(msg, isMe);
                          },
                        ),
                ),
                if (_uploading)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    color: AppTheme.cardBg,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(color: AppTheme.cyanAccent, strokeWidth: 2),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          lang.t('Uploading image...', 'Inapakia picha...'),
                          style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg,
                    border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.image_outlined, color: Colors.grey),
                          onPressed: _uploading
                              ? null
                              : () {
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
                                            onTap: () { Navigator.pop(ctx); _pickAndUploadImage(); },
                                          ),
                                          ListTile(
                                            leading: const Icon(Icons.camera_alt, color: AppTheme.cyanAccent),
                                            title: const Text('Camera', style: TextStyle(color: Colors.white)),
                                            onTap: () { Navigator.pop(ctx); _takeAndUploadPhoto(); },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                        ),
                        Expanded(
                          child: TextField(
                            controller: _messageCtrl,
                            style: const TextStyle(color: Colors.white),
                            onSubmitted: (_) => _sendMessage(),
                            decoration: InputDecoration(
                              hintText: lang.t('Type a message...', 'Andika ujumbe...'),
                              hintStyle: TextStyle(color: Colors.grey.shade600),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.03),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _sending ? null : _sendMessage,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [AppTheme.blueAccent, AppTheme.cyanAccent]),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: _sending
                                ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Icon(Icons.send, color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildMessageBubble(dynamic msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        decoration: BoxDecoration(
          gradient: isMe
              ? const LinearGradient(colors: [AppTheme.blueAccent, AppTheme.cyanAccent])
              : null,
          color: isMe ? null : AppTheme.cardBg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              msg['message'] ?? '',
              style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
            ),
            const SizedBox(height: 2),
            Text(
              DateTime.parse(msg['created_at']).toLocal().toString().substring(11, 16),
              style: TextStyle(color: isMe ? Colors.white.withValues(alpha: 0.7) : Colors.grey.shade600, fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }
}