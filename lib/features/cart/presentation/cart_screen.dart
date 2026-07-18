import 'package:bookapp/app/theme/app_tokens.dart';
import 'package:bookapp/core/widgets/async_message.dart';
import 'package:flutter/material.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
    backgroundColor: AppColors.midnight,
    body: SafeArea(
      child: AsyncMessage(
        icon: Icons.shopping_bag_outlined,
        title: 'Your bag is ready when you are',
        message:
            'Sign in to load and manage the cart attached to your account.',
      ),
    ),
  );
}
