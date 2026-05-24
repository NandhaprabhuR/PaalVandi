import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../theme/customers_login_themeview.dart';
import '../../core/widgets/responsive_helper.dart';
import '../models/booked_subscription_model.dart';
import '../viewmodels/subscriptions_scope.dart';

class ModifySubscriptionView extends StatefulWidget {
  final BookedSubscription booking;

  const ModifySubscriptionView({super.key, required this.booking});

  @override
  State<ModifySubscriptionView> createState() => _ModifySubscriptionViewState();
}

class _ModifySubscriptionViewState extends State<ModifySubscriptionView> {
  late String _selectedTiming;
  late DateTime _selectedDate;
  late double _selectedQuantity;

  @override
  void initState() {
    super.initState();
    // Parse current booking configurations to initialize states
    final hasEvening = widget.booking.configSummary.any((line) => line.contains('Evening'));
    final hasBoth = widget.booking.configSummary.any((line) => line.contains('Both') || line.contains('Morning + Evening'));
    
    if (hasBoth) {
      _selectedTiming = 'Both Morning & Evening';
    } else if (hasEvening) {
      _selectedTiming = 'Evening';
    } else {
      _selectedTiming = 'Morning';
    }

    _selectedDate = DateTime.now().add(const Duration(days: 1));

    // Try to parse quantity from summary (e.g. 500ml, 1L, 5L etc)
    double parsedQty = 1.0;
    for (final line in widget.booking.configSummary) {
      if (line.toLowerCase().contains('quantity:')) {
        final val = line.replaceAll(RegExp(r'quantity:', caseSensitive: false), '').trim();
        if (val.toLowerCase().contains('250ml')) {
          parsedQty = 0.25;
        } else if (val.toLowerCase().contains('500ml')) {
          parsedQty = 0.5;
        } else if (val.toLowerCase().contains('1.25l')) {
          parsedQty = 1.25;
        } else if (val.toLowerCase().contains('1.5l')) {
          parsedQty = 1.5;
        } else if (val.toLowerCase().contains('2l')) {
          parsedQty = 2.0;
        } else if (val.toLowerCase().contains('5l')) {
          parsedQty = 5.0;
        } else {
          final numeric = double.tryParse(val.replaceAll(RegExp(r'[^0-9.]'), ''));
          if (numeric != null) {
            parsedQty = numeric;
          }
        }
      }
    }
    _selectedQuantity = parsedQty;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
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
      setState(() => _selectedDate = picked);
    }
  }

  void _save() {
    final store = SubscriptionsScope.of(context);

    // Format new config summaries based on values selected
    final newConfigs = <String>[
      'Quantity: ${_selectedQuantity < 1.0 ? '${(_selectedQuantity * 1000).round()}ml' : '${_selectedQuantity.toStringAsFixed(2)}L'}',
      'Timing: $_selectedTiming',
      'Pause Date: ${DateFormat('dd MMM yyyy').format(_selectedDate)}',
      'Options: Pause anytime',
    ];

    final updatedBooking = BookedSubscription(
      planTitle: widget.booking.planTitle,
      bookedAt: widget.booking.bookedAt,
      configSummary: newConfigs,
      rateLines: widget.booking.rateLines,
      monthlyMilkRupees: widget.booking.monthlyMilkRupees,
      deliveryChargeRupees: widget.booking.deliveryChargeRupees,
      monthlyBillRupees: widget.booking.monthlyBillRupees,
      advanceRupees: widget.booking.advanceRupees,
      balanceOnFullPaymentRupees: widget.booking.balanceOnFullPaymentRupees,
      isFullyPaid: widget.booking.isFullyPaid,
    );

    store.updateBooking(widget.booking, updatedBooking);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Configurations saved successfully!',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context);
  }

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
          icon: Icon(
            Icons.arrow_back,
            color: CustomersLoginThemeView.primaryBlue,
            size: scaleF(24).clamp(20.0, 28.0),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Modify Subscription',
          style: CustomersLoginThemeView.brandTitleStyle.copyWith(
            fontSize: fs(19),
            letterSpacing: 0.5,
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
                padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: scaleF(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pause Delivery Date Picker
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Stop / Pause Deliveries on:',
                          style: GoogleFonts.montserrat(
                            fontSize: fs(13),
                            fontWeight: FontWeight.bold,
                            color: CustomersLoginThemeView.textDark,
                          ),
                        ),
                        TextButton.icon(
                          icon: Icon(Icons.calendar_month, size: scaleF(18), color: CustomersLoginThemeView.primaryBlue),
                          label: Text(
                            DateFormat('dd MMM yyyy').format(_selectedDate),
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                              fontSize: fs(13),
                              color: CustomersLoginThemeView.primaryBlue,
                            ),
                          ),
                          onPressed: _pickDate,
                        ),
                      ],
                    ),
                    Divider(color: CustomersLoginThemeView.borderColor.withValues(alpha: 0.5)),
                    SizedBox(height: scaleF(16)),

                    // Timing Selection
                    Text(
                      'Preferred Timing',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(13),
                        fontWeight: FontWeight.bold,
                        color: CustomersLoginThemeView.textDark,
                      ),
                    ),
                    SizedBox(height: scaleF(8)),
                    Wrap(
                      spacing: scaleF(8),
                      runSpacing: scaleF(8),
                      children: ['Morning', 'Evening', 'Both Morning & Evening'].map((t) {
                        final selected = _selectedTiming == t;
                        return ChoiceChip(
                          label: Text(t),
                          selected: selected,
                          onSelected: (val) {
                            if (val) {
                              setState(() => _selectedTiming = t);
                            }
                          },
                          selectedColor: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.1),
                          checkmarkColor: CustomersLoginThemeView.primaryBlue,
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: selected
                                ? CustomersLoginThemeView.primaryBlue
                                : CustomersLoginThemeView.borderColor,
                            width: selected ? 1.5 : 1.0,
                          ),
                          labelStyle: GoogleFonts.montserrat(
                            fontSize: fs(12),
                            fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                            color: selected
                                ? CustomersLoginThemeView.primaryBlue
                                : CustomersLoginThemeView.textDark,
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: scaleF(24)),

                    // Quantity Adjuster
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Adjust Delivery Quantity:',
                          style: GoogleFonts.montserrat(
                            fontSize: fs(13),
                            fontWeight: FontWeight.bold,
                            color: CustomersLoginThemeView.textDark,
                          ),
                        ),
                        Text(
                          _selectedQuantity < 1.0
                              ? '${(_selectedQuantity * 1000).round()} ml'
                              : '${_selectedQuantity.toStringAsFixed(2)} L',
                          style: GoogleFonts.montserrat(
                            fontSize: fs(14),
                            fontWeight: FontWeight.bold,
                            color: CustomersLoginThemeView.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: scaleF(12)),
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: CustomersLoginThemeView.primaryBlue,
                        inactiveTrackColor: CustomersLoginThemeView.borderColor,
                        thumbColor: CustomersLoginThemeView.primaryBlue,
                        overlayColor: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.12),
                        valueIndicatorColor: CustomersLoginThemeView.primaryBlue,
                        valueIndicatorTextStyle: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: fs(11),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: Slider(
                        value: _selectedQuantity,
                        min: 0.25,
                        max: 5.0,
                        divisions: 19, // Steps of 0.25
                        label: _selectedQuantity < 1.0
                            ? '${(_selectedQuantity * 1000).round()}ml'
                            : '${_selectedQuantity.toStringAsFixed(2)}L',
                        onChanged: (val) {
                          setState(() => _selectedQuantity = val);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(hPadding, scaleF(12), hPadding, scaleF(16) + MediaQuery.paddingOf(context).bottom),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: CustomersLoginThemeView.borderColor.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: scaleF(46).clamp(42.0, 52.0),
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomersLoginThemeView.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Save Configuration Changes',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(14),
                      fontWeight: FontWeight.bold,
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
