import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kiliride/screens/rider/screens/ride_details.scrn.dart';
import 'package:kiliride/shared/styles.shared.dart';

class MyRidesScreen extends StatefulWidget {
  const MyRidesScreen({super.key});

  @override
  State<MyRidesScreen> createState() => _MyRidesScreenState();
}

class _MyRidesScreenState extends State<MyRidesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Dummy data - replace with actual API data
  final List<Ride> _pastRides = [
    Ride(
      id: '1',
      date: '24 Dec',
      time: '22:14',
      destination: 'Kibaha, Tanzania',
      fare: 50000,
      status: 'completed',
      driverName: 'John',
      distance: '41.7 km',
      duration: '1h 46 min',
      pickup: 'Dar es Salaam, Tanzania',
      pickupTime: '22:47',
      dropoffTime: '00:32',
      vehicleType: 'XL',
      bookingFee: 1043.95,
      discount: 3000,
      paymentMethod: 'Cash',
      rating: 5,
    ),
    Ride(
      id: '2',
      date: '24 Dec',
      time: '17:32',
      destination: 'Dar es Salaam, Tanzania',
      fare: 3000,
      status: 'completed',
    ),
    Ride(
      id: '3',
      date: '24 Dec',
      time: '',
      destination: 'Dar es Salaam, Tanzania',
      fare: 0,
      status: 'cancelled',
    ),
    Ride(
      id: '4',
      date: '24 Dec',
      time: '',
      destination: 'Dar es Salaam, Tanzania',
      fare: 0,
      status: 'cancelled',
    ),
    Ride(
      id: '5',
      date: '24 Dec',
      time: '',
      destination: 'Dar es Salaam, Tanzania',
      fare: 0,
      status: 'cancelled',
    ),
    Ride(
      id: '6',
      date: '24 Dec',
      time: '15:52',
      destination: '3 Muafaka, Dar es Salaam',
      fare: 3000,
      status: 'completed',
    ),
    Ride(
      id: '7',
      date: '24 Dec',
      time: '13:06',
      destination: 'Dar es Salaam, Tanzania',
      fare: 5000,
      status: 'completed',
    ),
  ];

  final List<Ride> _upcomingRides = [];

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
      backgroundColor: AppStyle.appColor(context),
      appBar: AppBar(
        backgroundColor: AppStyle.appColor(context),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Rides',
          style: TextStyle(
            color: Colors.black87,
            fontSize: AppStyle.appFontSizeLLG,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppStyle.inputBackgroundColor(context),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.info_outline,
                color: Colors.black87,
                size: 20,
              ),
            ),
            onPressed: () {
              // Show ride info/help
            },
          ),
        ],
        bottom: TabBar(
          dividerColor: Colors.transparent,
          controller: _tabController,
          labelColor: Colors.black87,
          unselectedLabelColor: Colors.grey[600],
          labelStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
          indicatorColor: AppStyle.primaryColor(context),
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Past'),
            Tab(text: 'Upcoming'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRidesList(_pastRides),
          _buildRidesList(_upcomingRides),
        ],
      ),
    );
  }

  Widget _buildRidesList(List<Ride> rides) {
    if (rides.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No rides yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your ride history will appear here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rides.length,
      itemBuilder: (context, index) {
        final ride = rides[index];
        return _buildRideCard(ride);
      },
    );
  }

  Widget _buildRideCard(Ride ride) {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => RideDetailsScreen(ride: ride),
          transition: Transition.rightToLeft,
          duration: const Duration(milliseconds: 300),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppStyle.appGap),
        padding: const EdgeInsets.all(AppStyle.appPadding),
        decoration: BoxDecoration(
          color: Colors.white,
          // borderRadius: BorderRadius.circular(12),
          border: Border(
            
            bottom: BorderSide(
              color: Colors.grey[300]!
           ,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ride.status == 'cancelled'
                    ? Colors.grey[200]
                    : AppStyle.inputBackgroundColor(context),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                ride.status == 'cancelled'
                    ? Icons.cancel_outlined
                    : Icons.directions_car,
                size: 24,
                color: ride.status == 'cancelled'
                    ? Colors.grey[600]
                    : Colors.black87,
              ),
            ),
            const SizedBox(width: 16),
            // Ride details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${ride.date}${ride.time.isNotEmpty ? ' · ${ride.time}' : ''}${ride.status == 'cancelled' ? ' · Cancelled' : ''}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ride.destination,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'TZS ${ride.fare.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            // Rebook button
            if (ride.status != 'cancelled')
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppStyle.inputBackgroundColor(context),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.refresh,
                  size: 20,
                  color: Colors.black87,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class Ride {
  final String id;
  final String date;
  final String time;
  final String destination;
  final double fare;
  final String status;
  final String? driverName;
  final String? distance;
  final String? duration;
  final String? pickup;
  final String? pickupTime;
  final String? dropoffTime;
  final String? vehicleType;
  final double? bookingFee;
  final double? discount;
  final String? paymentMethod;
  final int? rating;

  Ride({
    required this.id,
    required this.date,
    required this.time,
    required this.destination,
    required this.fare,
    required this.status,
    this.driverName,
    this.distance,
    this.duration,
    this.pickup,
    this.pickupTime,
    this.dropoffTime,
    this.vehicleType,
    this.bookingFee,
    this.discount,
    this.paymentMethod,
    this.rating,
  });
}
