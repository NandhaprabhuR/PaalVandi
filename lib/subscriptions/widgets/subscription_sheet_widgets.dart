import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/customers_login_themeview.dart';

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
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: CustomersLoginThemeView.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                title,
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: CustomersLoginThemeView.primaryBlue,
                ),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: child,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                8,
                20,
                16 + MediaQuery.paddingOf(context).bottom,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48,
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
                      fontSize: 16,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: 15,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: selected
            ? CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.12)
            : Colors.white,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: value
            ? CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.12)
            : Colors.white,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () => onChanged(!value),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: GoogleFonts.montserrat(
          fontSize: 14,
          color: CustomersLoginThemeView.textDark,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.montserrat(
            color: CustomersLoginThemeView.textGrey,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
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
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: CustomersLoginThemeView.primaryBlue,
      content: Text(
        '$planName saved — we will confirm your subscription shortly.',
        style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
      ),
    ),
  );
}
