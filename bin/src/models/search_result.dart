import 'package:json_annotation/json_annotation.dart';

part 'search_result.g.dart';

@JsonSerializable()
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

  factory SearchResult.fromJson(Map<String, dynamic> json) =>
      _$SearchResultFromJson(json);

  Map<String, dynamic> toJson() => _$SearchResultToJson(this);
}
