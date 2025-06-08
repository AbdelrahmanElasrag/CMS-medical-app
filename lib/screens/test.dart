import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class test extends StatefulWidget {
  const test({super.key});


  @override
  State<test> createState() => _testState();
}

class _testState extends State<test> {
  String dropdownValue = 'ongoing';
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
        onChanged: (String? newValue){
          setState(() {
            dropdownValue = newValue!;
          });
        },
        items: const[
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
