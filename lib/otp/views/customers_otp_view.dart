import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_navigation.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodels/customers_otp_viewmodel.dart';
import '../../theme/customers_login_themeview.dart';
import '../../core/widgets/responsive_helper.dart';

class CustomersOtpView extends StatelessWidget {
  final String phoneNumber;
  
  const CustomersOtpView({super.key, required this.phoneNumber});

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
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Verify OTP',
          style: CustomersLoginThemeView.brandTitleStyle.copyWith(
            fontSize: fs(22),
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<CustomersOtpViewModel, CustomersOtpState>(
        listener: (context, state) {
          if (state is OtpSuccess) {
            if (state.isProfileComplete) {
              context.goPersist('/home');
            } else {
              context.goPersist('/profile');
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
                        SizedBox(height: scaleF(35)),

                          Text(
                            'Verify OTP',
                            style: CustomersLoginThemeView.titleStyle.copyWith(
                              fontSize: fs(18),
                            ),
                          ),
                          SizedBox(height: scaleF(8)),
                          Text(
                            'Enter the 6-digit code sent to\n$phoneNumber',
                            style: CustomersLoginThemeView.subtitleStyle.copyWith(
                              fontSize: fs(13),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: scaleF(24)),

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
                              style: TextStyle(
                                fontSize: fs(24), 
                                letterSpacing: 16,
                                color: CustomersLoginThemeView.textDark,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: InputDecoration(
                                hintText: '000000',
                                hintStyle: CustomersLoginThemeView.hintStyle.copyWith(letterSpacing: 16, fontSize: fs(24)),
                                border: InputBorder.none,
                                counterText: '',
                                contentPadding: EdgeInsets.symmetric(vertical: scaleF(16)),
                              ),
                              onChanged: (value) => context
                                  .read<CustomersOtpViewModel>()
                                  .add(OtpCodeChanged(value)),
                            ),
                          ),
                          SizedBox(height: scaleF(24)),

                          if (state is OtpLoading)
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
                                  context
                                      .read<CustomersOtpViewModel>()
                                      .add(OtpVerifySubmitted(phoneNumber));
                                },
                                child: Text(
                                  'Verify & Proceed',
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
