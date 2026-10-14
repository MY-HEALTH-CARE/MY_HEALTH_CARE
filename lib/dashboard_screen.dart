import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'main.dart';
import 'profile_setup_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => isLoading = false);
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      userData = doc.data();
    } catch (_) {
      userData = null;
    }
    if (mounted) setState(() => isLoading = false);
  }

  ImageProvider? _profileImage() {
    final img = (userData?['profileImage'] ?? '').toString();
    if (img.isEmpty) return null;
    try {
      return MemoryImage(
          base64Decode(img.replaceFirst('data:image/jpeg;base64,', '')));
    } catch (_) {
      return null;
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  void _comingSoon(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name - coming soon'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: Color(0xFF0077B6)),
            SizedBox(width: 10),
            Text('Log Out'),
          ],
        ),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD63031),
                foregroundColor: Colors.white),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String address = (userData?['address'] ?? '').toString();
    final String bloodGroup = (userData?['bloodGroup'] ?? '—').toString();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0077B6)))
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 300,
                  pinned: true,
                  backgroundColor: const Color(0xFF0077B6),
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 12, top: 6),
                      child: IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.logout,
                              color: Colors.white, size: 20),
                        ),
                        onPressed: _confirmLogout,
                      ),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF023E8A), Color(0xFF0096C7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            top: -40,
                            right: -30,
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.08),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -50,
                            left: -20,
                            child: Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF00B4D8)
                                    .withValues(alpha: 0.25),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 120, 20, 18),
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(16, 16, 14, 16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withValues(alpha: 0.20),
                                    Colors.white.withValues(alpha: 0.08),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(26),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.35),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.18),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFFFFD54F),
                                          Colors.white
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      radius: 34,
                                      backgroundColor: Colors.white,
                                      backgroundImage: _profileImage(),
                                      child: _profileImage() == null
                                          ? const Icon(Icons.person,
                                              size: 36,
                                              color: Color(0xFF0077B6))
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          (userData?['name'] ?? 'User')
                                              .toString(),
                                          style: const TextStyle(
                                            fontSize: 21,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                            letterSpacing: 0.2,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Icon(Icons.location_on_rounded,
                                                color: Colors.white
                                                    .withValues(alpha: 0.75),
                                                size: 14),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                address.isEmpty
                                                    ? 'Address not set'
                                                    : address,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white
                                                      .withValues(alpha: 0.75),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                  Icons.water_drop_rounded,
                                                  color: Color(0xFFD63031),
                                                  size: 13),
                                              const SizedBox(width: 5),
                                              Text(
                                                bloodGroup,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0xFF023E8A),
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ProfileSetupScreen(
                                              isEdit: true,
                                              userData: userData ?? {}),
                                        ),
                                      );
                                      if (result == true) loadUserData();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.white.withValues(alpha: 0.20),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.white
                                                .withValues(alpha: 0.35)),
                                      ),
                                      child: const Icon(Icons.edit_outlined,
                                          color: Colors.white, size: 18),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    collapseMode: CollapseMode.parallax,
                  ),
                  title: Text(
                    _getGreeting(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  titleSpacing: 10,
                ),

                // Quick actions
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _quickActionButton(
                            icon: Icons.stars_rounded,
                            label: 'Your Points',
                            gradientColors: const [
                              Color(0xFF6C5CE7),
                              Color(0xFFA29BFE)
                            ],
                            onTap: () => _comingSoon('Your Points'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _quickActionButton(
                            icon: Icons.card_giftcard_rounded,
                            label: 'Explore Offers',
                            gradientColors: const [
                              Color(0xFFFF6B6B),
                              Color(0xFFFFA36B)
                            ],
                            onTap: () => _comingSoon('Explore Offers'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Overview
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle('Overview'),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _overviewActionCard(
                                title: 'Your History',
                                subtitle: 'Past activity',
                                gradientColors: const [
                                  Color(0xFF0077B6),
                                  Color(0xFF00B4D8)
                                ],
                                icon: Icons.history,
                                onTap: () => _comingSoon('Your History'),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _overviewActionCard(
                                title: 'Live Chat',
                                subtitle: 'Chat with support',
                                gradientColors: const [
                                  Color(0xFF00B894),
                                  Color(0xFF38EF7D)
                                ],
                                icon: Icons.support_agent,
                                showLiveDot: true,
                                onTap: () => _comingSoon('Live Chat'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Services title
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                    child: _sectionTitle('Our Services'),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 1.1,
                    ),
                    delegate: SliverChildListDelegate([
                      _serviceCard(
                        icon: Icons.calendar_month,
                        title: 'Book\nAppointment',
                        gradientColors: const [
                          Color(0xFF0077B6),
                          Color(0xFF00B4D8)
                        ],
                        onTap: () => _comingSoon('Book Appointment'),
                      ),
                      _serviceCard(
                        icon: Icons.science,
                        title: 'Lab\nTest',
                        gradientColors: const [
                          Color(0xFF00B894),
                          Color(0xFF38EF7D)
                        ],
                        onTap: () => _comingSoon('Lab Test'),
                      ),
                      _serviceCard(
                        icon: Icons.medication,
                        title: 'Order\nMedicine',
                        gradientColors: const [
                          Color(0xFFE17055),
                          Color(0xFFFAB1A0)
                        ],
                        onTap: () => _comingSoon('Order Medicine'),
                      ),
                      _serviceCard(
                        icon: Icons.alarm,
                        title: 'Medicine\nReminder',
                        gradientColors: const [
                          Color(0xFF6C5CE7),
                          Color(0xFFA29BFE)
                        ],
                        onTap: () => _comingSoon('Medicine Reminder'),
                      ),
                      _serviceCard(
                        icon: Icons.support_agent,
                        title: 'Medical\nAdvisor',
                        gradientColors: const [
                          Color(0xFFFFAB00),
                          Color(0xFFFFD54F)
                        ],
                        onTap: () => _comingSoon('Medical Advisor'),
                      ),
                      _serviceCard(
                        icon: Icons.emergency,
                        title: 'Emergency',
                        gradientColors: const [
                          Color(0xFFD63031),
                          Color(0xFFFF7675)
                        ],
                        onTap: () => _comingSoon('Emergency'),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _sectionTitle(String text) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFF0077B6),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(text,
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E))),
      ],
    );
  }

  Widget _quickActionButton({
    required IconData icon,
    required String label,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withValues(alpha: 0.30),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 17),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _overviewActionCard({
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
    required IconData icon,
    required VoidCallback onTap,
    bool showLiveDot = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -25,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.10),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.22),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.35),
                                ),
                              ),
                              child: Icon(icon, color: Colors.white, size: 20),
                            ),
                            if (showLiveDot)
                              Positioned(
                                right: -2,
                                top: -2,
                                child: Container(
                                  width: 11,
                                  height: 11,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFE66D),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 2),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.20),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_forward_ios,
                              size: 10, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(title,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    const SizedBox(height: 3),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.85))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _serviceCard({
    required IconData icon,
    required String title,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withValues(alpha: 0.38),
              blurRadius: 18,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Positioned(
                right: -26,
                top: -30,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
              ),
              Positioned(
                left: -25,
                bottom: -35,
                child: Container(
                  width: 85,
                  height: 85,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Icon(icon, color: Colors.white, size: 26),
                    ),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}