class Repository {
  final String name;
  final String description;
  final String updatedAt;
  final String defaultBranch;
  final int forksCount;
  final int stargazersCount;
  final String language;

  Repository({
    required this.name,
    required this.description,
    required this.updatedAt,
    required this.defaultBranch,
    required this.forksCount,
    required this.stargazersCount,
    required this.language,
  });
}