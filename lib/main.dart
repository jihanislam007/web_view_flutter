import 'package:flutter/material.dart';

import 'WebAllView.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String _url = "https://github.com/techwithsam";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text('Flutter Webview Tutorial'),
            centerTitle: true,
            elevation: 0,
          ),
          body: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  MaterialButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WebAllView(url: _url),
                          ));
                    },
                    child: Text(
                      'Example 1',
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 70, vertical: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

