import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../providers/auth_provider.dart';
import 'chat_room_screen.dart';

class DriverChatListScreen extends StatefulWidget {
  const DriverChatListScreen({super.key});

  @override
  State<DriverChatListScreen> createState() => _DriverChatListScreenState();
}

class _ChatRoomItem {
  final String bookingId;
  final String name;
  final String msg;
  final String time;
  final int unread;
  final String img;
  final String tag;
  final bool isSupport;

  _ChatRoomItem({
    required this.bookingId,
    required this.name,
    required this.msg,
    required this.time,
    required this.unread,
    required this.img,
    required this.tag,
    this.isSupport = false,
  });
}

class _DriverChatListScreenState extends State<DriverChatListScreen> {
  List<_ChatRoomItem> _conversations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final driverId = authProvider.driverProfileData?['id'] as String?;

    if (driverId == null) {
      _loadMockChats();
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('bookings')
          .select('*, users:user_id(*)')
          .eq('driver_id', driverId)
          .order('created_at', ascending: false);

      final List<dynamic> bookings = response as List<dynamic>? ?? [];
      
      if (bookings.isEmpty) {
        _loadMockChats();
        return;
      }

      final List<_ChatRoomItem> loadedItems = [];
      
      for (var booking in bookings) {
        final userData = booking['users'];
        if (userData == null) continue;

        final bookingId = booking['id'] as String;
        final name = userData['full_name'] as String? ?? 'Klien';
        final img = userData['avatar_url'] as String? ?? 'https://i.pravatar.cc/300?img=12';
        
        final details = booking['additional_details'] as Map<String, dynamic>?;
        final msgs = details?['chat_messages'] as List<dynamic>?;
        
        String lastMsg = "Mulai chat dengan klien.";
        String lastTime = "";
        
        if (msgs != null && msgs.isNotEmpty) {
          final lastMsgMap = msgs.last as Map<dynamic, dynamic>;
          lastMsg = lastMsgMap['text'] as String? ?? '';
          lastTime = lastMsgMap['time'] as String? ?? '';
        } else {
          // Format booking date/time as fallback
          final createdAtStr = booking['created_at'] as String?;
          if (createdAtStr != null) {
            try {
              final date = DateTime.parse(createdAtStr).toLocal();
              lastTime = "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
            } catch (_) {}
          }
        }

        final status = booking['status'] as String? ?? 'pending';
        
        loadedItems.add(_ChatRoomItem(
          bookingId: bookingId,
          name: name,
          msg: lastMsg,
          time: lastTime,
          unread: 0,
          img: img,
          tag: status.toUpperCase(),
        ));
      }

      // Add support chat
      loadedItems.add(_ChatRoomItem(
        bookingId: 'support-chat-id',
        name: 'Driver Support',
        msg: "Informasi penyesuaian tarif jam sibuk telah diperbarui.",
        time: '18 Jun',
        unread: 0,
        img: '',
        tag: 'Support',
        isSupport: true,
      ));

      if (mounted) {
        setState(() {
          _conversations = loadedItems;
          _isLoading = false;
        });
      }

    } catch (e) {
      debugPrint('⚠️ Error loading driver bookings from Supabase: $e');
      _loadMockChats();
    }
  }

  void _loadMockChats() {
    if (!mounted) return;
    setState(() {
      _conversations = [
        _ChatRoomItem(
          bookingId: 'mock-booking-id-1',
          name: 'Aura Kasih',
          msg: "Halo Kak, posisinya di mana?",
          time: '12:00 PM',
          unread: 1,
          img: 'https://i.pravatar.cc/300?img=47',
          tag: 'ON THE WAY',
        ),
        _ChatRoomItem(
          bookingId: 'mock-booking-id-2',
          name: 'Nicholas Saputra',
          msg: "Halo Kak, sudah sampai di Grand Indonesia?",
          time: 'Yesterday',
          unread: 0,
          img: 'https://i.pravatar.cc/300?img=12',
          tag: 'COMPLETED',
        ),
        _ChatRoomItem(
          bookingId: 'support-chat-id',
          name: 'Driver Support',
          msg: "Informasi penyesuaian tarif jam sibuk telah diperbarui.",
          time: '18 Jun',
          unread: 0,
          img: '',
          tag: 'Support',
          isSupport: true,
        ),
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0910),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadConversations,
        backgroundColor: const Color(0xFFFF9DCC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.refresh_rounded, color: Color(0xFF4A1031), size: 28),
      ),
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
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF9DCC)),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadConversations,
                        color: const Color(0xFFFF9DCC),
                        backgroundColor: const Color(0xFF16151A),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              _buildSearchBar(),
                              const SizedBox(height: 25),
                              _buildOnlineStories(),
                              const SizedBox(height: 25),
                              _buildChatList(),
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final avatar = auth.user?.avatarUrl ?? 'https://i.pravatar.cc/300?img=33';

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Chat Klien",
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFFF9DCC),
            ),
          ),
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(avatar),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF16151A),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: Colors.white.withOpacity(0.3)),
          hintText: "Cari chat klien...",
          hintStyle: GoogleFonts.poppins(color: Colors.white.withOpacity(0.3), fontSize: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildOnlineStories() {
    final users = [
      {'name': 'Anda', 'img': 'https://i.pravatar.cc/300?img=33', 'isMe': true},
      {'name': 'Aura', 'img': 'https://i.pravatar.cc/300?img=47', 'isMe': false},
      {'name': 'Nicholas', 'img': 'https://i.pravatar.cc/300?img=12', 'isMe': false},
    ];

    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: users.length,
        separatorBuilder: (context, index) => const SizedBox(width: 20),
        itemBuilder: (context, index) {
          final user = users[index];
          return Column(
            children: [
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: user['isMe'] == true ? const Color(0xFFFF9DCC) : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 26,
                      backgroundImage: NetworkImage(user['img'] as String),
                    ),
                  ),
                  if (user['isMe'] == false)
                    Positioned(
                      right: 2,
                      bottom: 2,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.greenAccent,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF0B0910), width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                user['name'] as String,
                style: GoogleFonts.poppins(
                  color: user['isMe'] == true ? const Color(0xFFFF9DCC) : Colors.white.withOpacity(0.6),
                  fontSize: 11,
                  fontWeight: user['isMe'] == true ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _conversations.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final chat = _conversations[index];
        bool hasUnread = chat.unread > 0;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DriverChatRoomScreen(
                  bookingId: chat.bookingId,
                  clientName: chat.name,
                  clientImage: chat.img.isEmpty ? 'https://i.pravatar.cc/300?img=12' : chat.img,
                ),
              ),
            ).then((_) {
              _loadConversations();
            });
          },
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFF16151A),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: hasUnread 
                    ? const Color(0xFFFF9DCC).withOpacity(0.3) 
                    : Colors.white.withOpacity(0.05),
              ),
            ),
            child: Row(
              children: [
                _buildChatAvatar(chat),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            chat.name,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            chat.time,
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              chat.msg,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                color: hasUnread
                                    ? const Color(0xFFFF9DCC)
                                    : Colors.white.withOpacity(0.5),
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: chat.isSupport
                                  ? Colors.blue.withOpacity(0.15)
                                  : const Color(0xFFFF9DCC).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              chat.tag,
                              style: GoogleFonts.poppins(
                                color: chat.isSupport ? Colors.blue : const Color(0xFFFF9DCC),
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChatAvatar(_ChatRoomItem chat) {
    bool hasUnread = chat.unread > 0;
    
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: chat.isSupport ? Colors.white.withOpacity(0.1) : Colors.grey[800],
          backgroundImage: chat.img.isNotEmpty ? NetworkImage(chat.img) : null,
          child: chat.isSupport 
            ? const Icon(Icons.headset_mic_rounded, color: Color(0xFFFF9DCC), size: 24) 
            : null,
        ),
        if (hasUnread)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(color: Color(0xFFFF9DCC), shape: BoxShape.circle),
              child: Text(
                chat.unread.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }
}
