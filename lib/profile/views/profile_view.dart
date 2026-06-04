import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../../theme/paalvandi_theme.dart';
import '../../core/widgets/responsive_helper.dart';
import '../../core/services/haptic_service.dart';
import '../../core/constants/mock_data.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final scaleF =
        (num val) => ResponsiveHelper.scaledValue(context, val.toDouble());
    final fs =
        (num size) => ResponsiveHelper.scaledFontSize(context, size.toDouble());
    final hPadding = ResponsiveHelper.horizontalPadding(context);

    // Using RAVI KUMAR profile from mock data
    final profile = MockData.partnerProfile;

    return Scaffold(
      backgroundColor: PaalvandiTheme.bgCream,
      appBar: AppBar(
        backgroundColor: PaalvandiTheme.bgCream,
        elevation: 0,
        title: Text(
          'Partner Profile',
          style: GoogleFonts.montserrat(
            fontSize: fs(18),
            fontWeight: FontWeight.bold,
            color: PaalvandiTheme.textDark,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<ProfileViewModel, ProfileState>(
        builder: (context, state) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(), // Scroll bouncy back setup
            ),
            padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: scaleF(16)),
            child: Column(
              children: [
                // 1. Profile Photo and Basic Details Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(scaleF(20)),
                  decoration: PaalvandiTheme.cardDecoration,
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        width: scaleF(80),
                        height: scaleF(80),
                        decoration: BoxDecoration(
                          color: PaalvandiTheme.primaryBlue.withOpacity(0.08),
                          shape: BoxShape.circle,
                          border: Border.all(color: PaalvandiTheme.cardBorder, width: 2),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.delivery_dining_outlined,
                            size: scaleF(44),
                            color: PaalvandiTheme.primaryBlue,
                          ),
                        ),
                      ),
                      SizedBox(height: scaleF(12)),
                      Text(
                        profile.name,
                        style: GoogleFonts.montserrat(
                          fontSize: fs(16),
                          fontWeight: FontWeight.w900,
                          color: PaalvandiTheme.textDark,
                        ),
                      ),
                      SizedBox(height: scaleF(4)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: scaleF(10), vertical: scaleF(4)),
                        decoration: PaalvandiTheme.statusBadgeDecoration(
                          PaalvandiTheme.primaryBlue,
                        ),
                        child: Text(
                          profile.id,
                          style: GoogleFonts.montserrat(
                            fontSize: fs(10),
                            fontWeight: FontWeight.bold,
                            color: PaalvandiTheme.primaryBlue,
                          ),
                        ),
                      ),
                      SizedBox(height: scaleF(16)),
                      Divider(color: PaalvandiTheme.dividerColor, height: 1),
                      SizedBox(height: scaleF(16)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildProfileMetaItem(
                            Icons.phone_outlined,
                            'Phone',
                            '+91 ${profile.phone}',
                            fs,
                            scaleF,
                          ),
                          _buildProfileMetaItem(
                            Icons.directions_car_outlined,
                            'Vehicle',
                            profile.vehicleNumber,
                            fs,
                            scaleF,
                          ),
                          _buildProfileMetaItem(
                            Icons.my_location_outlined,
                            'Zone',
                            profile.zone,
                            fs,
                            scaleF,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: scaleF(16)),

                // 2. Statistics Grid
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Today's Progress",
                    style: GoogleFonts.montserrat(
                      fontSize: fs(13),
                      fontWeight: FontWeight.bold,
                      color: PaalvandiTheme.textSecondary,
                    ),
                  ),
                ),
                SizedBox(height: scaleF(8)),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: scaleF(12),
                  mainAxisSpacing: scaleF(12),
                  children: [
                    _buildStatCard(
                      'TODAY DELIVERIES',
                      '${state.todayDeliveries}',
                      Icons.local_shipping_outlined,
                      PaalvandiTheme.primaryBlue,
                      scaleF,
                      fs,
                    ),
                    _buildStatCard(
                      'MONTHLY TOTAL',
                      '${state.monthlyDeliveries}',
                      Icons.calendar_month_outlined,
                      PaalvandiTheme.accentGreen,
                      scaleF,
                      fs,
                    ),
                    _buildStatCard(
                      'BOTTLES COLLECTED',
                      '${state.bottleCollections}',
                      Icons.recycling_outlined,
                      PaalvandiTheme.statusPending,
                      scaleF,
                      fs,
                    ),
                    _buildStatCard(
                      'SUBSCRIPTIONS',
                      '${state.subscriptionDeliveries}',
                      Icons.autorenew_outlined,
                      PaalvandiTheme.assignedBlue,
                      scaleF,
                      fs,
                    ),
                  ],
                ),
                SizedBox(height: scaleF(20)),

                // 3. Settings Cards
                Container(
                  decoration: PaalvandiTheme.cardDecoration,
                  child: Column(
                    children: [
                      _buildSettingToggle(
                        icon: Icons.vibration_outlined,
                        title: 'Haptic Feedback',
                        subtitle: 'Light vibrations on clicks',
                        value: state.hapticEnabled,
                        onChanged: (val) {
                          HapticService.light();
                          context.read<ProfileViewModel>().add(const ToggleHapticFeedback());
                        },
                        scaleF: scaleF,
                        fs: fs,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: scaleF(16)),

                // 4. Support & Actions Card
                Container(
                  decoration: PaalvandiTheme.cardDecoration,
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: scaleF(16), vertical: scaleF(4)),
                        leading: Icon(Icons.support_agent_outlined, color: PaalvandiTheme.primaryBlue, size: scaleF(22)),
                        title: Text(
                          'Contact PaalVandi Admin',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            fontSize: fs(13),
                            color: PaalvandiTheme.textDark,
                          ),
                        ),
                        subtitle: Text(
                          'Call for immediate assistance',
                          style: GoogleFonts.montserrat(
                            fontSize: fs(11),
                            color: PaalvandiTheme.textSecondary,
                          ),
                        ),
                        trailing: Icon(Icons.chevron_right, color: PaalvandiTheme.textMuted, size: scaleF(20)),
                        onTap: () async {
                          HapticService.light();
                          final uri = Uri.parse('tel:9361051718');
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: scaleF(24)),

                // 5. Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PaalvandiTheme.statusError.withOpacity(0.08),
                      foregroundColor: PaalvandiTheme.statusError,
                      side: const BorderSide(color: PaalvandiTheme.statusError, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.symmetric(vertical: scaleF(14)),
                    ),
                    onPressed: () {
                      HapticService.medium();
                      showDialog(
                        context: context,
                        builder: (dialogContext) => Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: PaalvandiTheme.cardBorder, width: 2),
                          ),
                          backgroundColor: PaalvandiTheme.bgCream,
                          child: Padding(
                            padding: EdgeInsets.all(scaleF(20)),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.logout, size: scaleF(40), color: PaalvandiTheme.statusError),
                                SizedBox(height: scaleF(16)),
                                Text(
                                  'Logout Confirmation',
                                  style: GoogleFonts.montserrat(
                                    fontSize: fs(16),
                                    fontWeight: FontWeight.bold,
                                    color: PaalvandiTheme.textDark,
                                  ),
                                ),
                                SizedBox(height: scaleF(8)),
                                Text(
                                  'Are you sure you want to logout?',
                                  style: GoogleFonts.montserrat(
                                    fontSize: fs(12),
                                    color: PaalvandiTheme.textSecondary,
                                  ),
                                ),
                                SizedBox(height: scaleF(24)),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: PaalvandiTheme.textDark,
                                          side: const BorderSide(color: PaalvandiTheme.cardBorder, width: 1.5),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                        onPressed: () {
                                          HapticService.light();
                                          Navigator.pop(dialogContext);
                                        },
                                        child: Text('Cancel', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                    SizedBox(width: scaleF(12)),
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: PaalvandiTheme.statusError,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                        onPressed: () {
                                          HapticService.heavy();
                                          Navigator.pop(dialogContext);
                                          context.go('/login');
                                        },
                                        child: Text('Logout', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'LOGOUT FROM DEVICE',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        fontSize: fs(13),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: scaleF(30)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileMetaItem(
    IconData icon,
    String label,
    String value,
    Function fs,
    Function scaleF,
  ) {
    return Column(
      children: [
        Icon(icon, color: PaalvandiTheme.primaryBlue, size: scaleF(18)),
        SizedBox(height: scaleF(4)),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.montserrat(
            fontSize: fs(9),
            fontWeight: FontWeight.bold,
            color: PaalvandiTheme.textMuted,
          ),
        ),
        SizedBox(height: scaleF(2)),
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: fs(11),
            fontWeight: FontWeight.bold,
            color: PaalvandiTheme.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    Function scaleF,
    Function fs,
  ) {
    return Container(
      padding: EdgeInsets.all(scaleF(12)),
      decoration: PaalvandiTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.montserrat(
                  fontSize: fs(8),
                  fontWeight: FontWeight.bold,
                  color: PaalvandiTheme.textSecondary,
                  letterSpacing: 0.2,
                ),
              ),
              Icon(icon, color: color, size: scaleF(16)),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: fs(22),
              fontWeight: FontWeight.w900,
              color: PaalvandiTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingToggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Function scaleF,
    required Function fs,
  }) {
    return SwitchListTile.adaptive(
      value: value,
      onChanged: onChanged,
      activeColor: PaalvandiTheme.primaryBlue,
      contentPadding: EdgeInsets.symmetric(horizontal: scaleF(16), vertical: scaleF(2)),
      secondary: Icon(icon, color: PaalvandiTheme.primaryBlue, size: scaleF(20)),
      title: Text(
        title,
        style: GoogleFonts.montserrat(
          fontWeight: FontWeight.bold,
          fontSize: fs(13),
          color: PaalvandiTheme.textDark,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.montserrat(
          fontSize: fs(10),
          color: PaalvandiTheme.textSecondary,
        ),
      ),
    );
  }
}
