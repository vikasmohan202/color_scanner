class SubscriptionModel {
  final String id;
  final String user;
  final Plan plan;
  final String startDate;
  final bool isActive;
  final bool preExpireNotificationSent;
  final String endDate;
  final String createdAt;
  final String updatedAt;
  final int v;

  SubscriptionModel({
    required this.id,
    required this.user,
    required this.plan,
    required this.startDate,
    required this.isActive,
    required this.preExpireNotificationSent,
    required this.endDate,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['_id'] ?? '',
      user: json['user'] ?? '',
      plan: Plan.fromJson(json['plan'] ?? {}),
      startDate: json['startDate'] ?? '',
      isActive: json['isActive'] ?? false,
      preExpireNotificationSent:
          json['preExpireNotificationSent'] ?? false,
      endDate: json['endDate'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      v: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': user,
      'plan': plan.toJson(),
      'startDate': startDate,
      'isActive': isActive,
      'preExpireNotificationSent': preExpireNotificationSent,
      'endDate': endDate,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
    };
  }
}

class Plan {
  final String id;
  final String planName;
  final int planPrice;

  Plan({
    required this.id,
    required this.planName,
    required this.planPrice,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['_id'] ?? '',
      planName: json['planName'] ?? '',
      planPrice: json['planPrice'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'planName': planName,
      'planPrice': planPrice,
    };
  }
}
