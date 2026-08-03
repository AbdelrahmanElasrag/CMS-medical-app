import 'package:flutter/material.dart';

import 'package:cms/theme/app_tokens.dart';

/// Full offer detail (shared by [OffersScreen] and home carousel).
void showOfferDetailSheet(BuildContext context, Map<String, dynamic> o) {
  final cs = Theme.of(context).colorScheme;
  final title = o['title']?.toString() ?? 'Offer';
  final subtitle = o['subtitle']?.toString();
  final body = o['body']?.toString();
  final hospital = o['hospital'] is Map ? (o['hospital'] as Map)['name']?.toString() : null;

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
    ),
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.92,
      builder: (_, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.all(20),
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          if (hospital != null) ...[
            const SizedBox(height: 8),
            Text(hospital, style: TextStyle(color: cs.secondary, fontWeight: FontWeight.w600)),
          ],
          if (subtitle != null && subtitle.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(subtitle),
          ],
          if (body != null && body.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(body),
          ],
        ],
      ),
    ),
  );
}
