class FraudTip {
  final String title;
  final String description;
  final String source;

  FraudTip(
      {required this.title, required this.description, required this.source});

  factory FraudTip.fromJson(Map<String, dynamic> json) {
    return FraudTip(
      title: json['title'],
      description: json['description'],
      source: json['source'],
    );
  }
}
