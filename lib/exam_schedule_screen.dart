import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'ExamSchedule.dart';

List<ExamSchedule> examSchedules = [
  ExamSchedule(
    subjectName: 'Strukturno Programiranje',
    dateTime: DateTime.now(),
  ),
  ExamSchedule(
    subjectName: 'Mobilni Informaciski Sistemi',
    dateTime: DateTime.now(),
  ),
  ExamSchedule(
    subjectName: 'Kalkulus 2',
    dateTime: DateTime.now(),
  ),
];

class ExamScheduleScreen extends StatefulWidget {
  @override
  _ExamScheduleScreenState createState() => _ExamScheduleScreenState();
}

class _ExamScheduleScreenState extends State<ExamScheduleScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exam Schedules'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _showAddExamDialog(context);
            },
          ),
        ],
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemCount: examSchedules.length,
        itemBuilder: (context, index) {
          return Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  examSchedules[index].subjectName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0),
                Text(
                  DateFormat('MMMM dd, yyyy hh:mm a')
                      .format(examSchedules[index].dateTime),
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddExamDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddExamDialog(
          onExamAdded: (newExamSchedule) {
            setState(() {
              examSchedules.add(newExamSchedule);
            });
          },
        );
      },
    );
  }
}

class AddExamDialog extends StatelessWidget {
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  final Function(ExamSchedule) onExamAdded;

  AddExamDialog({required this.onExamAdded});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Exam Schedule'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: subjectController,
              decoration: InputDecoration(
                labelText: 'Subject Name',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                final selectedDateTime = await _selectDateTime(context);
                if (selectedDateTime != null) {
                  dateController.text =
                      DateFormat('MMMM dd, yyyy').format(selectedDateTime);
                  timeController.text =
                      DateFormat('hh:mm a').format(selectedDateTime);
                }
              },
              child: Text('Select Date and Time'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Validate user input
            if (subjectController.text.isNotEmpty &&
                dateController.text.isNotEmpty &&
                timeController.text.isNotEmpty) {
              final dateTime = DateFormat('MMMM dd, yyyy hh:mm a')
                  .parse('${dateController.text} ${timeController.text}');
              final newExamSchedule = ExamSchedule(
                  subjectName: subjectController.text, dateTime: dateTime);

              onExamAdded(newExamSchedule);
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Please fill in all fields.'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          child: Text('Add Exam Schedule'),
        ),
      ],
    );
  }

  Future<DateTime?> _selectDateTime(BuildContext context) async {
    return await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    ).then((selectedDate) {
      if (selectedDate != null) {
        return showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        ).then((selectedTime) {
          if (selectedTime != null) {
            return DateTime(selectedDate.year, selectedDate.month,
                selectedDate.day, selectedTime.hour, selectedTime.minute);
          } else {
            return null;
          }
        });
      } else {
        return null;
      }
    });
  }
}
