import 'package:flutter/material.dart';

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
        primarySwatch: Colors.blue,
      ),
      home: const Form1Page(),
    );
  }
}

class Form1Page extends StatefulWidget {
  const Form1Page({Key? key}) : super(key: key);

  @override
  State<Form1Page> createState() => _Form1PageState();
}

class _Form1PageState extends State<Form1Page> {
  final _emailFieldKey = GlobalKey<FormFieldState>();

  /*
  Issue:
  1. Cannot dynamically change error text, such as need call api to check email is valid or not.
  2. Cannot control error widget position, such as need show error text below the input field.
   */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 200,
          height: 250,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ColoredBox(
                color: Colors.transparent,
                child: TextFormField(
                  // error
                  key: _emailFieldKey,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    label: ColoredBox(
                      color: Colors.yellow,
                      child: Text('Enter your email'),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
              ),
              TextButton(
                onPressed: () {
                  _emailFieldKey.currentState?.reset();
                },
                child: const Text('Reset'),
              ),
              TextButton(
                onPressed: () {
                  _emailFieldKey.currentState?.validate();
                },
                child: const Text('validate'),
              ),
              TextButton(
                onPressed: () {
                  _emailFieldKey.currentState?.save();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content:
                        Text('Saved ${_emailFieldKey.currentState?.value}'),
                  ));
                },
                child: const Text('Saved'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
