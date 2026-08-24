import 'blocked_site.dart';

class AppStatus {
  final bool setupCompleted;
  final bool isProduction;
  final int siteDays;
  final int appDays;
  final bool adultBlock;
  final int appReqTime;
  final int appRemaining;
  final int productionStartTime;
  final List<BlockedSite> blockedSites;

  AppStatus({
    this.setupCompleted = false,
    this.isProduction = true,
    this.siteDays = 14,
    this.appDays = 30,
    this.adultBlock = true,
    this.appReqTime = 0,
    this.appRemaining = 0,
    this.productionStartTime = 0,
    List<BlockedSite>? blockedSites,
  }) : blockedSites = blockedSites ?? [];

  Map<String, dynamic> toJson() => {
        'setupCompleted': setupCompleted,
        'isProduction': isProduction,
        'siteDays': siteDays,
        'appDays': appDays,
        'adultBlock': adultBlock,
        'appReqTime': appReqTime,
        'appRemaining': appRemaining,
        'productionStartTime': productionStartTime,
        'blockedSites': blockedSites.map((s) => s.toJson()).toList(),
      };

  factory AppStatus.fromJson(Map<String, dynamic> json) {
    var rawSites = json['blockedSites'] as List? ?? [];
    return AppStatus(
      setupCompleted: json['setupCompleted'] ?? false,
      isProduction: json['isProduction'] ?? true,
      siteDays: json['siteDays'] ?? 14,
      appDays: json['appDays'] ?? 30,
      adultBlock: json['adultBlock'] ?? true,
      appReqTime: json['appReqTime'] ?? 0,
      appRemaining: json['appRemaining'] ?? 0,
      productionStartTime: json['productionStartTime'] ?? 0,
      blockedSites: rawSites.map((e) => BlockedSite.fromJson(Map<String, dynamic>.from(e))).toList(),
    );
  }
}
