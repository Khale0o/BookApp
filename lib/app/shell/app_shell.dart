import 'package:bookapp/app/theme/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  static const _destinations = <_ShellDestination>[
    _ShellDestination('Home', Icons.home_outlined, Icons.home_rounded),
    _ShellDestination('Explore', Icons.explore_outlined, Icons.explore_rounded),
    _ShellDestination(
      'Cart',
      Icons.shopping_bag_outlined,
      Icons.shopping_bag_rounded,
    ),
    _ShellDestination('Profile', Icons.person_outline, Icons.person_rounded),
  ];

  void _select(int index) => navigationShell.goBranch(
    index,
    initialLocation: index == navigationShell.currentIndex,
  );

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= AppLayout.tablet;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemOverlay.immersiveDark,
      child: Scaffold(
        backgroundColor: AppColors.midnight,
        body: wide
            ? Row(
                children: [
                  SafeArea(
                    right: false,
                    child: _EditorialRail(
                      selectedIndex: navigationShell.currentIndex,
                      onSelected: _select,
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(child: navigationShell),
                ],
              )
            : navigationShell,
        bottomNavigationBar: wide
            ? null
            : _EditorialBottomBar(
                selectedIndex: navigationShell.currentIndex,
                onSelected: _select,
              ),
      ),
    );
  }
}

class _EditorialBottomBar extends StatelessWidget {
  const _EditorialBottomBar({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: AppColors.midnightElevated,
      border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
    ),
    child: SafeArea(
      top: false,
      child: SizedBox(
        height: 66,
        child: Row(
          children: [
            for (var index = 0; index < AppShell._destinations.length; index++)
              Expanded(
                child: _DestinationButton(
                  destination: AppShell._destinations[index],
                  selected: selectedIndex == index,
                  onTap: () => onSelected(index),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

class _EditorialRail extends StatelessWidget {
  const _EditorialRail({required this.selectedIndex, required this.onSelected});

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => Container(
    width: 92,
    color: AppColors.midnightElevated,
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
    child: Column(
      children: [
        Text(
          'L&L',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const Spacer(),
        for (var index = 0; index < AppShell._destinations.length; index++)
          SizedBox(
            height: 68,
            child: _DestinationButton(
              destination: AppShell._destinations[index],
              selected: selectedIndex == index,
              onTap: () => onSelected(index),
            ),
          ),
        const Spacer(),
      ],
    ),
  );
}

class _DestinationButton extends StatelessWidget {
  const _DestinationButton({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final _ShellDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurfaceVariant;
    final reduced = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      selected: selected,
      button: true,
      label: destination.label,
      child: InkResponse(
        onTap: onTap,
        radius: 30,
        child: AnimatedScale(
          duration: reduced ? Duration.zero : AppMotion.quick,
          scale: selected && !reduced ? 1.04 : 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selected ? destination.selectedIcon : destination.icon,
                color: color,
                size: 21,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                destination.label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  letterSpacing: .15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShellDestination {
  const _ShellDestination(this.label, this.icon, this.selectedIcon);
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
