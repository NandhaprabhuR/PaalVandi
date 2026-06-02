import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import '../../../theme/customers_login_themeview.dart';
import '../../../core/widgets/responsive_helper.dart';
import '../../subscriptions/widgets/subscription_call_dialog.dart';
import '../../../core/app_id_generator.dart';
import '../../../core/widgets/shimmer_loading.dart';

/// Form screen for bulk bookings with white background and app theme.
class BulkBookingView extends StatefulWidget {
  final String initialProduct;
  static bool hasActiveBulkBooking = false;
  static String activePaymentMethod = 'Cash on Delivery';
  static String activeBulkBookingId = 'K8S2T';
  static String activeBookingDateTime = '01 Jun 2026 · 09:05 PM';

  const BulkBookingView({
    super.key,
    this.initialProduct = 'Fresh Cow Milk',
  });

  @override
  State<BulkBookingView> createState() => _BulkBookingViewState();
}

class _BulkBookingViewState extends State<BulkBookingView> {
  bool _isLocalLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _isLocalLoading = false;
        });
      }
    });
  }

  // Multi-product selection maps
  final Map<String, bool> _selectedProducts = {
    'Fresh Cow Milk': true,
    'Fresh Curd': false,
    'Fresh Buttermilk': false,
  };

  final Map<String, String> _productQuantities = {
    'Fresh Cow Milk': '20L',
    'Fresh Curd': '20L',
    'Fresh Buttermilk': '20L',
  };

  final Map<String, TextEditingController> _customQtyControllers = {
    'Fresh Cow Milk': TextEditingController(),
    'Fresh Curd': TextEditingController(),
    'Fresh Buttermilk': TextEditingController(),
  };

  // Address controllers and state
  final TextEditingController _addressController = TextEditingController(
    text: '123, Avinashi Road, Peelamedu, Coimbatore - 641004',
  );
  bool _isEditingAddress = false;

  // Delivery details
  DateTime _deliveryDate = DateTime.now().add(const Duration(days: 1)); // Default tomorrow
  String _selectedTimeSlot = 'Morning (5:00 AM - 9:00 AM)';
  TimeOfDay _customTime = const TimeOfDay(hour: 6, minute: 0);

  final List<String> _qtyOptions = [
    '10L',
    '20L',
    '25L',
    '30L',
    '35L',
    '40L',
    'Custom',
  ];

  final List<String> _timeSlots = [
    'Morning (5:00 AM - 9:00 AM)',
    'Noon (11:00 AM - 1:00 PM)',
    'Evening (5:00 PM - 9:00 PM)',
    'Custom Time',
  ];

  @override
  void dispose() {
    for (var controller in _customQtyControllers.values) {
      controller.dispose();
    }
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _deliveryDate,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: CustomersLoginThemeView.primaryBlue,
              onPrimary: Colors.white,
              onSurface: Color(0xFF1D3557),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _deliveryDate) {
      setState(() {
        _deliveryDate = picked;
      });
    }
  }

  Future<void> _selectCustomTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _customTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: CustomersLoginThemeView.primaryBlue,
              onPrimary: Colors.white,
              onSurface: Color(0xFF1D3557),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _customTime) {
      setState(() {
        _customTime = picked;
      });
    }
  }

  void _callSupport() {
    showSubscriptionCallDialog(context);
  }

  void _navigateToPayment() {
    // Form validations
    final selectedAny = _selectedProducts.values.any((val) => val);
    if (!selectedAny) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red[700],
          content: Text(
            'Please select at least one product',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
          ),
        ),
      );
      return;
    }

    // Validate quantities
    for (var prod in _selectedProducts.keys) {
      if (_selectedProducts[prod] == true) {
        if (_productQuantities[prod] == 'Custom') {
          final customVal = _customQtyControllers[prod]!.text.trim();
          if (customVal.isEmpty || double.tryParse(customVal) == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red[700],
                content: Text(
                  'Please enter a valid custom quantity for $prod',
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                ),
              ),
            );
            return;
          }
        }
      }
    }

    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red[700],
          content: Text(
            'Please specify a delivery address',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
          ),
        ),
      );
      return;
    }

    // Map the products and quantities for display
    final List<Map<String, String>> finalProductsList = [];
    _selectedProducts.forEach((prod, isSel) {
      if (isSel) {
        final qty = _productQuantities[prod] == 'Custom'
            ? '${_customQtyControllers[prod]!.text.trim()}L'
            : _productQuantities[prod]!;
        finalProductsList.add({'name': prod, 'qty': qty});
      }
    });

    final finalTimeStr = _selectedTimeSlot == 'Custom Time'
        ? 'Custom (${_customTime.format(context)})'
        : _selectedTimeSlot;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BulkPaymentSelectionView(
          products: finalProductsList,
          deliveryDate: DateFormat('EEEE, d MMMM y').format(_deliveryDate),
          deliveryTime: finalTimeStr,
          address: _addressController.text.trim(),
        ),
      ),
    );
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
          'Bulk Booking Form',
          style: CustomersLoginThemeView.brandTitleStyle.copyWith(
            fontSize: fs(20),
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.phone_in_talk,
              color: CustomersLoginThemeView.primaryBlue,
              size: scaleF(22),
            ),
            tooltip: 'Call Support',
            onPressed: _callSupport,
          ),
        ],
      ),
      body: _isLocalLoading
          ? _buildBulkBookingSkeleton(context, hPadding, scaleF, fs)
          : Stack(
              children: [
                GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(hPadding, scaleF(8), hPadding, scaleF(100)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Choose Product Header
                  Text(
                    'Select Products (You can choose multiple)',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(14),
                      fontWeight: FontWeight.bold,
                      color: CustomersLoginThemeView.textDark,
                    ),
                  ),
                  SizedBox(height: scaleF(12)),

                  // Product expansion block list
                  Column(
                    children: _selectedProducts.keys.map((prod) {
                      final isSel = _selectedProducts[prod] == true;
                      
                      // Match products with assets (images instead of emojis)
                      String imgPath = 'assets/allbottles.png';
                      if (prod.contains('Buttermilk')) {
                        imgPath = 'assets/100mlbottle.png';
                      }

                      return Container(
                        margin: EdgeInsets.only(bottom: scaleF(12)),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.black,
                            width: isSel ? 2.0 : 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header Row for product card
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedProducts[prod] = !isSel;
                                });
                              },
                              borderRadius: BorderRadius.circular(14),
                              child: Padding(
                                padding: EdgeInsets.all(scaleF(12)),
                                child: Row(
                                  children: [
                                    // Image selector
                                    Container(
                                      width: scaleF(46),
                                      height: scaleF(46),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Colors.black, width: 1.0),
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: Image.asset(imgPath, fit: BoxFit.contain),
                                    ),
                                    SizedBox(width: scaleF(12)),
                                    Expanded(
                                      child: Text(
                                        prod,
                                        style: GoogleFonts.montserrat(
                                          fontSize: fs(13),
                                          fontWeight: FontWeight.bold,
                                          color: CustomersLoginThemeView.textDark,
                                        ),
                                      ),
                                    ),
                                    Checkbox(
                                      value: isSel,
                                      activeColor: CustomersLoginThemeView.primaryBlue,
                                      onChanged: (val) {
                                        setState(() {
                                          _selectedProducts[prod] = val ?? false;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Nested Quantity block if product is selected
                            if (isSel) ...[
                              const Divider(height: 1, thickness: 1.0, color: Colors.black),
                              Padding(
                                padding: EdgeInsets.all(scaleF(14)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Quantity for ${prod.replaceAll('Fresh ', '')}',
                                      style: GoogleFonts.montserrat(
                                        fontSize: fs(11),
                                        fontWeight: FontWeight.bold,
                                        color: CustomersLoginThemeView.textGrey,
                                      ),
                                    ),
                                    SizedBox(height: scaleF(10)),
                                    Wrap(
                                      spacing: scaleF(6),
                                      runSpacing: scaleF(6),
                                      children: _qtyOptions.map((qty) {
                                        final isQtySel = _productQuantities[prod] == qty;
                                        return ChoiceChip(
                                          label: Text(
                                            qty,
                                            style: GoogleFonts.montserrat(
                                              fontSize: fs(11),
                                              fontWeight: FontWeight.bold,
                                              color: isQtySel ? Colors.white : CustomersLoginThemeView.textDark,
                                            ),
                                          ),
                                          selected: isQtySel,
                                          selectedColor: CustomersLoginThemeView.primaryBlue,
                                          backgroundColor: Colors.white,
                                          side: BorderSide(
                                            color: Colors.black, // Standard 1px black side border
                                            width: 1.0,
                                          ),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                          showCheckmark: false,
                                          onSelected: (selected) {
                                            if (selected) {
                                              setState(() {
                                                _productQuantities[prod] = qty;
                                              });
                                            }
                                          },
                                        );
                                      }).toList(),
                                    ),

                                    // Inline custom qty input
                                    if (_productQuantities[prod] == 'Custom') ...[
                                      SizedBox(height: scaleF(10)),
                                      SizedBox(
                                        height: scaleF(44),
                                        child: TextField(
                                          controller: _customQtyControllers[prod],
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            labelText: 'Custom Liters / Kgs',
                                            labelStyle: GoogleFonts.montserrat(fontSize: fs(11), color: CustomersLoginThemeView.textGrey),
                                            filled: true,
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: const BorderSide(color: Colors.black, width: 1.0),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: const BorderSide(color: CustomersLoginThemeView.primaryBlue, width: 1.2),
                                            ),
                                            contentPadding: EdgeInsets.symmetric(horizontal: scaleF(10), vertical: 0),
                                          ),
                                          style: GoogleFonts.montserrat(fontSize: fs(12), fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: scaleF(12)),

                  // 2. Select Date
                  Text(
                    'Select Date of Delivery',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(14),
                      fontWeight: FontWeight.bold,
                      color: CustomersLoginThemeView.textDark,
                    ),
                  ),
                  SizedBox(height: scaleF(10)),

                  InkWell(
                    onTap: () => _selectDate(context),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: EdgeInsets.all(scaleF(14)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.black, width: 1.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month, color: CustomersLoginThemeView.primaryBlue),
                          SizedBox(width: scaleF(12)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Delivery Date',
                                  style: GoogleFonts.montserrat(
                                    fontSize: fs(9),
                                    color: CustomersLoginThemeView.textGrey,
                                  ),
                                ),
                                SizedBox(height: scaleF(2)),
                                Text(
                                  DateFormat('EEEE, d MMMM y').format(_deliveryDate),
                                  style: GoogleFonts.montserrat(
                                    fontSize: fs(12),
                                    fontWeight: FontWeight.bold,
                                    color: CustomersLoginThemeView.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Change',
                            style: GoogleFonts.montserrat(
                              fontSize: fs(11),
                              fontWeight: FontWeight.bold,
                              color: CustomersLoginThemeView.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: scaleF(20)),

                  // 3. Time of Delivery Selector
                  Text(
                    'Delivery Time Slot',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(14),
                      fontWeight: FontWeight.bold,
                      color: CustomersLoginThemeView.textDark,
                    ),
                  ),
                  SizedBox(height: scaleF(10)),

                  Wrap(
                    spacing: scaleF(8),
                    runSpacing: scaleF(8),
                    children: _timeSlots.map((slot) {
                      final isSel = _selectedTimeSlot == slot;
                      return ChoiceChip(
                        label: Text(
                          slot == 'Custom Time' && _selectedTimeSlot == 'Custom Time'
                              ? 'Custom (${_customTime.format(context)})'
                              : slot,
                          style: GoogleFonts.montserrat(
                            fontSize: fs(11),
                            fontWeight: FontWeight.bold,
                            color: isSel ? Colors.white : CustomersLoginThemeView.textDark,
                          ),
                        ),
                        selected: isSel,
                        selectedColor: CustomersLoginThemeView.primaryBlue,
                        backgroundColor: Colors.white,
                        side: BorderSide(
                          color: Colors.black,
                          width: 1.0,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        showCheckmark: false,
                        onSelected: (selected) async {
                          if (selected) {
                            setState(() {
                              _selectedTimeSlot = slot;
                            });
                            if (slot == 'Custom Time') {
                              await _selectCustomTime(context);
                            }
                          }
                        },
                      );
                    }).toList(),
                  ),
                  SizedBox(height: scaleF(20)),

                  // 4. Delivery Address with Edit Pencil
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Delivery Address',
                        style: GoogleFonts.montserrat(
                          fontSize: fs(14),
                          fontWeight: FontWeight.bold,
                          color: CustomersLoginThemeView.textDark,
                        ),
                      ),
                      if (!_isEditingAddress)
                        IconButton(
                          icon: const Icon(Icons.edit, color: CustomersLoginThemeView.primaryBlue, size: 20),
                          tooltip: 'Edit Address',
                          onPressed: () {
                            setState(() {
                              _isEditingAddress = true;
                            });
                          },
                        ),
                    ],
                  ),
                  SizedBox(height: scaleF(4)),

                  if (!_isEditingAddress) ...[
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(scaleF(14)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.black, width: 1.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        _addressController.text.trim(),
                        style: GoogleFonts.montserrat(
                          fontSize: fs(12),
                          fontWeight: FontWeight.w600,
                          color: CustomersLoginThemeView.textDark,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ] else ...[
                    Column(
                      children: [
                        TextField(
                          controller: _addressController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: CustomersLoginThemeView.primaryBlue, width: 1.5),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.black, width: 1.0),
                            ),
                          ),
                          style: GoogleFonts.montserrat(fontSize: fs(12), fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: scaleF(6)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isEditingAddress = false;
                                });
                              },
                              child: Text('Cancel', style: GoogleFonts.montserrat(color: Colors.grey[600], fontWeight: FontWeight.bold)),
                            ),
                            SizedBox(width: scaleF(10)),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: CustomersLoginThemeView.primaryBlue,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              onPressed: () {
                                if (_addressController.text.trim().isNotEmpty) {
                                  setState(() {
                                    _isEditingAddress = false;
                                  });
                                }
                              },
                              child: Text('Save', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: scaleF(20)),
                ],
              ),
            ),
          ),

          // Bottom Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(hPadding, scaleF(12), hPadding, scaleF(16)),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomersLoginThemeView.primaryBlue,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, scaleF(48)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: _navigateToPayment,
                  child: Text(
                    'Continue to Payment',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(14),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulkBookingSkeleton(
    BuildContext context,
    double hPadding,
    double Function(double) scaleF,
    double Function(double) fs,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(hPadding, scaleF(8), hPadding, scaleF(100)),
            children: [
              // Choose Product Title
              const ShimmerSkeleton(width: 250, height: 14, borderRadius: 3),
              SizedBox(height: scaleF(12)),

              // 3 Product card skeletons
              ...List.generate(3, (index) {
                return Container(
                  margin: EdgeInsets.only(bottom: scaleF(12)),
                  padding: EdgeInsets.all(scaleF(12)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black12, width: 1.0),
                  ),
                  child: Row(
                    children: [
                      ShimmerSkeleton(width: scaleF(46), height: scaleF(46), borderRadius: 10),
                      SizedBox(width: scaleF(12)),
                      Expanded(
                        child: ShimmerSkeleton(width: scaleF(120), height: scaleF(14), borderRadius: 3),
                      ),
                      ShimmerSkeleton(width: scaleF(24), height: scaleF(24), borderRadius: 4),
                    ],
                  ),
                );
              }),
              SizedBox(height: scaleF(12)),

              // Address Header
              const ShimmerSkeleton(width: 180, height: 14, borderRadius: 3),
              SizedBox(height: scaleF(10)),

              // Address card box skeleton
              Container(
                padding: EdgeInsets.all(scaleF(14)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.black12, width: 1.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerSkeleton(width: double.infinity, height: scaleF(12), borderRadius: 2),
                    SizedBox(height: scaleF(6)),
                    ShimmerSkeleton(width: scaleF(200), height: scaleF(12), borderRadius: 2),
                  ],
                ),
              ),
              SizedBox(height: scaleF(20)),

              // Date section header
              const ShimmerSkeleton(width: 160, height: 14, borderRadius: 3),
              SizedBox(height: scaleF(10)),

              // Date card skeleton
              Container(
                padding: EdgeInsets.all(scaleF(14)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.black12, width: 1.0),
                ),
                child: Row(
                  children: [
                    ShimmerSkeleton(width: scaleF(24), height: scaleF(24), borderRadius: 12),
                    SizedBox(width: scaleF(12)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerSkeleton(width: scaleF(120), height: scaleF(12), borderRadius: 3),
                        SizedBox(height: scaleF(4)),
                        ShimmerSkeleton(width: scaleF(80), height: scaleF(10), borderRadius: 3),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: scaleF(20)),

              // Time slots header
              const ShimmerSkeleton(width: 140, height: 14, borderRadius: 3),
              SizedBox(height: scaleF(10)),

              // Time slot chips skeletons
              Wrap(
                spacing: scaleF(8),
                runSpacing: scaleF(8),
                children: List.generate(4, (index) {
                  return ShimmerSkeleton(width: scaleF(130), height: scaleF(32), borderRadius: 16);
                }),
              ),
            ],
          ),
        ),

        // Sticky bottom checkout button bar skeleton
        Container(
          padding: EdgeInsets.fromLTRB(hPadding, scaleF(10), hPadding, scaleF(14) + MediaQuery.paddingOf(context).bottom),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.black.withOpacity(0.08), width: 1)),
          ),
          child: ShimmerSkeleton(width: double.infinity, height: scaleF(44), borderRadius: 10),
        ),
      ],
    );
  }
}

