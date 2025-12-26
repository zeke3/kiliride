import 'package:kiliride/models/user.model.dart';
import 'package:flutter/material.dart';

// Helper class to manage country and currency data
class CountryCurrencyHelper {
  // Common countries from all continents
  static List<CountryData> getCommonCountries() {
    return [
        // Africa
        CountryData(code: 'NG', name: 'Nigeria'),
        CountryData(code: 'KE', name: 'Kenya'),
        CountryData(code: 'ZA', name: 'South Africa'),
        CountryData(code: 'GH', name: 'Ghana'),
        CountryData(code: 'EG', name: 'Egypt'),
        CountryData(code: 'ET', name: 'Ethiopia'),
        CountryData(code: 'TZ', name: 'Tanzania'),
        CountryData(code: 'MA', name: 'Morocco'),
        CountryData(code: 'UG', name: 'Uganda'),
        CountryData(code: 'SN', name: 'Senegal'),
        CountryData(code: 'RW', name: 'Rwanda'),

        // Americas
        CountryData(code: 'US', name: 'United States'),
        CountryData(code: 'CA', name: 'Canada'),
        CountryData(code: 'MX', name: 'Mexico'),
        CountryData(code: 'BR', name: 'Brazil'),
        CountryData(code: 'AR', name: 'Argentina'),
        CountryData(code: 'CO', name: 'Colombia'),
        CountryData(code: 'CL', name: 'Chile'),
        CountryData(code: 'PE', name: 'Peru'),
        CountryData(code: 'JM', name: 'Jamaica'),

        // Asia & Middle East
        CountryData(code: 'CN', name: 'China'),
        CountryData(code: 'IN', name: 'India'),
        CountryData(code: 'JP', name: 'Japan'),
        CountryData(code: 'KR', name: 'South Korea'),
        CountryData(code: 'ID', name: 'Indonesia'),
        CountryData(code: 'PH', name: 'Philippines'),
        CountryData(code: 'SG', name: 'Singapore'),
        CountryData(code: 'MY', name: 'Malaysia'),
        CountryData(code: 'AE', name: 'United Arab Emirates'),
        CountryData(code: 'SA', name: 'Saudi Arabia'),
        CountryData(code: 'PK', name: 'Pakistan'),
        CountryData(code: 'VN', name: 'Vietnam'),
        CountryData(code: 'TH', name: 'Thailand'),
        CountryData(code: 'IL', name: 'Israel'),
        CountryData(code: 'TR', name: 'Turkey'),

        // Europe
        CountryData(code: 'GB', name: 'United Kingdom'),
        CountryData(code: 'DE', name: 'Germany'),
        CountryData(code: 'FR', name: 'France'),
        CountryData(code: 'IT', name: 'Italy'),
        CountryData(code: 'ES', name: 'Spain'),
        CountryData(code: 'NL', name: 'Netherlands'),
        CountryData(code: 'SE', name: 'Sweden'),
        CountryData(code: 'CH', name: 'Switzerland'),
        CountryData(code: 'RU', name: 'Russia'),
        CountryData(code: 'PL', name: 'Poland'),
        CountryData(code: 'UA', name: 'Ukraine'),
        CountryData(code: 'NO', name: 'Norway'),
        CountryData(code: 'IE', name: 'Ireland'),
        CountryData(code: 'PT', name: 'Portugal'),

        // Oceania
        CountryData(code: 'AU', name: 'Australia'),
        CountryData(code: 'NZ', name: 'New Zealand'),
        CountryData(code: 'FJ', name: 'Fiji'),

        // Additional countries
        CountryData(code: 'AO', name: 'Angola'),
        CountryData(code: 'CM', name: 'Cameroon'),
        CountryData(code: 'LB', name: 'Lebanon'),
        CountryData(code: 'QA', name: 'Qatar'),
        CountryData(code: 'BH', name: 'Bahrain'),
        CountryData(code: 'KW', name: 'Kuwait'),
        CountryData(code: 'OM', name: 'Oman'),
      ].toList()
      ..sort((a, b) => a.name.compareTo(b.name)); // Sort alphabetically by name
  }

