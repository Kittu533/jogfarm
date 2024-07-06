class UserModel {
  String uid;
  String username;
  String email;
  String password;
  String phoneNumber;
  String? firstName;
  String? lastName;
  String? address;
  DateTime? dateOfBirth;
  String? ktpNumber;
  String? ktpPicture;
  String? gender;
  String? profilePicture;
  bool? isAdmin;
  bool? isBuyer;
  bool? isSeller;
  bool? isKtpConfirmed;
  DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.password,
    required this.phoneNumber,
    this.firstName,
    this.lastName,
    this.address,
    this.dateOfBirth,
    this.ktpNumber,
    this.ktpPicture,
    this.gender,
    this.profilePicture,
    this.isAdmin,
    this.isBuyer,
    this.isSeller,
    this.isKtpConfirmed,
    this.createdAt,
  });

  UserModel.update({
    required this.uid,
    required this.username,
    required this.email,
    required this.phoneNumber,
    this.firstName,
    this.lastName,
    this.address,
    this.dateOfBirth,
    this.ktpNumber,
    this.ktpPicture,
    this.gender,
    this.profilePicture,
    this.isAdmin,
    this.isBuyer,
    this.isSeller,
    this.isKtpConfirmed,
    this.createdAt,
  }) : password = '';

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'password': password,
      'phone_number': phoneNumber,
      'first_name': firstName,
      'last_name': lastName,
      'address': address,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'ktp_number': ktpNumber,
      'ktp_picture': ktpPicture,
      'gender': gender,
      'profile_picture': profilePicture,
      'is_admin': isAdmin,
      'is_buyer': isBuyer,
      'is_seller': isSeller,
      'is_ktp_confirmed': isKtpConfirmed,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      username: map['username'],
      email: map['email'],
      password: map['password'],
      phoneNumber: map['phone_number'],
      firstName: map['first_name'],
      lastName: map['last_name'],
      address: map['address'],
      dateOfBirth: map['date_of_birth'] != null
          ? DateTime.parse(map['date_of_birth'])
          : null,
      ktpNumber: map['ktp_number'],
      ktpPicture: map['ktp_picture'],
      gender: map['gender'],
      profilePicture: map['profile_picture'],
      isAdmin: map['is_admin'],
      isBuyer: map['is_buyer'],
      isSeller: map['is_seller'],
      isKtpConfirmed: map['is_ktp_confirmed'],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
    );
  }
}
