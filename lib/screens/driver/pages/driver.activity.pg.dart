import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../shared/styles.shared.dart';

class DriverActivityPage extends StatefulWidget {
  const DriverActivityPage({super.key});

  @override
  State<DriverActivityPage> createState() => _DriverActivityPageState();
}

class _DriverActivityPageState extends State<DriverActivityPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Sample data - replace with actual data from your backend
  final List<ActivityGroup> _pastActivities = [
    ActivityGroup(
      date: 'Sat, 10 Mar',
      totalEarnings: 'TZS 15,000',
      activities: [
        Activity(
          title: 'Trip to Airport',
          subtitle: 'Today, 10:23 AM',
          amount: '+ TZS 15,000',
          type: ActivityType.trip,
        ),
        Activity(
          title: 'Quest Bonus',
          subtitle: 'Yesterday',
          amount: '+ TZS 25,000',
          type: ActivityType.bonus,
        ),
        Activity(
          title: 'Trip to Airport',
          subtitle: 'Today, 10:23 AM',
          amount: '+ TZS 8,500',
          type: ActivityType.trip,
        ),
      ],
    ),
    ActivityGroup(
      date: 'Sat, 10 Mar',
      totalEarnings: '0 Tsh',
      activities: [],
    ),
    ActivityGroup(
      date: 'Sat, 10 Mar',
      totalEarnings: 'TZS 15,000',
      activities: [
        Activity(
          title: 'Trip to Airport',
          subtitle: 'Today, 10:23 AM',
          amount: '+ TZS 15,000',
          type: ActivityType.trip,
        ),
        Activity(
          title: 'Quest Bonus',
          subtitle: 'Yesterday',
          amount: '+ TZS 25,000',
          type: ActivityType.bonus,
        ),
        Activity(
          title: 'Trip to Airport',
          subtitle: 'Today, 10:23 AM',
          amount: '+ TZS 8,500',
          type: ActivityType.trip,
        ),
      ],
    ),
  ];

  final List<ActivityGroup> _upcomingActivities = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.appBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppStyle.appColor(context),
        elevation: 0,
        title: Text(
          'Ride Activity'.tr,
          style: TextStyle(
            fontSize: AppStyle.appFontSizeLG,
            fontWeight: FontWeight.w700,
            color: AppStyle.textPrimaryColor(context),
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: AppStyle.appColor(context),
            padding: const EdgeInsets.symmetric(
              horizontal: AppStyle.appPadding,
              vertical: 8,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: AppStyle.inputBackgroundColor(context),
                borderRadius: BorderRadius.circular(AppStyle.appRadius),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppStyle.appColor(context),
                  borderRadius: BorderRadius.circular(AppStyle.appRadius),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: AppStyle.textPrimaryColor(context),
                unselectedLabelColor: AppStyle.descriptionTextColor(context),
                labelStyle: const TextStyle(
                  fontSize: AppStyle.appFontSizeSM,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: AppStyle.appFontSizeSM,
                  fontWeight: FontWeight.w500,
                ),
                tabs: [
                  Tab(text: 'Past'.tr),
                  Tab(text: 'Upcoming'.tr),
                ],
              ),
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Past Tab
                _buildActivityList(_pastActivities),
                // Upcoming Tab
                _buildActivityList(_upcomingActivities),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityList(List<ActivityGroup> groups) {
    if (groups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: AppStyle.descriptionTextColor(context),
            ),
            const SizedBox(height: 16),
            Text(
              'No Activity'.tr,
              style: TextStyle(
                fontSize: AppStyle.appFontSizeMd,
                color: AppStyle.descriptionTextColor(context),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        return _buildActivityGroup(groups[index]);
      },
    );
  }

  Widget _buildActivityGroup(ActivityGroup group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Header
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppStyle.appPadding,
            vertical: 12,
          ),
          color: const Color(0xFFE8F1FF),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                group.date,
                style: const TextStyle(
                  fontSize: AppStyle.appFontSizeSM,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F1F1F),
                ),
              ),
              Text(
                group.totalEarnings,
                style: const TextStyle(
                  fontSize: AppStyle.appFontSizeSM,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F1F1F),
                ),
              ),
            ],
          ),
        ),

        // Activities or No Activity
        if (group.activities.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40),
            color: AppStyle.appColor(context),
            child: Center(
              child: Text(
                'No Activity'.tr,
                style: TextStyle(
                  fontSize: AppStyle.appFontSizeSM,
                  color: AppStyle.descriptionTextColor(context),
                ),
              ),
            ),
          )
        else
          Container(
            color: AppStyle.appColor(context),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: group.activities.length,
              separatorBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppStyle.appPadding,
                ),
                child: Divider(
                  height: 1,
                  color: AppStyle.borderColor(context),
                ),
              ),
              itemBuilder: (context, index) {
                return _buildActivityItem(group.activities[index]);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildActivityItem(Activity activity) {
    return InkWell(
      onTap: () {
        // TODO: Navigate to activity details
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppStyle.appPadding,
          vertical: 16,
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F1FF),
                borderRadius: BorderRadius.circular(AppStyle.appRadiusMd),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/car.svg',
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF1F8CF9),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: TextStyle(
                      fontSize: AppStyle.appFontSizeSM,
                      fontWeight: FontWeight.w700,
                      color: AppStyle.textPrimaryColor(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activity.subtitle,
                    style: TextStyle(
                      fontSize: AppStyle.appFontSizeXSM,
                      color: AppStyle.descriptionTextColor(context),
                    ),
                  ),
                ],
              ),
            ),
            // Amount
            Text(
              activity.amount,
              style: TextStyle(
                fontSize: AppStyle.appFontSizeSM,
                fontWeight: FontWeight.w700,
                color: AppStyle.textPrimaryColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Models
enum ActivityType {
  trip,
  bonus,
}

class Activity {
  final String title;
  final String subtitle;
  final String amount;
  final ActivityType type;

  Activity({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.type,
  });
}

class ActivityGroup {
  final String date;
  final String totalEarnings;
  final List<Activity> activities;

  ActivityGroup({
    required this.date,
    required this.totalEarnings,
    required this.activities,
  });
}
