import 'package:flutter/material.dart';
import 'package:shiney/core/client/model.dart';

import 'package:shiney/core/global/global.dart' show client;

class MangaView extends StatefulWidget {
  MangaView({Key key}) : super(key: key);

  @override
  _MangaView createState() => _MangaView();
}

class _MangaView extends State<MangaView> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HomeContent(),
      backgroundColor: Colors.black,
    );
  }
}

class HomeContent extends StatelessWidget{

  Future<List<Widget>> _getUrls() async {
    ImgResponse res = await client.testResponse('url');
    var tmp = res.data.map((e){
      return Image.network(e);
    });
    return tmp.toList();
  }

  Widget _buildFuture(BuildContext context, AsyncSnapshot snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.none:
        return Text('还没开始网络请求');
      case ConnectionState.active:
        return Text('ConnectionState.active');
      case ConnectionState.waiting:
        return Center(
          child: CircularProgressIndicator(),
        );
      case ConnectionState.done:
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');
        return _createListView(context, snapshot);
      default:
        return null;
    }
  }

  Widget _createListView(BuildContext context, AsyncSnapshot snapshot){
    //数据处理

    var data = snapshot.data;
    List<Image> listData = (data as List).cast();
    return ListView.builder(
      shrinkWrap: true,
      // physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return listData[index];
      },
      itemCount: listData.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return FutureBuilder(
      future: this._getUrls(),
      builder: this._buildFuture,
    );
  }
}
