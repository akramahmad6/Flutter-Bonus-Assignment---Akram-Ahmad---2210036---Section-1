import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:summer_iub_app/models/coffee_records_model.dart';
import 'package:summer_iub_app/state_management/coffee_state_management.dart';
import 'package:summer_iub_app/utility/vlaidators.dart';
import 'package:summer_iub_app/widgets/app_backgroud_design_widget.dart';
import 'package:summer_iub_app/widgets/core_input_widget.dart';

class CreateCoffeeRecordScreen extends StatefulWidget {
  final CoffeeRecordsModel? record;
  const CreateCoffeeRecordScreen({super.key, this.record});

  @override
  State<CreateCoffeeRecordScreen> createState() =>
      _CreateCoffeeRecordScreenState();
}

class _CreateCoffeeRecordScreenState extends State<CreateCoffeeRecordScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final record = widget.record;
    if (record != null) {
      _titleController.text = record.title;
      _amountController.text = record.amount?.toString() ?? '';
      _descriptionController.text = record.des;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.record == null ? 'Create Coffee Record' : 'Edit Coffee Record',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.00),
        ),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: AppBackgroudDesignWidget(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                CoreInputWidget(
                  controller: _titleController,
                  labelText: "Title",
                  validator: CustomValidators.validateTitle,
                ),

                const SizedBox(height: 20.00),

                CoreInputWidget(
                  controller: _amountController,
                  labelText: "Amount",
                  keyboardType: TextInputType.number,
                  validator: CustomValidators.validateAmount,
                ),

                const SizedBox(height: 20.00),

                CoreInputWidget(
                  controller: _descriptionController,
                  labelText: "Description",
                  keyboardType: TextInputType.multiline,
                  maxLine: 5,
                  validator: CustomValidators.validateDescreption,
                ),

                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _saving ? null : _save,
                  label: Text(
                    _saving ? 'Saving...' : 'Save Coffee Record',
                    style: const TextStyle(
                      fontSize: 18.00,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  icon: Icon(Icons.save, size: 30.00),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50.00),
                    padding: EdgeInsets.symmetric(
                      horizontal: 50.00,
                      vertical: 15.00,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final existing = widget.record;
    final record = CoffeeRecordsModel(
      documentId: existing?.documentId,
      id: existing?.id ?? DateTime.now().microsecondsSinceEpoch,
      title: _titleController.text.trim(),
      des: _descriptionController.text.trim(),
      amount: double.parse(_amountController.text),
      date: existing?.date ?? DateTime.now(),
    );
    try {
      final state = context.read<CoffeeStateManagement>();
      if (existing == null) {
        await state.addCoffeeRecord(record);
      } else {
        await state.updateCoffeeRecord(record);
      }
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save record: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}
