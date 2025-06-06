import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trixo_frontend/features/auth/presentation/screens/onboarding_screen.dart';

import 'package:trixo_frontend/features/auth/presentation/screens/screens.dart';
import 'package:trixo_frontend/config/config.dart';
import 'package:trixo_frontend/features/post/presentation/views/search_view.dart';
import 'package:trixo_frontend/features/shared/screens/screens.dart';
import 'package:trixo_frontend/features/post/presentation/views/post_views.dart';
import 'package:trixo_frontend/features/shop/presentation/views/checkout_confirmation_view.dart';
import 'package:trixo_frontend/features/shop/presentation/views/shop_views.dart';

final goRouterProvider = Provider((ref) {
  final goRouterNotifier = ref.watch(goRouterNotifierProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: goRouterNotifier,
    routes: [
      //*Loading Screen
      GoRoute(
        path: '/splash',
        builder: (context, state) => const CheckAuthStatusScreen(),
      ),
      //*Auth Routes
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(),
      ),
      GoRoute(
        path: '/signin',
        builder: (context, state) => SignInScreen(),
      ),
      GoRoute(
        path: '/reset_password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPreferencesView(),
      ),
      //* Views NavBar
      StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return Home(childView: navigationShell);
          },
          branches: [
            StatefulShellBranch(routes: <RouteBase>[
              //* Home View
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeView(),
              ),
              //* Search View
              GoRoute(
                path: '/search',
                builder: (context, state) => const SearchView(),
              ),
              //* Profile View
              GoRoute(
                path: '/profile/:userId',
                builder: (context, state) {
                  return Consumer(
                    builder: (context, ref, child) {
                      final userId = state.pathParameters['userId']!;

                      return ProfileView(
                        userId: userId,
                        actualUser: true,
                      );
                    },
                  );
                },
              ),
              //* External profile
              GoRoute(
                path: '/user/:userId',
                builder: (context, state) {
                  return Consumer(
                    builder: (context, ref, child) {
                      final userId = state.pathParameters['userId']!;
                      return ProfileView(
                        userId: userId,
                        actualUser: false,
                      );
                    },
                  );
                },
              ),
              //* Shop View
              GoRoute(
                path: '/shop',
                builder: (context, state) => const ShopView(),
              ),
              GoRoute(
                path: '/checkout_confirmation',
                builder: (context, state) {
                  final extra = state.extra;
                  if (extra is Map<String, double>) {
                    return CheckoutConfirmationView(
                      subtotal: extra['subtotal'] ?? 0.0,
                      delivery: extra['delivery'] ?? 0.0,
                      total: extra['total'] ?? 0.0,
                    );
                  } else {
                    return const CheckoutConfirmationView(
                      subtotal: 0.0,
                      delivery: 0.0,
                      total: 0.0,
                    );
                  }
                },
              ),
            ])
          ]),
      //* Create post section
      GoRoute(
        path: '/image-picker',
        builder: (context, state) => const ImagePickerView(),
      ),
      GoRoute(
        path: '/create-post',
        builder: (context, state) {
          final images = state.extra as List<String>;
          return CreatePostView(images: images);
        },
      ),
      GoRoute(
        path: '/select-tags',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return CreatePostSelectTagsView(
            availableTags: AppConstants().allPreferences,
            initialTags: extra['initialTags'] as List<String>,
          );
        },
      ),
      //* Settings
      GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen()),
    ],
    //* Bloquear si no se está autenticado de alguna manera
    // redirect: (context, state) {
    //   final isGoingTo = state.matchedLocation;
    //   final authStatus = goRouterNotifier.authStatus;

    //   //Se ponen las condiciones de las rutas (si estoy autenticado, si soy admin o no...)

    //   if (isGoingTo == '/splash' && authStatus == AuthStatus.checking) {
    //     return null;
    //   }

    //   if (authStatus == AuthStatus.notAuthenticated) {
    //     //Si no está autenticado  y quiere ir a signin o login le dejo pasar
    //     if (isGoingTo == '/login' || isGoingTo == '/signin') return null;
    //     //Pero si quiere ir a otro lado le redirijo a /login (evito que continue)
    //     return '/login';
    //   }

    //   if (authStatus == AuthStatus.authenticated) {
    //     if (isGoingTo == '/login' ||
    //         isGoingTo == '/signin' ||
    //         isGoingTo == '/splash') return '/home';

    //     return null;
    //   }

    //   return null;
    // },
  );
});
