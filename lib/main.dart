import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

const bool kScreenshotMode = bool.fromEnvironment('SCREENSHOT_MODE');

const String kAppName = 'AULARD SPENCER MARTINE MARIE-T';
const String kDeveloperName = 'AULARD SPENCER MARTINE MARIE-THERESE';
const String kSupportEmail = 'contact@aulard-operations.com';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = OperationsStore(screenshotMode: kScreenshotMode);
  await store.load();
  runApp(AulardOpsApp(store: store));
}

class AppColors {
  static const Color ink = Color(0xFF031B1F);
  static const Color panel = Color(0xFF082A31);
  static const Color panelSoft = Color(0xFF103A42);
  static const Color teal = Color(0xFF19D1C4);
  static const Color mint = Color(0xFF7ED9A8);
  static const Color green = Color(0xFF69D17F);
  static const Color violet = Color(0xFF8360E8);
  static const Color magenta = Color(0xFFD64AD3);
  static const Color warning = Color(0xFFF2B84B);
  static const Color danger = Color(0xFFFF5C7A);
  static const Color text = Color(0xFFE8F3F1);
}

class AulardOpsApp extends StatelessWidget {
  const AulardOpsApp({super.key, required this.store});

  final OperationsStore store;

  @override
  Widget build(BuildContext context) {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: AppColors.teal,
      brightness: Brightness.dark,
    );

    return MaterialApp(
      title: kAppName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: baseScheme.copyWith(
          primary: AppColors.teal,
          onPrimary: AppColors.ink,
          secondary: AppColors.mint,
          tertiary: AppColors.violet,
          surface: AppColors.ink,
          surfaceContainer: AppColors.panel,
          surfaceContainerHighest: AppColors.panelSoft,
          error: AppColors.danger,
          onSurface: AppColors.text,
        ),
        scaffoldBackgroundColor: AppColors.ink,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.ink,
          foregroundColor: AppColors.text,
          centerTitle: false,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        cardTheme: CardThemeData(
          color: AppColors.panel,
          margin: EdgeInsets.zero,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color(0xFF164E55)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF0C3037),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      home: OperationsShell(store: store),
    );
  }
}

enum ModuleType { visitor, quality, incident, appointment }

extension ModuleTypeInfo on ModuleType {
  String get label {
    switch (this) {
      case ModuleType.visitor:
        return 'Visitors';
      case ModuleType.quality:
        return 'Quality';
      case ModuleType.incident:
        return 'Incidents';
      case ModuleType.appointment:
        return 'Bookings';
    }
  }

  String get screenTitle {
    switch (this) {
      case ModuleType.visitor:
        return 'Visitor desk';
      case ModuleType.quality:
        return 'Quality control';
      case ModuleType.incident:
        return 'Incident board';
      case ModuleType.appointment:
        return 'Appointment book';
    }
  }

  String get actionLabel {
    switch (this) {
      case ModuleType.visitor:
        return 'Add visitor';
      case ModuleType.quality:
        return 'Add check';
      case ModuleType.incident:
        return 'Report incident';
      case ModuleType.appointment:
        return 'Book appointment';
    }
  }

  String get emptyLabel {
    switch (this) {
      case ModuleType.visitor:
        return 'No active visitor records yet.';
      case ModuleType.quality:
        return 'No quality checks have been logged.';
      case ModuleType.incident:
        return 'No incident reports are open.';
      case ModuleType.appointment:
        return 'No appointments are scheduled.';
    }
  }

  IconData get icon {
    switch (this) {
      case ModuleType.visitor:
        return Icons.badge_outlined;
      case ModuleType.quality:
        return Icons.verified_user_outlined;
      case ModuleType.incident:
        return Icons.report_gmailerrorred_outlined;
      case ModuleType.appointment:
        return Icons.event_available_outlined;
    }
  }

  Color get accent {
    switch (this) {
      case ModuleType.visitor:
        return AppColors.teal;
      case ModuleType.quality:
        return AppColors.green;
      case ModuleType.incident:
        return AppColors.magenta;
      case ModuleType.appointment:
        return AppColors.violet;
    }
  }

  List<String> get statuses {
    switch (this) {
      case ModuleType.visitor:
        return const ['Checked in', 'Cleared', 'Needs host'];
      case ModuleType.quality:
        return const ['Ready', 'In review', 'Action needed'];
      case ModuleType.incident:
        return const ['Open', 'Investigating', 'Resolved'];
      case ModuleType.appointment:
        return const ['Scheduled', 'Arrived', 'Completed'];
    }
  }

