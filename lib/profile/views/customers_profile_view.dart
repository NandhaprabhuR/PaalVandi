import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_navigation.dart';
import '../../core/app_route_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodels/customers_profile_viewmodel.dart';
import '../../theme/customers_login_themeview.dart';
import '../../core/widgets/responsive_helper.dart';

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
    required BuildContext context,
    required String hint,
    required Function(String) onChanged,
    required double Function(double) scaleF,
    required double Function(double) fs,
    TextEditingController? controller,
    bool isReadOnly = false,
    String? initialValue,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: scaleF(16)),
      decoration: BoxDecoration(
        border: Border.all(color: CustomersLoginThemeView.primaryBlue.withOpacity(0.5), width: 1.5),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: initialValue != null && isReadOnly
          ? Padding(
              padding: EdgeInsets.symmetric(horizontal: scaleF(16), vertical: scaleF(16)),
              child: Text(
                initialValue,
                style: TextStyle(fontSize: fs(16), color: CustomersLoginThemeView.textDark),
              ),
            )
          : TextField(
              controller: controller,
              readOnly: isReadOnly,
              keyboardType: keyboardType,
              style: TextStyle(fontSize: fs(16), color: CustomersLoginThemeView.textDark),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: CustomersLoginThemeView.hintStyle.copyWith(fontSize: fs(14)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: scaleF(16), vertical: scaleF(16)),
              ),
              onChanged: onChanged,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scaleF = (double val) => ResponsiveHelper.scaledValue(context, val);
    final fs = (double size) => ResponsiveHelper.scaledFontSize(context, size);
    final hPadding = ResponsiveHelper.horizontalPadding(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: CustomersLoginThemeView.primaryBlue),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              AppRouteStorage.clearSession();
              context.goPersist('/login');
            }
          },
        ),
        title: Text(
          'Complete Profile',
          style: CustomersLoginThemeView.brandTitleStyle.copyWith(
            fontSize: fs(22),
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<CustomersProfileViewModel, CustomersProfileState>(
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
                    padding: EdgeInsets.symmetric(horizontal: hPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: scaleF(16)),
                        Text(
                          'Set up your delivery details gently.',
                          style: CustomersLoginThemeView.subtitleStyle.copyWith(
                            fontSize: fs(14),
                          ),
                        ),
                        SizedBox(height: scaleF(20)),
                          Text(
                            'Personal Info',
                            style: GoogleFonts.montserrat(
                              fontSize: fs(16),
                              fontWeight: FontWeight.bold,
                              color: CustomersLoginThemeView.primaryBlue,
                            ),
                          ),
                          SizedBox(height: scaleF(12)),
                          _buildTextField(
                            context: context,
                            hint: 'Full Name',
                            controller: _nameController,
                            scaleF: scaleF,
                            fs: fs,
                            onChanged: (value) => context.read<CustomersProfileViewModel>().add(ProfileFieldChanged(name: value)),
                          ),
                          SizedBox(height: scaleF(16)),
                          Text(
                            'Delivery Address',
                            style: GoogleFonts.montserrat(
                              fontSize: fs(16),
                              fontWeight: FontWeight.bold,
                              color: CustomersLoginThemeView.primaryBlue,
                            ),
                          ),
                          SizedBox(height: scaleF(12)),
                          _buildTextField(
                            context: context,
                            hint: 'House / Flat No (Example: B-302)',
                            controller: _houseNoController,
                            scaleF: scaleF,
                            fs: fs,
                            onChanged: (value) => context.read<CustomersProfileViewModel>().add(ProfileFieldChanged(houseNo: value)),
                          ),
                          _buildTextField(
                            context: context,
                            hint: 'Apartment / Building Name',
                            controller: _apartmentController,
                            scaleF: scaleF,
                            fs: fs,
                            onChanged: (value) => context.read<CustomersProfileViewModel>().add(ProfileFieldChanged(apartmentName: value)),
                          ),
                          _buildTextField(
                            context: context,
                            hint: 'Street / Area (Example: Vadavalli)',
                            controller: _streetController,
                            scaleF: scaleF,
                            fs: fs,
                            onChanged: (value) => context.read<CustomersProfileViewModel>().add(ProfileFieldChanged(street: value)),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  context: context,
                                  hint: 'City',
                                  initialValue: 'Coimbatore',
                                  isReadOnly: true,
                                  scaleF: scaleF,
                                  fs: fs,
                                  onChanged: (_) {},
                                ),
                              ),
                              SizedBox(width: scaleF(16)),
                              Expanded(
                                child: _buildTextField(
                                  context: context,
                                  hint: 'Pincode',
                                  controller: _pincodeController,
                                  keyboardType: TextInputType.number,
                                  scaleF: scaleF,
                                  fs: fs,
                                  onChanged: (value) => context.read<CustomersProfileViewModel>().add(ProfileFieldChanged(pincode: value)),
                                ),
                              ),
                            ],
                          ),
                          
                          // Display fetched location if available
                          if (state.model.fetchedLocation.isNotEmpty)
                            Container(
                              margin: EdgeInsets.only(bottom: scaleF(12)),
                              padding: EdgeInsets.symmetric(horizontal: scaleF(16), vertical: scaleF(12)),
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
                                        fontSize: fs(12),
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
                            height: scaleF(50).clamp(44.0, 56.0),
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: CustomersLoginThemeView.primaryBlue, width: 1.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                backgroundColor: CustomersLoginThemeView.primaryBlue.withOpacity(0.05),
                              ),
                              onPressed: () {
                                context.read<CustomersProfileViewModel>().add(const ProfileFetchLocationRequested());
                              },
                              icon: Icon(Icons.my_location, size: scaleF(20), color: CustomersLoginThemeView.primaryBlue),
                              label: Text(
                                state.model.fetchedLocation.isEmpty ? 'Fetch Map Location' : 'Refresh Map Location',
                                style: GoogleFonts.montserrat(
                                  fontSize: fs(14),
                                  fontWeight: FontWeight.bold,
                                  color: CustomersLoginThemeView.primaryBlue,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: scaleF(24)),
                          Text(
                            'Referral',
                            style: GoogleFonts.montserrat(
                              fontSize: fs(16),
                              fontWeight: FontWeight.bold,
                              color: CustomersLoginThemeView.primaryBlue,
                            ),
                          ),
                          SizedBox(height: scaleF(12)),
                          _buildTextField(
                            context: context,
                            hint: 'Referral Code (Optional)',
                            controller: _referralController,
                            scaleF: scaleF,
                            fs: fs,
                            onChanged: (value) => context.read<CustomersProfileViewModel>().add(ProfileFieldChanged(referralCode: value)),
                          ),
                          SizedBox(height: scaleF(24)),
                          if (state is ProfileLoading)
                            const Center(child: CircularProgressIndicator(color: CustomersLoginThemeView.primaryBlue))
                          else
                            SizedBox(
                              width: double.infinity,
                              height: scaleF(52).clamp(44.0, 60.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: CustomersLoginThemeView.primaryBlue,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  context.read<CustomersProfileViewModel>().add(ProfileSubmit());
                                },
                                child: Text(
                                  'Save & Go to Home',
                                  style: CustomersLoginThemeView.buttonTextStyle.copyWith(
                                    fontSize: fs(15),
                                  ),
                                ),
                              ),
                            ),
                          SizedBox(height: scaleF(32)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }
  }
