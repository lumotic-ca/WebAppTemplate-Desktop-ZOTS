class SavedConnection {
  const SavedConnection({
    required this.id,
    required this.displayName,
    required this.url,
    this.lastUsedAt,
  });

  final String id;
  final String displayName;
  final String url;
  final DateTime? lastUsedAt;

  SavedConnection copyWith({
    String? displayName,
    String? url,
    DateTime? lastUsedAt,
  }) {
    return SavedConnection(
      id: id,
      displayName: displayName ?? this.displayName,
      url: url ?? this.url,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'url': url,
      'lastUsedAt': lastUsedAt?.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    return other is SavedConnection &&
        other.id == id &&
        other.displayName == displayName &&
        other.url == url &&
        other.lastUsedAt == lastUsedAt;
  }

  @override
  int get hashCode => Object.hash(id, displayName, url, lastUsedAt);

  factory SavedConnection.fromJson(Map<String, dynamic> json) {
    return SavedConnection(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      url: json['url'] as String,
      lastUsedAt: json['lastUsedAt'] != null
          ? DateTime.tryParse(json['lastUsedAt'] as String)
          : null,
    );
  }
}
