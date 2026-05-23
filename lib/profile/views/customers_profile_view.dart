import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_navigation.dart';
import '../../core/app_route_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodels/customers_profile_viewmodel.dart';
import '../../theme/customers_login_themeview.dart';

class CustomersProfileView extends StatefulWidget {
  const CustomersProfileView({super.key});

  @override
  State<CustomersProfileView> createState() => _CustomersProfileViewState();
}

class _CustomersProfileViewState extends State<CustomersProfileView> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _houseNoController = TextEditingController();
  final TextEditingController _apartmentController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _referralController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _houseNoController.dispose();
    _apartmentController.dispose();
    _streetController.dispose();
    _pincodeController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  Widget _buildTextField({
    required String hint,
    required Function(String) onChanged,
    TextEditingController? controller,
    bool isReadOnly = false,
    String? initialValue,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(color: CustomersLoginThemeView.primaryBlue.withOpacity(0.5), width: 1.5),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: initialValue != null && isReadOnly
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Text(
                initialValue,
                style: const TextStyle(fontSize: 16, color: CustomersLoginThemeView.textDark),
              ),
            )
          : TextField(
              controller: controller,
              readOnly: isReadOnly,
              keyboardType: keyboardType,
              style: const TextStyle(fontSize: 16, color: CustomersLoginThemeView.textDark),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: CustomersLoginThemeView.hintStyle.copyWith(fontSize: 14),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              onChanged: onChanged,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background_images/login_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: BlocConsumer<CustomersProfileViewModel, CustomersProfileState>(
          listener: (context, state) {
            if (state is ProfileSuccess) {
              context.goPersist('/home');
            } else if (state is ProfileFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            } else if (state is ProfileLocationFetched) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Live Map Location Captured Successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: CustomersLoginThemeView.textDark),
                            onPressed: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                AppRouteStorage.clearSession();
                                context.goPersist('/login');
                              }
                            },
                            padding: EdgeInsets.zero,
                            alignment: Alignment.centerLeft,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Complete Profile',
                            style: CustomersLoginThemeView.titleStyle,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Set up your delivery details gently.',
                            style: CustomersLoginThemeView.subtitleStyle,
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'Personal Info',
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: CustomersLoginThemeView.primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            hint: 'Full Name',
                            controller: _nameController,
                            onChanged: (value) => context.read<CustomersProfileViewModel>().add(ProfileFieldChanged(name: value)),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Delivery Address',
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: CustomersLoginThemeView.primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            hint: 'House / Flat No (Example: B-302)',
                            controller: _houseNoController,
                            onChanged: (value) => context.read<CustomersProfileViewModel>().add(ProfileFieldChanged(houseNo: value)),
                          ),
                          _buildTextField(
                            hint: 'Apartment / Building Name',
                            controller: _apartmentController,
                            onChanged: (value) => context.read<CustomersProfileViewModel>().add(ProfileFieldChanged(apartmentName: value)),
                          ),
                          _buildTextField(
                            hint: 'Street / Area (Example: Vadavalli)',
                            controller: _streetController,
                            onChanged: (value) => context.read<CustomersProfileViewModel>().add(ProfileFieldChanged(street: value)),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  hint: 'City',
                                  initialValue: 'Coimbatore',
                                  isReadOnly: true,
                                  onChanged: (_) {},
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  hint: 'Pincode',
                                  controller: _pincodeController,
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) => context.read<CustomersProfileViewModel>().add(ProfileFieldChanged(pincode: value)),
                                ),
                              ),
                            ],
                          ),
                          
                          // Display fetched location if available
                          if (state.model.fetchedLocation.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.05),
                                border: Border.all(color: Colors.green.withOpacity(0.5), width: 1.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Location: ${state.model.fetchedLocation}',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: CustomersLoginThemeView.primaryBlue, width: 1.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                backgroundColor: CustomersLoginThemeView.primaryBlue.withOpacity(0.05),
                              ),
                              onPressed: () {
                                context.read<CustomersProfileViewModel>().add(const ProfileFetchLocationRequested());
                              },
                              icon: const Icon(Icons.my_location, size: 20, color: CustomersLoginThemeView.primaryBlue),
                              label: Text(
                                state.model.fetchedLocation.isEmpty ? 'Fetch Map Location' : 'Refresh Map Location',
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: CustomersLoginThemeView.primaryBlue,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Referral',
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: CustomersLoginThemeView.primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            hint: 'Referral Code (Optional)',
                            controller: _referralController,
                            onChanged: (value) => context.read<CustomersProfileViewModel>().add(ProfileFieldChanged(referralCode: value)),
                          ),
                          const SizedBox(height: 32),
                          if (state is ProfileLoading)
                            const Center(child: CircularProgressIndicator(color: CustomersLoginThemeView.primaryBlue))
                          else
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: CustomersLoginThemeView.primaryBlue,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  context.read<CustomersProfileViewModel>().add(ProfileSubmit());
                                },
                                child: Text('Save & Go to Home', style: CustomersLoginThemeView.buttonTextStyle),
                              ),
                            ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