  // Common currencies from all regions
  static List<CurrencyData> getCommonCurrencies() {
    return [
      // Major world currencies
      CurrencyData(code: 'USD', name: 'US Dollar', symbol: '\$'),
      CurrencyData(code: 'EUR', name: 'Euro', symbol: '€'),
      CurrencyData(code: 'GBP', name: 'British Pound', symbol: '£'),
      CurrencyData(code: 'JPY', name: 'Japanese Yen', symbol: '¥'),
      CurrencyData(code: 'CNY', name: 'Chinese Yuan', symbol: '¥'),
      CurrencyData(code: 'CHF', name: 'Swiss Franc', symbol: 'CHF'),

      // African currencies
      CurrencyData(code: 'NGN', name: 'Nigerian Naira', symbol: '₦'),
      CurrencyData(code: 'KES', name: 'Kenyan Shilling', symbol: 'KSh'),
      CurrencyData(code: 'ZAR', name: 'South African Rand', symbol: 'R'),
      CurrencyData(code: 'GHS', name: 'Ghanaian Cedi', symbol: 'GH₵'),
      CurrencyData(code: 'EGP', name: 'Egyptian Pound', symbol: 'E£'),
      CurrencyData(code: 'MAD', name: 'Moroccan Dirham', symbol: 'MAD'),
      CurrencyData(code: 'UGX', name: 'Ugandan Shilling', symbol: 'USh'),
      CurrencyData(code: 'TZS', name: 'Tanzanian Shilling', symbol: 'TSh'),
      CurrencyData(code: 'XOF', name: 'West African CFA Franc', symbol: 'CFA'),
      CurrencyData(
        code: 'XAF',
        name: 'Central African CFA Franc',
        symbol: 'FCFA',
      ),
      CurrencyData(code: 'ETB', name: 'Ethiopian Birr', symbol: 'Br'),
      CurrencyData(code: 'RWF', name: 'Rwandan Franc', symbol: 'RF'),
      CurrencyData(code: 'AOA', name: 'Angolan Kwanza', symbol: 'Kz'),

      // American currencies
      CurrencyData(code: 'CAD', name: 'Canadian Dollar', symbol: 'C\$'),
      CurrencyData(code: 'MXN', name: 'Mexican Peso', symbol: 'Mex\$'),
      CurrencyData(code: 'BRL', name: 'Brazilian Real', symbol: 'R\$'),
      CurrencyData(code: 'ARS', name: 'Argentine Peso', symbol: 'AR\$'),
      CurrencyData(code: 'COP', name: 'Colombian Peso', symbol: 'COL\$'),
      CurrencyData(code: 'CLP', name: 'Chilean Peso', symbol: 'CLP\$'),
      CurrencyData(code: 'PEN', name: 'Peruvian Sol', symbol: 'S/'),
      CurrencyData(code: 'JMD', name: 'Jamaican Dollar', symbol: 'J\$'),

      // Asian & Middle Eastern currencies
      CurrencyData(code: 'INR', name: 'Indian Rupee', symbol: '₹'),
      CurrencyData(code: 'KRW', name: 'South Korean Won', symbol: '₩'),
      CurrencyData(code: 'IDR', name: 'Indonesian Rupiah', symbol: 'Rp'),
      CurrencyData(code: 'PHP', name: 'Philippine Peso', symbol: '₱'),
      CurrencyData(code: 'SGD', name: 'Singapore Dollar', symbol: 'S\$'),
      CurrencyData(code: 'MYR', name: 'Malaysian Ringgit', symbol: 'RM'),
      CurrencyData(code: 'AED', name: 'UAE Dirham', symbol: 'د.إ'),
      CurrencyData(code: 'SAR', name: 'Saudi Riyal', symbol: 'SR'),
      CurrencyData(code: 'PKR', name: 'Pakistani Rupee', symbol: '₨'),
      CurrencyData(code: 'VND', name: 'Vietnamese Dong', symbol: '₫'),
      CurrencyData(code: 'THB', name: 'Thai Baht', symbol: '฿'),
      CurrencyData(code: 'ILS', name: 'Israeli New Shekel', symbol: '₪'),
      CurrencyData(code: 'TRY', name: 'Turkish Lira', symbol: '₺'),
      CurrencyData(code: 'QAR', name: 'Qatari Riyal', symbol: 'QR'),
      CurrencyData(code: 'BHD', name: 'Bahraini Dinar', symbol: 'BD'),
      CurrencyData(code: 'KWD', name: 'Kuwaiti Dinar', symbol: 'KD'),
      CurrencyData(code: 'OMR', name: 'Omani Rial', symbol: 'OMR'),

      // European currencies
      CurrencyData(code: 'RUB', name: 'Russian Ruble', symbol: '₽'),
      CurrencyData(code: 'PLN', name: 'Polish Złoty', symbol: 'zł'),
      CurrencyData(code: 'UAH', name: 'Ukrainian Hryvnia', symbol: '₴'),
      CurrencyData(code: 'NOK', name: 'Norwegian Krone', symbol: 'kr'),
      CurrencyData(code: 'SEK', name: 'Swedish Krona', symbol: 'kr'),
      CurrencyData(code: 'DKK', name: 'Danish Krone', symbol: 'kr'),
      CurrencyData(code: 'CZK', name: 'Czech Koruna', symbol: 'Kč'),
      CurrencyData(code: 'HUF', name: 'Hungarian Forint', symbol: 'Ft'),

      // Oceania currencies
      CurrencyData(code: 'AUD', name: 'Australian Dollar', symbol: 'A\$'),
      CurrencyData(code: 'NZD', name: 'New Zealand Dollar', symbol: 'NZ\$'),
      CurrencyData(code: 'FJD', name: 'Fijian Dollar', symbol: 'FJ\$'),
    ].toList()..sort(
      (a, b) => a.name.compareTo(b.name),
    ); // Sort alphabetically by name
  }

