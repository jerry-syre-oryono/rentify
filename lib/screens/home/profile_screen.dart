import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_providers.dart';
import '../../utils/constants.dart';

import 'package:rentify/screens/home/edit_profile_screen.dart';
import 'package:rentify/screens/home/security_screen.dart';

class NotificationNotifier extends Notifier<bool> {
  @override
  bool build() {
    return true; // Default value
  }

  void toggle() {
    state = !state;
  }
}

final notificationProvider = NotifierProvider<NotificationNotifier, bool>(() {
  return NotificationNotifier();
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final notificationsEnabled = ref.watch(notificationProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: user == null
          ? const Center(child: Text('Please login to view profile'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    child: Icon(Icons.person, size: 50),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(user.email, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 32),
                  
                  // Seller Section
                  _buildSectionHeader('Selling'),
                  _buildProfileItem(
                    icon: Icons.dashboard_outlined,
                    title: 'Seller Dashboard',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.push(AppConstants.routeSellerDashboard);
                    },
                  ),
                  _buildProfileItem(
                    icon: Icons.add_business_outlined,
                    title: 'List a Property',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.push(AppConstants.routeAddProperty);
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  _buildSectionHeader('Account Settings'),
                  _buildProfileItem(
                    icon: Icons.edit_outlined,
                    title: 'Edit Profile',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                      );
                    },
                  ),
                  _buildProfileItem(
                    icon: Icons.notifications_none,
                    title: 'Notifications',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ref.read(notificationProvider.notifier).toggle();
                    },
                    trailing: Switch(
                      value: notificationsEnabled,
                      onChanged: (value) {
                        ref.read(notificationProvider.notifier).toggle();
                      },
                    ),
                  ),
                  _buildProfileItem(
                    icon: Icons.security,
                    title: 'Security',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SecurityScreen()),
                      );
                    },
                  ),
                  const Divider(height: 40),
                  _buildProfileItem(
                    icon: Icons.logout,
                    title: 'Logout',
                    textColor: Colors.red,
                    iconColor: Colors.red,
                    onTap: () async {
                      HapticFeedback.mediumImpact();
                      await ref.read(authNotifierProvider.notifier).logout();
                      if (context.mounted) {
                        context.go(AppConstants.routeLogin);
                      }
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? const Color(0xFF0066FF)),
      title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
      trailing: trailing ?? const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}
