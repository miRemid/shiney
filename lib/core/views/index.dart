import 'package:flutter/material.dart';
import 'package:shiney/core/client/model.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:shiney/core/global/global.dart' show client;

class IndexView extends StatefulWidget {
  IndexView({Key key}) : super(key: key);

  @override
  _IndexView createState() => _IndexView();
}

class _IndexView extends State<IndexView> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Shiney"),
      ),
      body: HomeContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {
          print("Click btn")
        },
        tooltip: "Hellooooooooooooooo",
        child: const Icon(Icons.add, size: 45,),
      ),
    );
  }
}

class HomeContent extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      child: Text("Index Page"),
    );
  }
}