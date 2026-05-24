import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/customers_login_themeview.dart';
import '../../core/widgets/responsive_helper.dart';

Future<void> showSubscriptionBottomSheet({
  required BuildContext context,
  required String title,
  required Widget child,
  required VoidCallback onContinue,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _SubscriptionSheetShell(
      title: title,
      onContinue: onContinue,
      child: child,
    ),
  );
}

class _SubscriptionSheetShell extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback onContinue;

  const _SubscriptionSheetShell({
    required this.title,
    required this.child,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final scaleF = (double val) => ResponsiveHelper.scaledValue(context, val);
    final fs = (double size) => ResponsiveHelper.scaledFontSize(context, size);
    final hPadding = ResponsiveHelper.horizontalPadding(context);

    return AnimatedPadding(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.92,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(
            top: BorderSide(color: CustomersLoginThemeView.primaryBlue, width: 2),
            left: BorderSide(
              color: CustomersLoginThemeView.primaryBlue,
              width: 1.2,
            ),
            right: BorderSide(
              color: CustomersLoginThemeView.primaryBlue,
              width: 1.2,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: scaleF(10)),
            Container(
              width: scaleF(40),
              height: 4,
              decoration: BoxDecoration(
                color: CustomersLoginThemeView.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(hPadding, scaleF(16), hPadding, 0),
              child: Text(
                title,
                style: GoogleFonts.montserrat(
                  fontSize: fs(18),
                  fontWeight: FontWeight.w800,
                  color: CustomersLoginThemeView.primaryBlue,
                ),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(hPadding, scaleF(12), hPadding, scaleF(8)),
                child: child,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                hPadding,
                scaleF(8),
                hPadding,
                scaleF(16) + MediaQuery.paddingOf(context).bottom,
              ),
              child: SizedBox(
                width: double.infinity,
                height: scaleF(48).clamp(42.0, 54.0),
                child: ElevatedButton(
                  onPressed: onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomersLoginThemeView.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: CustomersLoginThemeView.buttonTextStyle.copyWith(
                      fontSize: fs(16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SubscriptionSectionTitle extends StatelessWidget {
  final String label;

  const SubscriptionSectionTitle(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    final scaleF = (double val) => ResponsiveHelper.scaledValue(context, val);
    final fs = (double size) => ResponsiveHelper.scaledFontSize(context, size);

    return Padding(
      padding: EdgeInsets.only(bottom: scaleF(8), top: scaleF(4)),
      child: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: fs(15),
          fontWeight: FontWeight.w800,
          color: CustomersLoginThemeView.textDark,
        ),
      ),
    );
  }
}

class SubscriptionRadioTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const SubscriptionRadioTile({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scaleF = (double val) => ResponsiveHelper.scaledValue(context, val);
    final fs = (double size) => ResponsiveHelper.scaledFontSize(context, size);

    return Padding(
      padding: EdgeInsets.only(bottom: scaleF(4)),
      child: Material(
        color: selected
            ? CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.12)
            : Colors.white,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: scaleF(12), vertical: scaleF(10)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected
                    ? CustomersLoginThemeView.primaryBlue
                    : CustomersLoginThemeView.borderColor,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: CustomersLoginThemeView.primaryBlue,
                  size: scaleF(22).clamp(18.0, 26.0),
                ),
                SizedBox(width: scaleF(10)),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.montserrat(
                      fontSize: fs(14),
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w500,
                      color: CustomersLoginThemeView.textDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SubscriptionCheckTile extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SubscriptionCheckTile({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scaleF = (double val) => ResponsiveHelper.scaledValue(context, val);
    final fs = (double size) => ResponsiveHelper.scaledFontSize(context, size);

    return Padding(
      padding: EdgeInsets.only(bottom: scaleF(4)),
      child: Material(
        color: value
            ? CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.12)
            : Colors.white,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () => onChanged(!value),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: scaleF(12), vertical: scaleF(10)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: value
                    ? CustomersLoginThemeView.primaryBlue
                    : CustomersLoginThemeView.borderColor,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  value ? Icons.check_box : Icons.check_box_outline_blank,
                  color: CustomersLoginThemeView.primaryBlue,
                  size: scaleF(22).clamp(18.0, 26.0),
                ),
                SizedBox(width: scaleF(10)),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.montserrat(
                      fontSize: fs(14),
                      fontWeight: FontWeight.w600,
                      color: CustomersLoginThemeView.textDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SubscriptionTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;

  const SubscriptionTextField({
    super.key,
    required this.label,
    required this.controller,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final scaleF = (double val) => ResponsiveHelper.scaledValue(context, val);
    final fs = (double size) => ResponsiveHelper.scaledFontSize(context, size);

    return Padding(
      padding: EdgeInsets.only(bottom: scaleF(10)),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: GoogleFonts.montserrat(
          fontSize: fs(14),
          color: CustomersLoginThemeView.textDark,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.montserrat(
            color: CustomersLoginThemeView.textGrey,
            fontSize: fs(14),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: scaleF(14),
            vertical: scaleF(12),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: CustomersLoginThemeView.borderColor,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: CustomersLoginThemeView.primaryBlue,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

void showSubscriptionContinueSnackBar(BuildContext context, String planName) {
  final fs = (double size) => ResponsiveHelper.scaledFontSize(context, size);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: CustomersLoginThemeView.primaryBlue,
      content: Text(
        '$planName saved — we will confirm your subscription shortly.',
        style: GoogleFonts.montserrat(
          fontWeight: FontWeight.w600,
          fontSize: fs(14),
        ),
      ),
    ),
  );
}
