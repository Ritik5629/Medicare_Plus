import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models.dart';
import 'notification_service.dart';

class MedicineReminderScreen extends StatefulWidget {
  const MedicineReminderScreen({Key? key}) : super(key: key);

  @override
  _MedicineReminderScreenState createState() => _MedicineReminderScreenState();
}

class _MedicineReminderScreenState extends State<MedicineReminderScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  List<MedicineReminder> _reminders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReminders();
    _notificationService.initialize();
  }

  Future<void> _loadReminders() async {
    if (user != null) {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(user!.uid)
          .collection('medicineReminders')
          .get();

      List<MedicineReminder> reminders = snapshot.docs.map((doc) {
        return MedicineReminder.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();

      setState(() {
        _reminders = reminders;
        _isLoading = false;
      });
    }
  }

  Future<void> _addReminder() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddMedicineReminderScreen()),
    );

    if (result == true) {
      _loadReminders();
    }
  }

  Future<void> _deleteReminder(String id) async {
    await _firestore
        .collection('users')
        .doc(user!.uid)
        .collection('medicineReminders')
        .doc(id)
        .delete();

    _notificationService.cancelNotification(id.hashCode);
    _loadReminders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Reminders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addReminder,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reminders.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medication,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No medicine reminders',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tap + to add a new reminder',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _reminders.length,
        itemBuilder: (context, index) {
          final reminder = _reminders[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            child: ListTile(
              leading: const Icon(Icons.medication, color: Colors.blue),
              title: Text(reminder.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dosage: ${reminder.dosage}'),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8.0,
                    children: reminder.times.map((time) {
                      return Chip(
                        label: Text(time),
                        backgroundColor: Colors.blue.shade100,
                        padding: const EdgeInsets.all(4),
                      );
                    }).toList(),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteReminder(reminder.id),
              ),
            ),
          );
        },
      ),
    );
  }
}

class AddMedicineReminderScreen extends StatefulWidget {
  const AddMedicineReminderScreen({Key? key}) : super(key: key);

  @override
  _AddMedicineReminderScreenState createState() => _AddMedicineReminderScreenState();
}

class _AddMedicineReminderScreenState extends State<AddMedicineReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();

  List<String> _selectedTimes = [];
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;

  final List<String> _times = ['Morning', 'Afternoon', 'Night'];
  final NotificationService _notificationService = NotificationService();

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  Future<void> _saveReminder() async {
    if (_formKey.currentState!.validate() && _selectedTimes.isNotEmpty) {
      String id = DateTime.now().millisecondsSinceEpoch.toString();

      MedicineReminder reminder = MedicineReminder(
        id: id,
        name: _nameController.text.trim(),
        dosage: _dosageController.text.trim(),
        times: _selectedTimes,
        startDate: _startDate,
        endDate: _endDate,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('medicineReminders')
          .doc(id)
          .set(reminder.toMap());

      // Schedule notifications
      for (String time in _selectedTimes) {
        TimeOfDay notificationTime = _getTimeOfDay(time);
        await _notificationService.scheduleDailyNotification(
          id: id.hashCode,
          title: 'Medicine Reminder',
          body: 'Time to take ${reminder.name} (${reminder.dosage})',
          time: notificationTime,
        );
      }

      Navigator.pop(context, true);
    } else if (_selectedTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one time'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  TimeOfDay _getTimeOfDay(String time) {
    switch (time) {
      case 'Morning':
        return const TimeOfDay(hour: 8, minute: 0);
      case 'Afternoon':
        return const TimeOfDay(hour: 13, minute: 0);
      case 'Night':
        return const TimeOfDay(hour: 20, minute: 0);
      default:
        return const TimeOfDay(hour: 8, minute: 0);
    }
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate,
      firstDate: _startDate,
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Medicine Reminder'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Medicine Name',
                  prefixIcon: Icon(Icons.medication),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter medicine name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dosageController,
                decoration: const InputDecoration(
                  labelText: 'Dosage',
                  prefixIcon: Icon(Icons.local_pharmacy),
                  border: OutlineInputBorder(),
                  hintText: 'e.g., 1 tablet, 5ml',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter dosage';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Select Times',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                children: _times.map((time) {
                  return FilterChip(
                    label: Text(time),
                    selected: _selectedTimes.contains(time),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedTimes.add(time);
                        } else {
                          _selectedTimes.remove(time);
                        }
                      });
                    },
                    selectedColor: Colors.blue.shade100,
                    checkmarkColor: Colors.blue,
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Start Date'),
                subtitle: Text('${_startDate.day}/${_startDate.month}/${_startDate.year}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectStartDate,
              ),
              const SizedBox(height: 8),
              ListTile(
                title: const Text('End Date (Optional)'),
                subtitle: _endDate != null
                    ? Text('${_endDate!.day}/${_endDate!.month}/${_endDate!.year}')
                    : const Text('No end date'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectEndDate,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveReminder,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Save Reminder',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}