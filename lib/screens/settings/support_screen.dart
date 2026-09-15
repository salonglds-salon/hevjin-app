import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/theme.dart';
import '../../l10n/app_localizations.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _messageController = TextEditingController();
  String _category = 'Allgemein';
  bool _isSending = false;
  bool _sent = false;

  final List<String> _categories = [
    'Allgemein',
    'Technisches Problem',
    'Nutzer melden',
    'Profil / Fotos',
    'Match / Chat Problem',
    'Account loeschen',
    'Verbesserungsvorschlag',
    'Sonstiges',
  ];

  String _catLabel(BuildContext context, String c) {
    final l = AppLocalizations.of(context)!;
    switch (c) {
      case 'Allgemein': return l.supCatGeneral;
      case 'Technisches Problem': return l.supCatTechnical;
      case 'Nutzer melden': return l.supCatReportUser;
      case 'Profil / Fotos': return l.supCatProfilePhotos;
      case 'Match / Chat Problem': return l.supCatMatchChat;
      case 'Account loeschen': return l.supCatDeleteAccount;
      case 'Verbesserungsvorschlag': return l.supCatSuggestion;
      case 'Sonstiges': return l.supCatOther;
      default: return c;
    }
  }

  Future<void> _sendReport() async {
    if (_messageController.text.trim().isEmpty) return;

    setState(() => _isSending = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      await Supabase.instance.client.from('support_tickets').insert({
        'user_id': user?.id,
        'user_email': user?.email ?? user?.phone ?? 'unbekannt',
        'category': _category,
        'message': _messageController.text.trim(),
        'status': 'offen',
      });

      setState(() {
        _sent = true;
        _isSending = false;
      });
    } catch (e) {
      setState(() => _isSending = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorWithMsg(e.toString())), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HevjinTheme.background,
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.supTitle)),
      body: _sent ? _successView() : _formView(),
    );
  }

  Widget _successView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: HevjinTheme.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: HevjinTheme.success, size: 48),
            ),
            const SizedBox(height: 24),
            Text(AppLocalizations.of(context)!.supSentTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.supSentBody,
              textAlign: TextAlign.center,
              style: const TextStyle(color: HevjinTheme.textSecondary, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: HevjinTheme.secondary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              child: Text(AppLocalizations.of(context)!.back, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _formView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: HevjinTheme.secondary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(Icons.support_agent, size: 40, color: HevjinTheme.secondary),
                const SizedBox(height: 12),
                Text(AppLocalizations.of(context)!.supHeadline, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(AppLocalizations.of(context)!.supReplyTime, style: const TextStyle(color: HevjinTheme.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Kategorie
          Text(AppLocalizations.of(context)!.supCategory, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _category,
                isExpanded: true,
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(_catLabel(context, c)))).toList(),
                onChanged: (val) => setState(() => _category = val!),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Nachricht
          Text(AppLocalizations.of(context)!.supMessage, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: _messageController,
            maxLines: 6,
            maxLength: 1000,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.supHint,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Senden
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSending ? null : _sendReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: HevjinTheme.secondary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              child: _isSending
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(AppLocalizations.of(context)!.supSend, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 24),

          // Direkter Kontakt
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context)!.supDirectContact, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Icon(Icons.email_outlined, size: 16, color: HevjinTheme.textSecondary),
                    SizedBox(width: 8),
                    Text('hevjinsupport@gmail.com', style: TextStyle(color: HevjinTheme.textSecondary, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
