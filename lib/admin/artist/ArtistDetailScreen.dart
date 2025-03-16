import 'package:flutter/material.dart';

class ArtistDetailScreen extends StatelessWidget {
  final Map<String, dynamic> customer;

  ArtistDetailScreen({required this.customer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(customer['name'])),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${customer['email']}', style: TextStyle(fontSize: 16)),
            Text('Phone: ${customer['phone']}', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}