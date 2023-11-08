import 'package:blogman/services/http_service.dart';
import 'package:blogman/services/shared_preferences/settings.dart';
import 'package:blogman/ui/views/auth/auth_viewmodel.dart';
import 'package:blogman/ui/widgets/home/app_bar/app_bar_viewmodel.dart';
import 'package:get_it/get_it.dart';
import '../ui/views/home/home_viewmodel.dart';

final locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => AppSettings());
  locator.registerLazySingleton(() => HttpService());
  locator.registerLazySingleton(() => AuthViewModel());

  locator.registerLazySingleton(() => HomeViewModel());
  locator.registerLazySingleton(() => AppBarViewModel());

}
