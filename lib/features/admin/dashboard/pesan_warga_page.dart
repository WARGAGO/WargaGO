import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PesanWargaPage extends StatefulWidget {
  const PesanWargaPage({super.key});

  @override
  State<PesanWargaPage> createState() => _PesanWargaPageState();
}

class _PesanWargaPageState extends State<PesanWargaPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> allMessages = [
    {
      'name': 'Pak Rusdi',
      'message': 'Mohon info jadwal ronda bulan ini. Apakah ada perubahan',
      'date': '19 Oktober 2025',
      'time': '5 menit lalu',
      'isRead': false,
      'status': 'pending',
    },
    {
      'name': 'Pak Rusdi',
      'message': 'Mohon info jadwal ronda bulan ini. Apakah ada perubahan',
      'date': '19 Oktober 2025',
      'time': '5 menit lalu',
      'isRead': false,
      'status': 'pending',
    },
    {
      'name': 'Pak Rusdi',
      'message': 'Mohon info jadwal ronda bulan ini. Apakah ada perubahan',
      'date': '19 Oktober 2025',
      'time': '5 menit lalu',
      'isRead': true,
      'status': 'pending',
    },
    {
      'name': 'Pak Rusdi',
      'message': 'Mohon info jadwal ronda bulan ini. Apakah ada perubahan',
      'date': '19 Oktober 2025',
      'time': '5 menit lalu',
      'isRead': false,
      'status': 'pending',
    },
    {
      'name': 'Pak Rusdi',
      'message': 'Mohon info jadwal ronda bulan ini. Apakah ada perubahan',
      'date': '19 Oktober 2025',
      'time': '5 menit lalu',
      'isRead': true,
      'status': 'pending',
    },
    {
      'name': 'Pak Rusdi',
      'message': 'Mohon info jadwal ronda bulan ini. Apakah ada perubahan',
      'date': '19 Oktober 2025',
      'time': '5 menit lalu',
      'isRead': true,
      'status': 'diterima',
    },
    {
      'name': 'Pak Rusdi',
      'message': 'Mohon info jadwal ronda bulan ini. Apakah ada perubahan',
      'date': '19 Oktober 2025',
      'time': '5 menit lalu',
      'isRead': false,
      'status': 'pending',
    },
    {
      'name': 'Pak Rusdi',
      'message': 'Mohon info jadwal ronda bulan ini. Apakah ada perubahan',
      'date': '19 Oktober 2025',
      'time': '5 menit lalu',
      'isRead': true,
      'status': 'ditolak',
    },
  ];

  List<Map<String, dynamic>> getFilteredMessages(String status) {
    var messages = allMessages;

    if (status != 'all') {
      messages = messages.where((msg) => msg['status'] == status).toList();
    }

    if (searchQuery.isNotEmpty) {
      messages = messages.where((msg) {
        return msg['name']!.toLowerCase().contains(searchQuery.toLowerCase()) ||
            msg['message']!.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }

    return messages;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pesan dari Warga',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() => searchQuery = value);
                },
                decoration: InputDecoration(
                  hintText: 'Cari Pesan...',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                  icon: Icon(Icons.search, color: Colors.grey[500], size: 20),
                  border: InputBorder.none,
                ),
                style: GoogleFonts.poppins(fontSize: 14),
              ),
            ),
          ),

          // Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey[600],
              labelStyle: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: 'Pending'),
                Tab(text: 'Diterima'),
                Tab(text: 'Ditolak'),
              ],
              onTap: (index) => setState(() {}),
            ),
          ),

          const SizedBox(height: 16),

          // Messages List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMessageList('pending'),
                _buildMessageList('diterima'),
                _buildMessageList('ditolak'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(String status) {
    final messages = getFilteredMessages(status);

    if (messages.isEmpty) {
      return Center(
        child: Text(
          'Tidak ada pesan',
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: messages.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final message = messages[index];
        return _buildMessageCard(message);
      },
    );
  }

  Widget _buildMessageCard(Map<String, dynamic> message) {
    final bool isRead = message['isRead'] ?? false;
    final bool hasUnreadIndicator = !isRead;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRead
              ? const Color(0xFFE8EAF2)
              : const Color(0xFF2F80ED).withOpacity(0.3),
          width: isRead ? 1 : 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF2F80ED).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Color(0xFF2F80ED), size: 24),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      message['name']!,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (hasUnreadIndicator)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2F80ED),
                          shape: BoxShape.circle,
                        ),
                      ),
                    const Spacer(),
                    Text(
                      message['time']!,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  message['message']!,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  message['date']!,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey[600],
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
