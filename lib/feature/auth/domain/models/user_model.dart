import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String? email;
  final String? displayName;
  final String? phoneNumber;
  final String? photoURL;
  final String? fcmToken;
  final String role;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isEmailVerified;
  
  // New personal information fields
  final String? streetAddress;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? dateOfBirth;

  UserModel({
    required this.uid,
    this.email,
    this.displayName,
    this.phoneNumber,
    this.photoURL,
    this.fcmToken,
    this.role = 'user',
    this.createdAt,
    this.updatedAt,
    this.isEmailVerified = false,
    // New fields with default values
    this.streetAddress,
    this.city,
    this.state,
    this.zipCode,
    this.dateOfBirth,
  })  : assert(uid.isNotEmpty, 'UID cannot be empty'),
        assert(role.isNotEmpty, 'Role cannot be empty');

  // Factory method to create UserModel from Firebase User
  factory UserModel.fromFirebase(User user) {
    return UserModel(
      uid: user.uid,
      email: user.email?.isNotEmpty == true ? user.email : null,
      displayName: user.displayName?.isNotEmpty == true ? user.displayName : null,
      phoneNumber: user.phoneNumber?.isNotEmpty == true ? user.phoneNumber : null,
      photoURL: user.photoURL?.isNotEmpty == true ? user.photoURL : null,
      isEmailVerified: user.emailVerified,
      createdAt: user.metadata.creationTime,
    );
  }

  // Factory method to create UserModel from Firestore DocumentSnapshot
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      uid: doc.id,
      email: data['email']?.toString().isNotEmpty == true ? data['email']?.toString() : null,
      displayName: data['displayName']?.toString().isNotEmpty == true ? data['displayName']?.toString() : null,
      phoneNumber: data['phoneNumber']?.toString().isNotEmpty == true ? data['phoneNumber']?.toString() : null,
      photoURL: data['photoURL']?.toString().isNotEmpty == true ? data['photoURL']?.toString() : null,
      fcmToken: data['fcmToken']?.toString().isNotEmpty == true ? data['fcmToken']?.toString() : null,
      role: data['role']?.toString() ?? 'user',
      createdAt: data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : null,
      updatedAt: data['updatedAt'] != null ? (data['updatedAt'] as Timestamp).toDate() : null,
      isEmailVerified: data['isEmailVerified'] ?? false,
      // New fields from Firestore
      streetAddress: data['streetAddress']?.toString().isNotEmpty == true ? data['streetAddress']?.toString() : null,
      city: data['city']?.toString().isNotEmpty == true ? data['city']?.toString() : null,
      state: data['state']?.toString().isNotEmpty == true ? data['state']?.toString() : null,
      zipCode: data['zipCode']?.toString().isNotEmpty == true ? data['zipCode']?.toString() : null,
      dateOfBirth: data['dateOfBirth']?.toString().isNotEmpty == true ? data['dateOfBirth']?.toString() : null,
    );
  }

  // Convert UserModel to Firestore data
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'photoURL': photoURL,
      'fcmToken': fcmToken,
      'role': role,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'isEmailVerified': isEmailVerified,
      // New fields to Firestore
      'streetAddress': streetAddress,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'dateOfBirth': dateOfBirth,
    };
  }

  // Create a copy of the UserModel with optional updates
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? phoneNumber,
    String? photoURL,
    String? fcmToken,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEmailVerified,
    // New fields for copyWith
    String? streetAddress,
    String? city,
    String? state,
    String? zipCode,
    String? dateOfBirth,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email?.isNotEmpty == true ? email : this.email,
      displayName: displayName?.isNotEmpty == true ? displayName : this.displayName,
      phoneNumber: phoneNumber?.isNotEmpty == true ? phoneNumber : this.phoneNumber,
      photoURL: photoURL?.isNotEmpty == true ? photoURL : this.photoURL,
      fcmToken: fcmToken?.isNotEmpty == true ? fcmToken : this.fcmToken,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      // New fields
      streetAddress: streetAddress?.isNotEmpty == true ? streetAddress : this.streetAddress,
      city: city?.isNotEmpty == true ? city : this.city,
      state: state?.isNotEmpty == true ? state : this.state,
      zipCode: zipCode?.isNotEmpty == true ? zipCode : this.zipCode,
      dateOfBirth: dateOfBirth?.isNotEmpty == true ? dateOfBirth : this.dateOfBirth,
    );
  }

  // Utility method to validate photoURL
  bool isValidPhotoURL() {
    return photoURL?.isNotEmpty == true &&
        (photoURL!.startsWith('http://') || photoURL!.startsWith('https://'));
  }

  // Utility method to check if user has complete profile
  bool get hasCompleteProfile {
    return displayName?.isNotEmpty == true &&
        phoneNumber?.isNotEmpty == true &&
        email?.isNotEmpty == true;
  }

  // Utility method to check if user has address information
  bool get hasAddressInfo {
    return streetAddress?.isNotEmpty == true &&
        city?.isNotEmpty == true &&
        state?.isNotEmpty == true &&
        zipCode?.isNotEmpty == true;
  }

  // Get formatted address
  String? get formattedAddress {
    if (!hasAddressInfo) return null;
    return '$streetAddress, $city, $state $zipCode';
  }

  // Get user initials for avatar
  String get initials {
    if (displayName?.isNotEmpty == true) {
      final names = displayName!.split(' ');
      if (names.length > 1) {
        return '${names[0][0]}${names[1][0]}'.toUpperCase();
      }
      return names[0][0].toUpperCase();
    }
    return 'U';
  }

  // Calculate age from date of birth
  int? get age {
    if (dateOfBirth == null) return null;
    try {
      final birthDate = DateTime.parse(dateOfBirth!);
      final now = DateTime.now();
      int age = now.year - birthDate.year;
      if (now.month < birthDate.month ||
          (now.month == birthDate.month && now.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return null;
    }
  }
}