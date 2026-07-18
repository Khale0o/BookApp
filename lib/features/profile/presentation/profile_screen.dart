import 'package:bookapp/app/router/app_router.dart';
import 'package:bookapp/app/theme/app_tokens.dart';
import 'package:bookapp/core/utils/image_url_resolver.dart';
import 'package:bookapp/core/widgets/async_message.dart';
import 'package:bookapp/core/widgets/content_shell.dart';
import 'package:bookapp/features/auth/presentation/auth_controller.dart';
import 'package:bookapp/features/auth/presentation/auth_screens.dart';
import 'package:bookapp/features/profile/domain/account_models.dart';
import 'package:bookapp/features/profile/presentation/account_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    backgroundColor: AppColors.midnight,
    body: SafeArea(
      bottom: false,
      child: RequireAuth(
        child: _AuthenticatedProfile(
          state: ref.watch(accountControllerProvider),
        ),
      ),
    ),
  );
}

class _AuthenticatedProfile extends ConsumerWidget {
  const _AuthenticatedProfile({required this.state});
  final AccountState state;

  Future<void> _pickImage(BuildContext context, WidgetRef ref) async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null || !context.mounted) return;
    final extension = file.name.split('.').last.toLowerCase();
    if (!const {'jpg', 'jpeg', 'png', 'webp'}.contains(extension)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose a JPG, PNG, or WebP image.')),
      );
      return;
    }
    final bytes = await file.readAsBytes();
    if (bytes.length > 5 * 1024 * 1024) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Choose an image smaller than 5 MB.')),
        );
      }
      return;
    }
    await ref
        .read(accountControllerProvider.notifier)
        .uploadImage(file.name, bytes);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(accountControllerProvider.notifier);
    if (state.isLoading && state.profile == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.errorMessage != null && state.profile == null) {
      return AsyncMessage(
        icon: Icons.person_off_outlined,
        title: 'Account information is unavailable',
        message: state.errorMessage!,
        actionLabel: 'Try again',
        onAction: controller.load,
      );
    }
    final profile = state.profile;
    return RefreshIndicator(
      onRefresh: controller.load,
      child: ListView(
        key: const PageStorageKey('profile-scroll'),
        padding: const EdgeInsets.only(bottom: AppSpacing.huge),
        children: [
          ContentShell(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                0,
                AppSpacing.xl,
                0,
                AppSpacing.lg,
              ),
              child: Text(
                'Profile',
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
          ),
          ContentShell(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    _ProfileImage(profile: profile),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile?.displayName ?? 'Leaf & Loom reader',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          if (profile?.email != null) ...[
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              profile!.email!,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Change profile image',
                      onPressed: state.isMutating
                          ? null
                          : () => _pickImage(context, ref),
                      icon: const Icon(Icons.photo_camera_outlined),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (state.uploadProgress != null)
            ContentShell(
              child: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: LinearProgressIndicator(value: state.uploadProgress),
              ),
            ),
          const SizedBox(height: AppSpacing.xl),
          ContentShell(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                _ProfileRow(
                  icon: Icons.receipt_long_outlined,
                  title: 'Order history',
                  onTap: () => context.push(AppRoutes.orders),
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Addresses',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: state.isMutating
                          ? null
                          : () => _showAddressEditor(context, ref, null),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                if (state.addresses.isEmpty)
                  Text(
                    'No addresses were returned for this account.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  )
                else
                  for (final address in state.addresses)
                    _ProfileRow(
                      icon: Icons.location_on_outlined,
                      title: address.oneLine.isEmpty
                          ? 'Address details unavailable'
                          : address.oneLine,
                      onTap: address.id == null
                          ? null
                          : () => _showAddressEditor(context, ref, address),
                    ),
                if (state.errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    state.errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                OutlinedButton.icon(
                  onPressed: () async {
                    await ref.read(authControllerProvider.notifier).logout();
                    if (context.mounted) context.go(AppRoutes.home);
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Sign out'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileImage extends StatelessWidget {
  const _ProfileImage({required this.profile});
  final UserProfile? profile;

  @override
  Widget build(BuildContext context) {
    final url = resolveBookImageUrl(profile?.imageUrl);
    final initials = [profile?.firstName, profile?.lastName]
        .whereType<String>()
        .where((value) => value.isNotEmpty)
        .map((value) => value[0].toUpperCase())
        .take(2)
        .join();
    final fallback = CircleAvatar(
      radius: 34,
      backgroundColor: AppColors.slate,
      child: Text(initials.isEmpty ? 'L&L' : initials),
    );
    if (url == null) return fallback;
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: url,
        width: 68,
        height: 68,
        fit: BoxFit.cover,
        placeholder: (_, _) => fallback,
        errorWidget: (_, _, _) => fallback,
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.icon, required this.title, this.onTap});
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
    child: ListTile(
      tileColor: Theme.of(context).colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.sm),
        side: BorderSide(color: Theme.of(context).colorScheme.outline),
      ),
      leading: Icon(icon),
      title: Text(title, maxLines: 3, overflow: TextOverflow.ellipsis),
      trailing: onTap == null ? null : const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    ),
  );
}

Future<void> _showAddressEditor(
  BuildContext context,
  WidgetRef ref,
  UserAddress? address,
) async {
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.midnightElevated,
    builder: (context) => _AddressEditor(address: address),
  );
  if (saved == true) ref.read(accountControllerProvider.notifier).load();
}

class _AddressEditor extends ConsumerStatefulWidget {
  const _AddressEditor({this.address});
  final UserAddress? address;

  @override
  ConsumerState<_AddressEditor> createState() => _AddressEditorState();
}

class _AddressEditorState extends ConsumerState<_AddressEditor> {
  final _formKey = GlobalKey<FormState>();
  late final List<TextEditingController> _fields;

  @override
  void initState() {
    super.initState();
    final address = widget.address;
    _fields = [
      address?.addressLine1,
      address?.addressLine2,
      address?.city,
      address?.postalCode,
      address?.country,
    ].map((value) => TextEditingController(text: value)).toList();
  }

  @override
  void dispose() {
    for (final field in _fields) {
      field.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    String? value(int index) {
      final text = _fields[index].text.trim();
      return text.isEmpty ? null : text;
    }

    final saved = await ref
        .read(accountControllerProvider.notifier)
        .saveAddress(
          UserAddress(
            id: widget.address?.id,
            addressLine1: value(0),
            addressLine2: value(1),
            city: value(2),
            postalCode: value(3),
            country: value(4),
          ),
        );
    if (saved && mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final busy = ref.watch(accountControllerProvider).isMutating;
    const labels = [
      'Address line 1',
      'Address line 2',
      'City',
      'Postal code',
      'Country',
    ];
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.address == null ? 'Add address' : 'Edit address',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.lg),
                for (var index = 0; index < _fields.length; index++) ...[
                  TextFormField(
                    controller: _fields[index],
                    validator: index == 0
                        ? (value) => value?.trim().isEmpty ?? true
                              ? 'Enter the first address line.'
                              : null
                        : null,
                    decoration: InputDecoration(labelText: labels[index]),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: busy ? null : _save,
                    child: Text(busy ? 'Saving…' : 'Save address'),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'The API does not provide address deletion, so this form supports add and edit only.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
