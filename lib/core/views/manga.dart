import 'package:flutter/material.dart';
import 'package:shiney/core/client/model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shiney/core/database/database.dart';
import 'package:shiney/core/global/global.dart' show client;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shiney/core/style/size_config.dart';

class MangaView extends StatefulWidget {
  final String url;
  final String next;
  final String prev;
  MangaView({
    Key key,
    @required this.url,
    @required this.next,
    @required this.prev,
  }) : super(key: key);

  @override
  _MangaView createState() => _MangaView(url: url, next: next, prev: prev);
}

class _MangaView extends State<MangaView> {
  final String url;
  final String next;
  final String prev;
  _MangaView({
    @required this.url,
    @required this.next,
    @required this.prev,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HomeContent(url: url),
      backgroundColor: Colors.black,
    );
  }
}

class HomeContent extends StatelessWidget {
  final String url;

  HomeContent({Key key, @required this.url});

  Future<List<Widget>> _getUrls(String href) async {
    // 1. check database
    List<Widget> widgets = new List();
    List<ImageItem> list = await DBProvider.db.getImages(href);
    if (list.isEmpty) {
      ImgResponse res = await client.getChapterImages(href);
      res.data.forEach((element)  {
        DBProvider.db.insertImage(href, element);
        widgets.add(CachedNetworkImage(imageUrl: element,fit: BoxFit.fitWidth,));
      });
    } else {
      list.forEach((element) {
        widgets.add(CachedNetworkImage(imageUrl: element.url));
      });
    }
    return widgets;
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

  Widget _createListView(BuildContext context, AsyncSnapshot snapshot) {
    //数据处理
    var data = snapshot.data;
    List<Widget> listData = (data as List).cast();
    return CarouselSlider(
        items: listData,
        options: CarouselOptions(
          autoPlay: false,
          height: SizeConfig.screenHeight,
          enlargeCenterPage: false,
          viewportFraction: 1,
          initialPage: 0,
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return FutureBuilder(
      future: this._getUrls(url),
      builder: this._buildFuture,
    );
  }
}
