import 'dart:io' show exitCode, stdout;

import 'package:alfred_workflow/alfred_workflow.dart'
    show
        AlfredItem,
        AlfredItemIcon,
        AlfredItemText,
        AlfredItems,
        AlfredUpdater,
        AlfredWorkflow;
import 'package:algolia/algolia.dart' show AlgoliaQuerySnapshot;
import 'package:args/args.dart' show ArgParser, ArgResults;
import 'package:collection/collection.dart' show IterableExtension;

import 'src/constants/config.dart' show Config;
import 'src/extensions/string_helpers.dart' show StringHelpers;
import 'src/models/search_result.dart' show SearchResult;
import 'src/services/algolia_search.dart' show AlgoliaSearch;

final AlfredWorkflow workflow = AlfredWorkflow();
final AlfredUpdater updater = AlfredUpdater(
  githubRepositoryUrl: Config.githubRepositoryUrl,
  currentVersion: Config.version,
  updateInterval: Duration(days: 7),
);
bool verbose = false;
bool update = false;

void main(List<String> arguments) async {
  try {
    exitCode = 0;

    workflow.clearItems();

    final ArgParser parser = ArgParser()
      ..addOption('query', abbr: 'q', defaultsTo: '')
      ..addFlag('verbose', abbr: 'v', defaultsTo: false)
      ..addFlag('update', abbr: 'u', defaultsTo: false);
    final ArgResults args = parser.parse(arguments);

    update = args['update'];
    if (update) {
      stdout.writeln('Updating workflow...');

      return await updater.update();
    }

    verbose = args['verbose'];

    List<String> query =
        args['query'].replaceAll(RegExp(r'\s+'), ' ').trim().split(' ');
    String? version =
        query.firstWhereOrNull((el) => Config.supportedVersions.contains(el));
    if (version != null) {
      query.removeWhere((str) => str == version);
    } else {
      version = Config.supportedVersions.last;
    }
    final String queryString = query.join(' ').trim().toLowerCase();

    if (verbose) stdout.writeln('Query: "$queryString"');

    if (queryString.isEmpty) {
      _showPlaceholder();
    } else {
      workflow.cacheKey = '${queryString}_${version}';
      if (await workflow.getItems() == null) {
        await _performSearch(queryString, version: version);
      }
    }
  } on FormatException catch (err) {
    exitCode = 2;
    workflow.addItem(AlfredItem(title: err.toString()));
  } catch (err) {
    exitCode = 1;
    workflow.addItem(AlfredItem(title: err.toString()));
    if (verbose) rethrow;
  } finally {
    if (!update) {
      if (await updater.updateAvailable()) {
        workflow.run(addToBeginning: updateItem);
      } else {
        workflow.run();
      }
    }
  }
}

const updateItem = AlfredItem(
  title: 'Auto-Update available!',
  subtitle: 'Press <enter> to auto-update to a new version of this workflow.',
  arg: 'update:workflow',
  match:
      'Auto-Update available! Press <enter> to auto-update to a new version of this workflow.',
  icon: AlfredItemIcon(path: 'alfredhatcog.png'),
  valid: true,
);

void _showPlaceholder() {
  workflow.addItem(
    const AlfredItem(
      title: 'Search the Flask docs...',
      icon: AlfredItemIcon(path: 'icon.png'),
    ),
  );
}

Future<void> _performSearch(String query, {String? version}) async {
  final AlgoliaQuerySnapshot snapshot = await AlgoliaSearch.query(
    query,
    version: version,
  );

  if (snapshot.nbHits > 0) {
    final AlfredItems items = AlfredItems(
      snapshot.hits.map((snapshot) => SearchResult.fromJson(snapshot.data)).map(
        (result) {
          return AlfredItem(
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
          );
        },
      ).toList(),
    );
    workflow.addItems(items.items);
  } else {
    final Uri url =
        Uri.https('www.google.com', '/search', {'q': 'Flask $query'});

    workflow.addItem(
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
}
