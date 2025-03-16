import 'package:flutter/material.dart';
import 'package:flutter_supabase_independent_music_streaming/widgets/CustomDrawer.dart';

class AdminDashboard extends StatefulWidget {

  final String title;

  const AdminDashboard({super.key, required this.title});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      drawer: CustomDrawer(parentContext: context),
      body: Center(
        child: Text(widget.title),
      ),
    );
  }
}
