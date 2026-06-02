import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../theme/customers_login_themeview.dart';
import '../../core/widgets/responsive_helper.dart';
import '../models/subscription_plan_model.dart';
import '../models/subscription_quote_model.dart';
import '../services/subscription_pricing.dart';
import '../widgets/subscription_sheet_widgets.dart';
import '../viewmodels/subscriptions_scope.dart';
import 'subscription_flow.dart';
import '../../core/services/haptic_service.dart';

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

  bool _vacationMode = false;
  bool _pauseDelivery = false;
  DateTime? _pauseStartDate;
  DateTime? _pauseEndDate;

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  Future<void> _pickPauseDate({required bool isStart}) async {
    final now = DateTime.now();
    final initialDate = isStart
        ? (_pauseStartDate ?? now.add(const Duration(days: 1)))
        : (_pauseEndDate ?? (_pauseStartDate ?? now).add(const Duration(days: 3)));

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 120)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: CustomersLoginThemeView.primaryBlue,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      HapticService.selection();
      setState(() {
        if (isStart) {
          _pauseStartDate = picked;
          if (_pauseEndDate != null && _pauseEndDate!.isBefore(picked)) {
            _pauseEndDate = picked.add(const Duration(days: 1));
          }
        } else {
          _pauseEndDate = picked;
        }
      });
    }
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
    final List<String> options = [];
    if (_vacationMode) options.add('Vacation Mode');
    if (_pauseDelivery && _pauseStartDate != null && _pauseEndDate != null) {
      final s = DateFormat('dd MMM').format(_pauseStartDate!);
      final e = DateFormat('dd MMM').format(_pauseEndDate!);
      options.add('Paused ($s–$e)');
    }

    openSubscriptionConfirmation(
      context,
      SubscriptionPricing.family(
        quantity: qty,
        timing: timings[_timingIndex],
        options: options,
      ),
    );
  }

  Widget _buildTimingSummaryCard() {
    const timings = ['Morning (5AM–9AM)', 'Evening (4PM–9PM)', 'Both'];
    final selectedTiming = timings[_timingIndex];
    String summary = '';
    String desc = '';
    if (selectedTiming.contains('Morning')) {
      summary = '🌅 Morning Delivery';
      desc = 'Delivered fresh between 5:00 AM and 9:00 AM daily. Perfect for breakfast!';
    } else if (selectedTiming.contains('Evening')) {
      summary = '🌙 Evening Delivery';
      desc = 'Delivered fresh between 4:00 PM and 9:00 PM daily. Perfect for dinner & tea!';
    } else {
      summary = '⚡ Both Morning & Evening';
      desc = 'Two deliveries daily: Morning (5AM-9AM) and Evening (4PM-9PM) to ensure absolute freshness.';
    }

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            summary,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: CustomersLoginThemeView.primaryBlue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: GoogleFonts.montserrat(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: CustomersLoginThemeView.textGrey,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final qty = _qtyIndex == _quantities.length - 1
        ? (_customController.text.trim().isEmpty ? '500ml' : _customController.text.trim())
        : _quantities[_qtyIndex];
    const timings = ['Morning (5AM–9AM)', 'Evening (4PM–9PM)', 'Both'];
    final quote = SubscriptionPricing.family(
      quantity: qty,
      timing: timings[_timingIndex],
      options: const [],
    );
    final estMonthlyAmount = quote.monthlyBillRupees;

    final bottomHelper = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Estimated Monthly Amount',
              style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: CustomersLoginThemeView.textGrey,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '₹$estMonthlyAmount',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: CustomersLoginThemeView.textDark,
              ),
            ),
          ],
        ),
        if (_vacationMode || _pauseDelivery)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: CustomersLoginThemeView.sectionHeadingRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              _vacationMode ? 'Vacation Mode' : 'Pause Scheduled',
              style: GoogleFonts.montserrat(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: CustomersLoginThemeView.sectionHeadingRed,
              ),
            ),
          ),
      ],
    );

    return _wrapPage(
      context: context,
      title: 'Family Subscription',
      backgroundColor: SubscriptionPlans.family.cardTint,
      onContinue: _continue,
      bottomHelperWidget: bottomHelper,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SubscriptionSectionTitle('Select Quantity:'),
          ...List.generate(_quantities.length, (i) {
            final isPopular = _quantities[i] == '500ml' || _quantities[i] == '1L';
            return SubscriptionRadioTile(
              label: _quantities[i],
              selected: _qtyIndex == i,
              badgeLabel: isPopular ? 'Recommended' : null,
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
          _buildTimingSummaryCard(),
          const SubscriptionSectionTitle('Vacation & Pause:'),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: CustomersLoginThemeView.borderColor),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(
                    'Vacation Mode',
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: CustomersLoginThemeView.textDark,
                    ),
                  ),
                  subtitle: Text(
                    'Quick toggle to stop deliveries while away',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      color: CustomersLoginThemeView.textGrey,
                    ),
                  ),
                  activeColor: CustomersLoginThemeView.primaryBlue,
                  value: _vacationMode,
                  onChanged: (val) {
                    setState(() {
                      _vacationMode = val;
                      if (val) _pauseDelivery = false;
                    });
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: Text(
                    'Pause Delivery',
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: CustomersLoginThemeView.textDark,
                    ),
                  ),
                  subtitle: Text(
                    'Pause deliveries for specific dates',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      color: CustomersLoginThemeView.textGrey,
                    ),
                  ),
                  activeColor: CustomersLoginThemeView.primaryBlue,
                  value: _pauseDelivery,
                  onChanged: (val) {
                    setState(() {
                      _pauseDelivery = val;
                      if (val) _vacationMode = false;
                    });
                  },
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      children: [
                        _PickerRow(
                          label: _pauseStartDate == null
                              ? 'Select Start Date'
                              : 'Starts: ${DateFormat('dd MMM yyyy').format(_pauseStartDate!)}',
                          onTap: () => _pickPauseDate(isStart: true),
                        ),
                        _PickerRow(
                          label: _pauseEndDate == null
                              ? 'Select End Date'
                              : 'Ends: ${DateFormat('dd MMM yyyy').format(_pauseEndDate!)}',
                          onTap: () => _pickPauseDate(isStart: false),
                        ),
                      ],
                    ),
                  ),
                  crossFadeState: _pauseDelivery
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 220),
                ),
              ],
            ),
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
    'Catering',
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
    final qty = _qtyIndex == _quantities.length - 1
        ? (_customController.text.trim().isEmpty ? '5L' : _customController.text.trim())
        : _quantities[_qtyIndex];
    const timings = ['Morning', 'Evening', 'Morning + Evening'];
    final quote = SubscriptionPricing.business(
      quantity: qty,
      frequency: 'Once Daily',
      timing: timings[_timingIndex],
      businessType: _businessType,
    );
    final expectedMonthlyBill = quote.monthlyBillRupees;

    // Estimated monthly consumption calculation
    double dailyLiters = 5.0;
    if (qty.endsWith('L')) {
      dailyLiters = double.tryParse(qty.replaceAll('L', '').trim()) ?? 5.0;
    } else if (qty.endsWith('ml')) {
      dailyLiters = (double.tryParse(qty.replaceAll('ml', '').trim()) ?? 500) / 1000.0;
    } else {
      dailyLiters = double.tryParse(qty) ?? 5.0;
    }
    final monthlyConsumption = (dailyLiters * 30).toStringAsFixed(0);

    final bottomHelper = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Expected Monthly Bill',
              style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: CustomersLoginThemeView.textGrey,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '₹$expectedMonthlyBill',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: CustomersLoginThemeView.textDark,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'Est. $monthlyConsumption L/month',
            style: GoogleFonts.montserrat(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: CustomersLoginThemeView.primaryBlue,
            ),
          ),
        ),
      ],
    );

    return _wrapPage(
      context: context,
      title: 'Business Subscription',
      backgroundColor: SubscriptionPlans.business.cardTint,
      onContinue: _continue,
      bottomHelperWidget: bottomHelper,
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
                  if (v != null) {
                    HapticService.selection();
                    setState(() => _businessType = v);
                  }
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
  final _guestCountController = TextEditingController();
  final _contactPersonController = TextEditingController();
  bool _isRecurringEvent = false;

  @override
  void dispose() {
    _addressController.dispose();
    _instructionsController.dispose();
    _customController.dispose();
    _guestCountController.dispose();
    _contactPersonController.dispose();
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
    if (picked != null) {
      HapticService.selection();
      setState(() => _eventDate = picked);
    }
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
    if (picked != null) {
      HapticService.selection();
      setState(() => _eventTime = picked);
    }
  }

  void _continue() {
    final qty = _qtyIndex == _quantities.length - 1
        ? (_customController.text.trim().isEmpty
            ? 'Custom'
            : _customController.text.trim())
        : _quantities[_qtyIndex];
    
    final List<String> details = [];
    if (_guestCountController.text.trim().isNotEmpty) {
      details.add('Guests: ${_guestCountController.text.trim()}');
    }
    if (_contactPersonController.text.trim().isNotEmpty) {
      details.add('Contact: ${_contactPersonController.text.trim()}');
    }
    if (_isRecurringEvent) {
      details.add('Recurring Event');
    }

    final pricing = SubscriptionPricing.event(
      quantity: qty,
      eventDate: _eventDate != null
          ? DateFormat('dd MMM yyyy').format(_eventDate!)
          : 'To be confirmed',
      eventTime: _eventTime != null
          ? _eventTime!.format(context)
          : 'To be confirmed',
      address: _addressController.text.trim(),
      instructions: _instructionsController.text.trim(),
    );

    // Merge the custom details in the quote's summary
    final updatedSummary = List<String>.from(pricing.configSummary);
    updatedSummary.addAll(details);

    openSubscriptionConfirmation(
      context,
      SubscriptionQuote(
        planTitle: pricing.planTitle,
        backgroundColor: pricing.backgroundColor,
        configSummary: updatedSummary,
        rateLines: pricing.rateLines,
        monthlyMilkRupees: pricing.monthlyMilkRupees,
        deliveryChargeRupees: pricing.deliveryChargeRupees,
        monthlyBillRupees: pricing.monthlyBillRupees,
        advanceRupees: pricing.advanceRupees,
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
          const SubscriptionSectionTitle('Event Info:'),
          SubscriptionTextField(
            label: 'Contact Person Name',
            controller: _contactPersonController,
          ),
          SubscriptionTextField(
            label: 'Estimated Guest Count',
            controller: _guestCountController,
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: CustomersLoginThemeView.borderColor),
            ),
            child: SwitchListTile(
              title: Text(
                'Recurring Event',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: CustomersLoginThemeView.textDark,
                ),
              ),
              subtitle: Text(
                'Toggle if this event recurs weekly/monthly',
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  color: CustomersLoginThemeView.textGrey,
                ),
              ),
              activeColor: CustomersLoginThemeView.primaryBlue,
              value: _isRecurringEvent,
              onChanged: (val) => setState(() => _isRecurringEvent = val),
            ),
          ),
          const SubscriptionSectionTitle('Date & Time:'),
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

  @override
  void initState() {
    super.initState();
    // Setup a prefilled smart weekly plan to look stunning on first glance!
    _dayQty['Monday'] = '1L';
    _dayQty['Tuesday'] = '1L';
    _dayQty['Wednesday'] = '1L';
    _dayQty['Thursday'] = '1L';
    _dayQty['Friday'] = '1L';
    _dayQty['Saturday'] = '2L';
    _dayQty['Sunday'] = '500ml';
  }

  String _generateWeeklySummary() {
    final Map<String, List<String>> qtyToDays = {};
    for (final entry in _dayQty.entries) {
      if (entry.value == 'None') continue;
      qtyToDays.putIfAbsent(entry.value, () => []).add(entry.key.substring(0, 3));
    }
    if (qtyToDays.isEmpty) return 'No milk scheduled';

    final List<String> parts = [];
    qtyToDays.forEach((qty, days) {
      if (days.length == 7) {
        parts.add('Daily → $qty');
      } else if (days.length == 5 &&
          days.contains('Mon') &&
          days.contains('Tue') &&
          days.contains('Wed') &&
          days.contains('Thu') &&
          days.contains('Fri')) {
        parts.add('Mon–Fri → $qty');
      } else if (days.length == 2 && days.contains('Sat') && days.contains('Sun')) {
        parts.add('Sat–Sun → $qty');
      } else {
        parts.add('${days.join(', ')} → $qty');
      }
    });
    return parts.join('\n');
  }

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
    const timings = ['Morning', 'Evening', 'Both'];
    final quote = SubscriptionPricing.smart(
      dayQty: Map<String, String>.from(_dayQty),
      timing: timings[_timingIndex],
    );
    final estMonthlyBill = quote.monthlyBillRupees;

    final bottomHelper = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Estimated Monthly Bill',
              style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: CustomersLoginThemeView.textGrey,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '₹$estMonthlyBill',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: CustomersLoginThemeView.textDark,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'Smart Plan',
            style: GoogleFonts.montserrat(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: CustomersLoginThemeView.primaryBlue,
            ),
          ),
        ),
      ],
    );

    return _wrapPage(
      context: context,
      title: 'Smart Subscription',
      backgroundColor: SubscriptionPlans.smart.cardTint,
      onContinue: _continue,
      bottomHelperWidget: bottomHelper,
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
                          if (v != null) {
                            HapticService.selection();
                            setState(() => _dayQty[day] = v);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SubscriptionSectionTitle('Weekly Schedule Summary:'),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                const Text('📅', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _generateWeeklySummary(),
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: CustomersLoginThemeView.primaryBlue,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
  Widget? bottomHelperWidget,
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (bottomHelperWidget != null) ...[
                  bottomHelperWidget,
                  const SizedBox(height: 12),
                ],
                SizedBox(
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
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
