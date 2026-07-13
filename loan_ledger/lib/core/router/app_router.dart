import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/cloud_auth_service.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/customers/screens/customers_list_screen.dart';
import '../../features/customers/screens/customer_detail_screen.dart';
import '../../features/customers/screens/add_edit_customer_screen.dart';
import '../../features/loans/screens/loan_detail_screen.dart';
import '../../features/loans/screens/add_edit_loan_screen.dart';
import '../../features/payments/screens/receive_payment_screen.dart';
import '../../features/search/screens/search_screen.dart';
import '../../features/reports/screens/reports_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../shell/app_shell.dart';

/// Route names for type-safe navigation.
class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String signup = '/signup';
  static const String dashboard = '/';
  static const String customers = '/customers';
  static const String customerDetail = '/customers/:id';
  static const String addCustomer = '/customers/add';
  static const String editCustomer = '/customers/:id/edit';
  static const String loanDetail = '/loans/:id';
  static const String addLoan = '/loans/add';
  static const String editLoan = '/loans/:id/edit';
  static const String receivePayment = '/payments/receive';
  static const String search = '/search';
  static const String reports = '/reports';
  static const String notifications = '/notifications';
  static const String settings = '/settings';
}

/// Global navigation key for accessing navigator state.
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// GoRouter configuration provider.
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.dashboard,
    redirect: (context, state) {
      final isAuthRoute = state.uri.toString() == AppRoutes.login || 
                          state.uri.toString() == AppRoutes.signup;
      
      // If we are still loading auth state, don't redirect yet
      if (authState.isLoading) return null;
      
      final isAuth = authState.valueOrNull != null;

      if (!isAuth && !isAuthRoute) {
        return AppRoutes.login;
      }
      
      if (isAuth && isAuthRoute) {
        return AppRoutes.dashboard;
      }

      return null;
    },
    routes: [
      // ─── Auth Routes ─────────────────────────────────
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignUpScreen(),
      ),

      // ─── Shell Route (Bottom Navigation) ─────────────
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          // Dashboard
          GoRoute(
            path: AppRoutes.dashboard,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardScreen(),
            ),
          ),

          // Customers List
          GoRoute(
            path: AppRoutes.customers,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CustomersListScreen(),
            ),
          ),

          // Reports
          GoRoute(
            path: AppRoutes.reports,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ReportsScreen(),
            ),
          ),

          // Settings
          GoRoute(
            path: AppRoutes.settings,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
        ],
      ),

      // ─── Detail Routes (outside shell for full-screen) ───

      // Customer Detail
      GoRoute(
        path: '/customers/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final customerId = state.pathParameters['id']!;
          return CustomerDetailScreen(customerId: customerId);
        },
      ),

      // Add Customer
      GoRoute(
        path: '/customers/add',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddEditCustomerScreen(),
      ),

      // Edit Customer
      GoRoute(
        path: '/customers/:id/edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final customerId = state.pathParameters['id']!;
          return AddEditCustomerScreen(customerId: customerId);
        },
      ),

      // Loan Detail
      GoRoute(
        path: '/loans/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final loanId = state.pathParameters['id']!;
          return LoanDetailScreen(loanId: loanId);
        },
      ),

      // Add Loan
      GoRoute(
        path: '/loans/add',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final customerId = state.uri.queryParameters['customerId'];
          return AddEditLoanScreen(customerId: customerId);
        },
      ),

      // Edit Loan
      GoRoute(
        path: '/loans/:id/edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final loanId = state.pathParameters['id']!;
          return AddEditLoanScreen(loanId: loanId);
        },
      ),

      // Receive Payment
      GoRoute(
        path: '/payments/receive',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final loanId = state.uri.queryParameters['loanId'];
          final customerId = state.uri.queryParameters['customerId'];
          return ReceivePaymentScreen(
            loanId: loanId,
            customerId: customerId,
          );
        },
      ),

      // Search
      GoRoute(
        path: AppRoutes.search,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SearchScreen(),
      ),

      // Notifications
      GoRoute(
        path: AppRoutes.notifications,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
  );
});
