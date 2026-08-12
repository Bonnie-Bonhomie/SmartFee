class UserProfile {
  String fullName;
  String studentName;
  String className;
  String? email;
  String? phone;

  UserProfile({
    required this.fullName,
    required this.studentName,
    required this.className,
    this.email,
    this.phone,
  });

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'studentName': studentName,
        'className': className,
        'email': email,
        'phone': phone,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        fullName: json['fullName'] as String? ?? '',
        studentName: json['studentName'] as String? ?? '',
        className: json['className'] as String? ?? '',
        email: json['email'] as String?,
        phone: json['phone'] as String?,
      );
}
