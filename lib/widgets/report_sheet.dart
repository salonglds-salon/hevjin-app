import 'package:flutter/material.dart';
import '../services/report_service.dart';
import '../utils/theme.dart';

/// Shows Block & Report options for a user profile
Future<void> showReportSheet(BuildContext context, {
  required String userId,
  required String userName,
}) async {
  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          Text('$userName', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Was möchtest du tun?', style: TextStyle(color: HevjinTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 20),

          // Block
          _ActionTile(
            icon: Icons.block,
            color: HevjinTheme.error,
            title: 'Blockieren',
            subtitle: '$userName kann dich nicht mehr sehen oder kontaktieren',
            onTap: () async {
              Navigator.pop(ctx);
              final confirmed = await _showConfirmDialog(context,
                title: '$userName blockieren?',
                message: 'Diese Person kann dich nicht mehr finden, dir keine Nachrichten senden und sieht dein Profil nicht mehr.',
                confirmText: 'Blockieren',
              );
              if (confirmed == true) {
                final success = await ReportService().blockUser(userId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? '$userName wurde blockiert' : 'Fehler beim Blockieren'),
                      backgroundColor: success ? HevjinTheme.success : HevjinTheme.error,
                    ),
                  );
                }
              }
            },
          ),
          const SizedBox(height: 8),

          // Report
          _ActionTile(
            icon: Icons.flag_outlined,
            color: Colors.orange,
            title: 'Melden',
            subtitle: 'Unangemessenes Verhalten oder Fake-Profil melden',
            onTap: () {
              Navigator.pop(ctx);
              _showReportReasonSheet(context, userId: userId, userName: userName);
            },
          ),
          const SizedBox(height: 8),

          // Unmatch
          _ActionTile(
            icon: Icons.heart_broken_outlined,
            color: HevjinTheme.textSecondary,
            title: 'Match auflösen',
            subtitle: 'Entfernt das Match und den Chat',
            onTap: () {
              Navigator.pop(ctx);
              // TODO: Unmatch implementieren
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Match aufgelöst')),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );
}

/// Report reason selection
void _showReportReasonSheet(BuildContext context, {required String userId, required String userName}) {
  final reasons = [
    'Fake-Profil / Catfishing',
    'Unangemessene Inhalte',
    'Belästigung / Bedrohung',
    'Spam / Werbung',
    'Minderjährig',
    'Betrug / Geldanfragen',
    'Andere Gründe',
  ];

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) {
      final detailsController = TextEditingController();
      String? selectedReason;

      return StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              const Text('Grund der Meldung', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Warum möchtest du $userName melden?', style: TextStyle(color: HevjinTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 16),

              ...reasons.map((reason) => RadioListTile<String>(
                contentPadding: EdgeInsets.zero,
                title: Text(reason, style: const TextStyle(fontSize: 14)),
                value: reason,
                groupValue: selectedReason,
                activeColor: HevjinTheme.secondary,
                onChanged: (v) => setSheetState(() => selectedReason = v),
              )),

              const SizedBox(height: 12),
              TextField(
                controller: detailsController,
                maxLines: 3,
                maxLength: 500,
                decoration: const InputDecoration(hintText: 'Weitere Details (optional)...'),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedReason == null ? null : () async {
                    final success = await ReportService().reportUser(
                      userId, selectedReason!,
                      details: detailsController.text.trim().isNotEmpty ? detailsController.text.trim() : null,
                    );
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success ? 'Meldung gesendet. Danke!' : 'Fehler beim Senden'),
                          backgroundColor: success ? HevjinTheme.success : HevjinTheme.error,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: const Text('Meldung absenden'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<bool?> _showConfirmDialog(BuildContext context, {
  required String title,
  required String message,
  required String confirmText,
}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Abbrechen'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: ElevatedButton.styleFrom(backgroundColor: HevjinTheme.error),
          child: Text(confirmText),
        ),
      ],
    ),
  );
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: color.withOpacity(0.05),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: color, fontSize: 14)),
                  Text(subtitle, style: TextStyle(fontSize: 11, color: HevjinTheme.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: color.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }
}
