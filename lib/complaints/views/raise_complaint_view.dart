import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../theme/customers_login_themeview.dart';
import '../../core/widgets/responsive_helper.dart';
import '../viewmodels/complaints_viewmodel.dart';
import '../models/complaint_model.dart';

class RaiseComplaintView extends StatefulWidget {
  final ComplaintsViewModel viewModel;

  const RaiseComplaintView({super.key, required this.viewModel});

  @override
  State<RaiseComplaintView> createState() => _RaiseComplaintViewState();
}

class _RaiseComplaintViewState extends State<RaiseComplaintView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _descriptionController = TextEditingController();
  final List<String> _categories = [
    'Late Delivery',
    'Wrong Quantity',
    'Sour Milk',
    'Broken Bottle',
    'Other',
  ];
  int _selectedCategoryIndex = 0;
  bool _isSubmitting = false;

  // Voice recording & autofill simulation states
  bool _hasVoiceAttachment = false;
  bool _isPlayingVoice = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _startVoiceAutofill() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Listening...',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: CustomersLoginThemeView.primaryBlue,
                ),
              ),
              const SizedBox(height: 24),
              const SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  color: CustomersLoginThemeView.primaryBlue,
                  strokeWidth: 4,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Speak now to describe your issue...',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: CustomersLoginThemeView.textGrey,
                ),
              ),
            ],
          ),
        );
      },
    );

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        Navigator.pop(context);
        setState(() {
          _descriptionController.text =
              'The milk delivered this morning was sour and delivery was delayed by 30 minutes. Please check this.';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Voice note transcribed successfully!',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  void _recordVoiceAttachment() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Recording Voice Note...',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: CustomersLoginThemeView.sectionHeadingRed,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(8, (i) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 6,
                    height: 20.0 + (i % 3 * 15.0),
                    decoration: BoxDecoration(
                      color: CustomersLoginThemeView.sectionHeadingRed,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              Text(
                'Recording message for support...',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: CustomersLoginThemeView.textGrey,
                ),
              ),
            ],
          ),
        );
      },
    );

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        Navigator.pop(context);
        setState(() {
          _hasVoiceAttachment = true;
          _isPlayingVoice = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Voice note recorded and attached!',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
            ),
            backgroundColor: CustomersLoginThemeView.primaryBlue,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  void _submit() async {
    final desc = _descriptionController.text.trim();
    if (desc.isEmpty && !_hasVoiceAttachment) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: CustomersLoginThemeView.sectionHeadingRed,
          content: Text(
            'Please write a description or record a voice note for your issue.',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
          ),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 1000));

    final finalDesc = _hasVoiceAttachment
        ? (desc.isNotEmpty ? '$desc\n[Voice Note (0:12) Attached]' : '[Voice Note (0:12) Attached]')
        : desc;

    widget.viewModel.raiseComplaint(
      _categories[_selectedCategoryIndex],
      finalDesc,
    );

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _descriptionController.clear();
      _selectedCategoryIndex = 0;
      _hasVoiceAttachment = false;
      _isPlayingVoice = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
        content: Text(
          'Complaint raised successfully! Our support team is on it.',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
        ),
      ),
    );

    // Switch to history tab to see new complaint
    _tabController.animateTo(1);
  }

  @override
  Widget build(BuildContext context) {
    final scaleF = (double val) => ResponsiveHelper.scaledValue(context, val);
    final fs = (double size) => ResponsiveHelper.scaledFontSize(context, size);
    final hPadding = ResponsiveHelper.horizontalPadding(context);

    return AnimatedBuilder(
      animation: widget.viewModel,
      builder: (context, _) {
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
              'Help & Complaints',
              style: CustomersLoginThemeView.brandTitleStyle.copyWith(
                fontSize: fs(20),
                letterSpacing: 0.5,
              ),
            ),
            centerTitle: true,
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: CustomersLoginThemeView.primaryBlue,
              labelColor: CustomersLoginThemeView.primaryBlue,
              unselectedLabelColor: CustomersLoginThemeView.textGrey,
              labelStyle: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                fontSize: fs(13),
              ),
              unselectedLabelStyle: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
                fontSize: fs(13),
              ),
              tabs: const [
                Tab(text: 'Raise Complaint'),
                Tab(text: 'Complaint History'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            physics: const BouncingScrollPhysics(),
            children: [
              // 1. Raise Complaint Tab
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                padding: EdgeInsets.fromLTRB(hPadding, scaleF(16), hPadding, scaleF(24)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Calling Support Card with Copy Button
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: scaleF(14), vertical: scaleF(8)),
                      decoration: BoxDecoration(
                        color: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.phone_in_talk_outlined, color: CustomersLoginThemeView.primaryBlue, size: scaleF(20)),
                          SizedBox(width: scaleF(10)),
                          Expanded(
                            child: Text(
                              'Need immediate help? Call us at +91 93610 51718',
                              style: GoogleFonts.montserrat(
                                fontSize: fs(11),
                                fontWeight: FontWeight.bold,
                                color: CustomersLoginThemeView.primaryBlue,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.copy_rounded, color: CustomersLoginThemeView.primaryBlue, size: scaleF(18)),
                            onPressed: () {
                              Clipboard.setData(const ClipboardData(text: '9361051718'));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Support phone number copied!',
                                    style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                                  ),
                                  backgroundColor: CustomersLoginThemeView.primaryBlue,
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: scaleF(20)),

                    Text(
                      'What issue are you facing?',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(15),
                        fontWeight: FontWeight.w800,
                        color: CustomersLoginThemeView.textDark,
                      ),
                    ),
                    SizedBox(height: scaleF(6)),
                    Text(
                      'Select a category that best describes your problem.',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(12),
                        color: CustomersLoginThemeView.textGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: scaleF(14)),

                    // Category Selection Chips
                    Wrap(
                      spacing: scaleF(8),
                      runSpacing: scaleF(8),
                      children: List.generate(_categories.length, (index) {
                        final selected = _selectedCategoryIndex == index;
                        return ChoiceChip(
                          label: Text(_categories[index]),
                          selected: selected,
                          onSelected: (val) {
                            if (val) {
                              setState(() => _selectedCategoryIndex = index);
                            }
                          },
                          selectedColor: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.1),
                          checkmarkColor: CustomersLoginThemeView.primaryBlue,
                          backgroundColor: Colors.white,
                          labelStyle: GoogleFonts.montserrat(
                            fontSize: fs(11),
                            fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                            color: selected
                                ? CustomersLoginThemeView.primaryBlue
                                : CustomersLoginThemeView.textDark,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: selected
                                  ? CustomersLoginThemeView.primaryBlue
                                  : CustomersLoginThemeView.borderColor,
                              width: selected ? 1.5 : 1.0,
                            ),
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: scaleF(24)),

                    Text(
                      'Explain the problem in detail',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(15),
                        fontWeight: FontWeight.w800,
                        color: CustomersLoginThemeView.textDark,
                      ),
                    ),
                    SizedBox(height: scaleF(10)),

                    // Input Box with Voice Autofill (Microphone Icon)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: CustomersLoginThemeView.borderColor,
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _descriptionController,
                              maxLines: 6,
                              style: GoogleFonts.montserrat(
                                fontSize: fs(14),
                                color: CustomersLoginThemeView.textDark,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Please write your delivery house details, order ID (if any), timings or other details to help us solve the issue fast.',
                                hintStyle: GoogleFonts.montserrat(
                                  fontSize: fs(12),
                                  color: CustomersLoginThemeView.textGrey,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(scaleF(14)),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.mic_rounded, color: CustomersLoginThemeView.primaryBlue),
                            tooltip: 'Autofill with Voice',
                            onPressed: _startVoiceAutofill,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: scaleF(14)),

                    // Send Voice Note Recorder
                    if (!_hasVoiceAttachment)
                      OutlinedButton.icon(
                        onPressed: _recordVoiceAttachment,
                        icon: const Icon(Icons.mic_none_outlined, size: 18),
                        label: Text(
                          'Record & Send Voice Message',
                          style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: CustomersLoginThemeView.primaryBlue,
                          side: const BorderSide(color: CustomersLoginThemeView.primaryBlue, width: 1.2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      )
                    else
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: scaleF(12), vertical: scaleF(8)),
                        decoration: BoxDecoration(
                          color: CustomersLoginThemeView.sectionHeadingRed.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: CustomersLoginThemeView.sectionHeadingRed.withValues(alpha: 0.16),
                          ),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                _isPlayingVoice ? Icons.pause_circle_filled : Icons.play_circle_fill,
                                color: CustomersLoginThemeView.sectionHeadingRed,
                                size: scaleF(28),
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPlayingVoice = !_isPlayingVoice;
                                });
                              },
                            ),
                            SizedBox(width: scaleF(6)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Voice Note (0:12)',
                                    style: GoogleFonts.montserrat(
                                      fontSize: fs(11),
                                      fontWeight: FontWeight.bold,
                                      color: CustomersLoginThemeView.sectionHeadingRed,
                                    ),
                                  ),
                                  SizedBox(height: scaleF(4)),
                                  LinearProgressIndicator(
                                    value: _isPlayingVoice ? 0.6 : 0.0,
                                    color: CustomersLoginThemeView.sectionHeadingRed,
                                    backgroundColor: CustomersLoginThemeView.borderColor,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline, color: CustomersLoginThemeView.textGrey),
                              onPressed: () {
                                setState(() {
                                  _hasVoiceAttachment = false;
                                  _isPlayingVoice = false;
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                    SizedBox(height: scaleF(28)),

                    SizedBox(
                      width: double.infinity,
                      height: scaleF(48).clamp(42.0, 54.0),
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CustomersLoginThemeView.primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSubmitting
                            ? SizedBox(
                                width: scaleF(20),
                                height: scaleF(20),
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Submit Complaint',
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

              // 2. Complaint History Tab
              _buildHistoryTab(scaleF, fs, hPadding),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryTab(
    double Function(double) scaleF,
    double Function(double) fs,
    double hPadding,
  ) {
    final list = widget.viewModel.complaints;
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.done_all_rounded,
              color: CustomersLoginThemeView.textGrey,
              size: scaleF(48),
            ),
            SizedBox(height: scaleF(10)),
            Text(
              'No complaints registered',
              style: GoogleFonts.montserrat(
                fontSize: fs(14),
                fontWeight: FontWeight.bold,
                color: CustomersLoginThemeView.textGrey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: EdgeInsets.fromLTRB(hPadding, scaleF(16), hPadding, scaleF(24)),
      itemCount: list.length,
      separatorBuilder: (_, __) => SizedBox(height: scaleF(12)),
      itemBuilder: (context, index) {
        final cmp = list[index];
        final isResolved = cmp.status == 'Resolved';
        final statusColor = isResolved ? Colors.green : Colors.orange;
        final dateStr = DateFormat('dd MMM yyyy · hh:mm a').format(cmp.date);

        return Container(
          padding: EdgeInsets.all(scaleF(14)),
          decoration: CustomersLoginThemeView.cardDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      cmp.id,
                      style: GoogleFonts.montserrat(
                        fontSize: fs(11),
                        fontWeight: FontWeight.bold,
                        color: CustomersLoginThemeView.primaryBlue,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      cmp.status,
                      style: GoogleFonts.montserrat(
                        fontSize: fs(11),
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: scaleF(10)),
              Text(
                cmp.category,
                style: GoogleFonts.montserrat(
                  fontSize: fs(14),
                  fontWeight: FontWeight.bold,
                  color: CustomersLoginThemeView.sectionHeadingRed,
                ),
              ),
              SizedBox(height: scaleF(2)),
              Text(
                dateStr,
                style: GoogleFonts.montserrat(
                  fontSize: fs(10),
                  color: CustomersLoginThemeView.textGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: scaleF(8)),
              Text(
                cmp.description,
                style: GoogleFonts.montserrat(
                  fontSize: fs(12),
                  color: CustomersLoginThemeView.textDark,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
              if (cmp.reply != null) ...[
                Divider(
                  color: CustomersLoginThemeView.borderColor.withValues(alpha: 0.4),
                  height: scaleF(20),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.support_agent,
                      color: CustomersLoginThemeView.primaryBlue,
                      size: scaleF(20),
                    ),
                    SizedBox(width: scaleF(8)),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(scaleF(10)),
                        decoration: BoxDecoration(
                          color: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Support Agent Reply',
                              style: GoogleFonts.montserrat(
                                fontSize: fs(11),
                                fontWeight: FontWeight.bold,
                                color: CustomersLoginThemeView.primaryBlue,
                              ),
                            ),
                            SizedBox(height: scaleF(4)),
                            Text(
                              cmp.reply!,
                              style: GoogleFonts.montserrat(
                                fontSize: fs(11.5),
                                color: CustomersLoginThemeView.textDark,
                                fontWeight: FontWeight.w500,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
