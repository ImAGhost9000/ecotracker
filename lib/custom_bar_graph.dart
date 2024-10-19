import 'package:flutter/material.dart';

class CustomBarGraph extends StatelessWidget {
  final List<double> data;
  final List<String> labels;
  final String title;
  final Color barColor;
  final Color labelColor;
  final double maxValue;
  final String unit; // New parameter for the unit (Gal or kWh)

  const CustomBarGraph({
    Key? key,
    required this.data,
    required this.labels,
    required this.title,
    required this.barColor,
    this.labelColor = Colors.green,
    required this.maxValue,
    required this.unit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(
                  5,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      '${(maxValue * (5 - index) / 5).toStringAsFixed(0)} $unit',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 200,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(
                      data.length,
                      (index) => Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: 30,
                            height: (data[index] / maxValue) * 180,
                            color: barColor,
                          ),
                          SizedBox(height: 5),
                          Text(
                            labels[index],
                            style: TextStyle(color: labelColor, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}