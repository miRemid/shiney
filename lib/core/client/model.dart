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
  String cover;
  String title;
  String chapter;
}