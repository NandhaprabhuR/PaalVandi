import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_navigation.dart';
import '../../core/app_route_storage.dart';
import '../../theme/customers_login_themeview.dart';
import '../../core/widgets/responsive_helper.dart';
import '../../core/widgets/paalvandi_confirm_dialog.dart';
import '../viewmodels/customers_profile_viewmodel.dart';
import '../../cart/views/bottle_wallet_history_view.dart';
import '../../cart/viewmodels/cart_scope.dart';
import 'customers_profile_view.dart';
import 'add_address_view.dart';
import 'delete_account_view.dart';
import '../../subscriptions/viewmodels/subscriptions_scope.dart';
import '../../subscriptions/views/your_subscriptions_view.dart';
import '../../complaints/views/raise_complaint_view.dart';
import '../../complaints/viewmodels/complaints_viewmodel.dart';
import '../../home/views/product_reviews_view.dart';
import '../../home/views/bulk_booking_view.dart';
import '../../cart/views/order_history_view.dart';
import '../../bottomnavigation/views/bottom_navigation_view.dart';
import 'active_bulk_booking_view.dart';

class ProfileTabView extends StatelessWidget {
  final ComplaintsViewModel complaintsViewModel;

  const ProfileTabView({super.key, required this.complaintsViewModel});

