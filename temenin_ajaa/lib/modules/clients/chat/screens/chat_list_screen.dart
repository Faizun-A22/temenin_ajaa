import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chat_room_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0C11),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFFFF9DCC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.edit_note_rounded, color: Color(0xFF4A1031), size: 30),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
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
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 20),
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
          const CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage('https://i.pravatar.cc/300?img=12'),
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
          hintText: "Find conversations...",
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
  final chats = [
    {
      'name': 'Raditya Pratama',
      'msg': "I've arrived at the pickup location. See you soon!",
      'time': '10:42 AM',
      'unread': 2,
      'img': 'https://i.pravatar.cc/300?img=12'
    },
    {
      'name': 'Adrian Wijaya',
      'msg': "Thank you for the pleasant journey. Have a great day!",
      'time': 'Yesterday',
      'unread': 0,
      'img': 'https://i.pravatar.cc/300?img=13'
    },
    {
      'name': 'Budi Santoso',
      'msg': "Could you please confirm the booking time?",
      'time': 'Sunday',
      'unread': 1,
      'img': 'https://i.pravatar.cc/300?img=14'
    },
    {
      'name': 'Customer Support',
      'msg': "Your recent refund request has been processed successfully.",
      'time': '25 Oct',
      'unread': 0,
      'isSupport': true,
    },
  ];

  return ListView.separated(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: chats.length,
    separatorBuilder: (context, index) => const SizedBox(height: 15),
    itemBuilder: (context, index) {
      final chat = chats[index];
      bool hasUnread = (chat['unread'] as int) > 0;

      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ChatRoomScreen(),
            ),
          );
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
                          chat['name'] as String,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          chat['time'] as String,
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      chat['msg'] as String,
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


  Widget _buildChatAvatar(Map<String, dynamic> chat) {
    bool hasUnread = (chat['unread'] as int) > 0;
    
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: chat['isSupport'] == true ? Colors.white.withOpacity(0.1) : Colors.grey[800],
          backgroundImage: chat['img'] != null ? NetworkImage(chat['img'] as String) : null,
          child: chat['isSupport'] == true 
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
                chat['unread'].toString(),
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }
}