  List<String> get priorities {
    switch (this) {
      case ModuleType.visitor:
        return const ['Normal', 'VIP', 'Vendor'];
      case ModuleType.quality:
        return const ['Low risk', 'Monitor', 'Critical'];
      case ModuleType.incident:
        return const ['Low', 'Medium', 'High'];
      case ModuleType.appointment:
        return const ['Standard', 'Priority', 'Executive'];
    }
  }
}

class OpsRecord {
  const OpsRecord({
    required this.id,
    required this.module,
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.status,
    required this.priority,
    required this.dueLabel,
    required this.createdAt,
  });

  final String id;
  final ModuleType module;
  final String title;
  final String subtitle;
  final String detail;
  final String status;
  final String priority;
  final String dueLabel;
  final DateTime createdAt;

  OpsRecord copyWith({String? status}) {
    return OpsRecord(
      id: id,
      module: module,
      title: title,
      subtitle: subtitle,
      detail: detail,
      status: status ?? this.status,
      priority: priority,
      dueLabel: dueLabel,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'module': module.name,
      'title': title,
      'subtitle': subtitle,
      'detail': detail,
      'status': status,
      'priority': priority,
      'dueLabel': dueLabel,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory OpsRecord.fromJson(Map<String, dynamic> json) {
    return OpsRecord(
      id: json['id'] as String,
      module: ModuleType.values.byName(json['module'] as String),
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      detail: json['detail'] as String,
      status: json['status'] as String,
      priority: json['priority'] as String,
      dueLabel: json['dueLabel'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class OperationsStore extends ChangeNotifier {
  OperationsStore({
    required this.screenshotMode,
    List<OpsRecord>? initialRecords,
  }) : _records = List<OpsRecord>.from(initialRecords ?? const []);

  OperationsStore.memory([List<OpsRecord>? initialRecords])
    : screenshotMode = true,
      _records = List<OpsRecord>.from(initialRecords ?? seedRecords());

  static const String _storageKey = 'aulard_operations_records_v1';

  final bool screenshotMode;
  List<OpsRecord> _records;

  List<OpsRecord> get records {
    final sorted = List<OpsRecord>.from(_records)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(sorted);
  }

  Future<void> load() async {
    if (_records.isNotEmpty) {
      return;
    }

    if (screenshotMode) {
      _records = seedRecords();
      notifyListeners();
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      _records = seedRecords();
      notifyListeners();
      return;
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    _records = decoded
        .map((item) => OpsRecord.fromJson(item as Map<String, dynamic>))
        .toList();
    notifyListeners();
  }

  OpsRecord? find(String id) {
    for (final record in _records) {
      if (record.id == id) {
        return record;
      }
    }
    return null;
  }

  List<OpsRecord> recordsFor(ModuleType module) {
    return records.where((record) => record.module == module).toList();
  }

  int count(ModuleType module) {
    return _records.where((record) => record.module == module).length;
  }

  int countStatus(String status) {
    return _records.where((record) => record.status == status).length;
  }

  Future<void> addRecord(OpsRecord record) async {
    _records = [record, ..._records];
    notifyListeners();
    await _persist();
  }

  Future<void> updateStatus(String id, String status) async {
    _records = [
      for (final record in _records)
        if (record.id == id) record.copyWith(status: status) else record,
    ];
    notifyListeners();
    await _persist();
  }

  Future<void> delete(String id) async {
    _records = _records.where((record) => record.id != id).toList();
    notifyListeners();
    await _persist();
  }

  Future<void> resetLocalRecords() async {
    _records = seedRecords();
    notifyListeners();
    if (screenshotMode) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  Future<void> _persist() async {
    if (screenshotMode) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      _records.map((record) => record.toJson()).toList(),
    );
    await prefs.setString(_storageKey, encoded);
  }
}

class OperationsShell extends StatefulWidget {
  const OperationsShell({super.key, required this.store});

  final OperationsStore store;

  @override
  State<OperationsShell> createState() => _OperationsShellState();
}

class _OperationsShellState extends State<OperationsShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        final screens = [
          DashboardScreen(store: widget.store),
          ModuleScreen(store: widget.store, module: ModuleType.visitor),
          ModuleScreen(store: widget.store, module: ModuleType.quality),
          ModuleScreen(store: widget.store, module: ModuleType.incident),
          ModuleScreen(store: widget.store, module: ModuleType.appointment),
        ];

        return Scaffold(
          appBar: AppBar(
            titleSpacing: 16,
            title: const _BrandTitle(),
            actions: [
              IconButton(
                key: const ValueKey('settings-button'),
                tooltip: 'Settings',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SettingsScreen(store: widget.store),
                  ),
                ),
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
          body: IndexedStack(index: _selectedIndex, children: screens),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) =>
                setState(() => _selectedIndex = index),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const [
              NavigationDestination(
                key: ValueKey('nav-home'),
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: 'Today',
              ),
              NavigationDestination(
                key: ValueKey('nav-visitors'),
                icon: Icon(Icons.badge_outlined),
                selectedIcon: Icon(Icons.badge),
                label: 'Visitors',
              ),
              NavigationDestination(
                key: ValueKey('nav-quality'),
                icon: Icon(Icons.verified_user_outlined),
                selectedIcon: Icon(Icons.verified_user),
                label: 'Quality',
              ),
              NavigationDestination(
                key: ValueKey('nav-incidents'),
                icon: Icon(Icons.report_gmailerrorred_outlined),
                selectedIcon: Icon(Icons.report),
                label: 'Incidents',
              ),
              NavigationDestination(
                key: ValueKey('nav-bookings'),
                icon: Icon(Icons.event_available_outlined),
                selectedIcon: Icon(Icons.event_available),
                label: 'Bookings',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BrandTitle extends StatelessWidget {
  const _BrandTitle();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.asset(
            'docs/icon.png',
            width: 36,
            height: 36,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 10),
        const Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'AULARD Operations',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
              Text(
                'Visitor, quality, incidents, bookings',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, color: Color(0xFF9CCAC5)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.store});

  final OperationsStore store;

  @override
  Widget build(BuildContext context) {
    final activeIncidents = store
        .recordsFor(ModuleType.incident)
        .where((record) => record.status != 'Resolved');
    final qualityActions = store
        .recordsFor(ModuleType.quality)
        .where((record) => record.status == 'Action needed');
    final nextBookings = store
        .recordsFor(ModuleType.appointment)
        .take(3)
        .toList();
    final priorityQueue = store.records
        .where(
          (record) =>
              record.priority == 'High' || record.priority == 'Critical',
        )
        .take(3)
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.panel,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF18575B)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Operations hub',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                'Daily site movement, quality follow-up, incident status, and appointment flow are tracked on this device.',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.72),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _MetricTile(
                    label: 'Visitors',
                    value: store.count(ModuleType.visitor).toString(),
                    icon: ModuleType.visitor.icon,
                    color: ModuleType.visitor.accent,
                  ),
                  _MetricTile(
                    label: 'Open incidents',
                    value: activeIncidents.length.toString(),
                    icon: ModuleType.incident.icon,
                    color: ModuleType.incident.accent,
                  ),
                  _MetricTile(
                    label: 'Quality actions',
                    value: qualityActions.length.toString(),
                    icon: ModuleType.quality.icon,
                    color: ModuleType.quality.accent,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _SectionHeader(
          title: 'Priority queue',
          icon: Icons.priority_high_rounded,
        ),
        const SizedBox(height: 10),
        if (priorityQueue.isEmpty)
          const _EmptyPanel(text: 'No high priority operations are waiting.')
        else
          ...priorityQueue.map(
            (record) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _RecordCard(
                record: record,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        RecordDetailPage(store: store, recordId: record.id),
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(height: 8),
        _SectionHeader(
          title: 'Next appointments',
          icon: Icons.event_note_outlined,
        ),
        const SizedBox(height: 10),
        if (nextBookings.isEmpty)
          const _EmptyPanel(text: 'No appointments have been added.')
        else
          ...nextBookings.map(
            (record) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _RecordCard(
                record: record,
                compact: true,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        RecordDetailPage(store: store, recordId: record.id),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF0B3036),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.45)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 10),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF9CCAC5), fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ModuleScreen extends StatelessWidget {
  const ModuleScreen({super.key, required this.store, required this.module});

  final OperationsStore store;
  final ModuleType module;

  @override
  Widget build(BuildContext context) {
    final records = store.recordsFor(module);
    final unresolved = records.where((record) {
      return record.status != 'Cleared' &&
          record.status != 'Resolved' &&
          record.status != 'Completed';
    }).length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        key: ValueKey('add-${module.name}-button'),
        heroTag: 'add-${module.name}',
        onPressed: () => _createRecord(context),
        icon: const Icon(Icons.add),
        label: Text(module.actionLabel),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 92),
        children: [
          _ModuleHeader(
            module: module,
            total: records.length,
            unresolved: unresolved,
          ),
          const SizedBox(height: 14),
          if (records.isEmpty)
            _EmptyPanel(text: module.emptyLabel)
          else
            ...records.map(
              (record) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _RecordCard(
                  record: record,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          RecordDetailPage(store: store, recordId: record.id),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _createRecord(BuildContext context) async {
    final record = await showDialog<OpsRecord>(
      context: context,
      builder: (_) => RecordFormDialog(module: module),
    );

    if (record == null || !context.mounted) {
      return;
    }

    await store.addRecord(record);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${module.label} record saved on this device.')),
    );
  }
}

class _ModuleHeader extends StatelessWidget {
  const _ModuleHeader({
    required this.module,
    required this.total,
    required this.unresolved,
  });

  final ModuleType module;
  final int total;
  final int unresolved;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: module.accent.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: module.accent.withValues(alpha: 0.18),
            foregroundColor: module.accent,
            child: Icon(module.icon),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  module.screenTitle,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$total total records, $unresolved requiring attention',
                  style: const TextStyle(color: Color(0xFF9CCAC5)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({
    required this.record,
    required this.onTap,
    this.compact = false,
  });

  final OpsRecord record;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final accent = record.module.accent;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(compact ? 12 : 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(record.module.icon, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      record.subtitle,
                      maxLines: compact ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Color(0xFFB9DAD6)),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _StatusChip(label: record.status),
                        _SoftChip(label: record.priority),
                        _SoftChip(label: record.dueLabel),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Color(0xFF9CCAC5)),
            ],
          ),
        ),
      ),
    );
  }
}

class RecordDetailPage extends StatelessWidget {
  const RecordDetailPage({
    super.key,
    required this.store,
    required this.recordId,
  });

  final OperationsStore store;
  final String recordId;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final record = store.find(recordId);
        if (record == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Record removed')),
            body: const Center(
              child: Text('This local record no longer exists.'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text(record.module.screenTitle)),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.panel,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: record.module.accent.withValues(alpha: 0.55),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      record.module.icon,
                      color: record.module.accent,
                      size: 34,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      record.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(record.subtitle, style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _StatusChip(label: record.status),
                        _SoftChip(label: record.priority),
                        _SoftChip(label: record.dueLabel),
                      ],
                    ),
                    const Divider(height: 30),
                    Text(
                      record.detail,
                      style: const TextStyle(
                        color: Color(0xFFB9DAD6),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _SectionHeader(title: 'Update status', icon: Icons.sync_alt),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final status in record.module.statuses)
                    ChoiceChip(
                      label: Text(status),
                      selected: record.status == status,
                      onSelected: (_) => store.updateStatus(record.id, status),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: () => _confirmDelete(context, record),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete local record'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, OpsRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete local record?'),
        content: Text('${record.title} will be removed from this device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    await store.delete(record.id);
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }
}

class RecordFormDialog extends StatefulWidget {
  const RecordFormDialog({super.key, required this.module});

  final ModuleType module;

  @override
  State<RecordFormDialog> createState() => _RecordFormDialogState();
}

class _RecordFormDialogState extends State<RecordFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _detailController = TextEditingController();
  final _dueController = TextEditingController();
  late String _status;
  late String _priority;

  @override
  void initState() {
    super.initState();
    _status = widget.module.statuses.first;
    _priority = widget.module.priorities.first;
    _dueController.text = _defaultDueLabel(widget.module);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _detailController.dispose();
    _dueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.module.actionLabel),
      contentPadding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  key: const ValueKey('record-title-field'),
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: _titleLabel(widget.module),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: _required,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const ValueKey('record-subtitle-field'),
                  controller: _subtitleController,
                  decoration: InputDecoration(
                    labelText: _subtitleLabel(widget.module),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: _required,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const ValueKey('record-detail-field'),
                  controller: _detailController,
                  minLines: 3,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: _detailLabel(widget.module),
                  ),
                  validator: _required,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const ValueKey('record-due-field'),
                  controller: _dueController,
                  decoration: const InputDecoration(
                    labelText: 'Time or due window',
                  ),
                  validator: _required,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: [
                    for (final status in widget.module.statuses)
                      DropdownMenuItem(value: status, child: Text(status)),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _status = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _priority,
                  decoration: const InputDecoration(labelText: 'Priority'),
                  items: [
                    for (final priority in widget.module.priorities)
                      DropdownMenuItem(value: priority, child: Text(priority)),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _priority = value);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          key: const ValueKey('save-record-button'),
          onPressed: _submit,
          icon: const Icon(Icons.save_outlined),
          label: const Text('Save'),
        ),
      ],
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    final now = DateTime.now();
    Navigator.of(context).pop(
      OpsRecord(
        id: 'local-${now.microsecondsSinceEpoch}',
        module: widget.module,
        title: _titleController.text.trim(),
        subtitle: _subtitleController.text.trim(),
        detail: _detailController.text.trim(),
        status: _status,
        priority: _priority,
        dueLabel: _dueController.text.trim(),
        createdAt: now,
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.store});

  final OperationsStore store;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.panel,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF18575B)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Local privacy',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Records stay in local app storage on this Android device. There is no account sign-in, cloud sync, analytics, advertising, location tracking, or contact access.',
                      style: TextStyle(color: Color(0xFFB9DAD6), height: 1.38),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: const [
                        _SoftChip(label: 'Device only'),
                        _SoftChip(label: 'No account'),
                        _SoftChip(label: 'No cloud sync'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SettingsRow(
                icon: Icons.storage_outlined,
                title: 'Stored records',
                subtitle:
                    '${store.records.length} visitor, quality, incident, and booking records',
              ),
              const SizedBox(height: 10),
              _SettingsRow(
                icon: Icons.business_outlined,
                title: 'Provider',
                subtitle: kDeveloperName,
              ),
              const SizedBox(height: 10),
              _SettingsRow(
                icon: Icons.email_outlined,
                title: 'Support',
                subtitle: kSupportEmail,
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () => _confirmReset(context),
                icon: const Icon(Icons.restore_outlined),
                label: const Text('Restore starter records'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Restore starter records?'),
        content: const Text(
          'Current local records will be replaced with the starter operations set on this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await store.resetLocalRecords();
    }
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF164E55)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.teal),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFFB9DAD6)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.teal, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF164E55)),
      ),
      child: Text(text, style: const TextStyle(color: Color(0xFFB9DAD6))),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _statusColor(label).withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _statusColor(label).withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: TextStyle(
            color: _statusColor(label),
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Color _statusColor(String value) {
    final lower = value.toLowerCase();
    if (lower.contains('action') ||
        lower.contains('open') ||
        lower.contains('needs')) {
      return AppColors.warning;
    }
    if (lower.contains('resolved') ||
        lower.contains('cleared') ||
        lower.contains('completed')) {
      return AppColors.green;
    }
    if (lower.contains('investigating')) {
      return AppColors.magenta;
    }
    return AppColors.teal;
  }
}

class _SoftChip extends StatelessWidget {
  const _SoftChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF0C333A),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF1B5B62)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFFB9DAD6),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

String _titleLabel(ModuleType module) {
  switch (module) {
    case ModuleType.visitor:
      return 'Visitor name';
    case ModuleType.quality:
      return 'Checklist area';
    case ModuleType.incident:
      return 'Incident title';
    case ModuleType.appointment:
      return 'Guest or meeting name';
  }
}

String _subtitleLabel(ModuleType module) {
  switch (module) {
    case ModuleType.visitor:
      return 'Company and host';
    case ModuleType.quality:
      return 'Checkpoint summary';
    case ModuleType.incident:
      return 'Location and owner';
    case ModuleType.appointment:
      return 'Host and purpose';
  }
}

String _detailLabel(ModuleType module) {
  switch (module) {
    case ModuleType.visitor:
      return 'Visit notes';
    case ModuleType.quality:
      return 'Checklist notes';
    case ModuleType.incident:
      return 'Incident notes';
    case ModuleType.appointment:
      return 'Appointment notes';
  }
}

String _defaultDueLabel(ModuleType module) {
  switch (module) {
    case ModuleType.visitor:
      return 'Now';
    case ModuleType.quality:
      return 'Today';
    case ModuleType.incident:
      return 'Immediate';
    case ModuleType.appointment:
      return 'Tomorrow 10:00';
  }
}

List<OpsRecord> seedRecords() {
  final base = DateTime(2026, 5, 12, 9, 0);
  return [
    OpsRecord(
      id: 'visitor-1',
      module: ModuleType.visitor,
      title: 'Camille Bernard',
      subtitle: 'Northline Supply | Host: Marion P.',
      detail:
          'Vendor badge issued at reception. Waiting for warehouse escort before entering the operations floor.',
      status: 'Needs host',
      priority: 'Vendor',
      dueLabel: '09:15 today',
      createdAt: base.add(const Duration(minutes: 12)),
    ),
    OpsRecord(
      id: 'visitor-2',
      module: ModuleType.visitor,
      title: 'Jonas Meyer',
      subtitle: 'Facilities inspection | Host: Alain D.',
      detail:
          'Safety brief completed and access limited to meeting room B until facilities lead arrives.',
      status: 'Checked in',
      priority: 'Normal',
      dueLabel: '10:00 today',
      createdAt: base.add(const Duration(minutes: 8)),
    ),
    OpsRecord(
      id: 'quality-1',
      module: ModuleType.quality,
      title: 'Cold room handover',
      subtitle: 'Temperature log and seal check',
      detail:
          'Door seal passed. Temperature variance needs a second reading before the shift close.',
      status: 'In review',
      priority: 'Monitor',
      dueLabel: 'Before 13:00',
      createdAt: base.add(const Duration(minutes: 18)),
    ),
    OpsRecord(
      id: 'quality-2',
      module: ModuleType.quality,
      title: 'Dispatch lane 4',
      subtitle: 'Pallet staging checklist',
      detail:
          'Two outbound pallets missing secondary labels. Supervisor action is required before release.',
      status: 'Action needed',
      priority: 'Critical',
      dueLabel: '11:30 today',
      createdAt: base.add(const Duration(minutes: 15)),
    ),
    OpsRecord(
      id: 'quality-3',
      module: ModuleType.quality,
      title: 'Reception desk close',
      subtitle: 'Visitor log reconciliation',
      detail:
          'All signed-out visitors matched the local register. Paper passes filed for the morning shift.',
      status: 'Ready',
      priority: 'Low risk',
      dueLabel: '16:45 today',
      createdAt: base.add(const Duration(minutes: 3)),
    ),
    OpsRecord(
      id: 'incident-1',
      module: ModuleType.incident,
      title: 'Loading bay spill',
      subtitle: 'Bay 2 | Owner: Site lead',
      detail:
          'Small nonhazardous spill is contained. Cleaning team assigned and bay marked unavailable until cleared.',
      status: 'Investigating',
      priority: 'High',
      dueLabel: 'Immediate',
      createdAt: base.add(const Duration(minutes: 25)),
    ),
    OpsRecord(
      id: 'incident-2',
      module: ModuleType.incident,
      title: 'Badge printer offline',
      subtitle: 'Reception | Owner: Admin desk',
      detail:
          'Manual visitor badges are in use. Replacement ribbon has been requested from the supply cabinet.',
      status: 'Open',
      priority: 'Medium',
      dueLabel: 'Today',
      createdAt: base.add(const Duration(minutes: 6)),
    ),
    OpsRecord(
      id: 'appointment-1',
      module: ModuleType.appointment,
      title: 'Supplier onboarding',
      subtitle: 'Host: Spencer office | Purpose: contract review',
      detail:
          'Prepare visitor pass, meeting room C, and quality onboarding checklist before arrival.',
      status: 'Scheduled',
      priority: 'Executive',
      dueLabel: '14:30 today',
      createdAt: base.add(const Duration(minutes: 20)),
    ),
    OpsRecord(
      id: 'appointment-2',
      module: ModuleType.appointment,
      title: 'Maintenance walk-through',
      subtitle: 'Host: Facilities | Purpose: preventive review',
      detail:
          'Route starts at reception, continues to dispatch, and ends at the equipment storage area.',
      status: 'Scheduled',
      priority: 'Standard',
      dueLabel: '09:45 tomorrow',
      createdAt: base.add(const Duration(minutes: 4)),
    ),
  ];
}
