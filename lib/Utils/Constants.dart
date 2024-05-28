import 'package:flutter/material.dart';
import 'package:home_attendance_system/Models/UserModel.dart';

User? currentUser;


TimeOfDay parseTimeStringToTimeOfDay(String timeString) {
  // Split the time string into hours and minutes
  List<String> parts = timeString.split(':');

  // Extract hours and minutes
  int hours = int.parse(parts[0]);
  int minutes = int.parse(parts[1].split(" ")[0]); // Extract minutes

  // Determine whether it's AM or PM
  bool isPM = parts[1].contains("PM");

  // Adjust hours for PM
  if (isPM && hours != 12) {
    hours += 12;
  }

  // Create and return TimeOfDay object
  return TimeOfDay(hour: hours, minute: minutes);
}
