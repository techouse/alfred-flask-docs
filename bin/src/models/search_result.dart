class SearchResult {
  const SearchResult({
    required this.objectID,
    required this.id,
    required this.title,
    required this.permalink,
    required this.default_,
    required this.content,
  });

  final String objectID;
  final String id;
  final String title;
  final String permalink;
  final String default_;
  final String content;

  static const List<String> attributesToRetrieve = [
    'id',
    'title',
    'permalink',
    'default',
    'content',
  ];

  SearchResult.fromJson(Map<String, dynamic> json)
      : objectID = json['objectID'] as String,
        id = json['id'] as String,
        title = json['title'] as String,
        permalink = json['permalink'] as String,
        default_ = json['default'] as String,
        content = json['content'] as String;

  Map<String, dynamic> toJson() => {
        'objectID': objectID,
        'id': id,
        'title': title,
        'permalink': permalink,
        'default': default_,
        'content': content,
      };
}
