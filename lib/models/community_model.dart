enum Trend { up, down, same }

class RankingUser {
  final int id;
  final String name;
  final String avatar;
  final int territories;
  final int defended;
  final int captured;
  final Trend trend;
  final int rank;

  RankingUser({
    required this.id, required this.name, required this.avatar,
    required this.territories, required this.defended,
    required this.captured, required this.trend, required this.rank,
  });
}

class Friend {
  final int id;
  final String name;
  final String avatar;
  final bool isOnline;
  final int territories;

  Friend({required this.id, required this.name, required this.avatar, required this.isOnline, required this.territories});
}