part of 'main.dart';

final AlfredWorkflow _workflow = AlfredWorkflow()
  ..disableAlfredSmartResultOrdering = true;

final AlfredUpdater _updater = AlfredUpdater(
  githubRepositoryUrl: Uri.parse(Env.githubRepositoryUrl),
  currentVersion: Env.appVersion,
  updateInterval: Duration(days: 7),
);

const _updateItem = AlfredItem(
  title: 'Auto-Update available!',
  subtitle: 'Press <enter> to auto-update to a new version of this workflow.',
  arg: 'update:workflow',
  match:
      'Auto-Update available! Press <enter> to auto-update to a new version of this workflow.',
  icon: AlfredItemIcon(path: 'alfredhatcog.png'),
  valid: true,
);

void _showPlaceholder() {
  _workflow.addItem(
    const AlfredItem(
      title: 'Search the Flask docs...',
      icon: AlfredItemIcon(path: 'icon.png'),
    ),
  );
}

Future<void> _performSearch(String query, {String? version}) async {
  try {
    final SearchResponse searchResponse = await AlgoliaSearch.query(
      query,
      version: version,
    );

    if (searchResponse.nbHits > 0) {
      final AlfredItems items = AlfredItems(
        searchResponse.hits
            .map((Hit hit) => SearchResult.fromJson(
                <String, dynamic>{...hit, 'objectID': hit.objectID}))
            .map(
              (result) => AlfredItem(
                uid: result.objectID,
                title: result.id,
                subtitle: result.content.truncate(75),
                arg: result.permalink,
                text: AlfredItemText(
                  largeType: result.title,
                  copy: result.permalink,
                ),
                quickLookUrl: result.permalink,
                icon: AlfredItemIcon(path: 'icon.png'),
                valid: true,
              ),
            )
            .toList(),
      );
      _workflow.addItems(items.items);
    } else {
      final Uri url =
          Uri.https('www.google.com', '/search', {'q': 'Flask $query'});

      _workflow.addItem(
        AlfredItem(
          title: 'No matching answers found',
          subtitle: 'Shall I try and search Google?',
          arg: url.toString(),
          text: AlfredItemText(
            copy: url.toString(),
          ),
          quickLookUrl: url.toString(),
          icon: AlfredItemIcon(path: 'google.png'),
          valid: true,
        ),
      );
    }
  } finally {
    AlgoliaSearch.dispose();
  }
}
