import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodels/customers_login_viewmodel.dart';
import '../../theme/customers_login_themeview.dart';
import '../../core/widgets/responsive_helper.dart';

class CustomersLoginView extends StatelessWidget {
  const CustomersLoginView({super.key});

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
        automaticallyImplyLeading: false,
        title: Text(
          'PaalVandi',
          style: CustomersLoginThemeView.brandTitleStyle.copyWith(
            fontSize: fs(24),
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<CustomersLoginViewModel, CustomersLoginState>(
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
                    padding: EdgeInsets.symmetric(horizontal: hPadding),
                    child: Column(
                      children: [
                        SizedBox(height: scaleF(30)),
                        // Logo Area
                        Icon(
                          Icons.local_shipping_outlined,
                          size: scaleF(64).clamp(50.0, 80.0),
                          color: CustomersLoginThemeView.primaryBlue,
                        ),
                        SizedBox(height: scaleF(10)),
                        Text(
                          '— FRESH MILK, EVERY DAY —',
                          style: GoogleFonts.montserrat(
                            fontSize: fs(11),
                            fontWeight: FontWeight.bold,
                            color: CustomersLoginThemeView.primaryBlue,
                            letterSpacing: 1.0,
                          ),
                        ),
                        SizedBox(height: scaleF(30)),

                          // Login texts
                          Text(
                            'Login with Phone',
                            style: CustomersLoginThemeView.titleStyle.copyWith(
                              fontSize: fs(18),
                            ),
                          ),
                          SizedBox(height: scaleF(8)),
                          Text(
                            'We will send you an OTP\nto verify your number',
                            style: CustomersLoginThemeView.subtitleStyle.copyWith(
                              fontSize: fs(13),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: scaleF(24)),

                          // Phone Input Field
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: CustomersLoginThemeView.primaryBlue, width: 1.5),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                            ),
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: scaleF(12)),
                                  child: Row(
                                    children: [
                                      Text('🇮🇳', style: TextStyle(fontSize: fs(20))),
                                      const SizedBox(width: 6),
                                      Text(
                                        '+91',
                                        style: TextStyle(
                                          fontSize: fs(16),
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
                                  height: scaleF(30).clamp(24.0, 36.0),
                                  color: CustomersLoginThemeView.borderColor,
                                ),
                                Expanded(
                                  child: TextField(
                                    keyboardType: TextInputType.phone,
                                    style: TextStyle(fontSize: fs(16), color: CustomersLoginThemeView.textDark),
                                    decoration: InputDecoration(
                                      hintText: 'Enter mobile number',
                                      hintStyle: CustomersLoginThemeView.hintStyle.copyWith(fontSize: fs(14)),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(horizontal: scaleF(14), vertical: scaleF(14)),
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
                          SizedBox(height: scaleF(20)),

                          // Send OTP Button
                          if (state is LoginLoading)
                            const CircularProgressIndicator(color: CustomersLoginThemeView.primaryBlue)
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
                                  context.read<CustomersLoginViewModel>().add(LoginSendOtpSubmitted());
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Send OTP',
                                      style: CustomersLoginThemeView.buttonTextStyle.copyWith(
                                        fontSize: fs(15),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.arrow_forward, color: Colors.white),
                                  ],
                                ),
                              ),
                            ),
                          
                          SizedBox(height: scaleF(32)),

                          // Feature Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFeatureItem(context, Icons.water_drop_outlined, 'No Water\nAdded', fs, scaleF),
                              _buildDivider(scaleF),
                              _buildNoPreservativeIcon(context, fs, scaleF),
                              _buildDivider(scaleF),
                              _buildFeatureItem(context, Icons.local_drink_outlined, 'Delivered in\nGlass Bottles', fs, scaleF),
                            ],
                          ),

                          const Spacer(),
                          SizedBox(height: scaleF(20)),

                          // Footer
                          Padding(
                            padding: EdgeInsets.only(bottom: scaleF(20)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.verified_user_outlined, color: CustomersLoginThemeView.primaryBlue, size: scaleF(20)),
                                const SizedBox(width: 8),
                                Text(
                                  'Pure Milk. Pure Life.',
                                  style: TextStyle(
                                    fontSize: fs(14),
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
      );
    }

  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String text,
    double Function(double) fs,
    double Function(double) scaleF,
  ) {
    final boxSize = scaleF(65).clamp(52.0, 76.0);
    return Expanded(
      child: Column(
        children: [
          Container(
            width: boxSize,
            height: boxSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CustomersLoginThemeView.primaryBlue.withOpacity(0.06),
            ),
            child: Icon(icon, color: CustomersLoginThemeView.primaryBlue, size: scaleF(30).clamp(24.0, 36.0)),
          ),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: CustomersLoginThemeView.featureTextStyle.copyWith(
              fontSize: fs(10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoPreservativeIcon(
    BuildContext context,
    double Function(double) fs,
    double Function(double) scaleF,
  ) {
    final boxSize = scaleF(65).clamp(52.0, 76.0);
    return Expanded(
      child: Column(
        children: [
          Container(
            width: boxSize,
            height: boxSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CustomersLoginThemeView.primaryBlue.withOpacity(0.06),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.science_outlined, color: CustomersLoginThemeView.primaryBlue, size: scaleF(30).clamp(24.0, 36.0)),
                Transform.rotate(
                  angle: -0.785,
                  child: Container(
                    width: 2.5,
                    height: scaleF(38).clamp(30.0, 44.0),
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
            style: CustomersLoginThemeView.featureTextStyle.copyWith(
              fontSize: fs(10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(double Function(double) scaleF) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        width: 1,
        height: scaleF(40).clamp(32.0, 48.0),
        color: CustomersLoginThemeView.borderColor,
        margin: const EdgeInsets.symmetric(horizontal: 4),
      ),
    );
  }
}