  // Get currency based on country code
  static CurrencyData? getCurrencyForCountry(String countryCode) {
    // Map of country codes to their default currencies
    final Map<String, String> countryCurrencyMap = {
      // Africa
      'NG': 'NGN',
      'KE': 'KES',
      'ZA': 'ZAR',
      'GH': 'GHS',
      'EG': 'EGP',
      'MA': 'MAD',
      'UG': 'UGX',
      'TZ': 'TZS',
      'ET': 'ETB',
      'RW': 'RWF',
      'SN': 'XOF',
      'AO': 'AOA',
      'CM': 'XAF',

      // Americas
      'US': 'USD',
      'CA': 'CAD',
      'MX': 'MXN',
      'BR': 'BRL',
      'AR': 'ARS',
      'CO': 'COP',
      'CL': 'CLP',
      'PE': 'PEN',
      'JM': 'JMD',

      // Asia & Middle East
      'CN': 'CNY',
      'IN': 'INR',
      'JP': 'JPY',
      'KR': 'KRW',
      'ID': 'IDR',
      'PH': 'PHP',
      'SG': 'SGD',
      'MY': 'MYR',
      'AE': 'AED',
      'SA': 'SAR',
      'PK': 'PKR',
      'VN': 'VND',
      'TH': 'THB',
      'IL': 'ILS',
      'TR': 'TRY',
      'QA': 'QAR',
      'BH': 'BHD',
      'KW': 'KWD',
      'OM': 'OMR',
      'LB': 'LBP',

      // Europe
      'GB': 'GBP',
      'DE': 'EUR',
      'FR': 'EUR',
      'IT': 'EUR',
      'ES': 'EUR',
      'NL': 'EUR',
      'SE': 'SEK',
      'CH': 'CHF',
      'RU': 'RUB',
      'PL': 'PLN',
      'UA': 'UAH',
      'NO': 'NOK',
      'IE': 'EUR',
      'PT': 'EUR',
      'DK': 'DKK',
      'CZ': 'CZK',
      'HU': 'HUF',

      // Oceania
      'AU': 'AUD',
      'NZ': 'NZD',
      'FJ': 'FJD',
    };

    final currencyCode = countryCurrencyMap[countryCode];
    if (currencyCode == null) return null;

    // Find the currency in our list
    final currencies = getCommonCurrencies();
    try {
      return currencies.firstWhere(
        (currency) => currency.code == currencyCode,
        orElse: () => CurrencyData(
          code: currencyCode,
          name: currencyCode,
          symbol: currencyCode,
        ),
      );
    } catch (e) {
      // Fallback in case of any error
      return CurrencyData(
        code: currencyCode,
        name: currencyCode,
        symbol: currencyCode,
      );
    }
  }

