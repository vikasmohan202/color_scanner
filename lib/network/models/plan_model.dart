class SubscriptionPlan {
  final String id;
  final String planName;
  final String billingCycle;
  final double planPrice;
  final bool activeStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  SubscriptionPlan({
    required this.id,
    required this.planName,
    required this.billingCycle,
    required this.planPrice,
    required this.activeStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['_id'] ?? '',
      planName: json['planName'] ?? '',
      billingCycle: json['billingCycle'] ?? '',
      planPrice: (json['planPrice'] ?? 0).toDouble(),
      activeStatus: json['activeStatus'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      v: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'planName': planName,
      'billingCycle': billingCycle,
      'planPrice': planPrice,
      'activeStatus': activeStatus,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,
    };
  }
}
