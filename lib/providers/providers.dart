import 'package:flutter_riverpod/legacy.dart';
import 'package:kiliride/providers/app_data.provider.dart';
import 'package:kiliride/providers/user.provider.dart';


final userInfoProvider = ChangeNotifierProvider((ref) => UserProvider());
// final chatbotProvider = ChangeNotifierProvider((ref) => ChatbotProvider());
final appDataProvider = ChangeNotifierProvider((ref) => AppDataProvider(ref));
