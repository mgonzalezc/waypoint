import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../design_system/theming/waypoint_spacing.dart';

class LinkRow extends StatelessWidget {
  const LinkRow({required this.label, required this.url, this.onOpen, super.key});

  final String label;
  final String url;
  final VoidCallback? onOpen;

  Future<void> _open(BuildContext context) async {
    onOpen?.call();
    final launched = await launchUrl(Uri.parse(url));
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.detailSourceLaunchFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => _open(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: WaypointSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: Text(label, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface)),
            ),
            Icon(Icons.arrow_forward, size: WaypointSpacing.iconSm, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }
}