/// Themed Payment selection view for secure Bulk booking orders.
class BulkPaymentSelectionView extends StatefulWidget {
  final List<Map<String, String>> products;
  final String deliveryDate;
  final String deliveryTime;
  final String address;

  const BulkPaymentSelectionView({
    super.key,
    required this.products,
    required this.deliveryDate,
    required this.deliveryTime,
    required this.address,
  });

  @override
  State<BulkPaymentSelectionView> createState() => _BulkPaymentSelectionViewState();
}

class _BulkPaymentSelectionViewState extends State<BulkPaymentSelectionView> {
  String _selectedMethod = 'UPI'; // Default online method
  bool _isProcessing = false;

  void _confirmPayment(int finalTotal) {
    setState(() {
      _isProcessing = true;
    });

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
      });

      final bool isCOD = _selectedMethod == 'Cash on Delivery';
      final int finalAmt = isCOD ? 500 : finalTotal;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => BulkOrderSuccessView(
            products: widget.products,
            deliveryDate: widget.deliveryDate,
            deliveryTime: widget.deliveryTime,
            address: widget.address,
            paymentMethod: _selectedMethod,
            finalAmount: finalAmt,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final scaleF = (double val) => ResponsiveHelper.scaledValue(context, val);
    final fs = (double size) => ResponsiveHelper.scaledFontSize(context, size);
    final hPadding = ResponsiveHelper.horizontalPadding(context);

    final bool isCOD = _selectedMethod == 'Cash on Delivery';

    // Calculations for detailed bill
    int subtotal = 0;
    final List<Map<String, dynamic>> calculatedProducts = [];
    for (var p in widget.products) {
      final String qtyStr = p['qty'] ?? '0L';
      final int qty = int.tryParse(qtyStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 20;
      int rate = 60; // Cow Milk default
      if (p['name']!.contains('Curd')) {
        rate = 90;
      } else if (p['name']!.contains('Buttermilk')) {
        rate = 50;
      }
      final int total = qty * rate;
      subtotal += total;
      calculatedProducts.add({
        'name': p['name'],
        'qty': p['qty'],
        'rate': rate,
        'total': total,
      });
    }

    final int gst = (subtotal * 0.05).round();
    final int finalTotal = subtotal + gst;
    final int balanceDue = finalTotal - 500;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: CustomersLoginThemeView.primaryBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Select Payment Method',
          style: GoogleFonts.montserrat(
            fontSize: fs(18),
            fontWeight: FontWeight.bold,
            color: CustomersLoginThemeView.textDark,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(hPadding, scaleF(8), hPadding, scaleF(100)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display summary alert & Detailed Bill
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(scaleF(14)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black, width: 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DETAILED BILL INVOICE',
                        style: GoogleFonts.montserrat(
                          fontSize: fs(11),
                          fontWeight: FontWeight.bold,
                          color: CustomersLoginThemeView.sectionHeadingRed,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...calculatedProducts.map((p) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(p['name']!, style: GoogleFonts.montserrat(fontSize: fs(12), fontWeight: FontWeight.bold)),
                                Text('₹${p['total']}.00', style: GoogleFonts.montserrat(fontSize: fs(12), fontWeight: FontWeight.bold, color: CustomersLoginThemeView.primaryBlue)),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Quantity: ${p['qty']} (Rate: ₹${p['rate']}/L)', style: GoogleFonts.montserrat(fontSize: fs(11), color: CustomersLoginThemeView.textGrey, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ],
                        ),
                      )),
                      const Divider(height: 16, color: Colors.black),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Subtotal:', style: GoogleFonts.montserrat(fontSize: fs(11), color: CustomersLoginThemeView.textGrey, fontWeight: FontWeight.w500)),
                          Text('₹${subtotal}.00', style: GoogleFonts.montserrat(fontSize: fs(11), fontWeight: FontWeight.w600)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('GST (5%):', style: GoogleFonts.montserrat(fontSize: fs(11), color: CustomersLoginThemeView.textGrey, fontWeight: FontWeight.w500)),
                          Text('₹${gst}.00', style: GoogleFonts.montserrat(fontSize: fs(11), fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const Divider(height: 16, color: Colors.black),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Order Value:', style: GoogleFonts.montserrat(fontSize: fs(12), fontWeight: FontWeight.bold)),
                          Text('₹${finalTotal}.00', style: GoogleFonts.montserrat(fontSize: fs(12), fontWeight: FontWeight.bold, color: CustomersLoginThemeView.primaryBlue)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Immediate Advance Due:', style: GoogleFonts.montserrat(fontSize: fs(11), color: CustomersLoginThemeView.textGrey, fontWeight: FontWeight.w500)),
                          Text('₹500.00', style: GoogleFonts.montserrat(fontSize: fs(11), fontWeight: FontWeight.w600, color: CustomersLoginThemeView.primaryBlue)),
                        ],
                      ),
                      if (isCOD) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Balance Due at Doorstep:', style: GoogleFonts.montserrat(fontSize: fs(11), color: Colors.orange[850], fontWeight: FontWeight.bold)),
                            Text('₹${balanceDue}.00', style: GoogleFonts.montserrat(fontSize: fs(11), fontWeight: FontWeight.bold, color: Colors.orange[800])),
                          ],
                        ),
                      ],
                      const Divider(height: 16, color: Colors.black),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Delivery Date:', style: GoogleFonts.montserrat(fontSize: fs(11), color: CustomersLoginThemeView.textGrey, fontWeight: FontWeight.w500)),
                          Text(widget.deliveryDate, style: GoogleFonts.montserrat(fontSize: fs(11), fontWeight: FontWeight.w600)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Time Slot:', style: GoogleFonts.montserrat(fontSize: fs(11), color: CustomersLoginThemeView.textGrey, fontWeight: FontWeight.w500)),
                          Text(widget.deliveryTime, style: GoogleFonts.montserrat(fontSize: fs(11), fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: scaleF(20)),

                Text(
                  'Choose Payment Option',
                  style: GoogleFonts.montserrat(
                    fontSize: fs(14),
                    fontWeight: FontWeight.bold,
                    color: CustomersLoginThemeView.textDark,
                  ),
                ),
                SizedBox(height: scaleF(12)),

                // UPI Selectable Card
                _buildPaymentCard('UPI', 'Google Pay, PhonePe, Paytm', Icons.account_balance_wallet_outlined, scaleF, fs),
                _buildPaymentCard('Debit / Credit Card', 'Visa, Mastercard, RuPay', Icons.credit_card_outlined, scaleF, fs),
                _buildPaymentCard('Net Banking', 'All Indian Banks supported', Icons.account_balance_outlined, scaleF, fs),
                _buildPaymentCard('Cash on Delivery', 'Pay balance at doorstep', Icons.local_atm_outlined, scaleF, fs),

                SizedBox(height: scaleF(20)),

                // Advance Payment details breakdown if COD
                if (isCOD) ...[
                  Container(
                    padding: EdgeInsets.all(scaleF(14)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.black, width: 1.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                            SizedBox(width: scaleF(8)),
                            Text(
                              'COD Advance Required',
                              style: GoogleFonts.montserrat(
                                fontSize: fs(12),
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[950],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: scaleF(6)),
                        Text(
                          'For Cash on Delivery orders, a flat security deposit advance of ₹500 is still required now to secure logistic slots. The remainder order value is paid directly at your doorstep.',
                          style: GoogleFonts.montserrat(
                            fontSize: fs(11),
                            color: CustomersLoginThemeView.textDark,
                            height: 1.4,
                          ),
                        ),
                        const Divider(height: 16, color: Colors.black),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Immediate Advance Due:', style: GoogleFonts.montserrat(fontSize: fs(11), fontWeight: FontWeight.bold)),
                            Text('₹500.00', style: GoogleFonts.montserrat(fontSize: fs(12), fontWeight: FontWeight.bold, color: CustomersLoginThemeView.primaryBlue)),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Cash Due on Delivery:', style: GoogleFonts.montserrat(fontSize: fs(11))),
                            Text('₹${balanceDue}.00', style: GoogleFonts.montserrat(fontSize: fs(11), fontWeight: FontWeight.bold, color: Colors.orange[800])),
                          ],
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Online payments details card
                  Container(
                    padding: EdgeInsets.all(scaleF(14)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.black, width: 1.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.verified_outlined, color: CustomersLoginThemeView.primaryBlue),
                        SizedBox(width: scaleF(10)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Full Payment Online: ₹${finalTotal}.00',
                                style: GoogleFonts.montserrat(
                                  fontSize: fs(12),
                                  fontWeight: FontWeight.bold,
                                  color: CustomersLoginThemeView.primaryBlue,
                                ),
                              ),
                              SizedBox(height: scaleF(4)),
                              Text(
                                'You are paying the full amount of ₹${finalTotal}.00 online now. Secure servers are used to complete transaction.',
                                style: GoogleFonts.montserrat(
                                  fontSize: fs(11),
                                  color: CustomersLoginThemeView.textDark,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Sticky bottom confirm button
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(hPadding, scaleF(12), hPadding, scaleF(16)),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomersLoginThemeView.primaryBlue,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, scaleF(48)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: _isProcessing ? null : () => _confirmPayment(finalTotal),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : Text(
                          isCOD ? 'Confirm Order & Pay ₹500' : 'Pay ₹${finalTotal}.00 Online',
                          style: GoogleFonts.montserrat(
                            fontSize: fs(14),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(String method, String desc, IconData icon, double Function(double) scaleF, double Function(double) fs) {
    final isSel = _selectedMethod == method;
    
    // Choose appropriate emoji matching other screens
    String emoji = '💳';
    if (method.contains('Card')) emoji = '💳';
    if (method.contains('Banking')) emoji = '🏦';
    if (method.contains('Delivery')) emoji = '🚚';

    return AnimatedScale(
      scale: isSel ? 1.01 : 1.0,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        margin: EdgeInsets.only(bottom: scaleF(10)),
        decoration: BoxDecoration(
          color: isSel
              ? CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.04)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.black,
            width: isSel ? 2.0 : 1.0,
          ),
          boxShadow: isSel
              ? [
                  BoxShadow(
                    color: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: ListTile(
          onTap: () {
            setState(() {
              _selectedMethod = method;
            });
          },
          leading: Text(emoji, style: TextStyle(fontSize: fs(24))),
          title: Text(
            method,
            style: GoogleFonts.montserrat(
              fontSize: fs(14),
              fontWeight: FontWeight.bold,
              color: CustomersLoginThemeView.textDark,
            ),
          ),
          subtitle: Text(
            desc,
            style: GoogleFonts.montserrat(
              fontSize: fs(11),
              color: CustomersLoginThemeView.textGrey,
            ),
          ),
          trailing: Radio<String>(
            value: method,
            groupValue: _selectedMethod,
            activeColor: CustomersLoginThemeView.primaryBlue,
            onChanged: (val) {
              setState(() {
                _selectedMethod = val ?? '';
              });
            },
          ),
        ),
      ),
    );
  }
}

/// Simulated payment success screen specifically for bulk bookings.
/// Removed summary ticket and customized exactly like standard PaymentSuccessView.
class BulkOrderSuccessView extends StatefulWidget {
  final List<Map<String, String>> products;
  final String deliveryDate;
  final String deliveryTime;
  final String address;
  final String paymentMethod;
  final int finalAmount;

  const BulkOrderSuccessView({
    super.key,
    required this.products,
    required this.deliveryDate,
    required this.deliveryTime,
    required this.address,
    required this.paymentMethod,
    required this.finalAmount,
  });

  @override
  State<BulkOrderSuccessView> createState() => _BulkOrderSuccessViewState();
}

class _BulkOrderSuccessViewState extends State<BulkOrderSuccessView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    BulkBookingView.hasActiveBulkBooking = true;
    BulkBookingView.activePaymentMethod = widget.paymentMethod;
    BulkBookingView.activeBulkBookingId = AppIdGenerator.generate5CharId();
    BulkBookingView.activeBookingDateTime = DateFormat('dd MMM yyyy · hh:mm a').format(DateTime.now());
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    );
    _controller.forward();

    // Auto navigate back to home after 2500ms, exactly like the standard PaymentSuccessView
    Future<void>.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scaleF = (double val) => ResponsiveHelper.scaledValue(context, val);
    final fs = (double size) => ResponsiveHelper.scaledFontSize(context, size);
    final hPadding = ResponsiveHelper.horizontalPadding(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: hPadding),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ScaleTransition(
                          scale: _scale,
                          child: Lottie.asset(
                            'assets/animations/paymentsuccess.json',
                            width: scaleF(160),
                            height: scaleF(160),
                            fit: BoxFit.contain,
                            repeat: false,
                          ),
                        ),
                        SizedBox(height: scaleF(24)),
                        Text(
                          'Bulk Order Placed Successfully',
                          style: GoogleFonts.montserrat(
                            fontSize: fs(22),
                            fontWeight: FontWeight.w800,
                            color: CustomersLoginThemeView.primaryBlue,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: scaleF(8)),
                        Text(
                          widget.paymentMethod == 'Cash on Delivery'
                              ? 'Advance payment of ₹500 confirmed via Cash on Delivery'
                              : 'Full payment of ₹${widget.finalAmount} confirmed via ${widget.paymentMethod}',
                          style: GoogleFonts.montserrat(
                            fontSize: fs(14),
                            fontWeight: FontWeight.w500,
                            color: CustomersLoginThemeView.textGrey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
