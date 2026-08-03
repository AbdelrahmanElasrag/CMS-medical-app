import 'package:flutter/material.dart';

import 'package:cms/services/wellness_service.dart';
import 'package:cms/theme/app_tokens.dart';
import 'package:cms/ui/mobadra_ui.dart';

const Map<int, String> _weekdayLabels = {
  DateTime.monday: 'Monday',
  DateTime.tuesday: 'Tuesday',
  DateTime.wednesday: 'Wednesday',
  DateTime.thursday: 'Thursday',
  DateTime.friday: 'Friday',
  DateTime.saturday: 'Saturday',
  DateTime.sunday: 'Sunday',
};

class WellnessScreen extends StatefulWidget {
  const WellnessScreen({super.key});

  @override
  State<WellnessScreen> createState() => _WellnessScreenState();
}

class _WellnessScreenState extends State<WellnessScreen> {
  int _water = 0;
  int _waterGoal = 8;
  int _workout = 0;
  int _workoutGoal = 30;
  List<MedReminder> _meds = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final w = await WellnessService.instance.todayWaterGlasses();
    final wg = await WellnessService.instance.getWaterGoal();
    final wo = await WellnessService.instance.todayWorkoutMinutes();
    final wog = await WellnessService.instance.getWorkoutGoal();
    final m = await WellnessService.instance.loadMeds();
    if (mounted) {
      setState(() {
        _water = w;
        _waterGoal = wg;
        _workout = wo;
        _workoutGoal = wog;
        _meds = m;
        _loading = false;
      });
    }
  }

  Future<void> _addMedDialog() async {
    final nameCtrl = TextEditingController();
    var time = TimeOfDay.now();
    int? weekday;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setLocal) => ShadDialog(
          title: Row(
            children: [
              Icon(Icons.medication_liquid_rounded, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 10),
              const Text('Add reminder'),
            ],
          ),
          actions: [
            ShadButton.outline(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ShadButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;
                final med = MedReminder(
                  id: DateTime.now().microsecondsSinceEpoch.toString(),
                  name: nameCtrl.text.trim(),
                  hour: time.hour,
                  minute: time.minute,
                  weekday: weekday,
                );
                await WellnessService.instance.addMed(med);
                if (context.mounted) Navigator.pop(context);
                await _reload();
              },
              child: const Text('Save'),
            ),
          ],
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Medicine name',
                    prefixIcon: const Icon(Icons.label_outline_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.md)),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.md)),
                  tileColor: AppColors.primaryContainer.withValues(alpha: 0.5),
                  leading: const Icon(Icons.schedule_rounded, color: AppColors.primary),
                  title: const Text('Time'),
                  subtitle: Text(time.format(context), style: const TextStyle(fontWeight: FontWeight.w700)),
                  onTap: () async {
                    final picked = await showTimePicker(context: context, initialTime: time);
                    if (picked != null) setLocal(() => time = picked);
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<int?>(
                  value: weekday,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Day',
                    prefixIcon: const Icon(Icons.calendar_today_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.md)),
                  ),
                  items: [
                    const DropdownMenuItem<int?>(value: null, child: Text('Every day')),
                    ..._weekdayLabels.entries.map(
                      (e) => DropdownMenuItem<int?>(value: e.key, child: Text(e.value)),
                    ),
                  ],
                  onChanged: (v) => setLocal(() => weekday = v),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: AppColors.neutralSurface,
      appBar: MobadraAppBar(
        title: const Row(
          children: [
            Icon(Icons.spa_rounded, size: 26),
            SizedBox(width: 10),
            Text('Wellness'),
          ],
        ),
      ),
      body: _loading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.secondary, strokeWidth: 3),
                  const SizedBox(height: 16),
                  Text('Loading your habits…', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, 16, AppSpacing.md, 32),
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.tertiary.withValues(alpha: 0.22),
                        AppColors.primary.withValues(alpha: 0.12),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    border: Border.all(color: AppColors.tertiary.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: AppColors.tertiary, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'For your convenience only — not a medical device.',
                          style: TextStyle(color: Colors.grey.shade800, fontSize: 13, height: 1.35, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _MedicineRemindersSection(
                  meds: _meds,
                  onAddReminder: _addMedDialog,
                  onDeleteReminder: (id) async {
                    await WellnessService.instance.removeMed(id);
                    await _reload();
                  },
                ),
                const SizedBox(height: 16),
                _WellnessHeroCard(
                  title: 'Hydration',
                  subtitle: 'Water today',
                  iconAsset: 'assets/water.gif',
                  gradientColors: const [Color(0xFFE0F2FE), Color(0xFFBAE6FD)],
                  borderAccent: const Color(0xFF0284C7),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: _waterGoal > 0 ? (_water / _waterGoal).clamp(0, 1) : 0,
                          minHeight: 12,
                          backgroundColor: Colors.white.withValues(alpha: 0.7),
                          color: const Color(0xFF0284C7),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            '$_water',
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0369A1)),
                          ),
                          Text(
                            ' / $_waterGoal glasses',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF0284C7),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            onPressed: () async {
                              await WellnessService.instance.addWaterGlass();
                              await _reload();
                            },
                            icon: const Icon(Icons.add_rounded, size: 20),
                            label: const Text('+1 glass'),
                          ),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF0369A1),
                              side: const BorderSide(color: Color(0xFF7DD3FC)),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                            onPressed: () async {
                              await WellnessService.instance.resetWaterToday();
                              await _reload();
                            },
                            icon: const Icon(Icons.restart_alt_rounded, size: 20),
                            label: const Text('Reset day'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.flag_rounded, size: 18, color: Colors.grey.shade700),
                          const SizedBox(width: 6),
                          Text('Daily goal', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey.shade800)),
                          const SizedBox(width: 8),
                          DropdownButton<int>(
                            value: _waterGoal,
                            underline: const SizedBox.shrink(),
                            items: [6, 8, 10, 12]
                                .map((g) => DropdownMenuItem(value: g, child: Text('$g glasses')))
                                .toList(),
                            onChanged: (v) async {
                              if (v == null) return;
                              await WellnessService.instance.setWaterGoal(v);
                              await _reload();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _WellnessHeroCard(
                  title: 'Movement',
                  subtitle: 'Active minutes',
                  iconAsset: 'assets/running (1).gif',
                  gradientColors: const [Color(0xFFFFEDD5), Color(0xFFFED7AA)],
                  borderAccent: AppColors.tertiary,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: _workoutGoal > 0 ? (_workout / _workoutGoal).clamp(0, 1) : 0,
                          minHeight: 12,
                          backgroundColor: Colors.white.withValues(alpha: 0.75),
                          color: const Color(0xFFEA580C),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            '$_workout',
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFFC2410C)),
                          ),
                          Text(
                            ' / $_workoutGoal min',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text('Quick add', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey.shade800, fontSize: 13)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final add in [5, 10, 15, 30])
                            ActionChip(
                              avatar: Icon(Icons.add_circle_outline_rounded, size: 18, color: cs.primary),
                              label: Text('+$add min', style: const TextStyle(fontWeight: FontWeight.w700)),
                              backgroundColor: Colors.white,
                              side: BorderSide(color: AppColors.tertiary.withValues(alpha: 0.5)),
                              onPressed: () async {
                                await WellnessService.instance.addWorkoutMinutes(add);
                                await _reload();
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.flag_rounded, size: 18, color: Colors.grey.shade700),
                          const SizedBox(width: 6),
                          Text('Daily goal', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey.shade800)),
                          const SizedBox(width: 8),
                          DropdownButton<int>(
                            value: _workoutGoal,
                            underline: const SizedBox.shrink(),
                            items: [15, 30, 45, 60]
                                .map((g) => DropdownMenuItem(value: g, child: Text('$g min')))
                                .toList(),
                            onChanged: (v) async {
                              if (v == null) return;
                              await WellnessService.instance.setWorkoutGoal(v);
                              await _reload();
                            },
                          ),
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

