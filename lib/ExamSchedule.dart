import 'package:google_maps_flutter/google_maps_flutter.dart';

class ExamSchedule {
  late String subjectName;
  late DateTime dateTime;
  late LatLng location;
  late bool locationReminder;

  ExamSchedule({
    required this.subjectName,
    required this.dateTime,
    required this.location,
    this.locationReminder = false,
  });
}
