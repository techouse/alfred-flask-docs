import 'package:algolia/algolia.dart' show Algolia, AlgoliaQuerySnapshot;

import '../constants/config.dart';
import '../models/search_result.dart';

class AlgoliaSearch {
  AlgoliaSearch._();

  static final Algolia _algolia = Algolia.init(
    applicationId: Config.algoliaApplicationId,
    apiKey: Config.algoliaSearchOnlyApiKey,
  );

  static Future<AlgoliaQuerySnapshot> query(
    String queryString, {
    String? version,
  }) async =>
      _algolia.instance
          .index(Config.algoliaSearchIndex)
          .query(queryString)
          .facetFilter(
            'version:${(version ?? Config.supportedVersions.last).replaceAll('v', '')}',
          )
          .setAttributesToRetrieve(SearchResult.attributesToRetrieve)
          .setDistinct(value: 1)
          .setPage(0)
          .setHitsPerPage(20)
          .getObjects();
}