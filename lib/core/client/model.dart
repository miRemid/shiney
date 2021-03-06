import 'package:meta/meta.dart';
import 'dart:convert';

class MangItem {
  String cover = "";
  String href = "";
  String title = "";
  List<String> tags;
  String content;
  String author;

  MangItem(this.cover, this.href, this.title, this.tags);
}

class MangDetail {
  String state;
  String latestUpload;
  String latestHref;
  List<MangDetailItem> items;
  MangDetailInfo info;
}

class MangDetailItem {
  String href;
  String text;
}

class MangDetailInfo {
  String title;
  String stars;
  List<String> authors;
  String state;
  List<String> tags;
  String cover;
  String content;
}

class MangSearch {
  int total;
  List<MangSearchItem> items;
}

class MangSearchItem {
  String cover;
  String title;
  String chapter;
  String href;
}

ImgResponse imgResponseFromJson(String str) => ImgResponse.fromJson(json.decode(str));

String welcomeToJson(ImgResponse data) => json.encode(data.toJson());

class ImgResponse{
  ImgResponse({
    @required this.code,
    @required this.data,
    this.messgae,
  });

  int code;
  List<String> data;
  String messgae;

  factory ImgResponse.fromJson(String str) => ImgResponse.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ImgResponse.fromMap(Map<String, dynamic> json) => ImgResponse(
    code: json["code"],
    data: List<String>.from(json["images"].map((x) => x)),
    messgae: json["error"],
  );

  Map<String, dynamic> toMap() => {
    "code": code,
    "data": List<dynamic>.from(data.map((x) => x)),
    "messgae": messgae,
  };
}

