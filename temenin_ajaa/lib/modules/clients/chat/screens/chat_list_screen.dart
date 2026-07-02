import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../providers/auth_provider.dart';
import 'chat_room_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
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

class _ChatListScreenState extends State<ChatListScreen> {
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
    final userId = authProvider.user?.id;

    if (userId == null) {
      _loadMockChats();
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('bookings')
          .select('*, drivers(*, users(*))')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final List<dynamic> bookings = response as List<dynamic>? ?? [];
      
      if (bookings.isEmpty) {
        _loadMockChats();
        return;
      }

      final List<_ChatRoomItem> loadedItems = [];
      
      for (var booking in bookings) {
        final driverData = booking['drivers'];
        if (driverData == null) continue;
        final userData = driverData['users'];
        if (userData == null) continue;

        final bookingId = booking['id'] as String;
        final name = userData['full_name'] as String? ?? 'Pendamping';
        final img = userData['avatar_url'] as String? ?? 'https://i.pravatar.cc/300?img=33';
        
        final details = booking['additional_details'] as Map<String, dynamic>?;
        final msgs = details?['chat_messages'] as List<dynamic>?;
        
        String lastMsg = "Mulai chat dengan pendamping.";
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

        final rating = driverData['rating']?.toString() ?? '5.0';
        
        loadedItems.add(_ChatRoomItem(
          bookingId: bookingId,
          name: name,
          msg: lastMsg,
          time: lastTime,
          unread: 0,
          img: img,
          tag: "Rating $rating",
        ));
      }

      // Add support chat at the end as default
      loadedItems.add(_ChatRoomItem(
        bookingId: 'support-chat-id',
        name: 'Customer Support',
        msg: "Your recent refund request has been processed successfully.",
        time: '25 Oct',
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
      debugPrint('⚠️ Error loading bookings from Supabase: $e');
      _loadMockChats();
    }
  }

  void _loadMockChats() {
    if (!mounted) return;
    setState(() {
      _conversations = [
        _ChatRoomItem(
          bookingId: 'mock-booking-id-1',
          name: 'Raditya Pratama',
          msg: "I've arrived at the pickup location. See you soon!",
          time: '10:42 AM',
          unread: 2,
          img: 'https://i.pravatar.cc/300?img=12',
          tag: 'Gold',
        ),
        _ChatRoomItem(
          bookingId: 'mock-booking-id-2',
          name: 'Adrian Wijaya',
          msg: "Thank you for the pleasant journey. Have a great day!",
          time: 'Yesterday',
          unread: 0,
          img: 'https://i.pravatar.cc/300?img=13',
          tag: 'VVIP',
        ),
        _ChatRoomItem(
          bookingId: 'mock-booking-id-3',
          name: 'Budi Santoso',
          msg: "Could you please confirm the booking time?",
          time: 'Sunday',
          unread: 1,
          img: 'https://i.pravatar.cc/300?img=14',
          tag: 'Bronze',
        ),
        _ChatRoomItem(
          bookingId: 'support-chat-id',
          name: 'Customer Support',
          msg: "Your recent refund request has been processed successfully.",
          time: '25 Oct',
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
      backgroundColor: const Color(0xFF0D0C11),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadConversations,
        backgroundColor: const Color(0xFFFF9DCC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.refresh_rounded, color: Color(0xFF4A1031), size: 30),
      ),
      body: SafeArea(
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
                      backgroundColor: const Color(0xFF1C1B21),
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
                            const SizedBox(height: 30),
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
    );
  }

  Widget _buildAppBar() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final avatar = auth.user?.avatarUrl ?? 'https://i.pravatar.cc/300?img=12';

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                onPressed: () => Navigator.maybePop(context),
              ),
              const SizedBox(width: 10),
              Text(
                "Chat",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFF9DCC),
                ),
              ),
            ],
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
        color: const Color(0xFF1C1B21),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: Colors.white.withOpacity(0.3)),
          hintText: "Cari percakapan...",
          hintStyle: GoogleFonts.poppins(color: Colors.white.withOpacity(0.3), fontSize: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildOnlineStories() {
    final users = [
      {'name': 'You', 'img': 'https://i.pravatar.cc/300?img=11', 'isMe': true},
      {'name': 'Raditya', 'img': 'https://i.pravatar.cc/300?img=12', 'isMe': false},
      {'name': 'Adrian', 'img': 'https://i.pravatar.cc/300?img=13', 'isMe': false},
      {'name': 'Budi', 'img': 'https://i.pravatar.cc/300?img=14', 'isMe': false},
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
                      radius: 28,
                      backgroundImage: NetworkImage(user['img'] as String),
                    ),
                  ),
                  if (user['isMe'] == false)
                    Positioned(
                      right: 2,
                      bottom: 2,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.greenAccent,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF0D0C11), width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                user['name'] as String,
                style: GoogleFonts.poppins(
                  color: user['isMe'] == true ? const Color(0xFFFF9DCC) : Colors.white.withOpacity(0.6),
                  fontSize: 12,
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
      separatorBuilder: (context, index) => const SizedBox(height: 15),
      itemBuilder: (context, index) {
        final chat = _conversations[index];
        bool hasUnread = chat.unread > 0;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatRoomScreen(
                  bookingId: chat.bookingId,
                  partnerName: chat.name,
                  partnerImage: chat.img.isEmpty ? 'https://i.pravatar.cc/300?img=33' : chat.img,
                  partnerTag: chat.tag,
                  partnerStatus: chat.isSupport ? "Customer Support" : "Online Now",
                ),
              ),
            ).then((_) {
              // Refresh when returning to list
              _loadConversations();
            });
          },
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFF16151A),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
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
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            chat.time,
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        chat.msg,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: hasUnread
                              ? const Color(0xFFFF9DCC)
                              : Colors.white.withOpacity(0.5),
                          fontSize: 13,
                        ),
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
          radius: 30,
          backgroundColor: chat.isSupport ? Colors.white.withOpacity(0.1) : Colors.grey[800],
          backgroundImage: chat.img.isNotEmpty ? NetworkImage(chat.img) : null,
          child: chat.isSupport 
            ? const Icon(Icons.headset_mic_rounded, color: Color(0xFFFF9DCC), size: 30) 
            : null,
        ),
        if (hasUnread)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(color: Color(0xFFFF9DCC), shape: BoxShape.circle),
              child: Text(
                chat.unread.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }
}