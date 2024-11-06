import 'package:flutter/material.dart';

String getCurrentDate() {
  DateTime now = DateTime.now();
  List<String> weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  String weekday = weekdays[now.weekday - 1];
  return "$weekday - ${now.year}/${now.month}/${now.day}";
}

class Datecontainer extends StatelessWidget {
  const Datecontainer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 40, 39, 39),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          getCurrentDate(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}