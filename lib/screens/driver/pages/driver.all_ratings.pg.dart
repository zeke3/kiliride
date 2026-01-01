import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../shared/styles.shared.dart';

class DriverAllRatingsPage extends StatefulWidget {
  const DriverAllRatingsPage({super.key});

  @override
  State<DriverAllRatingsPage> createState() => _DriverAllRatingsPageState();
}

class _DriverAllRatingsPageState extends State<DriverAllRatingsPage> {
  // Sample data - replace with actual data from backend
  final double _averageRating = 4.95;
  final int _totalReviews = 1250;

  final List<RatingReview> _allReviews = [
    RatingReview(
      rating: 5,
      comment:
          "Great conversation and safe drive! The car was spotless and smell nice",
      date: "Yesterday",
      isVerified: true,
    ),
    RatingReview(
      rating: 5,
      comment: "Very smooth ride. Alex knew exactly where to drop off at air port",
      date: "Yesterday",
      isVerified: true,
    ),
    RatingReview(
      rating: 5,
      comment: "Professional and courteous driver. Clean car and great music!",
      date: "2 days ago",
      isVerified: true,
    ),
    RatingReview(
      rating: 4,
      comment: "Good driver, just took a slightly longer route than expected",
      date: "3 days ago",
      isVerified: true,
    ),
    RatingReview(
      rating: 5,
      comment: "Excellent service! Very friendly and helpful with luggage",
      date: "4 days ago",
      isVerified: true,
    ),
    RatingReview(
      rating: 5,
      comment: "Perfect ride. Will definitely request this driver again",
      date: "5 days ago",
      isVerified: false,
    ),
    RatingReview(
      rating: 5,
      comment: "Amazing experience! Super clean car and great conversation",
      date: "1 week ago",
      isVerified: true,
    ),
    RatingReview(
      rating: 4,
      comment: "Nice ride, driver was a bit quiet but very professional",
      date: "1 week ago",
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
          'Rider Ratings'.tr,
          style: TextStyle(
            fontSize: AppStyle.appFontSizeLG,
            fontWeight: FontWeight.w600,
            color: AppStyle.textPrimaryColor(context),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Rating Summary Header
          Container(
            color: AppStyle.appColor(context),
            padding: const EdgeInsets.all(AppStyle.appPadding),
            child: Column(
              children: [
                // Average Rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _averageRating.toStringAsFixed(2),
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

                // Total Reviews
                Text(
                  'Based on $_totalReviews rider reviews'.tr,
                  style: TextStyle(
                    fontSize: AppStyle.appFontSizeSM,
                    fontWeight: FontWeight.w500,
                    color: AppStyle.descriptionTextColor(context),
                  ),
                ),

                const SizedBox(height: AppStyle.appPadding),

                // Rating Distribution (Optional - you can add this later)
                _buildRatingDistribution(),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Reviews List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(AppStyle.appPadding),
              itemCount: _allReviews.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _buildReviewCard(_allReviews[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingDistribution() {
    // Calculate distribution (simplified - you'd calculate this from actual data)
    final Map<int, double> distribution = {
      5: 0.85,
      4: 0.10,
      3: 0.03,
      2: 0.01,
      1: 0.01,
    };

    return Column(
      children: [
        for (int stars = 5; stars >= 1; stars--)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                // Star count
                Text(
                  '$stars',
                  style: TextStyle(
                    fontSize: AppStyle.appFontSizeSM,
                    fontWeight: FontWeight.w600,
                    color: AppStyle.textPrimaryColor(context),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.star,
                  color: const Color(0xFFFFC107),
                  size: 16,
                ),
                const SizedBox(width: 12),
                // Progress bar
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: distribution[stars] ?? 0,
                      backgroundColor: AppStyle.inputBackgroundColor(context),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFFFC107),
                      ),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Percentage
                SizedBox(
                  width: 40,
                  child: Text(
                    '${((distribution[stars] ?? 0) * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: AppStyle.appFontSizeXSM,
                      fontWeight: FontWeight.w500,
                      color: AppStyle.descriptionTextColor(context),
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildReviewCard(RatingReview review) {
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
class RatingReview {
  final int rating;
  final String comment;
  final String date;
  final bool isVerified;

  RatingReview({
    required this.rating,
    required this.comment,
    required this.date,
    required this.isVerified,
  });
}
