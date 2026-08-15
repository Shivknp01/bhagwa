class Deity {
  final String id;
  final String name;
  final String title;
  final String symbol;
  final String icon;
  final String backgroundGradient;

  const Deity({
    required this.id,
    required this.name,
    required this.title,
    required this.symbol,
    required this.icon,
    this.backgroundGradient = 'saffron',
  });
}
