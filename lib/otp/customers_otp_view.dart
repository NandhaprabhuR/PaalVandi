import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'customers_otp_viewmodel.dart';
import '../theme/customers_login_themeview.dart';

class CustomersOtpView extends StatelessWidget {
  final String phoneNumber;
  
  const CustomersOtpView({super.key, required this.phoneNumber});

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
        child: BlocConsumer<CustomersOtpViewModel, CustomersOtpState>(
          listener: (context, state) {
            if (state is OtpSuccess) {
              if (state.isProfileComplete) {
                context.go('/home');
              } else {
                context.go('/profile');
              }
            } else if (state is OtpFailure) {
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
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back, color: CustomersLoginThemeView.textDark),
                              onPressed: () => context.pop(),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Logo Area
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

                          Text(
                            'Verify OTP',
                            style: CustomersLoginThemeView.titleStyle,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Enter the 6-digit code sent to\n$phoneNumber',
                            style: CustomersLoginThemeView.subtitleStyle,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),

                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: CustomersLoginThemeView.primaryBlue, width: 1.5),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                            ),
                            child: TextField(
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 24, 
                                letterSpacing: 16,
                                color: CustomersLoginThemeView.textDark,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: InputDecoration(
                                hintText: '000000',
                                hintStyle: CustomersLoginThemeView.hintStyle.copyWith(letterSpacing: 16),
                                border: InputBorder.none,
                                counterText: '',
                                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              onChanged: (value) => context
                                  .read<CustomersOtpViewModel>()
                                  .add(OtpCodeChanged(value)),
                            ),
                          ),
                          const SizedBox(height: 24),

                          if (state is OtpLoading)
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
                                  context
                                      .read<CustomersOtpViewModel>()
                                      .add(OtpVerifySubmitted(phoneNumber));
                                },
                                child: Text('Verify & Proceed', style: CustomersLoginThemeView.buttonTextStyle),
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
