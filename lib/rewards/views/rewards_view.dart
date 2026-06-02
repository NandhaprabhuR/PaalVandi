import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../../cart/models/order_history_model.dart';
import '../../core/widgets/responsive_helper.dart';
import '../../theme/customers_login_themeview.dart';
import '../../bottomnavigation/home_shell_scope.dart';
import '../models/plant_option.dart';
import '../viewmodels/rewards_viewmodel.dart';
import '../../core/widgets/shimmer_loading.dart';

class RewardsView extends StatefulWidget {
  final RewardsViewModel viewModel;

  const RewardsView({super.key, required this.viewModel});

  @override
  State<RewardsView> createState() => _RewardsViewState();
}

class _RewardsViewState extends State<RewardsView> {
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

  void _showLockedBottomSheetPopup(
    BuildContext context,
    double Function(double) scaleF,
    double Function(double) fs,
    int remainingOrders,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (sheetContext) {
        return Container(
          padding: EdgeInsets.fromLTRB(scaleF(20), scaleF(20), scaleF(20), scaleF(24)),
          decoration: BoxDecoration(
            color: CustomersLoginThemeView.cardBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            border: Border.all(color: Colors.black, width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/animations/pendingorders.json',
                height: scaleF(120),
                fit: BoxFit.contain,
              ),
              SizedBox(height: scaleF(16)),
              Text(
                'Rewards Still Locked! ',
                style: GoogleFonts.montserrat(
                  fontSize: fs(18),
                  fontWeight: FontWeight.bold,
                  color: CustomersLoginThemeView.textDark,
                ),
              ),
              SizedBox(height: scaleF(8)),
              Text(
                'You still need $remainingOrders more qualified daily order(s) of 500ml/g or above to get a free plant!',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: fs(13),
                  fontWeight: FontWeight.w500,
                  color: CustomersLoginThemeView.textGrey,
                  height: 1.4,
                ),
              ),
              SizedBox(height: scaleF(20)),
              GestureDetector(
                onTap: () {
                  Navigator.of(sheetContext).pop(); // dismiss bottom sheet popup using sheetContext
                  HomeShellScope.of(context).onTabSelected(0); // switch to Home tab using parent context
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: scaleF(14)),
                  decoration: BoxDecoration(
                    color: CustomersLoginThemeView.primaryBlue,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.local_mall_outlined, color: Colors.white, size: scaleF(18)),
                        SizedBox(width: scaleF(8)),
                        Text(
                          'Get Fresh Milk',
                          style: GoogleFonts.montserrat(
                            fontSize: fs(14),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFullScreenUnlockSuccess() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.white,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, _, __) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Lottie.asset(
              'assets/animations/rewardunlocked.json',
              fit: BoxFit.contain,
              repeat: false,
            ),
          ),
        );
      },
    );

    // Auto dismiss after 2.6 seconds
    Future.delayed(const Duration(milliseconds: 2600), () {
      if (mounted) {
        Navigator.of(context).pop(); // pop general dialog success overlay
        widget.viewModel.claimReward(); // set viewModel claimed state
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scaleF = (double val) => ResponsiveHelper.scaledValue(context, val);
    final fs = (double size) => ResponsiveHelper.scaledFontSize(context, size);
    final hPadding = ResponsiveHelper.horizontalPadding(context);

    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final qOrders = widget.viewModel.qualifiedOrders;
        final isUnlocked = widget.viewModel.isUnlocked;
        final selectedId = widget.viewModel.selectedPlantId;
        final isClaimed = widget.viewModel.isClaimed;

        return Scaffold(
          backgroundColor: CustomersLoginThemeView.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: CustomersLoginThemeView.scaffoldBackgroundColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false, // top-level bottom nav tab
            centerTitle: true,
            title: Text(
              'Go Green Rewards',
              style: CustomersLoginThemeView.brandTitleStyle.copyWith(
                fontSize: fs(20),
                letterSpacing: 0.5,
              ),
            ),
          ),
          body: _isLocalLoading
              ? _buildRewardsSkeleton(context, hPadding, scaleF, fs)
              : ListView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            padding: EdgeInsets.fromLTRB(hPadding, scaleF(8), hPadding, scaleF(32)),
            children: [
              // Go Green visual banner card with gohealthyplants.json animation
              Container(
                padding: EdgeInsets.all(scaleF(14)),
                decoration: CustomersLoginThemeView.cardDecoration,
                child: Column(
                  children: [
                    Lottie.asset(
                      'assets/animations/gohealthyplants.json',
                      height: scaleF(110),
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: scaleF(8)),
                    Text(
                      'Go Green, Go Healthy! 🌿',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(18),
                        fontWeight: FontWeight.bold,
                        color: CustomersLoginThemeView.primaryBlue,
                      ),
                    ),
                    SizedBox(height: scaleF(4)),
                    Text(
                      'Complete 5 qualified orders of 500ml/g or more and claim a premium flower plant for FREE on your 6th delivery!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: fs(12),
                        fontWeight: FontWeight.w500,
                        color: CustomersLoginThemeView.textGrey,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: scaleF(20)),

              // Horizontal milestones progress timeline
              Text(
                'Your Milestone Progress',
                style: GoogleFonts.montserrat(
                  fontSize: fs(15),
                  fontWeight: FontWeight.bold,
                  color: CustomersLoginThemeView.textDark,
                ),
              ),
              SizedBox(height: scaleF(12)),
              _buildMilestoneTimeline(scaleF, fs, qOrders),
              SizedBox(height: scaleF(24)),

              // Plants grid title (locked yellow bar badge completely removed)
              Text(
                'Choose Your Reward Plant',
                style: GoogleFonts.montserrat(
                  fontSize: fs(15),
                  fontWeight: FontWeight.bold,
                  color: CustomersLoginThemeView.textDark,
                ),
              ),
              SizedBox(height: scaleF(4)),
              Text(
                isUnlocked
                    ? 'Pick 1 out of 4 flower plants to deliver with your 6th order:'
                    : 'Earn 5 qualified orders to unlock plant selection:',
                style: GoogleFonts.montserrat(
                  fontSize: fs(11),
                  fontWeight: FontWeight.w500,
                  color: CustomersLoginThemeView.textGrey,
                ),
              ),
              SizedBox(height: scaleF(12)),

              // Plant grid wrapped in a Stack with a centered locked button overlay
              Stack(
                alignment: Alignment.center,
                children: [
                  IgnorePointer(
                    ignoring: !isUnlocked,
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.viewModel.plantOptions.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: scaleF(12),
                        mainAxisSpacing: scaleF(12),
                        childAspectRatio: 0.82,
                      ),
                      itemBuilder: (context, index) {
                        final plant = widget.viewModel.plantOptions[index];
                        final isSelected = selectedId == plant.id;
                        return _buildPlantCard(scaleF, fs, plant, isUnlocked, isSelected);
                      },
                    ),
                  ),

                  // Single central unlock/lock button in the center of the plants grid
                  if (!isUnlocked)
                    GestureDetector(
                      onTap: () => _showLockedBottomSheetPopup(context, scaleF, fs, 5 - qOrders.length),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: scaleF(16), vertical: scaleF(12)),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.black, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lock, color: CustomersLoginThemeView.sectionHeadingRed, size: scaleF(16)),
                            SizedBox(width: scaleF(8)),
                            Text(
                              'Locked (Earn ${5 - qOrders.length} More Order(s))',
                              style: GoogleFonts.montserrat(
                                fontSize: fs(12),
                                fontWeight: FontWeight.bold,
                                color: CustomersLoginThemeView.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: scaleF(20)),

              // Locking / confirmation area
              if (!isUnlocked) ...[
                Container(
                  padding: EdgeInsets.all(scaleF(14)),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: CustomersLoginThemeView.textGrey, size: scaleF(20)),
                      SizedBox(width: scaleF(12)),
                      Expanded(
                        child: Text(
                          'You need ${5 - qOrders.length} more qualified order(s) to unlock these organic flower plant rewards. Order daily and go green!',
                          style: GoogleFonts.montserrat(
                            fontSize: fs(11),
                            fontWeight: FontWeight.w500,
                            color: CustomersLoginThemeView.textGrey,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                if (isClaimed) ...[
                  // Reward claimed banner
                  Container(
                    padding: EdgeInsets.all(scaleF(14)),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green, width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green, size: 22),
                            SizedBox(width: scaleF(8)),
                            Expanded(
                              child: Text(
                                'Reward Plant Locked In!',
                                style: GoogleFonts.montserrat(
                                  fontSize: fs(14),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: scaleF(6)),
                        Text(
                          'You will receive your selected plant at hand while coming to the 6th delivery of orders! Go Green, Go Healthy! 🌿',
                          style: GoogleFonts.montserrat(
                            fontSize: fs(11),
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade800,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Rating feedback form stars and comment box
                  SizedBox(height: scaleF(20)),
                  Container(
                    padding: EdgeInsets.all(scaleF(14)),
                    decoration: BoxDecoration(
                      color: CustomersLoginThemeView.cardBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rate Your Go Green Experience ⭐',
                          style: GoogleFonts.montserrat(
                            fontSize: fs(14),
                            fontWeight: FontWeight.bold,
                            color: CustomersLoginThemeView.textDark,
                          ),
                        ),
                        SizedBox(height: scaleF(4)),
                        Text(
                          'We value your feedback! Rate us and suggest any improvements.',
                          style: GoogleFonts.montserrat(
                            fontSize: fs(11),
                            fontWeight: FontWeight.w500,
                            color: CustomersLoginThemeView.textGrey,
                          ),
                        ),
                        SizedBox(height: scaleF(12)),
                        
                        // 5 Interactive stars
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            final starVal = index + 1;
                            final hasStar = widget.viewModel.rating >= starVal;
                            return GestureDetector(
                              onTap: widget.viewModel.isReviewSubmitted
                                  ? null
                                  : () => widget.viewModel.setRating(starVal),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: scaleF(6)),
                                child: Icon(
                                  hasStar ? Icons.star : Icons.star_border,
                                  color: hasStar ? Colors.amber : Colors.grey,
                                  size: scaleF(32),
                                ),
                              ),
                            );
                          }),
                        ),
                        SizedBox(height: scaleF(16)),
                        
                        // Comment Text Box
                        TextField(
                          maxLines: 3,
                          enabled: !widget.viewModel.isReviewSubmitted,
                          onChanged: (text) => widget.viewModel.setReviewComment(text),
                          decoration: InputDecoration(
                            hintText: 'Share your feedback or suggest more organic plants...',
                            hintStyle: GoogleFonts.montserrat(
                              fontSize: fs(11),
                              color: CustomersLoginThemeView.textGrey,
                            ),
                            contentPadding: EdgeInsets.all(scaleF(12)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.black, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: CustomersLoginThemeView.primaryBlue, width: 1.5),
                            ),
                          ),
                          style: GoogleFonts.montserrat(
                            fontSize: fs(12),
                            fontWeight: FontWeight.w500,
                            color: CustomersLoginThemeView.textDark,
                          ),
                        ),
                        SizedBox(height: scaleF(16)),
                        
                        // Submit Review action button
                        if (widget.viewModel.isReviewSubmitted)
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: scaleF(12)),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green, width: 1),
                            ),
                            child: Center(
                              child: Text(
                                'Thank you for your valuable feedback! ❤️',
                                style: GoogleFonts.montserrat(
                                  fontSize: fs(12),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade900,
                                ),
                              ),
                            ),
                          )
                        else
                          GestureDetector(
                            onTap: widget.viewModel.rating == 0
                                ? null
                                : () => widget.viewModel.submitReview(),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: scaleF(12)),
                              decoration: BoxDecoration(
                                color: widget.viewModel.rating == 0
                                    ? Colors.grey.shade400
                                    : CustomersLoginThemeView.primaryBlue,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.black, width: 1),
                              ),
                              child: Center(
                                child: Text(
                                  'Submit Review',
                                  style: GoogleFonts.montserrat(
                                    fontSize: fs(12),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ] else ...[
                  GestureDetector(
                    onTap: selectedId == null
                        ? null
                        : () => _showFullScreenUnlockSuccess(),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: scaleF(14)),
                      decoration: BoxDecoration(
                        color: selectedId == null
                            ? Colors.grey
                            : CustomersLoginThemeView.primaryBlue,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      child: Center(
                        child: Text(
                          'Confirm Reward Selection',
                          style: GoogleFonts.montserrat(
                            fontSize: fs(14),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildMilestoneTimeline(
    double Function(double) scaleF,
    double Function(double) fs,
    List<OrderHistoryEntry> qOrders,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: scaleF(8), vertical: scaleF(14)),
      decoration: BoxDecoration(
        color: CustomersLoginThemeView.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalMilestones = 6;
          final nodeSize = scaleF(30);
          final cellWidth = nodeSize * 1.6;

          // We'll calculate a percentage of green filled timeline:
          // Milestone 1 to 5 is completed order 1 to 5.
          // Capped at 5 segments.
          final double progressFactor = (qOrders.length).clamp(0, 5) / 5.0;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Top row of Date Labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(totalMilestones, (index) {
                  final isCompleted = index < qOrders.length;
                  final isUnlockMilestone = index == 5;
                  
                  String dateText = '';
                  if (index < qOrders.length) {
                    dateText = DateFormat('MMM dd').format(qOrders[index].orderedAt);
                  } else if (isUnlockMilestone && qOrders.length >= 5) {
                    dateText = 'Ready';
                  } else {
                    dateText = 'Locked';
                  }

                  return SizedBox(
                    width: cellWidth,
                    child: Text(
                      dateText,
                      softWrap: false,
                      overflow: TextOverflow.visible,
                      style: GoogleFonts.montserrat(
                        fontSize: fs(9),
                        fontWeight: FontWeight.bold,
                        color: isCompleted
                            ? CustomersLoginThemeView.primaryBlue
                            : (dateText == 'Ready' ? Colors.green.shade700 : CustomersLoginThemeView.textGrey),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                  );
                }),
              ),
              SizedBox(height: scaleF(6)),

              // 2. Middle Stack of Progress Lines and Circles Row (Perfect vertical alignment)
              SizedBox(
                height: nodeSize,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Horizontal progress bar background (perfectly centered vertically)
                    Positioned(
                      left: cellWidth / 2,
                      right: cellWidth / 2,
                      top: (nodeSize - scaleF(4)) / 2,
                      child: Container(
                        height: scaleF(4),
                        color: Colors.grey.shade200,
                      ),
                    ),

                    // Horizontal progress bar active fill (perfectly centered vertically)
                    Positioned(
                      left: cellWidth / 2,
                      right: cellWidth / 2,
                      top: (nodeSize - scaleF(4)) / 2,
                      child: Row(
                        children: [
                          Expanded(
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: progressFactor,
                              child: Container(
                                height: scaleF(4),
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Milestone circles row (perfectly centered vertically inside a height: nodeSize container)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(totalMilestones, (index) {
                        final isCompleted = index < qOrders.length;
                        final isUnlockMilestone = index == 5;

                        return SizedBox(
                          width: cellWidth,
                          height: nodeSize,
                          child: Center(
                            child: Container(
                              width: nodeSize,
                              height: nodeSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isCompleted
                                    ? Colors.green
                                    : (isUnlockMilestone && qOrders.length >= 5 ? Colors.green.shade50 : Colors.white),
                                border: Border.all(
                                  color: Colors.black,
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: isCompleted
                                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                                    : (isUnlockMilestone
                                        ? Icon(
                                            qOrders.length >= 5 ? Icons.card_giftcard : Icons.lock,
                                            color: qOrders.length >= 5 ? Colors.green : Colors.grey,
                                            size: 14,
                                          )
                                        : Text(
                                            '${index + 1}',
                                            style: GoogleFonts.montserrat(
                                              fontSize: fs(11),
                                              fontWeight: FontWeight.bold,
                                              color: CustomersLoginThemeView.textGrey,
                                            ),
                                          )),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              SizedBox(height: scaleF(6)),

              // 3. Bottom row of milestone description labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(totalMilestones, (index) {
                  final isCompleted = index < qOrders.length;
                  final isUnlockMilestone = index == 5;

                  return SizedBox(
                    width: cellWidth,
                    child: Text(
                      isUnlockMilestone ? 'Reward' : '${index + 1} Ord',
                      softWrap: false,
                      overflow: TextOverflow.visible,
                      style: GoogleFonts.montserrat(
                        fontSize: fs(9),
                        fontWeight: FontWeight.bold,
                        color: isCompleted || (isUnlockMilestone && qOrders.length >= 5)
                            ? CustomersLoginThemeView.textDark
                            : CustomersLoginThemeView.textGrey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlantCard(
    double Function(double) scaleF,
    double Function(double) fs,
    PlantOption plant,
    bool isUnlocked,
    bool isSelected,
  ) {
    final isClaimed = widget.viewModel.isClaimed;
    final cardBorderColor = isSelected ? Colors.green.shade600 : Colors.black;
    final cardBorderWidth = isSelected ? 2.0 : 1.0;

    return GestureDetector(
      onTap: !isUnlocked || isClaimed ? null : () => widget.viewModel.selectPlant(plant.id),
      child: Container(
        decoration: BoxDecoration(
          color: CustomersLoginThemeView.cardBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: cardBorderColor,
            width: cardBorderWidth,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.15),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: Opacity(
          opacity: isUnlocked ? 1.0 : 0.45, // slightly lower opacity when locked
          child: Padding(
            padding: EdgeInsets.all(scaleF(12)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plant Emoji
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      plant.emoji,
                      style: TextStyle(fontSize: scaleF(28)),
                    ),
                    if (isSelected)
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green,
                        ),
                        child: const Icon(Icons.check, color: Colors.white, size: 14),
                      ),
                  ],
                ),
                SizedBox(height: scaleF(4)),

                // Name + Tamil
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plant.name,
                      style: GoogleFonts.montserrat(
                        fontSize: fs(12.5),
                        fontWeight: FontWeight.bold,
                        color: CustomersLoginThemeView.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '(${plant.tamilName})',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(10),
                        fontWeight: FontWeight.w600,
                        color: CustomersLoginThemeView.primaryBlue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: scaleF(4)),

                // Description
                Expanded(
                  child: Text(
                    plant.description,
                    style: GoogleFonts.montserrat(
                      fontSize: fs(9),
                      fontWeight: FontWeight.w500,
                      color: CustomersLoginThemeView.textGrey,
                      height: 1.25,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRewardsSkeleton(
    BuildContext context,
    double hPadding,
    double Function(double) scaleF,
    double Function(double) fs,
  ) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(hPadding, scaleF(8), hPadding, scaleF(32)),
      children: [
        // Top banner skeleton
        Container(
          padding: EdgeInsets.all(scaleF(14)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black12, width: 1),
          ),
          child: Column(
            children: [
              ShimmerSkeleton(width: scaleF(110), height: scaleF(110), borderRadius: 55),
              SizedBox(height: scaleF(12)),
              ShimmerSkeleton(width: scaleF(180), height: scaleF(18), borderRadius: 3),
              SizedBox(height: scaleF(8)),
              ShimmerSkeleton(width: double.infinity, height: scaleF(12), borderRadius: 3),
              SizedBox(height: scaleF(4)),
              ShimmerSkeleton(width: scaleF(240), height: scaleF(12), borderRadius: 3),
            ],
          ),
        ),
        SizedBox(height: scaleF(20)),

        // Milestone header skeleton
        ShimmerSkeleton(width: scaleF(170), height: scaleF(15), borderRadius: 3),
        SizedBox(height: scaleF(12)),

        // Milestone Timeline skeleton
        Container(
          padding: EdgeInsets.symmetric(horizontal: scaleF(8), vertical: scaleF(14)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12, width: 1),
          ),
          child: Column(
            children: [
              // Top date labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) => ShimmerSkeleton(width: scaleF(36), height: scaleF(9), borderRadius: 2)),
              ),
              SizedBox(height: scaleF(10)),
              // Middle progress row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) => ShimmerSkeleton(width: scaleF(30), height: scaleF(30), borderRadius: 15)),
              ),
              SizedBox(height: scaleF(10)),
              // Bottom desc labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) => ShimmerSkeleton(width: scaleF(36), height: scaleF(9), borderRadius: 2)),
              ),
            ],
          ),
        ),
        SizedBox(height: scaleF(24)),

        // Plant Grid Title skeleton
        ShimmerSkeleton(width: scaleF(200), height: scaleF(15), borderRadius: 3),
        SizedBox(height: scaleF(6)),
        ShimmerSkeleton(width: scaleF(240), height: scaleF(11), borderRadius: 3),
        SizedBox(height: scaleF(12)),

        // Plant Grid skeleton (2x2 cards)
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: scaleF(12),
            mainAxisSpacing: scaleF(12),
            childAspectRatio: 0.82,
          ),
          itemBuilder: (context, index) {
            return Container(
              padding: EdgeInsets.all(scaleF(12)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ShimmerSkeleton(width: scaleF(32), height: scaleF(32), borderRadius: 8),
                      ShimmerSkeleton(width: scaleF(14), height: scaleF(14), borderRadius: 7),
                    ],
                  ),
                  SizedBox(height: scaleF(8)),
                  ShimmerSkeleton(width: scaleF(80), height: scaleF(13), borderRadius: 3),
                  SizedBox(height: scaleF(4)),
                  ShimmerSkeleton(width: scaleF(60), height: scaleF(10), borderRadius: 3),
                  SizedBox(height: scaleF(8)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerSkeleton(width: double.infinity, height: scaleF(9), borderRadius: 2),
                        SizedBox(height: scaleF(3)),
                        ShimmerSkeleton(width: double.infinity, height: scaleF(9), borderRadius: 2),
                        SizedBox(height: scaleF(3)),
                        ShimmerSkeleton(width: scaleF(60), height: scaleF(9), borderRadius: 2),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
