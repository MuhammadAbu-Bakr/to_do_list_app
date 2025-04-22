import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class AddEditTaskScreen extends StatefulWidget {
  final Task? task;
  final int? index;

  const AddEditTaskScreen({
    super.key,
    this.task,
    this.index,
  });

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _title = widget.task?.title ?? '';
    _dueDate = widget.task?.dueDate;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final task = Task(
      title: _title,
      dueDate: _dueDate,
    );

    if (widget.task != null && widget.index != null) {
      taskProvider.updateTask(widget.index!, task);
    } else {
      taskProvider.addTask(task);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a task title';
                  }
                  return null;
                },
                onSaved: (value) => _title = value!,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    _dueDate == null
                        ? 'No due date'
                        : 'Due: ${DateFormat.yMMMd().format(_dueDate!)}',
                  ),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: const Text('Select Date'),
                  ),
                  if (_dueDate != null)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _dueDate = null;
                        });
                      },
                      child: const Text('Clear'),
                    ),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(
                  widget.task == null ? 'Add Task' : 'Update Task',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}