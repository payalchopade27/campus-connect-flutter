import 'package:flutter/material.dart';
import 'package:campus_connect/features/home/presentation/screens/communities_screen.dart';
import 'package:campus_connect/features/home/presentation/screens/profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F7),
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Campus Connect",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _welcomeCard(),
          const SizedBox(height: 24),

          _sectionTitle("Quick Actions"),
          _quickActions(context),

          const SizedBox(height: 28),
          _sectionTitle("Trending Communities"),
          _trendingCommunities(),

          const SizedBox(height: 28),
          _sectionTitle("Looking for Team"),
          _teamPreview(),
        ],
      ),
    );
  }

  // ================= UI SECTIONS =================

  Widget _welcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Build your next project 🚀",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Find teammates, join communities, and collaborate with students from your campus.",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _quickActions(BuildContext context) {
    return Row(
      children: [
        _actionTile(
          icon: Icons.groups_outlined,
          title: "Communities",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CommunitiesScreen(),
              ),
            );
          },
        ),
        const SizedBox(width: 16),
        _actionTile(
          icon: Icons.person_outline,
          title: "Profile",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ProfileScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _trendingCommunities() {
    return _placeholderCard(
      icon: Icons.local_fire_department_outlined,
      title: "Explore active communities",
      subtitle: "Join tech, startup & project-based groups",
    );
  }

  Widget _teamPreview() {
    return _placeholderCard(
      icon: Icons.groups,
      title: "Students looking for teammates",
      subtitle: "Open requests will appear here",
    );
  }

  // ================= REUSABLE =================

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, size: 36, color: const Color(0xFF4F46E5)),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholderCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 36, color: const Color(0xFF4F46E5)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}