import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final email = authState.email ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildAvatar(email),
          const SizedBox(height: 32),
          _buildSection('Account', [
            _buildTile(Icons.email_outlined, 'Email', email),
            _buildTile(Icons.person_outline, 'Username', email.split('@').first),
          ]),
          const SizedBox(height: 20),
          _buildSection('App', [
            _buildTile(Icons.info_outline, 'Version', '1.0.0'),
          ]),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: () async {
              await ref.read(authNotifierProvider).signOut();
              if (context.mounted) context.go('/login');
            },
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            label: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String email) {
    final initials = email.isNotEmpty ? email[0].toUpperCase() : '?';
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 42,
            backgroundColor: AppColors.primary,
            child: Text(
              initials,
              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            email,
            style: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> tiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(children: tiles),
        ),
      ],
    );
  }

  Widget _buildTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
