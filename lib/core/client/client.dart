import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:shiney/core/client/model.dart';

const INDEX_URL = "http://www.mangabz.com/";
const SEARCH_URL = "http://www.mangabz.com/search";
const FUN_URL = "http://42846943-1873125947972851.test.functioncompute.com/getImages";

class ShineyHTTPClient {
  Dio _client;

  ShineyHTTPClient() {
    this._client = new Dio();
    this._client.options.headers =  {
      'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.88 Safari/537.36',
      'Accept': '*/*',
      'Accept-Encoding': 'gzip, deflate',
    };
  }

  MangItem _parseItem(Element item, String prefix) {
    String cover = item.getElementsByTagName('img')[0].attributes['src'];
    Element bind = item.getElementsByClassName(prefix + '-title')[0];
    Element a = bind.getElementsByTagName('a')[0];
    String title = a.innerHtml;
    String href = a.attributes['href'];
    List<Element> tag = item.getElementsByTagName('span');
    List<String> tags = new List<String>();
    for (Element t in tag) {
      tags.add(t.text);
    }
    return new MangItem(cover, href, title, tags);
  }

  Future<Map<String, List<MangItem>>> getIndexData() async {
    Map<String, List<MangItem>> res = new Map<String, List<MangItem>>();

    Response response = await this._client.get(INDEX_URL);
    Document document = parse(response.data);

    res['rank'] = this._getRankList(document.getElementsByClassName('rank-list')[0]);
    res['fast'] = this._getFastList(document.getElementsByClassName('carousel-right-list')[0]);

    // index-list
    List<Element> indexItemsList = document.getElementsByClassName('index-manga-list');
    res['popular'] = this._extracIndexMangaList(indexItemsList[0]);
    res['editor'] = this._extracIndexMangaList(indexItemsList[1]);
    res['boom'] = this._extracIndexMangaList(indexItemsList[2]);
    res['love'] = this._extracIndexMangaList(indexItemsList[3]);
    res['school'] = this._extracIndexMangaList(indexItemsList[4]);
    res['fantasy'] = this._extracIndexMangaList(indexItemsList[5]);
    res['science'] = this._extracIndexMangaList(indexItemsList[6]);

    return res;
  }

  List<MangItem> _getRankList(Element rankList) {
    List<MangItem> res = new List<MangItem>();
    List<Element> rankItmes = rankList.getElementsByClassName('list');
    for (Element item in rankItmes) {
      res.add(this._parseItem(item, 'rank-item'));
    }
    return res;
  }

  List<MangItem> _extracIndexMangaList(Element itemList) {
    List<MangItem> res = new List<MangItem>();
    List<Element> mangItems =
    itemList.getElementsByClassName('index-manga-item');
    for (Element item in mangItems) {
      res.add(this._parseItem(item, 'index-manga-item'));
    }
    return res;
  }

  List<MangItem> _getFastList(Element fastList) {
    String cls = 'carousel-right-item';
    List<MangItem> res = new List<MangItem>();
    List<Element> fastItems = fastList.getElementsByClassName(cls);
    for (Element item in fastItems) {
      MangItem ii = this._parseItem(item, cls);
      ii.content = item.getElementsByClassName(cls+'-content')[0].text;
      ii.author = item.getElementsByClassName(cls+'-subtitle')[0].text;
      res.add(ii);
    }
    return res;
  }

  Future<ImgResponse> getChapterImages(String url) async {
    Map<String, dynamic> map = Map();
    map["url"] = url;
    Response response = await this._client.get(FUN_URL, queryParameters: map);
    ImgResponse imgResponse = ImgResponse.fromMap(response.data);
    return imgResponse;
  }
  
  Future<ImgResponse> testResponse(String url) async {

    List<String> data = [
      "http://image.mangabz.com/1/134/160658/1_5568.jpg?cid=160658&key=7de7d47fe97e85373e3e8a5c65271e83&uk=",
      "http://image.mangabz.com/1/134/160658/2_1165.jpg?cid=160658&key=7de7d47fe97e85373e3e8a5c65271e83&uk=",
      "http://image.mangabz.com/1/134/160658/3_1630.jpg?cid=160658&key=7de7d47fe97e85373e3e8a5c65271e83&uk=",
      "http://image.mangabz.com/1/134/160658/4_1399.jpg?cid=160658&key=7de7d47fe97e85373e3e8a5c65271e83&uk=",
      "http://image.mangabz.com/1/134/160658/5_5557.jpg?cid=160658&key=7de7d47fe97e85373e3e8a5c65271e83&uk=",
      "http://image.mangabz.com/1/134/160658/6_6752.jpg?cid=160658&key=7de7d47fe97e85373e3e8a5c65271e83&uk=",
      "http://image.mangabz.com/1/134/160658/7_9261.jpg?cid=160658&key=7de7d47fe97e85373e3e8a5c65271e83&uk=",
      "http://image.mangabz.com/1/134/160658/8_6425.jpg?cid=160658&key=7de7d47fe97e85373e3e8a5c65271e83&uk=",
      "http://image.mangabz.com/1/134/160658/9_8322.jpg?cid=160658&key=7de7d47fe97e85373e3e8a5c65271e83&uk=",
      "http://image.mangabz.com/1/134/160658/10_5523.jpg?cid=160658&key=7de7d47fe97e85373e3e8a5c65271e83&uk=",
      "http://image.mangabz.com/1/134/160658/11_7717.jpg?cid=160658&key=7de7d47fe97e85373e3e8a5c65271e83&uk="
    ];
    return ImgResponse(code: 0, data: data, messgae: "null");
  }

}

main(List<String> args) {
  ShineyHTTPClient client = new ShineyHTTPClient();
  client.testResponse('url').then((ImgResponse value) => {
    print(value.data)
  });

}
