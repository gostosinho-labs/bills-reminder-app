import 'package:bills_reminder/data/services/background/bills_background_service_local.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

class DebugBackgroundWork extends StatefulWidget {
  const DebugBackgroundWork({super.key});

  @override
  State<DebugBackgroundWork> createState() => _DebugBackgroundWorkState();
}

class _DebugBackgroundWorkState extends State<DebugBackgroundWork> {
  late final Workmanager _workmanager;

  late List<({String id, String description, bool enabled})> _tasks;

  @override
  void initState() {
    super.initState();

    _workmanager = Workmanager();

    _tasks = [
      (
        id: BillsBackgroundServiceLocal.dailyNotificationUniqueName,
        description: 'Daily notification background task',
        enabled: false,
      ),
    ];

    Future.microtask(_refresh);
  }

  Future<void> _refresh() async {
    _tasks = await Future.wait(
      _tasks.map(
        (task) async => (
          id: task.id,
          description: task.description,
          enabled: await _workmanager.isScheduledByUniqueName(task.id),
        ),
      ),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'DEBUG',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            ListTile(
              title: Text('Scheduled Background Work (${_tasks.length})'),
              trailing: IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _refresh,
                tooltip: 'Refresh',
              ),
            ),
            if (_tasks.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.work_off_outlined,
                        size: 24,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No scheduled background work',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._tasks.map(
                (task) => ListTile(
                  title: Text(task.id),
                  subtitle: Text(task.description),
                  dense: true,
                  trailing: Text(task.enabled ? 'Enabled' : 'Disabled'),
                  visualDensity: VisualDensity.compact,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
