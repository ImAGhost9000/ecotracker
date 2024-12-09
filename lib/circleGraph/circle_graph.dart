import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';


class Piegraph extends StatefulWidget {


  const Piegraph({
    super.key,
    required this.pieChartSections,
    required this.unit,
  });

  final List<Map<String, dynamic>> pieChartSections;
  final String unit;

  @override
  State<Piegraph> createState() => _PiegraphState();
}

class _PiegraphState extends State<Piegraph> {
  int? touchedIndex;

  // Calculate the total value of all sections
  double getTotal(List<Map<String, dynamic>> data) {
    double total = 0;
    for (var item in data) {
      if (item.containsKey("value") && item["value"] is num) {
        total += item["value"];
      }
    }
    return total;
  }

  List<Map<String,dynamic>> sortSections(){
    List<Map<String,dynamic>> sortedSections = widget.pieChartSections.where((item){
      return item.containsKey("value") && item["value"] is num;
    }).toList(); //null safeguard

    sortedSections.sort((a,b) => b['value'].compareTo(a['value']));
    return sortedSections; 
  }

  @override
  Widget build(BuildContext context) {
    double totalUsage = getTotal(widget.pieChartSections);
    List<Map<String,dynamic>> sortedSections = sortSections();

    return Container(
      margin: const EdgeInsets.all(10.0),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 40, 39, 39),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 400,
                child: PieChart(
                  PieChartData(
                    sections: sortedSections.asMap().entries.map((entry) {
                      int index = entry.key;
                      Map<String, dynamic> section = entry.value;

                      final isTouched = index == touchedIndex;
                      final double fontSize = isTouched ? 18 : 14;
                      final double radius = isTouched ? 70 : 60;

                      final double percentage = ((section['value'] / totalUsage) * 100);
                      const double minPercentage = 5.0;
                      final bool tooSmall = percentage < minPercentage;

                      double adjustedValue = section['value'];
                      if(tooSmall && section['value'] != 0){
                        adjustedValue = totalUsage * (minPercentage / 100);
                      }

              

                      return PieChartSectionData(
                        value: adjustedValue,
                        color: section['color'],
                        radius: radius,
                        title: '${percentage.toStringAsFixed(2)}%',
                        titleStyle: TextStyle(
                          fontSize: fontSize,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList(),
                    centerSpaceRadius: 90,
                    // Handle touch interactions
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (pieTouchResponse != null &&
                              pieTouchResponse.touchedSection != null) {
                            touchedIndex =
                                pieTouchResponse.touchedSection!.touchedSectionIndex;
                          } else {
                            touchedIndex = null;
                          }
                        });
                      },
                    ),
                  ),
                  swapAnimationCurve: Curves.bounceIn,
                  swapAnimationDuration: const Duration(milliseconds: 150),
                ),
              ),
              Text(
                '${totalUsage.toStringAsFixed(1)} ${widget.unit}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            children: sortedSections.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> section = entry.value;
              
              final isTouched = index == touchedIndex;
              final double fontSize = isTouched ? 20 : 18;
              final FontWeight fontWeight = isTouched ? FontWeight.bold : FontWeight.normal;
              

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    color: section['color'],  // Color box
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${section['title']} : ${section['value'].toStringAsFixed(2)} ${widget.unit}',
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: fontWeight,
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}


double getTotal(List<Map<String, dynamic>> data){
  double total = 0;

  for(var item in data){
    if(item.containsKey("value") && item["value"] is num){
      total+=item["value"];
    }
  }
  
  return total;
}