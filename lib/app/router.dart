import 'package:blogman/ui/views/auth/auth_view.dart';
import 'package:go_router/go_router.dart';
import '../ui/views/home/home_view.dart';

final GoRouter router = GoRouter(
  initialLocation: '/auth',
  routes: [
    GoRoute(
      path: '/auth',
      name: 'auth',
      builder: (context, state) => const AuthView(),
    ),
    GoRoute(
      path: '/home/:blogId',
      name: 'home',
      builder: (context, state) =>
          HomeView(blogId: state.pathParameters['blogId']!),
    ),
  ],
);
