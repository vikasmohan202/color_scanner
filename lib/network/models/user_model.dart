class UserModel {
  final String id;
  final String name;
  final String email;
  final String phoneNo;
  final String profile;
  final String scans;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNo,
    required this.profile,
    required this.scans,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNo: json['phoneNo'] ?? '',
      profile: json['profile'] ?? '',
      scans: json['scans'].toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'phoneNo': phoneNo,
      'profile': profile,
    };
  }
}
