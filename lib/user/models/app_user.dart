class AppUser {
  final String uid;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? gender;
  final String? dob;
  final String? height; // lưu dạng string cho đơn giản
  final String? weight;
  final String? goal;
  final String? displayName;


  AppUser({
    required this.uid,
    this.email,
    this.firstName,
    this.lastName,
    this.gender,
    this.dob,
    this.height,
    this.weight,
    this.goal,
    this.displayName,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'] ?? '',
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      gender: json['gender'],
      dob: json['dob'],
      height: json['height']?.toString(),
      weight: json['weight']?.toString(),
      goal: json['goal'],
      displayName: json['displayName'],

    );
  }
  AppUser copyWith({
    String? uid,
    String? email,
    String? firstName,
    String? lastName,
    String? gender,
    String? dob,
    String? weight,
    String? height,
    String? goal,
    String? displayName,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      goal: goal ?? this.goal,
      displayName: displayName ?? this.displayName,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'dob': dob,
      'height': height,
      'weight': weight,
      'goal': goal,
      'displayName': displayName,
    };
  }

  /// Dùng để check đã đủ thông tin CompleteProfile chưa
  bool get isProfileCompleted {
    return (gender ?? '').trim().isNotEmpty &&
        (dob ?? '').trim().isNotEmpty &&
        (height ?? '').trim().isNotEmpty &&
        (weight ?? '').trim().isNotEmpty;
  }
}
