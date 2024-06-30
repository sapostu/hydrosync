import 'package:flutter/material.dart';
import 'package:health/health.dart';

class StepsWidget extends StatefulWidget {
  final String email;
  final Function(int) updateStepsAdjustment;

  StepsWidget({required this.email, required this.updateStepsAdjustment});

  @override
  _StepsWidgetState createState() => _StepsWidgetState();
}

class _StepsWidgetState extends State<StepsWidget> {
  int? _steps;
  int? _stepsAdjustment;

  @override
  void initState() {
    super.initState();
    fetchSteps();
  }

  Future<void> fetchSteps() async {
    HealthFactory health = HealthFactory();
    bool isAuthorized = await health.requestAuthorization([HealthDataType.STEPS]);

    if (isAuthorized) {
      DateTime endDate = DateTime.now();
      DateTime startDate = DateTime(endDate.year, endDate.month, endDate.day);
      List<HealthDataPoint> healthData = await health.getHealthDataFromTypes(startDate, endDate, [HealthDataType.STEPS]);

      int totalSteps = healthData
          .where((dataPoint) => dataPoint.type == HealthDataType.STEPS)
          .fold(0, (sum, dataPoint) => sum + (dataPoint.value is NumericHealthValue ? (dataPoint.value as NumericHealthValue).numericValue.toInt() : dataPoint.value as int));

      int stepsAdjustment = 0;
      if (totalSteps >= 10000) {
        stepsAdjustment = 3;
        _stepsAdjustment = 3;
      } else if (totalSteps >= 7500) {
        stepsAdjustment = 2;
        _stepsAdjustment = 2;
      } else if (totalSteps >= 5000) {
        stepsAdjustment = 1;
        _stepsAdjustment = 1;
      }

      setState(() {
        _steps = totalSteps;
      });

      widget.updateStepsAdjustment(stepsAdjustment);
    } else {
      print("Authorization not granted");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Steps Today',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (_steps != null)
              Text(
                '$_steps steps',
                style: TextStyle(fontSize: 16),
              )
            else
              Text(
                'Fetching steps...',
                style: TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}
