import 'dart:async';
import '../models/profile.dart';

class ProfileService {
  Future<Profile> fetchProfile({bool simulateError = false}) async {
    try {
      await Future.delayed(const Duration(seconds: 2));

      if (simulateError) {
        throw Exception('Network error: Unable to retrieve profile data.');
      }

      return const Profile(
        name: 'Yahyah Odin',
        role: 'Student',
        email: 'ysodin@addu.edu.ph',
        bio:
            'I am a BS Computer Science Student from Davao City, Philippines. puede nang mangarap',
        location: 'Davao City, Philippines',
      );
    } catch (e) {
      rethrow;
    }
  }
}
