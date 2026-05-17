// lib/modules/home/pages/rewards_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:temenin_ajaa/core/services/reward_service.dart';
import '../../../providers/auth_provider.dart';


class RewardsPage extends StatefulWidget {
  const RewardsPage({super.key});

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> with SingleTickerProviderStateMixin {
  final RewardService _rewardService = RewardService();
  late TabController _tabController;
  
  List<Reward> _rewards = [];
  List<Voucher> _vouchers = [];
  List<Transaction> _transactions = [];
  
  bool _isLoading = true;
  String? _errorMessage;
  
  int _totalPoints = 0;
  int _pointsToNextLevel = 500;
  int _currentLevel = 1;
  String _currentTier = 'Bronze';
  
  final Map<String, dynamic> _tierInfo = {
    'Bronze': {'minPoints': 0, 'color': Color(0xFFCD7F32), 'benefits': ['Basic support', 'Standard booking']},
    'Silver': {'minPoints': 1000, 'color': Color(0xFFC0C0C0), 'benefits': ['Priority support', '5% discount', 'Free cancellation']},
    'Gold': {'minPoints': 5000, 'color': Color(0xFFFFD700), 'benefits': ['VIP support', '10% discount', 'Free cancellation', 'Priority booking']},
    'Platinum': {'minPoints': 15000, 'color': Color(0xFFE5E4E2), 'benefits': ['24/7 VIP support', '15% discount', 'Free cancellation', 'Priority booking', 'Exclusive events']},
    'Diamond': {'minPoints': 30000, 'color': Color(0xFFB9F2FF), 'benefits': ['Personal assistant', '20% discount', 'Free cancellation', 'Priority booking', 'Exclusive events', 'Birthday gift']},
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user!.id;
      
      final rewardsResult = await _rewardService.getRewards(userId);
      final vouchersResult = await _rewardService.getVouchers(userId);
      final pointsResult = await _rewardService.getUserPoints(userId);
      
      if (rewardsResult['success'] == true) {
        _rewards = rewardsResult['rewards'];
        _transactions = rewardsResult['transactions'] ?? [];
      }
      
      if (vouchersResult['success'] == true) {
        _vouchers = vouchersResult['vouchers'];
      }
      
      if (pointsResult['success'] == true) {
        _totalPoints = pointsResult['points'];
        _updateTier();
      }
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _updateTier() {
    if (_totalPoints >= 30000) {
      _currentTier = 'Diamond';
      _pointsToNextLevel = 0;
    } else if (_totalPoints >= 15000) {
      _currentTier = 'Platinum';
      _pointsToNextLevel = 30000 - _totalPoints;
    } else if (_totalPoints >= 5000) {
      _currentTier = 'Gold';
      _pointsToNextLevel = 15000 - _totalPoints;
    } else if (_totalPoints >= 1000) {
      _currentTier = 'Silver';
      _pointsToNextLevel = 5000 - _totalPoints;
    } else {
      _currentTier = 'Bronze';
      _pointsToNextLevel = 1000 - _totalPoints;
    }
  }

  Future<void> _redeemReward(Reward reward) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1C24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Redeem Reward',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              reward.name,
              style: GoogleFonts.poppins(color: const Color(0xFFFF9DCC), fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              reward.description,
              style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.7)),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9DCC).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Color(0xFFFF9DCC), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Cost: ${reward.pointsCost} points',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFFF9DCC),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_totalPoints < reward.pointsCost)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Insufficient points! You need ${reward.pointsCost - _totalPoints} more points.',
                        style: GoogleFonts.poppins(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.5))),
          ),
          ElevatedButton(
            onPressed: _totalPoints >= reward.pointsCost
                ? () async {
                    Navigator.pop(context);
                    
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(
                        child: CircularProgressIndicator(color: Color(0xFFFF9DCC)),
                      ),
                    );
                    
                    final result = await _rewardService.redeemReward(reward.id);
                    
                    if (context.mounted) {
                      Navigator.pop(context);
                      
                      if (result['success'] == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Reward redeemed successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        _loadData();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result['message'] ?? 'Failed to redeem reward'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF9DCC),
              foregroundColor: Colors.black,
            ),
            child: const Text('Redeem'),
          ),
        ],
      ),
    );
  }

  Future<void> _claimVoucher(Voucher voucher) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1C24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Claim Voucher',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2D1121), Color(0xFF6B2142)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    voucher.code,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFFF9DCC),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    voucher.discount == voucher.maxDiscount
                        ? '${voucher.discount}% OFF'
                        : 'Up to ${voucher.discount}% OFF',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Min. spend Rp ${_formatPrice(voucher.minSpend)}',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              voucher.description,
              style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.7)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Valid until: ${_formatDate(voucher.expiryDate)}',
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.5))),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFF9DCC)),
                ),
              );
              
              final result = await _rewardService.claimVoucher(voucher.id);
              
              if (context.mounted) {
                Navigator.pop(context);
                
                if (result['success'] == true) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: const Color(0xFF1E1C24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      title: Text(
                        'Voucher Claimed! 🎉',
                        style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.local_offer, color: Color(0xFFFF9DCC), size: 50),
                          const SizedBox(height: 16),
                          Text(
                            voucher.code,
                            style: GoogleFonts.poppins(
                              color: const Color(0xFFFF9DCC),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Use this code at checkout',
                            style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.7)),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('OK', style: GoogleFonts.poppins(color: const Color(0xFFFF9DCC))),
                        ),
                      ],
                    ),
                  );
                  _loadData();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result['message'] ?? 'Failed to claim voucher'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF9DCC),
              foregroundColor: Colors.black,
            ),
            child: const Text('Claim Now'),
          ),
        ],
      ),
    );
  }

  String _formatPrice(int? price) {
    if (price == null) return '0';
    return price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0B10),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Rewards & Vouchers',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFF9DCC),
          labelColor: const Color(0xFFFF9DCC),
          unselectedLabelColor: Colors.white.withOpacity(0.5),
          tabs: const [
            Tab(text: 'Rewards'),
            Tab(text: 'Vouchers'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFF9DCC),
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF9DCC),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildRewardsTab(),
                    _buildVouchersTab(),
                    _buildHistoryTab(),
                  ],
                ),
    );
  }

  Widget _buildRewardsTab() {
    return Column(
      children: [
        // Points Card
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2D1121), Color(0xFF6B2142)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Points',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '$_totalPoints',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFFF9DCC),
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9DCC).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.star,
                      color: Color(0xFFFF9DCC),
                      size: 40,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Tier',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          _currentTier,
                          style: GoogleFonts.poppins(
                            color: (_tierInfo[_currentTier]['color'] as Color),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_pointsToNextLevel > 0)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Next: ${_getNextTier()}',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '$_pointsToNextLevel points to go',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFFFF9DCC),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: _getProgressValue(),
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF9DCC)),
                borderRadius: BorderRadius.circular(10),
              ),
            ],
          ),
        ),
        
        // Rewards List
        Expanded(
          child: _rewards.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.card_giftcard,
                        size: 64,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No rewards available',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _rewards.length,
                  itemBuilder: (context, index) {
                    final reward = _rewards[index];
                    return _buildRewardCard(reward);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildRewardCard(Reward reward) {
    final canRedeem = _totalPoints >= reward.pointsCost;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF16151A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9DCC).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                reward.icon,
                color: const Color(0xFFFF9DCC),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reward.name,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reward.description,
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Color(0xFFFF9DCC)),
                      const SizedBox(width: 4),
                      Text(
                        '${reward.pointsCost} points',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFFF9DCC),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (reward.stock > 0) ...[
                        const SizedBox(width: 12),
                        const Icon(Icons.inventory, size: 14, color: Colors.white54),
                        const SizedBox(width: 4),
                        Text(
                          '${reward.stock} left',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: canRedeem && reward.stock != 0 ? () => _redeemReward(reward) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canRedeem && reward.stock != 0
                    ? const Color(0xFFFF9DCC)
                    : Colors.grey,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(canRedeem ? 'Redeem' : 'Locked'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVouchersTab() {
    return _vouchers.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_offer_outlined,
                  size: 64,
                  color: Colors.white.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No vouchers available',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _vouchers.length,
            itemBuilder: (context, index) {
              final voucher = _vouchers[index];
              return _buildVoucherCard(voucher);
            },
          );
  }

  Widget _buildVoucherCard(Voucher voucher) {
    final isExpired = voucher.expiryDate?.isBefore(DateTime.now()) ?? false;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isExpired
              ? [Colors.grey.withOpacity(0.3), Colors.grey.withOpacity(0.1)]
              : [const Color(0xFF2D1121), const Color(0xFF6B2142)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.local_offer,
                    color: Color(0xFFFF9DCC),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        voucher.discount == voucher.maxDiscount
                            ? '${voucher.discount}% OFF'
                            : 'Up to ${voucher.discount}% OFF',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFFF9DCC),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        voucher.description,
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.attach_money, size: 14, color: Colors.white54),
                          const SizedBox(width: 4),
                          Text(
                            'Min spend Rp ${_formatPrice(voucher.minSpend)}',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.calendar_today, size: 12, color: Colors.white54),
                          const SizedBox(width: 4),
                          Text(
                            'Valid until ${_formatDate(voucher.expiryDate)}',
                            style: GoogleFonts.poppins(
                              color: isExpired ? Colors.red : Colors.white.withOpacity(0.5),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (!isExpired && !voucher.isClaimed)
                  ElevatedButton(
                    onPressed: () => _claimVoucher(voucher),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9DCC),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Claim'),
                  ),
                if (voucher.isClaimed)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Claimed',
                      style: GoogleFonts.poppins(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (isExpired)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Expired',
                      style: GoogleFonts.poppins(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (voucher.isClaimed)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
                child: Text(
                  'CLAIMED',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return _transactions.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 64,
                  color: Colors.white.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No transaction history',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _transactions.length,
            itemBuilder: (context, index) {
              final transaction = _transactions[index];
              return _buildTransactionCard(transaction);
            },
          );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16151A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: transaction.type == 'earn'
                  ? Colors.green.withOpacity(0.1)
                  : const Color(0xFFFF9DCC).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              transaction.type == 'earn' ? Icons.add_circle : Icons.card_giftcard,
              color: transaction.type == 'earn' ? Colors.green : const Color(0xFFFF9DCC),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(transaction.createdAt),
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            transaction.type == 'earn' ? '+${transaction.points}' : '-${transaction.points}',
            style: GoogleFonts.poppins(
              color: transaction.type == 'earn' ? Colors.green : const Color(0xFFFF9DCC),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  double _getProgressValue() {
  if (_currentTier == 'Diamond') return 1.0;
  
  final tiers = ['Bronze', 'Silver', 'Gold', 'Platinum', 'Diamond'];
  final currentIndex = tiers.indexOf(_currentTier);
  final nextTierPoints = _getTierMinPoints(tiers[currentIndex + 1]);
  
  // 🔴 HAPUS 'const' - ini yang menyebabkan error
  final prevTierPoints = _getTierMinPoints(_currentTier);  // ← Hapus 'const'
  
  final pointsInCurrentTier = _totalPoints - prevTierPoints;
  final pointsNeeded = nextTierPoints - prevTierPoints;
  
  if (pointsNeeded <= 0) return 1.0;
  return (pointsInCurrentTier / pointsNeeded).clamp(0.0, 1.0);
}

  int _getTierMinPoints(String tier) {
    switch (tier) {
      case 'Bronze': return 0;
      case 'Silver': return 1000;
      case 'Gold': return 5000;
      case 'Platinum': return 15000;
      case 'Diamond': return 30000;
      default: return 0;
    }
  }

  String _getNextTier() {
    final tiers = ['Bronze', 'Silver', 'Gold', 'Platinum', 'Diamond'];
    final currentIndex = tiers.indexOf(_currentTier);
    if (currentIndex < tiers.length - 1) {
      return tiers[currentIndex + 1];
    }
    return 'Max Level';
  }
}

// Models
class Reward {
  final String id;
  final String name;
  final String description;
  final int pointsCost;
  final IconData icon;
  final int stock;

  Reward({
    required this.id,
    required this.name,
    required this.description,
    required this.pointsCost,
    required this.icon,
    required this.stock,
  });
}

class Voucher {
  final String id;
  final String code;
  final String description;
  final int discount;
  final int maxDiscount;
  final int minSpend;
  final DateTime? expiryDate;
  final bool isClaimed;

  Voucher({
    required this.id,
    required this.code,
    required this.description,
    required this.discount,
    required this.maxDiscount,
    required this.minSpend,
    this.expiryDate,
    this.isClaimed = false,
  });
}

class Transaction {
  final String id;
  final String description;
  final int points;
  final String type; // 'earn' or 'redeem'
  final DateTime? createdAt;

  Transaction({
    required this.id,
    required this.description,
    required this.points,
    required this.type,
    this.createdAt,
  });
}