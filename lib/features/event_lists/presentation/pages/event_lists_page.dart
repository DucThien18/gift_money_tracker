import 'package:flutter/material.dart';

class EventListsPage extends StatelessWidget {
  const EventListsPage({super.key});

  static const String routeName = '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gift Money Tracker')),
      body: const Center(child: Text('Phase 1 Foundation Ready')),
    );
  }
}
