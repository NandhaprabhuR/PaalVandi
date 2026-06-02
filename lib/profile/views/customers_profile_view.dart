import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final TextEditingController _emergencyContactController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final model = context.read<CustomersProfileViewModel>().state.model;
    _nameController.text = model.name;
    _houseNoController.text = model.houseNo;
    _apartmentController.text = model.apartmentName;
    _streetController.text = model.street;
    _pincodeController.text = model.pincode;
    _referralController.text = model.referralCode;
    _emergencyContactController.text = model.emergencyContact;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _houseNoController.dispose();
    _apartmentController.dispose();
    _streetController.dispose();
    _pincodeController.dispose();
    _referralController.dispose();
    _emergencyContactController.dispose();
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
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: scaleF(16)),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1.0),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: initialValue != null && isReadOnly
          ? Padding(
              padding: EdgeInsets.symmetric(horizontal: scaleF(16), vertical: scaleF(16)),
              child: Text(
                initialValue,
                style: GoogleFonts.montserrat(
                  fontSize: fs(14),
                  fontWeight: FontWeight.w500,
                  color: CustomersLoginThemeView.textDark,
                ),
              ),
            )
          : TextField(
              controller: controller,
              readOnly: isReadOnly,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              style: GoogleFonts.montserrat(
                fontSize: fs(14),
                fontWeight: FontWeight.w500,
                color: CustomersLoginThemeView.textDark,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.montserrat(
                  fontSize: fs(13),
                  color: CustomersLoginThemeView.textGrey,
                ),
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
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: CustomersLoginThemeView.primaryBlue),
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
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: hPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: scaleF(16)),
                    Text(
                      'Set up your delivery details gently.',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(14),
                        color: CustomersLoginThemeView.textGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: scaleF(20)),
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: scaleF(70),
                            height: scaleF(70),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.1),
                              border: Border.all(color: CustomersLoginThemeView.primaryBlue, width: 2),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              state.model.profilePhoto.isNotEmpty ? state.model.profilePhoto : '👩‍🦰',
                              style: TextStyle(fontSize: fs(34)),
                            ),
                          ),
                          SizedBox(height: scaleF(8)),
                          Text(
                            'Select Profile Avatar',
                            style: GoogleFonts.montserrat(
                              fontSize: fs(12),
                              fontWeight: FontWeight.bold,
                              color: CustomersLoginThemeView.textDark,
                            ),
                          ),
                          SizedBox(height: scaleF(8)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const ['👩‍🦰', '🧔', '👳', '👱‍♀️', '🧑‍⚕️', '👨‍🎓'].map((emoji) {
                              final isSelected = state.model.profilePhoto == emoji;
                              return GestureDetector(
                                onTap: () {
                                  context.read<CustomersProfileViewModel>().add(
                                    ProfileFieldChanged(profilePhoto: emoji),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected ? CustomersLoginThemeView.primaryBlue : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: Text(emoji, style: TextStyle(fontSize: 22)),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: scaleF(24)),
                    Text(
                      'Personal Info',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(16),
                        fontWeight: FontWeight.bold,
                        color: CustomersLoginThemeView.sectionHeadingRed,
                      ),
                    ),
                    SizedBox(height: scaleF(12)),
                    _buildTextField(
                      context: context,
                      hint: 'Full Name',
                      controller: _nameController,
                      scaleF: scaleF,
                      fs: fs,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                      ],
                      onChanged: (value) => context.read<CustomersProfileViewModel>().add(ProfileFieldChanged(name: value)),
                    ),
                    SizedBox(height: scaleF(16)),
                    Text(
                      'Delivery Address',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(16),
                        fontWeight: FontWeight.bold,
                        color: CustomersLoginThemeView.sectionHeadingRed,
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
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(6),
                            ],
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
                          side: const BorderSide(color: Colors.black, width: 1.0),
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
                      'Delivery Preferences',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(16),
                        fontWeight: FontWeight.bold,
                        color: CustomersLoginThemeView.sectionHeadingRed,
                      ),
                    ),
                    SizedBox(height: scaleF(12)),
                    // Preferred Delivery Time Slot Dropdown
                    Container(
                      margin: EdgeInsets.only(bottom: scaleF(16)),
                      padding: EdgeInsets.symmetric(horizontal: scaleF(16)),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1.0),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: state.model.preferredDeliveryTime,
                          isExpanded: true,
                          style: GoogleFonts.montserrat(
                            fontSize: fs(14),
                            fontWeight: FontWeight.w500,
                            color: CustomersLoginThemeView.textDark,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Morning (6:00 AM – 8:00 AM)',
                              child: Text('Morning (6:00 AM – 8:00 AM)'),
                            ),
                            DropdownMenuItem(
                              value: 'Evening (6:00 PM – 8:00 PM)',
                              child: Text('Evening (6:00 PM – 8:00 PM)'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              context.read<CustomersProfileViewModel>().add(
                                    ProfileFieldChanged(preferredDeliveryTime: val),
                                  );
                            }
                          },
                        ),
                      ),
                    ),
                    // Emergency Contact Number
                    _buildTextField(
                      context: context,
                      hint: 'Emergency Contact (Optional)',
                      controller: _emergencyContactController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      scaleF: scaleF,
                      fs: fs,
                      onChanged: (value) => context.read<CustomersProfileViewModel>().add(ProfileFieldChanged(emergencyContact: value)),
                    ),
                    SizedBox(height: scaleF(16)),

                    // Notification Settings Toggles
                    Text(
                      'Notification Preferences',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(16),
                        fontWeight: FontWeight.bold,
                        color: CustomersLoginThemeView.sectionHeadingRed,
                      ),
                    ),
                    SizedBox(height: scaleF(8)),
                    _buildSwitchTile(
                      label: 'Push Notifications',
                      value: state.model.enablePushNotification,
                      onChanged: (val) {
                        context.read<CustomersProfileViewModel>().add(
                              ProfileFieldChanged(enablePushNotification: val),
                            );
                      },
                      fs: fs,
                    ),
                    _buildSwitchTile(
                      label: 'WhatsApp Alerts',
                      value: state.model.enableWhatsAppNotification,
                      onChanged: (val) {
                        context.read<CustomersProfileViewModel>().add(
                              ProfileFieldChanged(enableWhatsAppNotification: val),
                            );
                      },
                      fs: fs,
                    ),
                    _buildSwitchTile(
                      label: 'SMS Notifications',
                      value: state.model.enableSmsNotification,
                      onChanged: (val) {
                        context.read<CustomersProfileViewModel>().add(
                              ProfileFieldChanged(enableSmsNotification: val),
                            );
                      },
                      fs: fs,
                    ),
                    SizedBox(height: scaleF(24)),
                    Text(
                      'Referral',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(16),
                        fontWeight: FontWeight.bold,
                        color: CustomersLoginThemeView.sectionHeadingRed,
                      ),
                    ),
                    SizedBox(height: scaleF(12)),
                    _buildTextField(
                      context: context,
                      hint: 'Referral Code (Optional)',
                      controller: _referralController,
                      scaleF: scaleF,
                      fs: fs,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                        LengthLimitingTextInputFormatter(7),
                      ],
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
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: Colors.black, width: 1.0),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            context.read<CustomersProfileViewModel>().add(ProfileSubmit());
                          },
                          child: Text(
                            'Save & Go to Home',
                            style: GoogleFonts.montserrat(
                              fontSize: fs(15),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    SizedBox(height: scaleF(32)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSwitchTile({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
    required double Function(double) fs,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: CustomersLoginThemeView.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 1.0),
      ),
      child: SwitchListTile(
        title: Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: fs(13),
            fontWeight: FontWeight.w600,
            color: CustomersLoginThemeView.textDark,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: CustomersLoginThemeView.primaryBlue,
        activeTrackColor: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.15),
        inactiveThumbColor: Colors.grey.shade400,
        inactiveTrackColor: Colors.grey.shade200,
      ),
    );
  }
}
