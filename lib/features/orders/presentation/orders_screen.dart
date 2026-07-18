import 'package:bookapp/app/theme/app_tokens.dart';
import 'package:bookapp/core/widgets/async_message.dart';
import 'package:bookapp/core/widgets/content_shell.dart';
import 'package:bookapp/features/auth/presentation/auth_screens.dart';
import 'package:bookapp/features/profile/domain/account_models.dart';
import 'package:bookapp/features/profile/presentation/account_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final ordersProvider = FutureProvider.autoDispose<List<UserOrder>>(
  (ref) => ref.watch(accountRepositoryProvider).getOrders(),
);

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);
    return Scaffold(
      backgroundColor: AppColors.midnight,
      appBar: AppBar(title: const Text('Orders')),
      body: SafeArea(
        child: RequireAuth(
          child: orders.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => AsyncMessage(
              icon: Icons.receipt_long_outlined,
              title: 'Orders could not be loaded',
              message: 'The backend did not return a usable order list.',
              actionLabel: 'Try again',
              onAction: () => ref.invalidate(ordersProvider),
            ),
            data: (items) => items.isEmpty
                ? const AsyncMessage(
                    icon: Icons.receipt_long_outlined,
                    title: 'No orders yet',
                    message: 'Completed backend orders will appear here.',
                  )
                : RefreshIndicator(
                    onRefresh: () => ref.refresh(ordersProvider.future),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      itemCount: items.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) =>
                          ContentShell(child: _OrderCard(order: items[index])),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});
  final UserOrder order;

  @override
  Widget build(BuildContext context) => ExpansionTile(
    backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
    collapsedBackgroundColor: Theme.of(context).colorScheme.surfaceContainer,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadii.sm),
      side: BorderSide(color: Theme.of(context).colorScheme.outline),
    ),
    collapsedShape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadii.sm),
      side: BorderSide(color: Theme.of(context).colorScheme.outline),
    ),
    title: Text(order.id == null ? 'Order' : 'Order ${order.id}'),
    subtitle: Text(
      [
        order.status,
        if (order.date != null)
          '${order.date!.year}-${order.date!.month.toString().padLeft(2, '0')}-${order.date!.day.toString().padLeft(2, '0')}',
      ].whereType<String>().join(' · '),
    ),
    children: [
      if (order.lines.isEmpty)
        const ListTile(title: Text('No item details were returned.'))
      else
        for (final line in order.lines)
          ListTile(
            title: Text(
              line.title ??
                  (line.bookId == null ? 'Book' : 'Book ${line.bookId}'),
            ),
            subtitle: line.quantity == null
                ? null
                : Text('Quantity ${line.quantity}'),
            trailing: line.price == null
                ? null
                : Text(line.price!.toStringAsFixed(2)),
          ),
      if (order.total != null)
        ListTile(
          title: const Text('Computed item total'),
          trailing: Text(
            order.total!.toStringAsFixed(2),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
    ],
  );
}
