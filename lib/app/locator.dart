import 'package:blogman/ui/views/auth/auth_viewmodel.dart';
import 'package:blogman/ui/views/profile/profile_viewmodel.dart';
import 'package:get_it/get_it.dart';
import '../commons/services/services.dart';
import '../ui/views/home/home_viewmodel.dart';
import '../ui/views/home/widgets/app_bar/app_bar_viewmodel.dart';

final locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => AppSettings());
  locator.registerLazySingleton(() => HttpService());

  locator.registerLazySingleton(() => AuthViewModel());

  locator.registerLazySingleton(() => HomeViewModel());
  locator.registerLazySingleton(() => AppBarViewModel());

  locator.registerLazySingleton(() => ProfileViewModel());

}

void userSignOutResetLocator() {
  locator.unregister<HomeViewModel>();
  locator.unregister<AppBarViewModel>();

  locator.registerLazySingleton(() => HomeViewModel());
  locator.registerLazySingleton(() => AppBarViewModel());
}
