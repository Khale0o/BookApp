import 'package:bookapp/app/theme/app_tokens.dart';
import 'package:bookapp/core/widgets/async_message.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
    backgroundColor: AppColors.midnight,
    body: SafeArea(
      child: AsyncMessage(
        icon: Icons.person_outline_rounded,
        title: 'Your reading account',
        message: 'Sign in to view account information, addresses, and orders.',
      ),
    ),
  );
}
