import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/profile_service.dart';
import '../utils/theme.dart';
import '../utils/chip_emojis.dart';

/// Felder, die beim Speichern automatisch kapitalisiert werden.
const _kCapitalizeFields = {'tribe', 'city', 'job', 'display_name'};

// Speichert ein Feld und refresht das Profil
BuildContext? _parentContext;

Future<void> _saveAndRefresh(BuildContext context, String field, dynamic value) async {
  final userId = Supabase.instance.client.auth.currentUser!.id;
  await Supabase.instance.client.from('profiles').update({field: value}).eq('id', userId);
  // Refresh nach einem Frame (verhindert setState during build)
  final ctx = _parentContext ?? context;
  if (ctx.mounted) {
    Future.microtask(() {
      if (ctx.mounted) ctx.read<ProfileService>().fetchProfile();
    });
  }
}

/// Exportierte Version für externe Nutzung
Future<void> saveAndRefreshProfile(BuildContext context, String field, dynamic value) async {
  await _saveAndRefresh(context, field, value);
}

/// Shows a bottom sheet to edit a single text field
Future<void> showTextEditSheet(
  BuildContext context, {
  required String title,
  required String field,
  String? currentValue,
  String hint = '',
  int maxLines = 1,
  int maxLength = 100,
}) async {
  _parentContext = context;
  final controller = TextEditingController(text: currentValue);

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            maxLines: maxLines,
            maxLength: maxLength,
            autofocus: true,
            decoration: InputDecoration(hintText: hint),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final raw = controller.text.trim();
                final normalized = _kCapitalizeFields.contains(field) ? capitalizeWords(raw) : raw;
                final value = normalized.isNotEmpty ? normalized : null;
                await _saveAndRefresh(ctx, field, value);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Speichern'),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Shows a bottom sheet to select from dropdown options
Future<void> showDropdownEditSheet(
  BuildContext context, {
  required String title,
  required String field,
  required List<MapEntry<String, String>> options,
  String? currentValue,
}) async {
  _parentContext = context;
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
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...options.map((opt) => ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(opt.value),
            trailing: currentValue == opt.key
                ? Icon(Icons.check_circle, color: HevjinTheme.secondary)
                : null,
            onTap: () async {
              await _saveAndRefresh(ctx, field, opt.key);
              if (ctx.mounted) Navigator.pop(ctx);
            },
          )),
        ],
      ),
    ),
  );
}

/// Shows a bottom sheet to edit chips (multi-select from list)
Future<void> showChipsEditSheet(
  BuildContext context, {
  required String title,
  required String field,
  required List<String> availableOptions,
  required List<String> currentSelection,
  int maxSelection = 5,
}) async {
  _parentContext = context;
  List<String> selected = List.from(currentSelection);

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheetState) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Wähle bis zu $maxSelection (${selected.length}/$maxSelection)', style: TextStyle(fontSize: 13, color: HevjinTheme.textSecondary)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: availableOptions.map((opt) {
                final isSelected = selected.contains(opt);
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      setSheetState(() {
                        if (isSelected) {
                          selected.remove(opt);
                        } else if (selected.length < maxSelection) {
                          selected.add(opt);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: isSelected ? HevjinTheme.secondary.withOpacity(0.12) : const Color(0xFFF5F5F5),
                        border: Border.all(color: isSelected ? HevjinTheme.secondary : Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSelected) ...[
                            Icon(Icons.check, size: 14, color: HevjinTheme.secondary),
                            const SizedBox(width: 4),
                          ],
                          Text(opt, style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: isSelected ? HevjinTheme.secondary : HevjinTheme.textPrimary,
                          )),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await _saveAndRefresh(ctx, field, selected);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Speichern'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Shows a bottom sheet for number input (height slider)
Future<void> showSliderEditSheet(
  BuildContext context, {
  required String title,
  required String field,
  required int currentValue,
  int min = 140,
  int max = 220,
  String unit = 'cm',
}) async {
  _parentContext = context;
  int value = currentValue;

  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheetState) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Text('$value $unit', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            Slider(
              value: value.toDouble(),
              min: min.toDouble(),
              max: max.toDouble(),
              divisions: max - min,
              activeColor: HevjinTheme.secondary,
              onChanged: (v) => setSheetState(() => value = v.round()),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await _saveAndRefresh(ctx, field, value);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Speichern'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Shows a bottom sheet for boolean selection
Future<void> showBoolEditSheet(
  BuildContext context, {
  required String title,
  required String field,
  bool? currentValue,
  String trueLabel = 'Ja',
  String falseLabel = 'Nein',
}) async {
  _parentContext = context;
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
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(trueLabel),
            trailing: currentValue == true ? Icon(Icons.check_circle, color: HevjinTheme.secondary) : null,
            onTap: () async {
              await _saveAndRefresh(ctx, field, true);
              if (ctx.mounted) Navigator.pop(ctx);
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(falseLabel),
            trailing: currentValue == false ? Icon(Icons.check_circle, color: HevjinTheme.secondary) : null,
            onTap: () async {
              await _saveAndRefresh(ctx, field, false);
              if (ctx.mounted) Navigator.pop(ctx);
            },
          ),
        ],
      ),
    ),
  );
}

