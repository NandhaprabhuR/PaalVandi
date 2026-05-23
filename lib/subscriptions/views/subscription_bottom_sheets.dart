import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../theme/customers_login_themeview.dart';
import '../models/subscription_plan_model.dart';
import '../services/subscription_pricing.dart';
import '../widgets/subscription_sheet_widgets.dart';
import 'subscription_flow.dart';

void showFamilySubscriptionSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const _FamilySubscriptionSheet(),
  );
}

void showBusinessSubscriptionSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const _BusinessSubscriptionSheet(),
  );
}

void showEventSubscriptionSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const _EventSubscriptionSheet(),
  );
}

void showSmartSubscriptionSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const _SmartSubscriptionSheet(),
  );
}

class _FamilySubscriptionSheet extends StatefulWidget {
  const _FamilySubscriptionSheet();

  @override
  State<_FamilySubscriptionSheet> createState() =>
      _FamilySubscriptionSheetState();
}

class _FamilySubscriptionSheetState extends State<_FamilySubscriptionSheet> {
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
  bool _pauseAnytime = true;
  bool _vacationMode = false;
  bool _extraMilk = false;

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  void _continue() {
    final qty = _qtyIndex == _quantities.length - 1
        ? (_customController.text.trim().isEmpty
            ? 'Custom'
            : _customController.text.trim())
        : _quantities[_qtyIndex];
    const timings = ['Morning (5AM–9AM)', 'Evening (4PM–9PM)', 'Both'];
    final options = <String>[
      if (_pauseAnytime) 'Pause anytime',
      if (_vacationMode) 'Vacation mode',
      if (_extraMilk) 'Extra milk for one day',
    ];
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
    return _wrapSheet(
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
          const SubscriptionSectionTitle('Additional Options:'),
          SubscriptionCheckTile(
            label: 'Pause anytime',
            value: _pauseAnytime,
            onChanged: (v) => setState(() => _pauseAnytime = v),
          ),
          SubscriptionCheckTile(
            label: 'Vacation mode',
            value: _vacationMode,
            onChanged: (v) => setState(() => _vacationMode = v),
          ),
          SubscriptionCheckTile(
            label: 'Add extra milk for one day',
            value: _extraMilk,
            onChanged: (v) => setState(() => _extraMilk = v),
          ),
        ],
      ),
    );
  }
}

class _BusinessSubscriptionSheet extends StatefulWidget {
  const _BusinessSubscriptionSheet();

  @override
  State<_BusinessSubscriptionSheet> createState() =>
      _BusinessSubscriptionSheetState();
}

class _BusinessSubscriptionSheetState
    extends State<_BusinessSubscriptionSheet> {
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
  int _frequencyIndex = 0;
  int _timingIndex = 0;
  String _businessType = 'Hotel';
  final _customController = TextEditingController();

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  void _continue() {
    final qty = _qtyIndex == _quantities.length - 1
        ? (_customController.text.trim().isEmpty
            ? 'Custom'
            : _customController.text.trim())
        : _quantities[_qtyIndex];
    const frequencies = ['Once Daily', 'Twice Daily'];
    const timings = ['Morning', 'Evening', 'Morning + Evening'];
    openSubscriptionConfirmation(
      context,
      SubscriptionPricing.business(
        quantity: qty,
        frequency: frequencies[_frequencyIndex],
        timing: timings[_timingIndex],
        businessType: _businessType,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _wrapSheet(
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
          const SubscriptionSectionTitle('Delivery Frequency:'),
          SubscriptionRadioTile(
            label: 'Once Daily',
            selected: _frequencyIndex == 0,
            onTap: () => setState(() => _frequencyIndex = 0),
          ),
          SubscriptionRadioTile(
            label: 'Twice Daily',
            selected: _frequencyIndex == 1,
            onTap: () => setState(() => _frequencyIndex = 1),
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
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.35),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _businessType,
                items: _businessTypes
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(
                          t,
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
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

class _EventSubscriptionSheet extends StatefulWidget {
  const _EventSubscriptionSheet();

  @override
  State<_EventSubscriptionSheet> createState() =>
      _EventSubscriptionSheetState();
}

class _EventSubscriptionSheetState extends State<_EventSubscriptionSheet> {
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

    return _wrapSheet(
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

class _SmartSubscriptionSheet extends StatefulWidget {
  const _SmartSubscriptionSheet();

  @override
  State<_SmartSubscriptionSheet> createState() =>
      _SmartSubscriptionSheetState();
}

class _SmartSubscriptionSheetState extends State<_SmartSubscriptionSheet> {
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
    return _wrapSheet(
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
                        fontSize: 13,
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
                        items: _qtyOptions
                            .map(
                              (q) => DropdownMenuItem(
                                value: q,
                                child: Text(
                                  q,
                                  style: GoogleFonts.montserrat(fontSize: 13),
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
                      fontSize: 14,
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

Widget _wrapSheet({
  required String title,
  required Color backgroundColor,
  required VoidCallback onContinue,
  required Widget child,
}) {
  return Builder(
    builder: (context) {
      return AnimatedPadding(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.92,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: const Border(
              top: BorderSide(
                color: CustomersLoginThemeView.primaryBlue,
                width: 2,
              ),
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
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: CustomersLoginThemeView.primaryBlue,
                    ),
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
    },
  );
}
