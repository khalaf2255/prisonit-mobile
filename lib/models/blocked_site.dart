class BlockedSite {
  final string domain;
  final int reqTime;
  final int remainingSeconds;
  final int lockedSinceTicks;

  BlockedSite({
    required this.domain,
    this.reqTime = 0,
    this.remainingSeconds = 0,
    int? lockedSinceTicks,
  }) : lockedSinceTicks = lockedSinceTicks ?? DateTime.now().microsecondsSinceEpoch * 10;

  bool get isUnlocking => reqTime > 0 && remainingSeconds > 0;
  bool get isUnlocked => reqTime > 0 && remainingSeconds <= 0;

  Map<String, dynamic> toJson() => {
        'domain': domain,
        'reqTime': reqTime,
        'remainingSeconds': remainingSeconds,
        'lockedSinceTicks': lockedSinceTicks,
      };

  factory BlockedSite.fromJson(Map<String, dynamic> json) {
    return BlockedSite(
      domain: json['domain'] ?? '',
      reqTime: json['reqTime'] ?? 0,
      remainingSeconds: json['remainingSeconds'] ?? 0,
      lockedSinceTicks: json['lockedSinceTicks'] ?? 0,
    );
  }
}
