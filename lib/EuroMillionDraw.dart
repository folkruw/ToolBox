import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class EuroMillionDraw {
  final DateTime date;
  final int drawId;
  final bool hasWinner;
  final int id;
  final List<String> numbers;
  final double prize;
  final List<String> stars;

  EuroMillionDraw({
    required this.date,
    required this.drawId,
    required this.hasWinner,
    required this.id,
    required this.numbers,
    required this.prize,
    required this.stars,
  });

  factory EuroMillionDraw.fromJson(Map<String, dynamic> json) {
    return EuroMillionDraw(
      date: DateFormat('E, d MMM yyyy HH:mm:ss z').parse(json['date']),
      drawId: json['draw_id'],
      hasWinner: json['has_winner'],
      id: json['id'],
      numbers: List<String>.from(json['numbers']),
      prize: json['prize'],
      stars: List<String>.from(json['stars']),
    );
  }
}

class EuroMillionScreen extends StatefulWidget {
  const EuroMillionScreen({super.key});

  @override
  _EuroMillionScreenState createState() => _EuroMillionScreenState();
}

class _EuroMillionScreenState extends State<EuroMillionScreen> {
  List<EuroMillionDraw> draws = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('https://euromillions.api.pedromealha.dev/draws'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      final List<EuroMillionDraw> euroMillionDraws = jsonData.map((data) {
        DateTime date = DateFormat('E, d MMM yyyy HH:mm:ss z').parse(data['date']);
        return EuroMillionDraw(
          date: date,
          drawId: data['draw_id'],
          hasWinner: data['has_winner'],
          id: data['id'],
          numbers: List<String>.from(data['numbers']),
          prize: data['prize'],
          stars: List<String>.from(data['stars']),
        );
      }).toList();

      euroMillionDraws.sort((a, b) => b.date.compareTo(a.date));

      setState(() {
        draws = euroMillionDraws;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: ListView.builder(
        itemCount: draws.length,
        itemBuilder: (context, index) {
          final draw = draws[index];
          return ListTile(
            title: Text('Tirage du ${draw.date}'),
            subtitle: Text(
                'Numéros: ${draw.numbers.join(", ")} | Étoiles: ${draw.stars.join(", ")}'),
            trailing: Text('Gain: ${draw.prize.toStringAsFixed(2)} €'),
          );
        },
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EuroMillion Numbers',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const EuroMillionScreen(),
    );
  }
}
