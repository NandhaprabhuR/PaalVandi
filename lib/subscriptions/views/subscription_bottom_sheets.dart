import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../theme/customers_login_themeview.dart';
import '../../core/widgets/responsive_helper.dart';
import '../models/subscription_plan_model.dart';
import '../services/subscription_pricing.dart';
import '../widgets/subscription_sheet_widgets.dart';
import '../viewmodels/subscriptions_scope.dart';
import 'subscription_flow.dart';

void showFamilySubscriptionSheet(BuildContext context) {
  final store = SubscriptionsScope.of(context);
  Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (ctx) => SubscriptionsScope(
        store: store,
        child: const _FamilySubscriptionPage(),
      ),
    ),
  );
}

void showBusinessSubscriptionSheet(BuildContext context) {
  final store = SubscriptionsScope.of(context);
  Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (ctx) => SubscriptionsScope(
        store: store,
        child: const _BusinessSubscriptionPage(),
      ),
    ),
  );
}

void showEventSubscriptionSheet(BuildContext context) {
  final store = SubscriptionsScope.of(context);
  Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (ctx) => SubscriptionsScope(
        store: store,
        child: const _EventSubscriptionPage(),
      ),
    ),
  );
}

void showSmartSubscriptionSheet(BuildContext context) {
  final store = SubscriptionsScope.of(context);
  Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (ctx) => SubscriptionsScope(
        store: store,
        child: const _SmartSubscriptionPage(),
      ),
    ),
  );
}

class _FamilySubscriptionPage extends StatefulWidget {
  const _FamilySubscriptionPage();

  @override
  State<_FamilySubscriptionPage> createState() =>
      _FamilySubscriptionPageState();
}

class _FamilySubscriptionPageState extends State<_FamilySubscriptionPage> {
  static const _quantities = [
    '250ml',
    '500ml',
    '1L',
    '1.25L',
    '1.5L',
    '2L',
    'Custom',
  ];

  int _qtyIndex = 1;
  int _timingIndex = 0;
  final _customController = TextEditingController();

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  void _continue() {
    if (_qtyIndex == _quantities.length - 1 && _customController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a custom quantity.',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
          ),
          backgroundColor: CustomersLoginThemeView.sectionHeadingRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final qty = _qtyIndex == _quantities.length - 1
        ? _customController.text.trim()
        : _quantities[_qtyIndex];
    const timings = ['Morning (5AM–9AM)', 'Evening (4PM–9PM)', 'Both'];
    const options = <String>[];
    openSubscriptionConfirmation(
      context,
      SubscriptionPricing.family(
        quantity: qty,
        timing: timings[_timingIndex],
        options: options,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _wrapPage(
      context: context,
      title: 'Family Subscription',
      backgroundColor: SubscriptionPlans.family.cardTint,
      onContinue: _continue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SubscriptionSectionTitle('Select Quantity:'),
          ...List.generate(_quantities.length, (i) {
            return SubscriptionRadioTile(
              label: _quantities[i],
              selected: _qtyIndex == i,
              onTap: () => setState(() => _qtyIndex = i),
            );
          }),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 8),
              child: SubscriptionTextField(
                label: 'Enter quantity',
                controller: _customController,
              ),
            ),
            crossFadeState: _qtyIndex == _quantities.length - 1
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          ),
          const SubscriptionSectionTitle('Delivery Timing:'),
          SubscriptionRadioTile(
            label: 'Morning (5AM–9AM)',
            selected: _timingIndex == 0,
            onTap: () => setState(() => _timingIndex = 0),
          ),
          SubscriptionRadioTile(
            label: 'Evening (4PM–9PM)',
            selected: _timingIndex == 1,
            onTap: () => setState(() => _timingIndex = 1),
          ),
          SubscriptionRadioTile(
            label: 'Both',
            selected: _timingIndex == 2,
            onTap: () => setState(() => _timingIndex = 2),
          ),
        ],
      ),
    );
  }
}

class _BusinessSubscriptionPage extends StatefulWidget {
  const _BusinessSubscriptionPage();

  @override
  State<_BusinessSubscriptionPage> createState() =>
      _BusinessSubscriptionPageState();
}

