// lib/modules/clients/chat/screens/chat_room_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatRoomScreen extends StatefulWidget {
  final String? bookingId;
  final String? partnerName;
  final String? partnerImage;
  final String? partnerStatus;
  final String? partnerTag;

  const ChatRoomScreen({
    super.key,
    this.bookingId,
    this.partnerName,
    this.partnerImage,
    this.partnerStatus,
    this.partnerTag,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  List<Map<String, dynamic>> _messages = [];
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  Map<String, dynamic>? _bookingData;
  StreamSubscription<List<Map<String, dynamic>>>? _streamSubscription;
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    if (widget.bookingId != null && 
        widget.bookingId != 'mock-booking-id' && 
        !widget.bookingId!.startsWith('mock-booking-id')) {
      _isConnecting = true;
      _subscribeToChat();
    } else {
      // Default initial mock messages
      _messages.addAll([
        {
          'sender': 'driver',
          'text': "Hi! I'm already at the location we agreed on. I'm wearing a dark coat and standing near the main entrance. Ready for our walk?",
          'time': "14:22",
        },
        {
          'sender': 'user',
          'text': "Perfect! I just parked my car. Be there in 2 minutes. Can't wait to meet you! ✨",
          'time': "14:23",
        },
      ]);
    }
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _subscribeToChat() {
    try {
      _streamSubscription = Supabase.instance.client
          .from('bookings')
          .stream(primaryKey: ['id'])
          .eq('id', widget.bookingId!)
          .listen((List<Map<String, dynamic>> data) {
            if (data.isNotEmpty && mounted) {
              setState(() {
                _bookingData = data.first;
                final details = _bookingData?['additional_details'] as Map<String, dynamic>?;
                final msgs = details?['chat_messages'] as List<dynamic>?;
                _messages = msgs?.map((m) => Map<String, dynamic>.from(m as Map)).toList() ?? [];
                _isConnecting = false;
              });
              _scrollToBottom();
            }
          }, onError: (err) {
            debugPrint('Client chat room stream error: $err');
            if (mounted) {
              setState(() {
                _isConnecting = false;
              });
            }
          });
    } catch (e) {
      debugPrint('Supabase stream setup error: $e');
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }
    }
  }

  void _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    final now = DateTime.now();
    final timeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    
    final newMsg = {
      'sender': 'user',
      'text': text,
      'time': timeStr,
      'timestamp': now.toIso8601String(),
    };

    if (widget.bookingId != null && 
        widget.bookingId != 'mock-booking-id' && 
        !widget.bookingId!.startsWith('mock-booking-id')) {
      
      final updatedMessages = List<Map<String, dynamic>>.from(_messages)..add(newMsg);
      final currentDetails = Map<String, dynamic>.from(_bookingData?['additional_details'] ?? {});
      currentDetails['chat_messages'] = updatedMessages;

      setState(() {
        _messages = updatedMessages;
        _msgController.clear();
      });
      _scrollToBottom();

      try {
        await Supabase.instance.client
            .from('bookings')
            .update({
              'additional_details': currentDetails,
            })
            .eq('id', widget.bookingId!);
        debugPrint('✅ Message sent from client to Supabase successfully');
      } catch (e) {
        debugPrint('❌ Error sending message from client: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal mengirim pesan: $e"), backgroundColor: Colors.red),
          );
        }
      }
    } else {
      // Mock simulation mode
      setState(() {
        _messages.add(newMsg);
        _msgController.clear();
      });
      _scrollToBottom();

      // Mock driver automated reply
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          final replyTime = DateTime.now();
          final replyTimeStr = "${replyTime.hour.toString().padLeft(2, '0')}:${replyTime.minute.toString().padLeft(2, '0')}";
          setState(() {
            _messages.add({
              'sender': 'driver',
              'text': _getMockDriverReply(text),
              'time': replyTimeStr,
            });
          });
          _scrollToBottom();
        }
      });
    }
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  String _getMockDriverReply(String userMessage) {
    final lower = userMessage.toLowerCase();
    if (lower.contains('halo') || lower.contains('hi') || lower.contains('hello')) {
      return "Halo! Ada yang bisa saya bantu untuk request Anda?";
    } else if (lower.contains('dimana') || lower.contains('posisi') || lower.contains('lokasi')) {
      return "Saya di dekat pintu lobi utama, berjaket hitam dan menggunakan helm/masker ya.";
    } else if (lower.contains('tolong') || lower.contains('bantu')) {
      return "Siap Kak, saya bantu laksanakan sekarang. Ada instruksi tambahan?";
    } else if (lower.contains('makasih') || lower.contains('terima kasih') || lower.contains('thank')) {
      return "Sama-sama Kak! Senang bisa mendampingi perjalanannya. 🙏";
    }
    return "Baik Kak, dimengerti. Saya stand by sesuai instruksi.";
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
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
    final name = widget.partnerName ?? "Dian Sastro";
    final image = widget.partnerImage ?? "https://i.pravatar.cc/300?img=14";
    final status = widget.partnerStatus ?? "Online Now";
    final tag = widget.partnerTag ?? "Gold";

    return Scaffold(
      backgroundColor: const Color(0xFF0D0C11),
      appBar: _buildAppBar(context, name, image, status, tag),
      body: Column(
        children: [
          Expanded(
            child: _isConnecting
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF9DCC)),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isMe = msg['sender'] == 'user';

                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isMe ? const Color(0xFFFF9DCC) : const Color(0xFF1C1B21),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(20),
                            topRight: const Radius.circular(20),
                            bottomLeft: isMe ? const Radius.circular(20) : Radius.zero,
                            bottomRight: isMe ? Radius.zero : const Radius.circular(20),
                          ),
                        ),
                        child: Text(
                          msg['text'],
                          style: GoogleFonts.poppins(
                            color: isMe ? const Color(0xFF4A1031) : Colors.white,
                            fontSize: 14,
                            fontWeight: isMe ? FontWeight.w600 : FontWeight.normal,
                            height: 1.4,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 15),
                        child: Text(
                          msg['time'],
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.2),
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, String name, String image, String status, String tag) {
    return AppBar(
      backgroundColor: const Color(0xFF16151A),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(image),
                child: Container(
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white24)),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF16151A), width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9DCC).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        color: Color(0xFFFF9DCC),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                status,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.phone_outlined, color: Color(0xFFFF9DCC)),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Melakukan panggilan VOIP aman (Trust & Safety)...")),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 30),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0C11),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.location_on_outlined, color: Colors.white54),
            onPressed: () {
              setState(() {
                _messages.add({
                  'sender': 'user',
                  'text': "📍 Mengirim lokasi saat ini (Senayan City Mall)",
                  'time': _getCurrentTime(),
                });
              });
              _scrollToBottom();
            },
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1B21),
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _msgController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Tulis pesan...",
                  hintStyle: TextStyle(color: Colors.white24, fontSize: 13),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFFFF9DCC),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Color(0xFF4A1031),
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}