import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DriverChatRoomScreen extends StatefulWidget {
  final String bookingId;
  final String clientName;
  final String clientImage;

  const DriverChatRoomScreen({
    super.key,
    required this.bookingId,
    required this.clientName,
    required this.clientImage,
  });

  @override
  State<DriverChatRoomScreen> createState() => _DriverChatRoomScreenState();
}

class _DriverChatRoomScreenState extends State<DriverChatRoomScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<Map<String, dynamic>> _messages = [];
  Map<String, dynamic>? _bookingData;
  StreamSubscription<List<Map<String, dynamic>>>? _streamSubscription;
  bool _isConnecting = true;

  @override
  void initState() {
    super.initState();
    _subscribeToChat();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _getMockClientReply(String driverMessage) {
    final lower = driverMessage.toLowerCase();
    if (lower.contains('halo') || lower.contains('hi') || lower.contains('hello')) {
      return "Halo Kak! Saya siap menunggu di lokasi penjemputan.";
    } else if (lower.contains('jalan') || lower.contains('menuju') || lower.contains('otw')) {
      return "Siap Kak, hati-hati di jalan ya! Kabari kalau sudah sampai.";
    } else if (lower.contains('sampai') || lower.contains('lokasi') || lower.contains('disini')) {
      return "Baik Kak, saya langsung keluar ke lobi sekarang.";
    } else if (lower.contains('terima kasih') || lower.contains('makasih') || lower.contains('thanks')) {
      return "Sama-sama Kak! 🙏";
    }
    return "Baik Kak, terima kasih infonya. Saya tunggu ya.";
  }

  void _subscribeToChat() {
    debugPrint('📡 Subscribing to chat updates for Booking: ${widget.bookingId}');
    if (widget.bookingId == 'dummy-booking-id') {
      setState(() {
        _messages = [
          {
            'sender': 'user',
            'text': 'Halo Kak, posisinya di mana?',
            'time': '12:00',
          }
        ];
        _isConnecting = false;
      });
      _scrollToBottom();
      return;
    }

    try {
      _streamSubscription = Supabase.instance.client
          .from('bookings')
          .stream(primaryKey: ['id'])
          .eq('id', widget.bookingId)
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
            debugPrint('❌ Stream subscription error: $err');
            if (mounted) {
              setState(() {
                _isConnecting = false;
              });
            }
          });
    } catch (e) {
      debugPrint('❌ Supabase stream error: $e');
      setState(() {
        _isConnecting = false;
      });
    }
  }

  void _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    final now = DateTime.now();
    final timeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    
    final newMsg = {
      'sender': 'driver',
      'text': text,
      'time': timeStr,
      'timestamp': now.toIso8601String(),
    };

    final updatedMessages = List<Map<String, dynamic>>.from(_messages)..add(newMsg);

    if (widget.bookingId == 'dummy-booking-id') {
      setState(() {
        _messages = updatedMessages;
        _msgController.clear();
      });
      _scrollToBottom();

      // Trigger automatic client reply after 1.5 seconds
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          final replyTime = DateTime.now();
          final replyTimeStr = "${replyTime.hour.toString().padLeft(2, '0')}:${replyTime.minute.toString().padLeft(2, '0')}";
          setState(() {
            _messages.add({
              'sender': 'user', // client
              'text': _getMockClientReply(text),
              'time': replyTimeStr,
              'timestamp': replyTime.toIso8601String(),
            });
          });
          _scrollToBottom();
        }
      });
      return;
    }
    
    // Create copy of current additional details
    final currentDetails = Map<String, dynamic>.from(_bookingData?['additional_details'] ?? {});
    currentDetails['chat_messages'] = updatedMessages;

    // Optimistic UI update
    setState(() {
      _messages = updatedMessages;
      _msgController.clear();
    });
    _scrollToBottom();

    // Write to database
    try {
      await Supabase.instance.client
          .from('bookings')
          .update({
            'additional_details': currentDetails,
          })
          .eq('id', widget.bookingId);
      debugPrint('✅ Message sent successfully to Supabase');
    } catch (e) {
      debugPrint('❌ Failed to update messages in Supabase: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal mengirim pesan: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients && mounted) {
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
    return Scaffold(
      backgroundColor: const Color(0xFF0B0910),
      appBar: _buildAppBar(context),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF160D27),
              Color(0xFF0B0910),
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: _isConnecting
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF9DCC)),
                      ),
                    )
                  : _messages.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final msg = _messages[index];
                            final isMe = msg['sender'] == 'driver';

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
                                      border: isMe 
                                          ? null 
                                          : Border.all(color: Colors.white.withOpacity(0.05)),
                                    ),
                                    child: Text(
                                      msg['text'] ?? '',
                                      style: GoogleFonts.poppins(
                                        color: isMe ? const Color(0xFF4A1031) : Colors.white,
                                        fontSize: 14,
                                        fontWeight: isMe ? FontWeight.w600 : FontWeight.normal,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5, bottom: 15, left: 4, right: 4),
                                    child: Text(
                                      msg['time'] ?? '',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.25),
                                        fontSize: 10,
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
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF16151A),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(widget.clientImage),
            backgroundColor: Colors.white10,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    widget.clientName,
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
                      color: const Color(0xFFFF9DCC).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "Client",
                      style: GoogleFonts.poppins(
                        color: const Color(0xFFFF9DCC),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                "Hubungan Aman & Terenkripsi",
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: Colors.white30,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 64,
              color: const Color(0xFFFF9DCC).withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              "Mulai Obrolan",
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Kirim pesan ke client untuk mengabarkan posisi Anda atau koordinasi penjemputan.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    final quickReplies = [
      "Saya sedang menuju lokasi ya.",
      "Saya sudah sampai di lokasi.",
      "Saya menggunakan helm & jaket pendamping.",
      "Siap Kak, terima kasih!",
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF16151A),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Replies Bar
          Container(
            height: 48,
            padding: const EdgeInsets.only(top: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: quickReplies.length,
              itemBuilder: (context, index) {
                final reply = quickReplies[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ActionChip(
                    label: Text(
                      reply,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFFFF9DCC),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    backgroundColor: const Color(0xFFFF9DCC).withOpacity(0.1),
                    side: BorderSide(color: const Color(0xFFFF9DCC).withOpacity(0.25)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    onPressed: () {
                      _msgController.text = reply;
                      _sendMessage();
                    },
                  ),
                );
              },
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.my_location_rounded, color: Color(0xFFFF9DCC)),
                  onPressed: () {
                    // Quick share location template
                    _msgController.text = "Saya sudah berada dekat lokasi penjemputan Anda.";
                  },
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B0910),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: TextField(
                      controller: _msgController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: "Tulis pesan ke client...",
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
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
