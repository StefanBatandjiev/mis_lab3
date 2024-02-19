import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'ExamSchedule.dart';
import 'location_selection_screen.dart';
import 'map_widget.dart';

List<ExamSchedule> examSchedules = [
  ExamSchedule(
    subjectName: 'Strukturno Programiranje',
    dateTime: DateTime.now().add(Duration(hours: 6)),
    location: LatLng(42.00, 21.40),
  ),
  ExamSchedule(
    subjectName: 'Mobilni Informaciski Sistemi',
    dateTime: DateTime.now().add(Duration(hours: 8)),
    location: LatLng(42.004186212873655, 21.409531941596985),
  ),
  ExamSchedule(
    subjectName: 'Kalkulus 2',
    dateTime: DateTime.now().add(Duration(hours: 12)),
    location: LatLng(42.5, 21.5),
  ),
];

class ExamScheduleScreen extends StatefulWidget {
  @override
  _ExamScheduleScreenState createState() => _ExamScheduleScreenState();
}

class _ExamScheduleScreenState extends State<ExamScheduleScreen> {
  List<ExamSchedule> _examSchedules = [];
  late CalendarFormat _calendarFormat = CalendarFormat.month;
  late DateTime _focusedDay = DateTime.now();
  late DateTime _selectedDay = DateTime.now();

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late GoogleMapController mapController;
  late Set<Marker> markers;

  @override
  void initState() {
    super.initState();
    _updateExamList();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    markers = Set<Marker>.from(_examSchedules.map((schedule) => Marker(
          markerId: MarkerId(schedule.subjectName),
          position: schedule.location,
          infoWindow: InfoWindow(
            title: schedule.subjectName,
            snippet:
                DateFormat('MMMM dd, yyyy hh:mm a').format(schedule.dateTime),
          ),
        )));
  }

  Future<void> _scheduleNotification(ExamSchedule examSchedule) async {
    var androidDetails = AndroidNotificationDetails(
      'appointment_id',
      'Appointment Notifications',
      channelDescription: 'Notification channel for appointment reminders',
      importance: Importance.max,
      priority: Priority.high,
    );
    var platformDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      examSchedule.hashCode,
      'Appointment Reminder',
      '${examSchedule.subjectName} is scheduled for ${examSchedule.dateTime}',
      platformDetails,
    );
  }

  void _updateExamList() {
    setState(() {
      _examSchedules = List.from(examSchedules);
      _examSchedules.retainWhere((exam) =>
          exam.dateTime.year == _selectedDay.year &&
          exam.dateTime.month == _selectedDay.month &&
          exam.dateTime.day == _selectedDay.day);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exam Schedules'),
        actions: [
          IconButton(
            icon: Icon(Icons.map),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MapWidget(
                    markers: markers,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _showAddExamDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                _updateExamList();
              });
            },
            availableCalendarFormats: const {
              CalendarFormat.month: 'Month',
            },
            onPageChanged: (focusedDay) {
              setState(() {
                if (focusedDay.isBefore(DateTime.utc(2030, 12, 31))) {
                  _focusedDay = focusedDay;
                } else {
                  _focusedDay = DateTime.now();
                }
              });
            },
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemCount: _examSchedules.length,
              itemBuilder: (context, index) {
                final exam = _examSchedules[index];
                return Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        exam.subjectName,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        DateFormat('MMMM dd, yyyy hh:mm a')
                            .format(exam.dateTime),
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
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
              _scheduleNotification(newExamSchedule);
              _updateExamList();
            });
          },
          onSelectLocation: () async {
            // Add a callback for selecting location
            LatLng? selectedLocation = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LocationSelectionScreen(),
              ),
            );

            // Handle the selected location
            if (selectedLocation != null) {
              // Do something with the selected location
            }
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
  final Function() onSelectLocation;

  AddExamDialog({required this.onExamAdded, required this.onSelectLocation});

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
            return DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              selectedTime.hour,
              selectedTime.minute,
            );
          } else {
            return null;
          }
        });
      } else {
        return null;
      }
    });
  }

  Future<LatLng?> _selectLocation(BuildContext context) async {
    Completer<LatLng?> completer = Completer();
    LatLng? selectedLocation;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationSelectionScreen(),
      ),
    ).then((value) {
      selectedLocation = value;
      completer.complete(selectedLocation);
    });

    return completer.future;
  }

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
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                final selectedLocation = await _selectLocation(context);
                if (selectedLocation != null) {
                  final dateTime = DateFormat('MMMM dd, yyyy hh:mm a')
                      .parse('${dateController.text} ${timeController.text}');
                  final newExamSchedule = ExamSchedule(
                    subjectName: subjectController.text,
                    dateTime: dateTime,
                    location: selectedLocation,
                    locationReminder: true, // Set location reminder
                  );

                  onExamAdded(newExamSchedule);
                  Navigator.pop(context);
                }
              },
              child: Text('Select Location'),
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
            if (subjectController.text.isNotEmpty &&
                dateController.text.isNotEmpty &&
                timeController.text.isNotEmpty) {
              final dateTime = DateFormat('MMMM dd, yyyy hh:mm a')
                  .parse('${dateController.text} ${timeController.text}');
              final newExamSchedule = ExamSchedule(
                subjectName: subjectController.text,
                dateTime: dateTime,
                location: LatLng(42.004186212873655, 21.409531941596985),
              );

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
}
