import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/customers_login_themeview.dart';
import '../../core/widgets/responsive_helper.dart';
import '../viewmodels/customers_profile_viewmodel.dart';

class AddAddressView extends StatefulWidget {
  const AddAddressView({super.key});

  @override
  State<AddAddressView> createState() => _AddAddressViewState();
}

class _AddAddressViewState extends State<AddAddressView> {
  final _houseNoController = TextEditingController();
  final _apartmentController = TextEditingController();
  final _streetController = TextEditingController();
  final _pincodeController = TextEditingController();

  String _selectedLabel = 'Home';
  final List<String> _labels = ['Home', 'Office', 'Other Places'];

  bool _isFetchingGPS = false;
  String _deliveryPreference = 'Deliver Here (Primary)';

  @override
  void dispose() {
    _houseNoController.dispose();
    _apartmentController.dispose();
    _streetController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  void _fetchGPSLocation() async {
    setState(() => _isFetchingGPS = true);

    // Mock GPS retrieval delay
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() {
      _isFetchingGPS = false;
      _houseNoController.text = 'B-302';
      _apartmentController.text = 'Green Meadows';
      _streetController.text = 'Vadavalli';
      _pincodeController.text = '641041';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Location fetched successfully via GPS!',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _save() {
    final house = _houseNoController.text.trim();
    final apt = _apartmentController.text.trim();
    final street = _streetController.text.trim();
    final pin = _pincodeController.text.trim();

    if (house.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'House No. / Flat / Villa is required.',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
          ),
          backgroundColor: CustomersLoginThemeView.sectionHeadingRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (apt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Apartment / Society Name / Landmark is required.',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
          ),
          backgroundColor: CustomersLoginThemeView.sectionHeadingRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (street.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Street Name / Area Name is required.',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
          ),
          backgroundColor: CustomersLoginThemeView.sectionHeadingRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (pin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pincode is required.',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
          ),
          backgroundColor: CustomersLoginThemeView.sectionHeadingRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final pincodeRegex = RegExp(r'^\d{6}$');
    if (!pincodeRegex.hasMatch(pin)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pincode must be exactly 6 digits.',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
          ),
          backgroundColor: CustomersLoginThemeView.sectionHeadingRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Dispatch event to BLoC to update profile details
    context.read<CustomersProfileViewModel>().add(
          ProfileFieldChanged(
            houseNo: house,
            apartmentName: apt,
            street: street,
            pincode: pin,
            deliveryPreference: _deliveryPreference,
          ),
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Address saved successfully as $_selectedLabel!',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.of(context).pop();
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
          'Add More Address',
          style: CustomersLoginThemeView.brandTitleStyle.copyWith(
            fontSize: fs(20),
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: EdgeInsets.fromLTRB(hPadding, scaleF(16), hPadding, scaleF(32)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown selection for label
            Text(
              'Address Label / Type',
              style: GoogleFonts.montserrat(
                fontSize: fs(14),
                fontWeight: FontWeight.bold,
                color: CustomersLoginThemeView.textDark,
              ),
            ),
            SizedBox(height: scaleF(8)),
            Container(
              padding: EdgeInsets.symmetric(horizontal: scaleF(12)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: CustomersLoginThemeView.borderColor,
                  width: 1.2,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedLabel,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down, color: CustomersLoginThemeView.primaryBlue),
                  style: GoogleFonts.montserrat(
                    fontSize: fs(14),
                    fontWeight: FontWeight.w600,
                    color: CustomersLoginThemeView.textDark,
                  ),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedLabel = val);
                    }
                  },
                  items: _labels.map((lbl) {
                    return DropdownMenuItem<String>(
                      value: lbl,
                      child: Text(lbl),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: scaleF(20)),

            // Fetch Current Location Button
            SizedBox(
              width: double.infinity,
              height: scaleF(44),
              child: OutlinedButton.icon(
                onPressed: _isFetchingGPS ? null : _fetchGPSLocation,
                icon: _isFetchingGPS
                    ? SizedBox(
                        width: scaleF(16),
                        height: scaleF(16),
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: CustomersLoginThemeView.primaryBlue,
                        ),
                      )
                    : const Icon(Icons.my_location, size: 18),
                label: Text(
                  _isFetchingGPS ? 'Fetching Location...' : 'Use Current GPS Location',
                  style: GoogleFonts.montserrat(
                    fontSize: fs(13),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: CustomersLoginThemeView.primaryBlue,
                  side: const BorderSide(
                    color: CustomersLoginThemeView.primaryBlue,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            SizedBox(height: scaleF(16)),

            Row(
              children: [
                Expanded(child: Divider(color: CustomersLoginThemeView.borderColor)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'OR FILL MANUALLY',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(10),
                      fontWeight: FontWeight.bold,
                      color: CustomersLoginThemeView.textGrey,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: CustomersLoginThemeView.borderColor)),
              ],
            ),
            SizedBox(height: scaleF(20)),

            // Manual inputs
            _buildInputField(
              controller: _houseNoController,
              label: 'House No. / Flat / Villa',
              hint: 'e.g. B-302',
              scaleF: scaleF,
              fs: fs,
            ),
            SizedBox(height: scaleF(14)),

            _buildInputField(
              controller: _apartmentController,
              label: 'Apartment / Society Name / Landmark',
              hint: 'e.g. Green Meadows',
              scaleF: scaleF,
              fs: fs,
            ),
            SizedBox(height: scaleF(14)),

            _buildInputField(
              controller: _streetController,
              label: 'Street Name / Area Name *',
              hint: 'e.g. Vadavalli',
              scaleF: scaleF,
              fs: fs,
            ),
            SizedBox(height: scaleF(14)),

             _buildInputField(
              controller: _pincodeController,
              label: 'Pincode *',
              hint: 'e.g. 641041',
              scaleF: scaleF,
              fs: fs,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
            ),
            SizedBox(height: scaleF(20)),

            Text(
              'Delivery Preference',
              style: GoogleFonts.montserrat(
                fontSize: fs(13),
                fontWeight: FontWeight.bold,
                color: CustomersLoginThemeView.textDark,
              ),
            ),
            SizedBox(height: scaleF(8)),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _deliveryPreference = 'Deliver Here (Primary)';
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: scaleF(12)),
                      decoration: BoxDecoration(
                        color: _deliveryPreference == 'Deliver Here (Primary)'
                            ? CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.08)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _deliveryPreference == 'Deliver Here (Primary)'
                              ? CustomersLoginThemeView.primaryBlue
                              : CustomersLoginThemeView.borderColor,
                          width: _deliveryPreference == 'Deliver Here (Primary)' ? 1.8 : 1.2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.home_outlined,
                            color: _deliveryPreference == 'Deliver Here (Primary)'
                                ? CustomersLoginThemeView.primaryBlue
                                : CustomersLoginThemeView.textGrey,
                          ),
                          SizedBox(height: scaleF(4)),
                          Text(
                            'Deliver Here\n(Primary)',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              fontSize: fs(11),
                              fontWeight: FontWeight.bold,
                              color: _deliveryPreference == 'Deliver Here (Primary)'
                                  ? CustomersLoginThemeView.primaryBlue
                                  : CustomersLoginThemeView.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: scaleF(12)),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _deliveryPreference = 'Deliver to Both Places';
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: scaleF(12)),
                      decoration: BoxDecoration(
                        color: _deliveryPreference == 'Deliver to Both Places'
                            ? CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.08)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _deliveryPreference == 'Deliver to Both Places'
                              ? CustomersLoginThemeView.primaryBlue
                              : CustomersLoginThemeView.borderColor,
                          width: _deliveryPreference == 'Deliver to Both Places' ? 1.8 : 1.2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.local_shipping_outlined,
                            color: _deliveryPreference == 'Deliver to Both Places'
                                ? CustomersLoginThemeView.primaryBlue
                                : CustomersLoginThemeView.textGrey,
                          ),
                          SizedBox(height: scaleF(4)),
                          Text(
                            'Deliver to\nBoth Places',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              fontSize: fs(11),
                              fontWeight: FontWeight.bold,
                              color: _deliveryPreference == 'Deliver to Both Places'
                                  ? CustomersLoginThemeView.primaryBlue
                                  : CustomersLoginThemeView.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: scaleF(28)),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: scaleF(48).clamp(42.0, 54.0),
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomersLoginThemeView.primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Save Address',
                  style: GoogleFonts.montserrat(
                    fontSize: fs(14),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required double Function(double) scaleF,
    required double Function(double) fs,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: fs(13),
            fontWeight: FontWeight.bold,
            color: CustomersLoginThemeView.textDark,
          ),
        ),
        SizedBox(height: scaleF(6)),
        Container(
          padding: EdgeInsets.symmetric(horizontal: scaleF(12)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: CustomersLoginThemeView.borderColor,
              width: 1.2,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            style: GoogleFonts.montserrat(
              fontSize: fs(14),
              color: CustomersLoginThemeView.textDark,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.montserrat(
                fontSize: fs(13),
                color: CustomersLoginThemeView.textGrey,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: scaleF(10)),
            ),
          ),
        ),
      ],
    );
  }
}
