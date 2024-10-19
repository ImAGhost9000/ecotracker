import 'package:flutter/material.dart';
import 'dart:math';
import 'home_page.dart'; // Import the HomePage

class UsagePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()), // Navigate to HomePage
            );
          },
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 1, // Height of the top border
            color: Color(0xFF1C1C1C), // Darker black color
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildUsageSection(
                      title: 'Electrical Devices',
                      titleColor: Colors.yellow,
                      totalUsage: '90 kWh',
                      data: [
                        UsageData('PC', 11.0, Color(0xFFFFF176)),
                        UsageData('Microwave', 22.0, Color(0xFFFFEE58)),
                        UsageData('Phone', 22.0, Color(0xFFFFD54F)),
                        UsageData('Air-con', 45.0, Color(0xFFFFB300)),
                      ],
                      textColor: Colors.yellow,
                    ),
                    SizedBox(height: 30),
                    _buildUsageSection(
                      title: 'Water Utilities',
                      titleColor: Colors.blue,
                      totalUsage: '408 Gallons',
                      data: [
                        UsageData('Shower', 30.0, Color(0xFF90CAF9)),
                        UsageData('Flushing', 15.0, Color(0xFF42A5F5)),
                        UsageData('Sink', 55.0, Color(0xFF1E88E5)),
                      ],
                      textColor: Colors.blue,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageSection({
    required String title,
    required Color titleColor,
    required String totalUsage,
    required List<UsageData> data,
    required Color textColor,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: titleColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 20),
        Center(
          child: SizedBox(
            width: 250,
            height: 250,
            child: CustomPaint(
              painter: DonutChartPainter(
                data: data,
                totalValue: totalUsage,
                textColor: textColor,
              ),
            ),
          ),
        ),
        SizedBox(height: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: data.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              '${item.name} ${item.percentage.toStringAsFixed(1)}%',
              style: TextStyle(color: item.color),
            ),
          )).toList(),
        ),
      ],
    );
  }
}

class UsageData {
  final String name;
  final double percentage;
  final Color color;

  UsageData(this.name, this.percentage, this.color);
}

class DonutChartPainter extends CustomPainter {
  final List<UsageData> data;
  final String totalValue;
  final Color textColor;

  DonutChartPainter({
    required this.data,
    required this.totalValue,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    double startAngle = -pi / 2; // Start from the top
    for (var item in data) {
      final sweepAngle = 2 * pi * (item.percentage / 100);
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = item.color;

      // Draw the arc without any gap
      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
      startAngle += sweepAngle;
    }

    // Draw center hole
    canvas.drawCircle(
      center,
      radius * 0.45,
      Paint()..color = const Color.fromARGB(255, 20, 20, 20),
    );

    // Draw total value
    final textPainter = TextPainter(
      text: TextSpan(
        text: totalValue,
        style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

void main() {
  runApp(MaterialApp(home: UsagePage()));
}
