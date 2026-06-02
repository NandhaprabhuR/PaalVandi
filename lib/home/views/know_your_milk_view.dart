import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/customers_login_themeview.dart';
import '../../core/widgets/responsive_helper.dart';

class KnowYourMilkView extends StatelessWidget {
  const KnowYourMilkView({super.key});

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
          icon: const Icon(Icons.arrow_back_ios_new, color: CustomersLoginThemeView.primaryBlue, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Know Your Milk',
          style: CustomersLoginThemeView.brandTitleStyle.copyWith(
            fontSize: fs(20),
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: scaleF(12)),
        children: [
          // Hero Banner Header Card
          Container(
            padding: EdgeInsets.all(scaleF(20)),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [CustomersLoginThemeView.primaryBlue, Color(0xFF4A90E2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.black, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pure. Untouched. Fresh.',
                  style: GoogleFonts.montserrat(
                    fontSize: fs(22),
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: scaleF(6)),
                Text(
                  'Delivering organic, organic-certified dairy directly from the farm to your doorstep in sterilised glass bottles within hours of milking.',
                  style: GoogleFonts.montserrat(
                    fontSize: fs(12),
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: scaleF(24)),

          // 1. Farm Story Card
          _buildInfoCard(
            context,
            icon: '🏡',
            title: 'Our Farm Story',
            description:
                'Our happy cows roam freely on organic grasslands in local chemical-free environments, fed with highly nutritious natural fodder. No hormonal injections or synthetic stimulants are ever used, ensuring our milk is naturally wholesome and filled with fresh country goodness.',
            scaleF: scaleF,
            fs: fs,
          ),

          // 2. Collection Process Card
          _buildInfoCard(
            context,
            icon: '🥛',
            title: 'Hygienic Collection Process',
            description:
                'Milking is executed utilizing strictly untouched automated systems. The raw milk is instantly chilled within 1 hour to 4°C to arrest bacterial proliferation and maintain optimal freshness without boiling or processing.',
            scaleF: scaleF,
            fs: fs,
          ),

          // 3. Quality Testing Card
          _buildInfoCard(
            context,
            icon: '🧪',
            title: 'Rigorous Quality Testing',
            description:
                'Every batch undergoes 24 strict quality parameters before dispatch, screening for water adulteration, density, somatic cells, antibiotics, and contaminants. We commit to a solid 100% pure standard.',
            scaleF: scaleF,
            fs: fs,
          ),

          // 4. Bottle Cleaning Process Card
          _buildInfoCard(
            context,
            icon: '🧼',
            title: 'Advanced Sterilization',
            description:
                'Returned bottles undergo an intensive 6-stage industrial sterilization cycle, including warm water rinses, hot caustic baths, disinfectant treatment, and dry heat sterilization at 120°C to guarantee zero contamination and fully sustainable packaging.',
            scaleF: scaleF,
            fs: fs,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String icon,
    required String title,
    required String description,
    required double Function(double) scaleF,
    required double Function(double) fs,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: scaleF(16)),
      padding: EdgeInsets.all(scaleF(16)),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFD),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(scaleF(10)),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: CustomersLoginThemeView.primaryBlue.withOpacity(0.2), width: 1.5),
            ),
            child: Text(icon, style: TextStyle(fontSize: fs(22))),
          ),
          SizedBox(width: scaleF(14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: fs(14),
                    fontWeight: FontWeight.w800,
                    color: CustomersLoginThemeView.textDark,
                  ),
                ),
                SizedBox(height: scaleF(6)),
                Text(
                  description,
                  style: GoogleFonts.montserrat(
                    fontSize: fs(12),
                    fontWeight: FontWeight.w500,
                    color: CustomersLoginThemeView.textDark.withOpacity(0.75),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