class _WellnessHeroCard extends StatelessWidget {
  const _WellnessHeroCard({
    required this.title,
    required this.subtitle,
    required this.iconAsset,
    required this.gradientColors,
    required this.borderAccent,
    required this.child,
  });

  final String title;
  final String subtitle;
  final String iconAsset;
  final List<Color> gradientColors;
  final Color borderAccent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        border: Border.all(color: borderAccent.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: borderAccent.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: borderAccent.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Image.asset(iconAsset, fit: BoxFit.contain),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: Colors.grey.shade900,
                              letterSpacing: -0.3,
                            ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _MedicineRemindersSection extends StatelessWidget {
  const _MedicineRemindersSection({
    required this.meds,
    required this.onAddReminder,
    required this.onDeleteReminder,
  });

  final List<MedReminder> meds;
  final VoidCallback onAddReminder;
  final Future<void> Function(String id) onDeleteReminder;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'Medicine reminders',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Colors.grey.shade900,
                        letterSpacing: -0.3,
                      ),
                ),
              ],
            ),
            IconButton.filled(
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: onAddReminder,
              icon: const Icon(Icons.add_rounded),
              tooltip: 'Add reminder',
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (meds.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
              boxShadow: [
                BoxShadow(color: AppColors.primary.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              children: [
                SizedBox(
                  width: 52,
                  height: 52,
                  child: Image.asset('assets/bell (1).gif', fit: BoxFit.contain),
                ),
                const SizedBox(height: 12),
                Text(
                  'No reminders yet',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.grey.shade800),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tap + to get daily notifications for your medicines.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.35),
                ),
              ],
            ),
          )
        else
          ...meds.map(
            (m) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                    border: Border.all(color: AppColors.secondary.withValues(alpha: 0.25)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondary.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primaryContainer,
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: Image.asset('assets/bell (1).gif', fit: BoxFit.contain),
                      ),
                    ),
                    title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    subtitle: Row(
                      children: [
                        Icon(Icons.repeat_rounded, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          _reminderScheduleLabel(m),
                          style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400),
                      onPressed: () async {
                        await onDeleteReminder(m.id);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _reminderScheduleLabel(MedReminder m) {
    final time = '${m.hour.toString().padLeft(2, '0')}:${m.minute.toString().padLeft(2, '0')}';
    final day = _weekdayLabels[m.weekday];
    if (day == null) return '$time · daily';
    return '$time · $day';
  }
}
