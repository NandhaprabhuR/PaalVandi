import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodels/customers_login_viewmodel.dart';
import '../../theme/customers_login_themeview.dart';

class CustomersLoginView extends StatelessWidget {
  const CustomersLoginView({super.key});

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
        child: BlocConsumer<CustomersLoginViewModel, CustomersLoginState>(
          listener: (context, state) {
            if (state is LoginOtpSent) {
              context.go('/otp', extra: state.phoneNumber);
            } else if (state is LoginFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
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
                        children: [
                          const SizedBox(height: 60),
                          // Logo Area (Wait for actual images, using icons for now)
                          const Icon(
                            Icons.local_shipping_outlined,
                            size: 80,
                            color: CustomersLoginThemeView.primaryBlue,
                          ),
                          const SizedBox(height: 10),
                    Text(
                      'PaalVandi',
                      style: GoogleFonts.montserrat(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: CustomersLoginThemeView.primaryBlue,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '— FRESH MILK, EVERY DAY —',
                      style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                              color: CustomersLoginThemeView.primaryBlue,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 60),

                          // Login texts
                          Text(
                            'Login with Phone',
                            style: CustomersLoginThemeView.titleStyle,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'We will send you an OTP\nto verify your number',
                            style: CustomersLoginThemeView.subtitleStyle,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),

                          // Phone Input Field
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: CustomersLoginThemeView.primaryBlue, width: 1.5),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                            ),
                            child: Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Row(
                                    children: [
                                      Text('🇮🇳', style: TextStyle(fontSize: 20)),
                                      SizedBox(width: 8),
                                      Text(
                                        '+91',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: CustomersLoginThemeView.textDark,
                                        ),
                                      ),
                                      Icon(Icons.keyboard_arrow_down, color: CustomersLoginThemeView.textDark),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 30,
                                  color: CustomersLoginThemeView.borderColor,
                                ),
                                Expanded(
                                  child: TextField(
                                    keyboardType: TextInputType.phone,
                                    style: const TextStyle(fontSize: 18, color: CustomersLoginThemeView.textDark),
                                    decoration: InputDecoration(
                                      hintText: 'Enter your mobile number',
                                      hintStyle: CustomersLoginThemeView.hintStyle,
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                    ),
                                    onChanged: (value) {
                                      final fullNumber = value.startsWith('+') ? value : '+91$value';
                                      context.read<CustomersLoginViewModel>().add(LoginPhoneNumberChanged(fullNumber));
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Send OTP Button
                          if (state is LoginLoading)
                            const CircularProgressIndicator(color: CustomersLoginThemeView.primaryBlue)
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
                                  context.read<CustomersLoginViewModel>().add(LoginSendOtpSubmitted());
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Send OTP', style: CustomersLoginThemeView.buttonTextStyle),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward, color: Colors.white),
                                  ],
                                ),
                              ),
                            ),
                          
                          const SizedBox(height: 40),

                          // Feature Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFeatureItem(Icons.water_drop_outlined, 'No Water\nAdded'),
                              _buildDivider(),
                              _buildNoPreservativeIcon(),
                              _buildDivider(),
                              _buildFeatureItem(Icons.local_drink_outlined, 'Delivered in\nGlass Bottles'),
                            ],
                          ),

                          const Spacer(), // Pushes the footer exactly to the bottom

                          // Footer
                          const Padding(
                            padding: EdgeInsets.only(bottom: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.verified_user_outlined, color: CustomersLoginThemeView.primaryBlue, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Pure Milk. Pure Life.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: CustomersLoginThemeView.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
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

  Widget _buildFeatureItem(IconData icon, String text) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CustomersLoginThemeView.primaryBlue.withOpacity(0.06), // Very light blue background
            ),
            child: Icon(icon, color: CustomersLoginThemeView.primaryBlue, size: 30),
          ),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: CustomersLoginThemeView.featureTextStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildNoPreservativeIcon() {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CustomersLoginThemeView.primaryBlue.withOpacity(0.06),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.science_outlined, color: CustomersLoginThemeView.primaryBlue, size: 30),
                Transform.rotate(
                  angle: -0.785, // -45 degree line over the icon
                  child: Container(
                    width: 2.5,
                    height: 38,
                    color: CustomersLoginThemeView.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No Preservatives\nAdded',
            textAlign: TextAlign.center,
            style: CustomersLoginThemeView.featureTextStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        width: 1,
        height: 40,
        color: CustomersLoginThemeView.borderColor,
        margin: const EdgeInsets.symmetric(horizontal: 4),
      ),
    );
  }
}
