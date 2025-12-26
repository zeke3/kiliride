import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


/// App-wide data provider to manage centralized data initialization
/// This provider handles background data fetching that continues even when users navigate away
class AppDataProvider with ChangeNotifier {
  // Reference to other providers
  final Ref _ref;

  // Loading state
  bool _isLoading = false;
  bool _isInitialized = false;
  DateTime? _lastFetchTime;

  // Cache validity duration (5 minutes by default)
  final Duration _cacheValidity = const Duration(minutes: 5);

  AppDataProvider(this._ref);

  // Getters
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  DateTime? get lastFetchTime => _lastFetchTime;

  /// Initialize all app data (non-blocking)
  /// This method should be called once at app startup
  Future<void> initializeAllData() async {
    if (_isInitialized) {
      debugPrint('AppDataProvider: Already initialized, skipping...');
      return;
    }

    debugPrint('AppDataProvider: Starting initialization...');
    _isLoading = true;
    notifyListeners();

    try {
      // Run all fetch operations in parallel
      // await Future.wait([
      //   _fetchSourceOfFunds(),
      //   _fetchMemberStatuses(),
      //   _fetchInsuranceTypes(),
      //   _fetchInsuranceProducts(),
      //   _fetchBenefitTypes(),
      //   _fetchBenefitItems(),
      //   _fetchProductBenefitCoverages(),
      //   _fetchPremiums(),
      // ]);

      _isInitialized = true;
      _lastFetchTime = DateTime.now();
      debugPrint('AppDataProvider: Initialization completed successfully');
    } catch (e) {
      debugPrint('AppDataProvider: Initialization error: $e');
      // Don't set _isInitialized to true if there was an error
      // This allows retry on next attempt
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh all app data (can be called manually)
  Future<void> refreshAllData() async {
    debugPrint('AppDataProvider: Starting manual refresh...');
    _isLoading = true;
    notifyListeners();

    try {
      // await Future.wait([
      //   _fetchSourceOfFunds(),
      //   _fetchMemberStatuses(),
      //   _fetchInsuranceTypes(),
      //   _fetchInsuranceProducts(),
      //   _fetchBenefitTypes(),
      //   _fetchBenefitItems(),
      //   _fetchProductBenefitCoverages(),
      //   _fetchPremiums(),
      // ]);

      _lastFetchTime = DateTime.now();
      debugPrint('AppDataProvider: Refresh completed successfully');
    } catch (e) {
      debugPrint('AppDataProvider: Refresh error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch data only if cache is stale
  Future<void> fetchIfNeeded() async {
    if (_lastFetchTime == null ||
        DateTime.now().difference(_lastFetchTime!) > _cacheValidity) {
      debugPrint('AppDataProvider: Cache is stale, fetching fresh data...');
      await refreshAllData();
    } else {
      debugPrint('AppDataProvider: Cache is still valid, skipping fetch');
    }
  }

  // =================== PRIVATE FETCH METHODS ===================

  // Future<void> _fetchSourceOfFunds() async {
  //   try {
  //     final membershipService = MembershipService.instance;
  //     final result = await membershipService.getSourceOfFunds();

  //     if (result['success'] == true) {
  //       final List<Map<String, String>> sourceOfFundsList =
  //           (result['data'] as List<dynamic>).cast<Map<String, String>>();

  //       // Store in membership provider
  //       _ref.read(membershipProvider).setSourceOfFunds(sourceOfFundsList);
  //       debugPrint('AppDataProvider: Source of funds fetched successfully');
  //     }
  //   } catch (e) {
  //     debugPrint('AppDataProvider: Error fetching source of funds: $e');
  //     rethrow;
  //   }
  // }

  // Future<void> _fetchMemberStatuses() async {
  //   try {
  //     final membershipService = MembershipService.instance;
  //     final membershipProv = _ref.read(membershipProvider);

  //     final result = await membershipService.getMemberStatuses(
  //       provider: membershipProv,
  //     );

  //     if (result['success'] == true) {
  //       debugPrint('AppDataProvider: Member statuses fetched successfully');
  //     } else {
  //       debugPrint(
  //         'AppDataProvider: Error fetching member statuses: ${result['message']}',
  //       );
  //     }
  //   } catch (e) {
  //     debugPrint('AppDataProvider: Error fetching member statuses: $e');
  //     rethrow;
  //   }
  // }

  // Future<void> _fetchInsuranceTypes() async {
  //   try {
  //     final insuranceService = InsuranceProductService.instance;
  //     final result = await insuranceService.getInsuranceTypes(
  //       page: 1,
  //       pageSize: 100, // Fetch all insurance types
  //     );

  //     if (result['success'] == true) {
  //       _ref.read(insuranceProvider).setInsuranceTypes(result['data']);
  //       debugPrint('AppDataProvider: Insurance types fetched successfully');
  //     }
  //   } catch (e) {
  //     debugPrint('AppDataProvider: Error fetching insurance types: $e');
  //     rethrow;
  //   }
  // }

  // Future<void> _fetchInsuranceProducts() async {
  //   try {
  //     final insuranceService = InsuranceProductService.instance;
  //     final result = await insuranceService.getInsuranceProducts(
  //       page: 1,
  //       pageSize: 100, // Fetch all products
  //       onlyValid: true, // Only get currently valid products
  //     );

  //     if (result['success'] == true) {
  //       _ref.read(insuranceProvider).setInsuranceProducts(result['data']);
  //       debugPrint('AppDataProvider: Insurance products fetched successfully');
  //     }
  //   } catch (e) {
  //     debugPrint('AppDataProvider: Error fetching insurance products: $e');
  //     rethrow;
  //   }
  // }

  // Future<void> _fetchBenefitTypes() async {
  //   try {
  //     final insuranceService = InsuranceProductService.instance;
  //     final result = await insuranceService.getBenefitTypes(
  //       page: 1,
  //       pageSize: 100, // Fetch all benefit types
  //     );

  //     if (result['success'] == true) {
  //       _ref.read(insuranceProvider).setBenefitTypes(result['data']);
  //       debugPrint('AppDataProvider: Benefit types fetched successfully');
  //     }
  //   } catch (e) {
  //     debugPrint('AppDataProvider: Error fetching benefit types: $e');
  //     rethrow;
  //   }
  // }

  // Future<void> _fetchBenefitItems() async {
  //   try {
  //     final insuranceService = InsuranceProductService.instance;
  //     final result = await insuranceService.getBenefitItems(
  //       page: 1,
  //       pageSize: 100, // Fetch all benefit items
  //     );

  //     if (result['success'] == true) {
  //       _ref.read(insuranceProvider).setBenefitItems(result['data']);
  //       debugPrint('AppDataProvider: Benefit items fetched successfully');
  //     }
  //   } catch (e) {
  //     debugPrint('AppDataProvider: Error fetching benefit items: $e');
  //     rethrow;
  //   }
  // }

  // Future<void> _fetchProductBenefitCoverages() async {
  //   try {
  //     final insuranceService = InsuranceProductService.instance;
  //     final result = await insuranceService.getProductBenefitCoverages(
  //       page: 1,
  //       pageSize: 100, // Fetch all coverages
  //     );

  //     if (result['success'] == true) {
  //       _ref.read(insuranceProvider).setProductBenefitCoverages(result['data']);
  //       debugPrint(
  //         'AppDataProvider: Product benefit coverages fetched successfully',
  //       );
  //     }
  //   } catch (e) {
  //     debugPrint(
  //       'AppDataProvider: Error fetching product benefit coverages: $e',
  //     );
  //     rethrow;
  //   }
  // }

  // Future<void> _fetchPremiums() async {
  //   try {
  //     final insuranceService = InsuranceProductService.instance;
  //     final result = await insuranceService.getPremiums(
  //       page: 1,
  //       pageSize: 100, // Fetch all premiums
  //     );

  //     if (result['success'] == true) {
  //       _ref.read(insuranceProvider).setPremiums(result['data']);
  //       debugPrint('AppDataProvider: Premiums fetched successfully');
  //     }
  //   } catch (e) {
  //     debugPrint('AppDataProvider: Error fetching premiums: $e');
  //     rethrow;
  //   }
  // }
}
