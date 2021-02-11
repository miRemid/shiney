import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:shiney/core/client/model.dart';
import 'package:shiney/core/style/font.dart' as font;
import 'package:shiney/core/style/size_config.dart' as size;
import 'package:shiney/core/router/router.dart' as router;
import 'package:shiney/core/global/global.dart';
import 'package:cached_network_image/cached_network_image.dart';


class DetailView extends StatefulWidget {
  final String href;

  DetailView({
    Key key,
    @required this.href,
  }) : super(key: key);

  @override
  _DetailView createState() => _DetailView(href: href);
}

class _DetailView extends State<DetailView> {
  final String href;

  _DetailView({
    @required this.href,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: DetailContent(href: href),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          "Detail",
          style: TextStyle(color: Colors.black),
        ),
        actions: [],
      ),
    );
  }
}

class DetailContent extends StatelessWidget {
  final String href;

  DetailContent({
    Key key,
    @required this.href,
  }) : super(key: key);

  Future<MangDetail> _getData() async {
    Future<MangDetail> detail = client.getMangaDetailInfo(href);
    return detail;
  }

  Widget _buildFuture(BuildContext context, AsyncSnapshot snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.none:
        return Text('还没开始网络请求');
      case ConnectionState.active:
        return Center(
          child: Text("正在获取漫画信息..."),
        );
      case ConnectionState.waiting:
        return Center(
          child: Text("正在获取漫画信息..."),
        );
      case ConnectionState.done:
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');
        return _createView(context, snapshot);
      default:
        return null;
    }
  }

  List<Widget> _buildList(BuildContext context, MangDetail detail) {
    List<Widget> res = new List();
    for (int index = 0; index < detail.items.length; index++) {
      String href = detail.items[index].href;
      String prev, next;
      if (detail.items.length == 1) {
        prev = href;
        next = href;
      } else if (index == 0) {
        prev = href;
        next = detail.items[index+1].href;
      } else if (index == detail.items.length - 1) {
        prev = detail.items[index-1].href;
        next = href;
      } else {
        prev = detail.items[index-1].href;
        next = detail.items[index+1].href;
      }
      res.add(InkWell(
        onTap: (){
          List<String> args = new List();
          args.add(href);
          args.add(next);
          args.add(prev);
          Navigator.pushNamed(context, router.MangaRouter, arguments: args);
        },
        child: Container(
          width: 150,
          height: 80,
          decoration: BoxDecoration(
              border: Border.all(color: Color.fromRGBO(246, 177, 177, 0.3))
          ),
          padding: EdgeInsets.all(5),
          child: Center(
            child: Text(detail.items[index].text,overflow: TextOverflow.ellipsis,),
          ),
        ),
      ));
    }
    return res;
  }

  Widget _createView(BuildContext context, AsyncSnapshot snapshot) {
    var data = snapshot.data;
    MangDetail detail = (data as MangDetail);

    return SafeArea(
        child: Center(
      child: Column(
        children: [
          // 1. Cover, Title and Content
          Container(
            width: size.SizeConfig.screenWidth * 0.9,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 1), // changes position of shadow
                ),
              ],
            ),
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: detail.info.cover,
                    )),
                SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        detail.info.title,
                        style: font.titleStyle,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Expanded(
                          child: SingleChildScrollView(
                        child: Text(detail.info.content),
                      ))
                    ],
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 5 / 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                padding: EdgeInsets.all(10),
                children: this._buildList(context, detail),
              ),
            )
          ),
          // 2. Item List
        ],
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    // 1. get data
    return FutureBuilder(
      future: this._getData(),
      builder: this._buildFuture,
    );
  }
}
