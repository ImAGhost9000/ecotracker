class IndividualBar {
  final int x;
  final double y;

  IndividualBar({
    required this.x,
    required this.y
  });
}

class BarData {
  final double monAmount;
  final double tueAmount;
  final double wedAmount;
  final double thrAmount;
  final double friAmount;
  final double satAmount;
  final double sunAmount;

  BarData({
    required this.monAmount,
    required this.tueAmount,
    required this.wedAmount,
    required this.thrAmount,
    required this.friAmount,
    required this.satAmount,
    required this.sunAmount,
  });

  List<IndividualBar> barData = [];


  void initializeBarData(){
    barData = [
      IndividualBar(x: 0, y: monAmount),
      IndividualBar(x: 1, y: tueAmount),
      IndividualBar(x: 2, y: wedAmount),
      IndividualBar(x: 3, y: thrAmount),
      IndividualBar(x: 4, y: friAmount),
      IndividualBar(x: 5, y: satAmount),
      IndividualBar(x: 6, y: sunAmount)
    ];
  }
}

List<double> electricalUsage = [90.0, 15.0, 97.0, 90.0, 70.0, 80.0, 20.0];
List<double> waterUsage = [30.0,23.0,60.0,85.0,33.0,45.0,65.0];