  @override
  Widget build(BuildContext context) {
    final scaleF = (double val) => ResponsiveHelper.scaledValue(context, val);
    final fs = (double size) => ResponsiveHelper.scaledFontSize(context, size);
    final hPadding = ResponsiveHelper.horizontalPadding(context);
    final cart = CartScope.of(context);
    final subscriptionsStore = SubscriptionsScope.of(context);

    return AnimatedBuilder(
      animation: Listenable.merge([subscriptionsStore, cart]),
      builder: (context, _) {
        return Scaffold(
          backgroundColor: CustomersLoginThemeView.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: CustomersLoginThemeView.scaffoldBackgroundColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: Text(
              'Profile',
              style: CustomersLoginThemeView.brandTitleStyle.copyWith(
                fontSize: fs(22),
                letterSpacing: 0.5,
              ),
            ),
          ),
          body: BlocBuilder<CustomersProfileViewModel, CustomersProfileState>(
            builder: (context, state) {
              final model = state.model;
              final hasName = model.name.isNotEmpty;
              final displayName = hasName ? model.name : 'Nandha Prabhu';
              final displayPhone = '+91 98765 43210';
              
              final hasAddress = model.houseNo.isNotEmpty ||
                  model.apartmentName.isNotEmpty ||
                  model.street.isNotEmpty;
                  
              final String displayAddress = hasAddress
                  ? '${model.houseNo.isNotEmpty ? '${model.houseNo}, ' : ''}${model.apartmentName.isNotEmpty ? '${model.apartmentName}, ' : ''}${model.street.isNotEmpty ? '${model.street}, ' : ''}Coimbatore - ${model.pincode.isNotEmpty ? model.pincode : '641041'}'
                  : 'B-302, Green Meadows, Vadavalli, Coimbatore - 641041';

              final avatarInitial = displayName.isNotEmpty 
                  ? displayName[0].toUpperCase() 
                  : 'N';

              return ListView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                padding: EdgeInsets.fromLTRB(hPadding, scaleF(12), hPadding, scaleF(24)),
                children: [
                  // Premium User Profile Details Card
                  Container(
                    padding: EdgeInsets.all(scaleF(16)),
                    decoration: CustomersLoginThemeView.cardDecoration,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: scaleF(54),
                              height: scaleF(54),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    CustomersLoginThemeView.primaryBlue,
                                    Color(0xFF4A90E2),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  avatarInitial,
                                  style: GoogleFonts.montserrat(
                                    fontSize: fs(22),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: scaleF(14)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.montserrat(
                                      fontSize: fs(18),
                                      fontWeight: FontWeight.bold,
                                      color: CustomersLoginThemeView.textDark,
                                    ),
                                  ),
                                  SizedBox(height: scaleF(3)),
                                  Text(
                                    displayPhone,
                                    style: GoogleFonts.montserrat(
                                      fontSize: fs(12),
                                      fontWeight: FontWeight.w600,
                                      color: CustomersLoginThemeView.textGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Divider(
                          color: CustomersLoginThemeView.borderColor.withValues(alpha: 0.5),
                          height: scaleF(24),
                          thickness: 1,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: scaleF(20),
                              color: CustomersLoginThemeView.primaryBlue,
                            ),
                            SizedBox(width: scaleF(10)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Delivery Address',
                                    style: GoogleFonts.montserrat(
                                      fontSize: fs(12),
                                      fontWeight: FontWeight.bold,
                                      color: CustomersLoginThemeView.primaryBlue,
                                    ),
                                  ),
                                  SizedBox(height: scaleF(3)),
                                  Text(
                                    displayAddress,
                                    style: GoogleFonts.montserrat(
                                      fontSize: fs(13),
                                      fontWeight: FontWeight.w500,
                                      color: CustomersLoginThemeView.textDark,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: scaleF(24)),

                  // Your Activity Label
                  Text(
                    'Your Activity',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(14),
                      fontWeight: FontWeight.bold,
                      color: CustomersLoginThemeView.sectionHeadingRed,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: scaleF(10)),

                  // Your Orders Menu Tile
                  _buildActivityTile(
                    context,
                    icon: Icons.shopping_bag_outlined,
                    title: 'Your Orders',
                    isEmpty: cart.allOrderHistory.isEmpty,
                    subtitle: cart.allOrderHistory.isEmpty
                        ? 'No orders yet. Tap + to order fresh milk!'
                        : '${cart.allOrderHistory.length} orders placed recently',
                    scaleF: scaleF,
                    fs: fs,
                    onPlusTap: () {
                      if (BottomNavigationView.onSelectTabGlobal != null) {
                        BottomNavigationView.onSelectTabGlobal!(0); // Home tab
                      }
                    },
                    onTap: () {
                      if (cart.allOrderHistory.isEmpty) {
                        if (BottomNavigationView.onSelectTabGlobal != null) {
                          BottomNavigationView.onSelectTabGlobal!(0); // Home tab
                        }
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CartScope(
                              store: cart,
                              child: const OrderHistoryView(),
                            ),
                          ),
                        );
                      }
                    },
                  ),

                  // Bulk Bookings Menu Tile
                  _buildActivityTile(
                    context,
                    icon: Icons.local_shipping_outlined,
                    title: 'Bulk Bookings',
                    isEmpty: !BulkBookingView.hasActiveBulkBooking,
                    subtitle: !BulkBookingView.hasActiveBulkBooking
                        ? 'No bulk bookings. Tap + to book for events!'
                        : '1 Active Bulk Booking (Pending Delivery)',
                    scaleF: scaleF,
                    fs: fs,
                    onPlusTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const BulkBookingView(),
                        ),
                      );
                    },
                    onTap: () {
                      if (!BulkBookingView.hasActiveBulkBooking) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const BulkBookingView(),
                          ),
                        );
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ActiveBulkBookingView(),
                          ),
                        );
                      }
                    },
                  ),