  // Format price with currency symbol
  static String formatPrice(double price, CurrencyData currency) {
    // Special formatting for different currencies
    switch (currency.code) {
      case 'JPY':
      case 'KRW':
      case 'VND':
      case 'IDR':
        // These currencies typically don't show decimal places
        return '${currency.symbol}${price.round()}';
      default:
        return '${currency.symbol}${price.toStringAsFixed(2)}';
    }
  }

  // Display a bottom sheet to select country with search
  static Future<CountryData?> showCountryPicker(BuildContext context) async {
    final allCountries = getCommonCountries();
    List<CountryData> filteredCountries = List.from(allCountries);
    final TextEditingController searchController = TextEditingController();

    return showModalBottomSheet<CountryData>(
      context: context,
      isScrollControlled: true, // Makes the bottom sheet larger
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height:
                  MediaQuery.of(context).size.height *
                  0.7, // 70% of screen height
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Country',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  // Search bar
                  TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search countries...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        if (value.isEmpty) {
                          filteredCountries = List.from(allCountries);
                        } else {
                          filteredCountries = allCountries
                              .where(
                                (country) =>
                                    country.name.toLowerCase().contains(
                                      value.toLowerCase(),
                                    ) ||
                                    country.code.toLowerCase().contains(
                                      value.toLowerCase(),
                                    ),
                              )
                              .toList();
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: filteredCountries.isEmpty
                        ? const Center(child: Text('No countries found'))
                        : ListView.builder(
                            itemCount: filteredCountries.length,
                            itemBuilder: (context, index) {
                              final country = filteredCountries[index];
                              return ListTile(
                                title: Text(country.name),
                                leading: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    country.code,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  Navigator.of(context).pop(country);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Display a bottom sheet to select currency with search
  static Future<CurrencyData?> showCurrencyPicker(BuildContext context) async {
    final allCurrencies = getCommonCurrencies();
    List<CurrencyData> filteredCurrencies = List.from(allCurrencies);
    final TextEditingController searchController = TextEditingController();

    return showModalBottomSheet<CurrencyData>(
      context: context,
      isScrollControlled: true, // Makes the bottom sheet larger
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height:
                  MediaQuery.of(context).size.height *
                  0.7, // 70% of screen height
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Currency',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  // Search bar
                  TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search currencies...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        if (value.isEmpty) {
                          filteredCurrencies = List.from(allCurrencies);
                        } else {
                          filteredCurrencies = allCurrencies
                              .where(
                                (currency) =>
                                    currency.name.toLowerCase().contains(
                                      value.toLowerCase(),
                                    ) ||
                                    currency.code.toLowerCase().contains(
                                      value.toLowerCase(),
                                    ) ||
                                    currency.symbol.toLowerCase().contains(
                                      value.toLowerCase(),
                                    ),
                              )
                              .toList();
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: filteredCurrencies.isEmpty
                        ? const Center(child: Text('No currencies found'))
                        : ListView.builder(
                            itemCount: filteredCurrencies.length,
                            itemBuilder: (context, index) {
                              final currency = filteredCurrencies[index];
                              return ListTile(
                                title: Text(currency.name),
                                leading: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    currency.symbol,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                trailing: Text(
                                  currency.code,
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.of(context).pop(currency);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
