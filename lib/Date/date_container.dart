import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ecotracker/Providers/date_provider.dart';

class DateContainer extends ConsumerWidget {
  const DateContainer({super.key});


  String formatDate(DateTime date) {
    const List<String> weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    String weekday = weekdays[date.weekday - 1];
    return "$weekday - ${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}";
  }

  
  void selectDate(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(selectedDateNotifierProvider.notifier);
    final currentDate = ref.read(selectedDateNotifierProvider);

    showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2000),
      lastDate: currentDate,
    ).then((pickedDate) {
      if (pickedDate != null && pickedDate != currentDate) {
        notifier.updateDate(pickedDate); 
      }
    }).catchError((error) {
      debugPrint("Date Picker Error: $error");
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateNotifierProvider);
    final defaultDate = DateTime.now();

    bool isDefaultDate = selectedDate.year == defaultDate.year &&
        selectedDate.month == defaultDate.month &&
        selectedDate.day == defaultDate.day;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => selectDate(context, ref),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.green[600],
              borderRadius: BorderRadius.circular(40),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                formatDate(selectedDate),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        
        if(!isDefaultDate)
          IconButton(
            onPressed: () => ref.read(selectedDateNotifierProvider.notifier).resetToDefault(), 
            icon: const Icon(Icons.close), 
            highlightColor: Colors.purpleAccent, 
            iconSize: 12,
            padding: EdgeInsets.zero,
          ),
      ],
    );
  }
}