class _BusinessSubscriptionPageState
    extends State<_BusinessSubscriptionPage> {
  static const _quantities = ['5L', '10L', '15L', '20L', '25L', '30L', 'Custom'];
  static const _businessTypes = [
    'Hotel',
    'Tea Shop',
    'Cafe',
    'Bakery',
    'Restaurant',
    'Other',
  ];

  int _qtyIndex = 0;
  int _timingIndex = 0;
  String _businessType = 'Hotel';
  final _customController = TextEditingController();

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  void _continue() {
    if (_qtyIndex == _quantities.length - 1 && _customController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a custom quantity.',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
          ),
          backgroundColor: CustomersLoginThemeView.sectionHeadingRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final qty = _qtyIndex == _quantities.length - 1
        ? _customController.text.trim()
        : _quantities[_qtyIndex];
    const timings = ['Morning', 'Evening', 'Morning + Evening'];
    openSubscriptionConfirmation(
      context,
      SubscriptionPricing.business(
        quantity: qty,
        frequency: 'Once Daily',
        timing: timings[_timingIndex],
        businessType: _businessType,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _wrapPage(
      context: context,
      title: 'Business Subscription',
      backgroundColor: SubscriptionPlans.business.cardTint,
      onContinue: _continue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SubscriptionSectionTitle('Select Quantity:'),
          ...List.generate(_quantities.length, (i) {
            return SubscriptionRadioTile(
              label: _quantities[i],
              selected: _qtyIndex == i,
              onTap: () => setState(() => _qtyIndex = i),
            );
          }),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 8),
              child: SubscriptionTextField(
                label: 'Enter quantity',
                controller: _customController,
              ),
            ),
            crossFadeState: _qtyIndex == _quantities.length - 1
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          ),
          const SubscriptionSectionTitle('Delivery Timing:'),
          SubscriptionRadioTile(
            label: 'Morning',
            selected: _timingIndex == 0,
            onTap: () => setState(() => _timingIndex = 0),
          ),
          SubscriptionRadioTile(
            label: 'Evening',
            selected: _timingIndex == 1,
            onTap: () => setState(() => _timingIndex = 1),
          ),
          SubscriptionRadioTile(
            label: 'Morning + Evening',
            selected: _timingIndex == 2,
            onTap: () => setState(() => _timingIndex = 2),
          ),
          const SubscriptionSectionTitle('Business Type:'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.35),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _businessType,
                dropdownColor: Colors.white,
                items: _businessTypes
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(
                          t,
                          style: GoogleFonts.montserrat(
                            fontSize: ResponsiveHelper.scaledFontSize(context, 14),
                            fontWeight: FontWeight.w600,
                            color: CustomersLoginThemeView.textDark,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _businessType = v);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventSubscriptionPage extends StatefulWidget {
  const _EventSubscriptionPage();

  @override
  State<_EventSubscriptionPage> createState() =>
      _EventSubscriptionPageState();
}

class _EventSubscriptionPageState extends State<_EventSubscriptionPage> {
  static const _quantities = ['10L', '20L', '50L', '100L', 'Custom'];

  int _qtyIndex = 0;
  DateTime? _eventDate;
  TimeOfDay? _eventTime;
  final _addressController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _customController = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    _instructionsController.dispose();
    _customController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _eventDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: CustomersLoginThemeView.primaryBlue,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _eventDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _eventTime ?? const TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: CustomersLoginThemeView.primaryBlue,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _eventTime = picked);
  }

  void _continue() {
    final qty = _qtyIndex == _quantities.length - 1
        ? (_customController.text.trim().isEmpty
            ? 'Custom'
            : _customController.text.trim())
        : _quantities[_qtyIndex];
    openSubscriptionConfirmation(
      context,
      SubscriptionPricing.event(
        quantity: qty,
        eventDate: _eventDate != null
            ? DateFormat('dd MMM yyyy').format(_eventDate!)
            : 'To be confirmed',
        eventTime: _eventTime != null
            ? _eventTime!.format(context)
            : 'To be confirmed',
        address: _addressController.text.trim(),
        instructions: _instructionsController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = _eventDate != null
        ? DateFormat('dd MMM yyyy').format(_eventDate!)
        : 'Select event date';
    final timeLabel = _eventTime != null
        ? _eventTime!.format(context)
        : 'Select event time';

    return _wrapPage(
      context: context,
      title: 'Event Subscription',
      backgroundColor: SubscriptionPlans.event.cardTint,
      onContinue: _continue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SubscriptionSectionTitle('Select Quantity:'),
          ...List.generate(_quantities.length, (i) {
            return SubscriptionRadioTile(
              label: _quantities[i],
              selected: _qtyIndex == i,
              onTap: () => setState(() => _qtyIndex = i),
            );
          }),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 8),
              child: SubscriptionTextField(
                label: 'Enter quantity',
                controller: _customController,
              ),
            ),
            crossFadeState: _qtyIndex == _quantities.length - 1
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          ),
          const SubscriptionSectionTitle('Event Details:'),
          _PickerRow(label: dateLabel, onTap: _pickDate),
          _PickerRow(label: timeLabel, onTap: _pickTime),
          SubscriptionTextField(
            label: 'Event Address',
            controller: _addressController,
            maxLines: 2,
          ),
          SubscriptionTextField(
            label: 'Special Instructions',
            controller: _instructionsController,
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}

class _SmartSubscriptionPage extends StatefulWidget {
  const _SmartSubscriptionPage();

  @override
  State<_SmartSubscriptionPage> createState() =>
      _SmartSubscriptionPageState();
}

class _SmartSubscriptionPageState extends State<_SmartSubscriptionPage> {
  static const _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const _qtyOptions = [
    'None',
    '250ml',
    '500ml',
    '1L',
    '1.25L',
    '1.5L',
    '2L',
  ];

  final Map<String, String> _dayQty = {
    for (final d in _days) d: '500ml',
  };

  int _timingIndex = 0;

  void _continue() {
    const timings = ['Morning', 'Evening', 'Both'];
    openSubscriptionConfirmation(
      context,
      SubscriptionPricing.smart(
        dayQty: Map<String, String>.from(_dayQty),
        timing: timings[_timingIndex],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _wrapPage(
      context: context,
      title: 'Smart Subscription',
      backgroundColor: SubscriptionPlans.smart.cardTint,
      onContinue: _continue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SubscriptionSectionTitle('Weekly Planner:'),
          ..._days.map((day) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: CustomersLoginThemeView.primaryBlue.withValues(
                    alpha: 0.25,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      day,
                      style: GoogleFonts.montserrat(
                        fontSize: ResponsiveHelper.scaledFontSize(context, 13),
                        fontWeight: FontWeight.w700,
                        color: CustomersLoginThemeView.textDark,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _dayQty[day],
                        dropdownColor: Colors.white,
                        items: _qtyOptions
                            .map(
                              (q) => DropdownMenuItem(
                                value: q,
                                child: Text(
                                  q,
                                  style: GoogleFonts.montserrat(
                                    fontSize: ResponsiveHelper.scaledFontSize(context, 13),
                                    color: CustomersLoginThemeView.textDark,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _dayQty[day] = v);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SubscriptionSectionTitle('Delivery Time:'),
          SubscriptionRadioTile(
            label: 'Morning',
            selected: _timingIndex == 0,
            onTap: () => setState(() => _timingIndex = 0),
          ),
          SubscriptionRadioTile(
            label: 'Evening',
            selected: _timingIndex == 1,
            onTap: () => setState(() => _timingIndex = 1),
          ),
          SubscriptionRadioTile(
            label: 'Both',
            selected: _timingIndex == 2,
            onTap: () => setState(() => _timingIndex = 2),
          ),
        ],
      ),
    );
  }
}

class _PickerRow extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PickerRow({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.montserrat(
                      fontSize: ResponsiveHelper.scaledFontSize(context, 14),
                      color: CustomersLoginThemeView.textDark,
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: CustomersLoginThemeView.primaryBlue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _wrapPage({
  required BuildContext context,
  required String title,
  required Color backgroundColor,
  required VoidCallback onContinue,
  required Widget child,
}) {
  final hPadding = ResponsiveHelper.horizontalPadding(context);
  final vPadding = ResponsiveHelper.verticalPadding(context);

  return Scaffold(
    backgroundColor: backgroundColor,
    appBar: AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: CustomersLoginThemeView.primaryBlue,
          size: 20,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        title,
        style: GoogleFonts.montserrat(
          fontSize: ResponsiveHelper.scaledFontSize(context, 18),
          fontWeight: FontWeight.w800,
          color: CustomersLoginThemeView.primaryBlue,
        ),
      ),
      centerTitle: true,
    ),
    body: SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: vPadding),
              child: child,
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(hPadding, 12, hPadding, 16 + MediaQuery.paddingOf(context).bottom),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomersLoginThemeView.primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Continue',
                  style: CustomersLoginThemeView.buttonTextStyle.copyWith(
                    fontSize: ResponsiveHelper.scaledFontSize(context, 15),
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
