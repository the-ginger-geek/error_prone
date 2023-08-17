import 'package:error_prone/dropdown_item.dart';
import 'package:flutter/material.dart';

import 'custom_dropdown.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final data = ['One', 'Two', 'Three', 'Four', 'Five', 'Six'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: SizedBox(
          width: 400,
          child: CustomDropdown<String>(
            children: List.generate(
              data.length,
              (index) => DropdownItem<String>(
                key: (index + 1).toString(),
                value: data[index],
              ),
            ),
            onChanged: (item) {
              print('changed $item');
            },
            hint: 'Please Select',
          ),
        ),
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
