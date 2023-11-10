import 'package:blogman/app/locator.dart';
import 'package:blogman/ui/views/auth/auth_view.dart';
import 'package:blogman/ui/views/comments/comments_view.dart';
import 'package:blogman/ui/views/comments/comments_viewmodel.dart';
import 'package:blogman/ui/views/preview/preview_view.dart';
import 'package:blogman/ui/views/profile/profile_view.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
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
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfileView(),
    ),
    GoRoute(
      path: '/comments',
      name: 'comments',
      builder: (context, state) => ChangeNotifierProvider<CommentsViewModel>(
        create: (context) => CommentsViewModel(),
        child: CommentsView(postId: state.uri.queryParameters['postId']),
      ),
    ),
    GoRoute(
      path: '/preview',
      name: 'preview',
      builder: (context, state) =>
          PreviewView(postId: state.uri.queryParameters['postId']!),
    ),
  ],
);

void resetApp() async {
  while (router.canPop()) {
    router.pop();
  }
  userSignOutResetLocator();
  router.replaceNamed('auth');
}
