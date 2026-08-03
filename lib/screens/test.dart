import 'package:flutter/material.dart';

/// Dev-only dropdown playground (not routed in production).
class PlaygroundDropdownScreen extends StatefulWidget {
  const PlaygroundDropdownScreen({super.key});

  @override
  State<PlaygroundDropdownScreen> createState() => _PlaygroundDropdownScreenState();
}

class _PlaygroundDropdownScreenState extends State<PlaygroundDropdownScreen> {
  String dropdownValue = 'Ongoing';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DropdownButton<String>(
        value: dropdownValue,
        icon: const Icon(Icons.menu),
        style: const TextStyle(color: Colors.white),
        underline: Container(
          height: 2,
          color: Colors.white,
        ),
        onChanged: (String? newValue) {
          setState(() {
            dropdownValue = newValue!;
          });
        },
        items: const [
          DropdownMenuItem<String>(
            value: 'Ongoing',
            child: Text('Ongoing'),
          ),
          DropdownMenuItem<String>(
            value: 'Expired',
            child: Text('Expired'),
          ),
        ],
      ),
    );
  }
}
