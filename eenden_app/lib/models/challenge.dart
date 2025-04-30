class Challenge {
  final String id;
  final String textKey; // Key for localized challenge text
  final int playerCount; // Add player count
  final int points; // Add points field

  const Challenge({
    required this.id,
    required this.textKey,
    this.playerCount = 1,
    this.points = 1 // Default points to 1
  }); // Default to 1

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'] as String,
      textKey: json['textKey'] as String,
      playerCount: json['playerCount'] as int? ?? 1, // Read from JSON, default to 1 if missing
      points: json['points'] as int? ?? 1, // Read points, default to 1 if missing
    );
  }
} 