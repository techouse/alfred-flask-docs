class Config {
  Config._();

  static const String version = '2.1.1';
  static final Uri githubRepositoryUrl =
      Uri.https('github.com', '/techouse/alfred-flask-docs');
  static const String algoliaApplicationId = 'WODHKE4WZG';
  static const String algoliaSearchOnlyApiKey =
      '7456cdd91ba8d4f87846549697397759';
  static const String algoliaSearchIndex = 'flask';
  static const List<String> supportedVersions = [
    'v0.12',
    'v1',
    'v1.1',
    'v2',
    'v2.1',
    'v2.2',
  ];
}
