import 'package:bookapp/app/theme/app_tokens.dart';
import 'package:bookapp/core/errors/api_failure_mapper.dart';
import 'package:bookapp/core/widgets/content_shell.dart';
import 'package:bookapp/features/auth/presentation/auth_screens.dart';
import 'package:bookapp/features/books/presentation/books_providers.dart';
import 'package:bookapp/features/cart/presentation/cart_controller.dart';
import 'package:bookapp/features/checkout/data/checkout_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

final checkoutRepositoryProvider = Provider<CheckoutRepository>(
  (ref) => ApiCheckoutRepository(ref.watch(apiClientProvider)),
);

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  bool _busy = false;
  String? _error;

  Future<void> _continue() async {
    final items = ref.read(cartControllerProvider).items;
    if (items.isEmpty || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final value = await ref
          .read(checkoutRepositoryProvider)
          .createSession(items);
      final uri = validateCheckoutUri(value);
      if (uri == null) {
        throw const FormatException(
          'The checkout value is not a verified HTTPS URL.',
        );
      }
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened) {
        throw StateError('The payment provider could not be opened.');
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error is FormatException
              ? 'The backend returned an unverified checkout destination. No payment page was opened.'
              : mapApiFailure(error);
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartControllerProvider);
    return Scaffold(
      backgroundColor: AppColors.midnight,
      appBar: AppBar(title: const Text('Checkout')),
      body: SafeArea(
        child: RequireAuth(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ContentShell(
              maxWidth: 760,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Review and handoff',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Leaf & Loom asks the bookstore service to create a checkout session. Payment, if configured, continues with the external provider.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _CheckoutStep(
                    number: '1',
                    title: 'Bag',
                    detail:
                        '${cart.items.length} items · ${cart.subtotal.toStringAsFixed(2)}',
                  ),
                  const _CheckoutStep(
                    number: '2',
                    title: 'Shipping',
                    detail:
                        'The checkout contract does not accept an address payload.',
                  ),
                  const _CheckoutStep(
                    number: '3',
                    title: 'Payment',
                    detail:
                        'Secure external handoff when the backend returns a verified HTTPS URL.',
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        _error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: cart.items.isEmpty || _busy ? null : _continue,
                      icon: _busy
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.open_in_new_rounded),
                      label: Text(
                        cart.items.isEmpty
                            ? 'Your bag is empty'
                            : 'Continue to payment provider',
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Returning from the provider does not imply payment success. Order and cart state must be verified with the backend.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckoutStep extends StatelessWidget {
  const _CheckoutStep({
    required this.number,
    required this.title,
    required this.detail,
  });
  final String number;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              child: Text(number),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    detail,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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
