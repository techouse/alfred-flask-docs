// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchResult _$SearchResultFromJson(Map<String, dynamic> json) => SearchResult(
      objectID: json['objectID'] as String,
      id: json['id'] as String,
      title: json['title'] as String,
      permalink: json['permalink'] as String,
      default_: json['default_'] as String,
      content: json['content'] as String,
    );

Map<String, dynamic> _$SearchResultToJson(SearchResult instance) =>
    <String, dynamic>{
      'objectID': instance.objectID,
      'id': instance.id,
      'title': instance.title,
      'permalink': instance.permalink,
      'default_': instance.default_,
      'content': instance.content,
    };
