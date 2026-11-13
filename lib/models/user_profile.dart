/// Represents an authenticated user's profile and role in PokéMart.
///
/// Maps directly to `public.profiles` joined with `public.roles`.
class UserProfile {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final int roleId;
  final String role; // 'customer' or 'admin'

  const UserProfile({
    required this.id,
    required this.email,
    this.firstName = '',
    this.lastName = '',
    this.roleId = 1,
    this.role = 'customer',
  });

  bool get isAdmin => role.toLowerCase() == 'admin' || roleId == 2;
  bool get isCustomer => !isAdmin;

  String get fullName {
    final full = [firstName.trim(), lastName.trim()]
        .where((s) => s.isNotEmpty)
        .join(' ');
    return full;
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    String parsedRole = 'customer';
    int parsedRoleId = (json['role_id'] as num?)?.toInt() ?? 1;

    final rolesData = json['roles'];
    if (rolesData is Map<String, dynamic> && rolesData['role'] != null) {
      parsedRole = rolesData['role'].toString();
    } else if (json['role'] != null) {
      parsedRole = json['role'].toString();
    } else if (parsedRoleId == 2) {
      parsedRole = 'admin';
    }

    return UserProfile(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      firstName: json['firstname']?.toString() ?? '',
      lastName: json['lastname']?.toString() ?? '',
      roleId: parsedRoleId,
      role: parsedRole,
    );
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    int? roleId,
    String? role,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      roleId: roleId ?? this.roleId,
      role: role ?? this.role,
    );
  }
}

