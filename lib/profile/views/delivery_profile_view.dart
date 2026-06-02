import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/delivery_theme.dart';
import '../../auth/viewmodels/delivery_auth_viewmodel.dart';
import '../../home/viewmodels/delivery_home_viewmodel.dart';
import '../../core/widgets/responsive_helper.dart';

class DeliveryProfileView extends StatelessWidget {
  const DeliveryProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final scaleF = (num val) => ResponsiveHelper.scaledValue(context, val.toDouble());
    final fs = (num size) => ResponsiveHelper.scaledFontSize(context, size.toDouble());
    final hPadding = ResponsiveHelper.horizontalPadding(context);

    return Scaffold(
      backgroundColor: DeliveryTheme.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: scaleF(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                'My Profile',
                style: GoogleFonts.montserrat(
                  fontSize: fs(22),
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: scaleF(32)),

              // Profile Card
              _buildPartnerInfoCard(fs, scaleF),
              SizedBox(height: scaleF(24)),

              // Vehicle Details Card
              _buildVehicleDetailsCard(fs, scaleF),
              SizedBox(height: scaleF(24)),

              // Performance Stats Card
              _buildStatsSummaryCard(fs, scaleF),
              SizedBox(height: scaleF(32)),

              // Safe Logout Button
              SizedBox(
                height: scaleF(52),
                child: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9B0F06), // Exact matching premium dark red
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ).buttons(
                  onPressed: () {
                    // Trigger BLoC logout
                    context.read<DeliveryAuthViewModel>().add(const AuthLogout());
                    // Clear online status
                    context.read<DeliveryHomeViewModel>().add(const ToggleOnlineStatus());
                    context.go('/login');
                  },
                  child: Text(
                    'Logout & End Duty',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(14),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context, 2, scaleF, fs),
    );
  }

  Widget _buildPartnerInfoCard(Function fs, Function scaleF) {
    return Container(
      decoration: BoxDecoration(
        color: DeliveryTheme.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DeliveryTheme.borderDark, width: 1.5),
      ),
      padding: EdgeInsets.all(scaleF(20)),
      child: Row(
        children: [
          CircleAvatar(
            radius: scaleF(32),
            backgroundColor: DeliveryTheme.primaryOrange.withOpacity(0.1),
            child: Icon(Icons.sports_motorsports, color: DeliveryTheme.primaryOrange, size: scaleF(40)),
          ),
          SizedBox(width: scaleF(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ravi Kumar',
                  style: GoogleFonts.montserrat(
                    fontSize: fs(18),
                    fontWeight: FontWeight.bold,
                    color: DeliveryTheme.textLight,
                  ),
                ),
                Text(
                  'ID: PV-DP-4820',
                  style: GoogleFonts.montserrat(
                    fontSize: fs(12),
                    color: DeliveryTheme.primaryOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: scaleF(4)),
                Text(
                  '+91 9876543210',
                  style: GoogleFonts.montserrat(
                    fontSize: fs(12),
                    color: DeliveryTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleDetailsCard(Function fs, Function scaleF) {
    return Container(
      decoration: BoxDecoration(
        color: DeliveryTheme.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DeliveryTheme.borderDark, width: 1.5),
      ),
      padding: EdgeInsets.all(scaleF(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vehicle Details',
            style: GoogleFonts.montserrat(
              fontSize: fs(14),
              fontWeight: FontWeight.bold,
              color: DeliveryTheme.textLight,
            ),
          ),
          SizedBox(height: scaleF(16)),
          _buildDetailRow('Vehicle Class', 'Two Wheeler (Motorcycle)', fs, scaleF),
          Divider(color: DeliveryTheme.borderDark, height: scaleF(20)),
          _buildDetailRow('License Number', 'TN-37-BY-8832', fs, scaleF),
          Divider(color: DeliveryTheme.borderDark, height: scaleF(20)),
          _buildDetailRow('Registration City', 'Coimbatore North RTO', fs, scaleF),
        ],
      ),
    );
  }

  Widget _buildStatsSummaryCard(Function fs, Function scaleF) {
    return Container(
      decoration: BoxDecoration(
        color: DeliveryTheme.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DeliveryTheme.borderDark, width: 1.5),
      ),
      padding: EdgeInsets.all(scaleF(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Duty Statistics',
            style: GoogleFonts.montserrat(
              fontSize: fs(14),
              fontWeight: FontWeight.bold,
              color: DeliveryTheme.textLight,
            ),
          ),
          SizedBox(height: scaleF(16)),
          _buildDetailRow('Weekly Active Hours', '38.5 hrs', fs, scaleF),
          Divider(color: DeliveryTheme.borderDark, height: scaleF(20)),
          _buildDetailRow('Customer Rating', '4.92 ★ (120 reviews)', fs, scaleF),
          Divider(color: DeliveryTheme.borderDark, height: scaleF(20)),
          _buildDetailRow('Acceptance Rate', '98.5%', fs, scaleF),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Function fs, Function scaleF) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: fs(12),
            color: DeliveryTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: fs(13),
            fontWeight: FontWeight.bold,
            color: DeliveryTheme.textLight,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav(BuildContext context, int activeIdx, Function scaleF, Function fs) {
    return Container(
      decoration: BoxDecoration(
        color: DeliveryTheme.cardDark,
        border: Border(top: BorderSide(color: DeliveryTheme.borderDark, width: 1.5)),
      ),
      child: BottomNavigationBar(
        currentIndex: activeIdx,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: DeliveryTheme.primaryOrange,
        unselectedItemColor: DeliveryTheme.textSecondary,
        selectedLabelStyle: GoogleFonts.montserrat(fontSize: fs(11), fontWeight: FontWeight.bold),
        unselectedLabelStyle: GoogleFonts.montserrat(fontSize: fs(11), fontWeight: FontWeight.w500),
        onTap: (index) {
          if (index == 0) context.go('/home');
          if (index == 1) context.go('/earnings');
          if (index == 2) context.go('/profile');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Trips'),
          BottomNavigationBarItem(icon: Icon(Icons.currency_rupee_outlined), activeIcon: Icon(Icons.currency_rupee), label: 'Earnings'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// Quick helper extension to map button styling in an easy Drop-In way
extension ButtonElevatedHelper on ButtonStyle {
  Widget buttons({required VoidCallback onPressed, required Widget child}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: this,
      child: child,
    );
  }
}