                  // View Bottle Wallet Menu Tile (Moved to Your Activity)
                  _buildMenuTile(
                    context,
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'View Bottle Wallet',
                    subtitle: 'Delivered, returned, and pending bottles stats',
                    scaleF: scaleF,
                    fs: fs,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CartScope(
                            store: cart,
                            child: const BottleWalletHistoryView(),
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: scaleF(24)),

                  // Subscriptions Label
                  Text(
                    'Subscriptions',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(14),
                      fontWeight: FontWeight.bold,
                      color: CustomersLoginThemeView.sectionHeadingRed,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: scaleF(10)),

                  // Your Subscriptions Menu Tile (Moved to Subscriptions section)
                  _buildActivityTile(
                    context,
                    icon: Icons.inventory_2_outlined,
                    title: 'Your Subscriptions',
                    isEmpty: !subscriptionsStore.hasBookings,
                    subtitle: !subscriptionsStore.hasBookings
                        ? 'No active subscriptions. Tap + to subscribe!'
                        : 'Manage your active milk subscriptions',
                    scaleF: scaleF,
                    fs: fs,
                    onPlusTap: () {
                      if (BottomNavigationView.onSelectTabGlobal != null) {
                        BottomNavigationView.onSelectTabGlobal!(2); // Subscription tab
                      }
                    },
                    onTap: () {
                      if (!subscriptionsStore.hasBookings) {
                        if (BottomNavigationView.onSelectTabGlobal != null) {
                          BottomNavigationView.onSelectTabGlobal!(2); // Subscription tab
                        }
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SubscriptionsScope(
                              store: subscriptionsStore,
                              child: const YourSubscriptionsView(),
                            ),
                          ),
                        );
                      }
                    },
                    trailing: subscriptionsStore.hasBookings && subscriptionsStore.bookings.any((b) => !b.isFullyPaid)
                        ? Badge(
                            backgroundColor: CustomersLoginThemeView.sectionHeadingRed,
                            child: Icon(
                              Icons.chevron_right,
                              color: CustomersLoginThemeView.textGrey,
                              size: scaleF(20),
                            ),
                          )
                        : null,
                  ),

                  SizedBox(height: scaleF(24)),

                  // Reviews Label
                  Text(
                    'Reviews',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(14),
                      fontWeight: FontWeight.bold,
                      color: CustomersLoginThemeView.sectionHeadingRed,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: scaleF(10)),

                  // View Product Reviews Menu Tile (Moved to Reviews section)
                  _buildMenuTile(
                    context,
                    icon: Icons.reviews_outlined,
                    title: 'View Product Reviews',
                    subtitle: 'Read or write customer feedback for fresh products',
                    scaleF: scaleF,
                    fs: fs,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CartScope(
                            store: cart,
                            child: const ProductReviewsView(productName: 'Fresh Cow Milk'),
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: scaleF(24)),

                  // Enquiries Label
                  Text(
                    'Enquiries',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(14),
                      fontWeight: FontWeight.bold,
                      color: CustomersLoginThemeView.sectionHeadingRed,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: scaleF(10)),

                  // Raise Complaint Option Tile (Moved to Enquiries section)
                  _buildMenuTile(
                    context,
                    icon: Icons.support_agent_outlined,
                    title: 'Raise Complaint',
                    subtitle: 'Report late delivery, wrong quantity or sour milk',
                    scaleF: scaleF,
                    fs: fs,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => RaiseComplaintView(
                            viewModel: complaintsViewModel,
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: scaleF(24)),

                  // Menu Settings & Actions Label
                  Text(
                    'Account Settings',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(14),
                      fontWeight: FontWeight.bold,
                      color: CustomersLoginThemeView.sectionHeadingRed,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: scaleF(10)),

                  _buildMenuTile(
                    context,
                    icon: Icons.edit_outlined,
                    title: 'Edit Profile',
                    subtitle: 'Update your personal profile details',
                    scaleF: scaleF,
                    fs: fs,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CustomersProfileView(),
                        ),
                      );
                    },
                  ),
                  _buildMenuTile(
                    context,
                    icon: Icons.add_location_alt_outlined,
                    title: 'Add More Address',
                    subtitle: 'Manage or update your delivery address',
                    scaleF: scaleF,
                    fs: fs,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AddAddressView(),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: scaleF(12)),

                  // Delete Account Action Tile (Card style with red border and red elements to warn/premiumize)
                  Container(
                    margin: EdgeInsets.only(bottom: scaleF(10)),
                    decoration: BoxDecoration(
                      color: CustomersLoginThemeView.cardBackgroundColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: CustomersLoginThemeView.sectionHeadingRed.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const DeleteAccountView(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: scaleF(16), vertical: scaleF(14)),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(scaleF(8)),
                                decoration: BoxDecoration(
                                  color: CustomersLoginThemeView.sectionHeadingRed.withValues(alpha: 0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.delete_forever_outlined,
                                  color: CustomersLoginThemeView.sectionHeadingRed,
                                  size: scaleF(20),
                                ),
                              ),
                              SizedBox(width: scaleF(14)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Delete Account',
                                      style: GoogleFonts.montserrat(
                                        fontSize: fs(14),
                                        fontWeight: FontWeight.bold,
                                        color: CustomersLoginThemeView.sectionHeadingRed,
                                      ),
                                    ),
                                    SizedBox(height: scaleF(2)),
                                    Text(
                                      'Permanently remove your account and data',
                                      style: GoogleFonts.montserrat(
                                        fontSize: fs(11),
                                        fontWeight: FontWeight.w500,
                                        color: CustomersLoginThemeView.textGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: CustomersLoginThemeView.sectionHeadingRed.withValues(alpha: 0.7),
                                size: scaleF(20),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Logout Action Tile (Solid Flat Red background, white text/icons, NO SHADOW/SHINE)
                  GestureDetector(
                    onTap: () => _confirmLogout(context, fs),
                    child: Container(
                      margin: EdgeInsets.only(bottom: scaleF(10)),
                      padding: EdgeInsets.symmetric(horizontal: scaleF(16), vertical: scaleF(14)),
                      decoration: BoxDecoration(
                        color: const Color(0xFF9B0F06),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(scaleF(8)),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.logout_outlined,
                              color: Colors.white,
                              size: scaleF(20),
                            ),
                          ),
                          SizedBox(width: scaleF(14)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Logout',
                                  style: GoogleFonts.montserrat(
                                    fontSize: fs(14),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: scaleF(2)),
                                Text(
                                  'Securely sign out of your account',
                                  style: GoogleFonts.montserrat(
                                    fontSize: fs(11),
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                            size: scaleF(20),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMenuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required double Function(double) scaleF,
    required double Function(double) fs,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: scaleF(10)),
      decoration: BoxDecoration(
        color: CustomersLoginThemeView.cardBackgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.black,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: scaleF(16), vertical: scaleF(14)),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(scaleF(8)),
                  decoration: BoxDecoration(
                    color: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: CustomersLoginThemeView.primaryBlue,
                    size: scaleF(20),
                  ),
                ),
                SizedBox(width: scaleF(14)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.montserrat(
                          fontSize: fs(14),
                          fontWeight: FontWeight.bold,
                          color: CustomersLoginThemeView.textDark,
                        ),
                      ),
                      SizedBox(height: scaleF(2)),
                      Text(
                        subtitle,
                        style: GoogleFonts.montserrat(
                          fontSize: fs(11),
                          fontWeight: FontWeight.w500,
                          color: CustomersLoginThemeView.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                trailing ?? Icon(
                  Icons.chevron_right,
                  color: CustomersLoginThemeView.textGrey,
                  size: scaleF(20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isEmpty,
    required double Function(double) scaleF,
    required double Function(double) fs,
    required VoidCallback onPlusTap,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: scaleF(10)),
      decoration: BoxDecoration(
        color: CustomersLoginThemeView.cardBackgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.black,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: scaleF(16), vertical: scaleF(14)),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(scaleF(8)),
                  decoration: BoxDecoration(
                    color: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: CustomersLoginThemeView.primaryBlue,
                    size: scaleF(20),
                  ),
                ),
                SizedBox(width: scaleF(14)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.montserrat(
                          fontSize: fs(14),
                          fontWeight: FontWeight.bold,
                          color: CustomersLoginThemeView.textDark,
                        ),
                      ),
                      SizedBox(height: scaleF(2)),
                      Text(
                        subtitle,
                        style: GoogleFonts.montserrat(
                          fontSize: fs(11),
                          fontWeight: FontWeight.w500,
                          color: CustomersLoginThemeView.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                isEmpty
                    ? Container(
                        width: scaleF(32),
                        height: scaleF(32),
                        decoration: BoxDecoration(
                          color: CustomersLoginThemeView.primaryBlue,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: onPlusTap,
                            borderRadius: BorderRadius.circular(16),
                            child: const Center(
                              child: Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      )
                    : (trailing ?? Icon(
                        Icons.chevron_right,
                        color: CustomersLoginThemeView.textGrey,
                        size: scaleF(20),
                      )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, double Function(double) fs) async {
    final confirmed = await showPaalvandiConfirmDialog(
      context,
      title: 'Logout?',
      message: 'Are you sure you want to logout of PaalVandi?',
      noLabel: 'Cancel',
      yesLabel: 'Logout',
    );
    if (confirmed == true && context.mounted) {
      await AppRouteStorage.clearSession();
      if (context.mounted) {
        context.goPersist('/login');
      }
    }
  }
}
