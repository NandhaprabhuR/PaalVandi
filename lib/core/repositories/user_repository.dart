import '../../profile/models/customers_profile_model.dart';

abstract class UserRepository {
  Future<CustomersProfileModel> getProfile();
  Future<void> saveProfile(CustomersProfileModel profile);
}

class MockUserRepository implements UserRepository {
  CustomersProfileModel _cachedProfile = const CustomersProfileModel();

  @override
  Future<CustomersProfileModel> getProfile() async {
    // Simulate minor network delay
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return _cachedProfile;
  }

  @override
  Future<void> saveProfile(CustomersProfileModel profile) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _cachedProfile = profile;
  }
}
