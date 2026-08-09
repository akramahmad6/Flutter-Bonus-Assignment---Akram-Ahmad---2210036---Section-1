import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:summer_iub_app/models/coffee_records_model.dart';
import 'package:summer_iub_app/screens/create_coffee_record_screen.dart';
import 'package:summer_iub_app/state_management/coffee_state_management.dart';
import 'package:summer_iub_app/widgets/app_backgroud_design_widget.dart';

class CoffeRecordsScreen extends StatelessWidget {
  const CoffeRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.read<CoffeeStateManagement>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coffee Records'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: AppBackgroudDesignWidget(
        child: StreamBuilder<List<CoffeeRecordsModel>>(
          stream: state.coffeeRecordsStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Could not load coffee records.\n${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final records = snapshot.data!;
            if (records.isEmpty) {
              return const Center(
                child: Text(
                  'No coffee records yet.\nTap + to add your first order.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.brown),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              itemCount: records.length,
              itemBuilder: (context, index) => _RecordTile(record: records[index]),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add coffee record',
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CreateCoffeeRecordScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({required this.record});

  final CoffeeRecordsModel record;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.coffee, color: Colors.brown),
        title: Text(record.title),
        subtitle: Text('${record.des}\nAmount: ${record.amount?.toStringAsFixed(2) ?? '0.00'}'),
        isThreeLine: true,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => CreateCoffeeRecordScreen(record: record)),
        ),
        trailing: IconButton(
          tooltip: 'Delete record',
          icon: const Icon(Icons.delete_outline),
          onPressed: record.documentId == null
              ? null
              : () => _confirmDelete(context, record),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, CoffeeRecordsModel record) async {
    final delete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete record?'),
        content: Text('Remove "${record.title}" permanently?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (delete != true || !context.mounted) return;

    try {
      await context.read<CoffeeStateManagement>().deleteCoffeeRecord(record.documentId!);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not delete record: $error')),
        );
      }
    }
  }
}
