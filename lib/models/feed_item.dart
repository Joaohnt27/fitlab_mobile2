enum FeedType { run, achievement, territory, milestone }

class FeedItem {
  final int id;
  final FeedType type;
  final String userName;
  final String userAvatar;
  final String timestamp;
  final String title;
  final String? description;
  final Map<String, String>? stats;
  final Map<String, String>? badge;
  final int likes;
  final int comments;

  FeedItem({
    required this.id,
    required this.type,
    required this.userName,
    required this.userAvatar,
    required this.timestamp,
    required this.title,
    this.description,
    this.stats,
    this.badge,
    required this.likes,
    required this.comments,
  });
}
