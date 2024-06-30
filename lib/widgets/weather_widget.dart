import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class WeatherWidget extends StatefulWidget {
  final String email;
  final Function(int, int) updateAdjustments;

  WeatherWidget({required this.email, required this.updateAdjustments});

  @override
  _WeatherWidgetState createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  String? temperature;
  String? description;
  String? city;
  String? humidity;
  String? errorMessage;
  int tempAdjustment = 0;
  int humidityAdjustment = 0;

  @override
  void initState() {
    super.initState();
    fetchWeather();
    print('WeatherWidget initialized');
  }

  Future<void> fetchWeather() async {
    try {
      final response = await http.get(Uri.parse('http://api.openweathermap.org/data/2.5/weather?q=chicago&appid=c210c346bca05345422160e3f0c30b05&units=imperial'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          temperature = data['main']['temp'].toString();
          description = data['weather'][0]['description'];
          city = data['name'];
          humidity = data['main']['humidity'].toString();
          errorMessage = null;
        });
        print('Weather data fetched: $data');
        _calculateAdjustments();
      } else {
        throw Exception('Failed to load weather');
      }
    } catch (error) {
      setState(() {
        errorMessage = error.toString();
      });
      print('Error fetching weather: $error');
    }
  }

  void _calculateAdjustments() {
    if (temperature != null && humidity != null) {
      double temp = double.parse(temperature!);
      int humidityValue = int.parse(humidity!);

      if (temp <= 70) {
        tempAdjustment = 0;
      } else if (temp <= 80) {
        tempAdjustment = 1;
      } else if (temp <= 90) {
        tempAdjustment = 2;
      } else {
        tempAdjustment = 3;
      }

      if (humidityValue <= 30) {
        humidityAdjustment = 0;
      } else if (humidityValue <= 50) {
        humidityAdjustment = 1;
      } else if (humidityValue <= 70) {
        humidityAdjustment = 2;
      } else {
        humidityAdjustment = 3;
      }

      print('Temperature adjustment: $tempAdjustment, Humidity adjustment: $humidityAdjustment');
    }
  }

  Future<void> updateWaterPerDay() async {
    int totalAdjustment = tempAdjustment + humidityAdjustment;

    // Update the Firestore database
    final currentDayDoc = FirebaseFirestore.instance.collection('current_day').where('email', isEqualTo: widget.email);
    currentDayDoc.get().then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        int waterPerDay = doc['water_per_day'];
        FirebaseFirestore.instance.collection('current_day').doc(doc.id).update({
          'water_per_day': waterPerDay + totalAdjustment,
        });
        print('Updated water_per_day in Firestore for ${widget.email}');
      });
    });

    widget.updateAdjustments(tempAdjustment, humidityAdjustment);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            if (errorMessage != null)
              Text(
                'Error: $errorMessage',
                style: TextStyle(fontSize: 16, color: Colors.red),
              )
            else ...[
              Text(
                city != null ? 'Weather in $city' : 'Fetching weather...',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (temperature != null && description != null && humidity != null) ...[
                Text(
                  '$temperature°F',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  description!,
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Humidity: $humidity%',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Temperature Adjustment: $tempAdjustment',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Humidity Adjustment: $humidityAdjustment',
                  style: TextStyle(fontSize: 16),
                ),
              ],
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  print('Adjust water per day button pressed');
                  updateWaterPerDay();
                },
                icon: Icon(Icons.update),
                label: Text('Adjust Water Per Day'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
