import '../models/partner_model.dart';
import '../../core/constants/mock_data.dart';

/// Abstract auth repository — swap MockAuthRepository for SupabaseAuthRepository later.
abstract class AuthRepository {
  Future<bool> isPhoneApproved(String phone);
  Future<bool> sendOtp(String phone);
  Future<bool> verifyOtp(String phone, String otp);
  PartnerModel? getPartnerProfile();
}

class MockAuthRepository implements AuthRepository {
  @override
  Future<bool> isPhoneApproved(String phone) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockData.approvedPhones.contains(phone);
  }

  @override
  Future<bool> sendOtp(String phone) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return true; // Always succeed in mock
  }

  @override
  Future<bool> verifyOtp(String phone, String otp) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return otp == '123456'; // Mock OTP
  }

  @override
  PartnerModel? getPartnerProfile() {
    return MockData.partnerProfile;
  }
}
