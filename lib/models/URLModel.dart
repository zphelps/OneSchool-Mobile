class URL {
  String mime;

  String url;

  URL({this.mime = '', this.url = ''});

  factory URL.fromJson(Map<dynamic, dynamic> parsedJson) {
    return URL(mime: parsedJson['mime'] ?? '', url: parsedJson['url'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'mime': mime, 'url': url};
  }
}