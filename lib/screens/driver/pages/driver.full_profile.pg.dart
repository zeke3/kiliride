import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:kiliride/components/custom_avatr_comp.dart';
import '../../../shared/styles.shared.dart';
import 'driver.all_ratings.pg.dart';

class DriverFullProfilePage extends StatefulWidget {
  const DriverFullProfilePage({super.key});

  @override
  State<DriverFullProfilePage> createState() => _DriverFullProfilePageState();
}

class _DriverFullProfilePageState extends State<DriverFullProfilePage> {
  // Sample data - replace with actual user data
  final String _userName = "Kassa Mwema";
  final String _userAvatar = "";
  final String _vehicleInfo = "Tesla Model 3. 8XJ-992";
  final double _rating = 4.95;
  final String _ratingDescription = "Based on Rider feedback";
  final int _totalTrips = 1250;
  final String _acceptanceRate = "98%";
  final String _cancelRate = "1%";

  // Sample reviews
  final List<Review> _reviews = [
    Review(
      rating: 5,
      comment:
          "Great conversation and safe drive! The car was spotless and smell nice",
      date: "Yesterday",
      isVerified: true,
    ),
    Review(
      rating: 5,
      comment: "Very smooth ride. Alex knew exactly where to drop off at air port",
      date: "Yesterday",
      isVerified: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.appBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppStyle.appColor(context),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppStyle.textPrimaryColor(context),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profile'.tr,
          style: TextStyle(
            fontSize: AppStyle.appFontSizeLG,
            fontWeight: FontWeight.w600,
            color: AppStyle.textPrimaryColor(context),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Avatar with verification badge
            Stack(
              children: [
                _userAvatar.isNotEmpty
                    ? CustomAvatar(
                        imageURL: _userAvatar,
                        size: 100,
                        fullName: _userName,
                      )
                    : Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppStyle.inputBackgroundColor(context),
                          border: Border.all(
                            color: AppStyle.borderColor(context),
                            width: 3,
                          ),
                        ),
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: AppStyle.descriptionTextColor(context),
                        ),
                      ),
                // Verification badge
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1DA1F2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppStyle.appColor(context),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Name
            Text(
              _userName,
              style: TextStyle(
                fontSize: AppStyle.appFontSizeMd,
                fontWeight: FontWeight.w700,
                color: AppStyle.textPrimaryColor(context),
              ),
            ),

            const SizedBox(height: 12),

            // Vehicle Info
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppStyle.inputBackgroundColor(context),
                borderRadius: BorderRadius.circular(AppStyle.appRadiusLG),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.directions_car,
                    size: 20,
                    color: AppStyle.descriptionTextColor(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _vehicleInfo,
                    style: TextStyle(
                      fontSize: AppStyle.appFontSizeSM,
                      fontWeight: FontWeight.w600,
                      color: AppStyle.textPrimaryColor(context),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppStyle.appPadding),

            // Edit Profile Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 80),
              child: SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Navigate to edit profile page
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8F1FF),
                    foregroundColor: const Color(0xFF1F8CF9),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppStyle.appRadiusLG),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.edit,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Edit Profile'.tr,
                        style: const TextStyle(
                          fontSize: AppStyle.appFontSizeSM,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppStyle.appPadding + 4),

            // Rating Section
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _rating.toStringAsFixed(2),
                  style: TextStyle(
                    fontSize: AppStyle.appFontSizeXLG,
                    fontWeight: FontWeight.bold,
                    color: AppStyle.textPrimaryColor(context),
                    height: 1,
                  ),
                ),
                const SizedBox(width: AppStyle.appGap / 2),
                SvgPicture.asset(
                  'assets/icons/star.svg',
                  colorFilter: const ColorFilter.mode(
                    Color.fromRGBO(255, 208, 65, 1),
                    BlendMode.srcIn,
                  ),
                  height: 24,
                )
              ],
            ),

            const SizedBox(height: AppStyle.appGap),
            Text(
              _ratingDescription,
              style: TextStyle(
                fontSize: AppStyle.appFontSizeSM,
                fontWeight: FontWeight.w500,
                color: AppStyle.invertedTextAppColor(context),
              ),
            ),

            const SizedBox(height: AppStyle.appPadding + 4),

            // Stats Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppStyle.appPadding),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppStyle.appPadding,
                  vertical: AppStyle.appPadding + 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F1FF),
                  borderRadius: BorderRadius.circular(AppStyle.appRadiusLG),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildStatItem(
                      label: 'Trips',
                      value: _totalTrips.toString(),
                    ),
                    Container(
                      width: 1,
                      height: 25,
                      color: AppStyle.invertedTextAppColor(context),
                    ),
                    _buildStatItem(
                      label: 'Acceptance',
                      value: _acceptanceRate,
                    ),
                    Container(
                      width: 1,
                      height: 25,
                      color: AppStyle.invertedTextAppColor(context),
                    ),
                    _buildStatItem(
                      label: 'Cancel',
                      value: _cancelRate,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppStyle.appPadding),

            // Recent Rider Ratings Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppStyle.appPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Rider Ratings'.tr,
                    style: TextStyle(
                      fontSize: AppStyle.appFontSizeMd,
                      fontWeight: FontWeight.w800,
                      color: AppStyle.textPrimaryColor(context),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.to(
                        () => const DriverAllRatingsPage(),
                        transition: Transition.rightToLeftWithFade,
                        duration: const Duration(milliseconds: 300),
                      );
                    },
                    child: Text(
                      'View all'.tr,
                      style: const TextStyle(
                        fontSize: AppStyle.appFontSizeSM,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F8CF9),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Reviews List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: AppStyle.appPadding),
              itemCount: _reviews.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _buildReviewCard(_reviews[index]);
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Text(
          label.tr,
          style: TextStyle(
            fontSize: AppStyle.appFontSizeSM,
            fontWeight: FontWeight.w600,
            color: AppStyle.descriptionTextColor(context),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: AppStyle.appFontSizeLG,
            fontWeight: FontWeight.w700,
            color: AppStyle.textPrimaryColor(context),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppStyle.appColor(context),
        borderRadius: BorderRadius.circular(AppStyle.appRadiusMd),
        border: Border.all(
          color: AppStyle.borderColor(context),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stars and date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < review.rating ? Icons.star : Icons.star_border,
                    color: const Color(0xFFFFC107),
                    size: 18,
                  ),
                ),
              ),
              Text(
                review.date,
                style: TextStyle(
                  fontSize: AppStyle.appFontSizeXSM,
                  color: AppStyle.descriptionTextColor(context),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Review comment
          Text(
            review.comment,
            style: TextStyle(
              fontSize: AppStyle.appFontSizeSM,
              color: AppStyle.textPrimaryColor(context),
              height: 1.4,
            ),
          ),

          const SizedBox(height: 12),

          // Verified badge
          if (review.isVerified)
            Row(
              children: [
                Icon(
                  Icons.verified_user,
                  size: 16,
                  color: AppStyle.descriptionTextColor(context),
                ),
                const SizedBox(width: 6),
                Text(
                  'Verified Rider'.tr,
                  style: TextStyle(
                    fontSize: AppStyle.appFontSizeXSM,
                    fontWeight: FontWeight.w600,
                    color: AppStyle.descriptionTextColor(context),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// Review Model
class Review {
  final int rating;
  final String comment;
  final String date;
  final bool isVerified;

  Review({
    required this.rating,
    required this.comment,
    required this.date,
    required this.isVerified,
  });
}
