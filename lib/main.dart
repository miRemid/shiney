import 'package:flutter/material.dart';
import 'core/client/client.dart';

import 'package:shiney/core/views/index.dart';

ShineyHTTPClient client = new ShineyHTTPClient();

void main() => runApp(ShineyApp());

class ShineyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Shiney",
      home: IndexView(),
      theme: ThemeData(
        primarySwatch: Colors.pink,
        appBarTheme: AppBarTheme(
            color: Colors.transparent,
            elevation: 0,
            brightness: Brightness.light
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
        )
      ),
    );
  }
}
