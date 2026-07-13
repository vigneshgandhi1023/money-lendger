import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../providers/customer_providers.dart';
import '../widgets/customer_card.dart';

/// Customers list screen — tab 2 in the bottom navigation.
///
/// Shows all customers sorted alphabetically with search,
/// outstanding balance, and active loan count.
class CustomersListScreen extends ConsumerStatefulWidget {
  const CustomersListScreen({super.key});

  @override
  ConsumerState<CustomersListScreen> createState() =>
      _CustomersListScreenState();
}

class _CustomersListScreenState extends ConsumerState<CustomersListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customersAsync = _searchQuery.isEmpty
        ? ref.watch(allCustomersProvider)
        : ref.watch(customerSearchProvider(_searchQuery));

    return Scaffold(
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            snap: true,
            title: Text('Customers', style: theme.textTheme.headlineMedium),
            actions: [
              IconButton(
                onPressed: () => context.push('/search'),
                icon: const Icon(Icons.search_rounded),
              ),
              const SizedBox(width: 4),
            ],
          ),

          // Search Bar
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.horizontalPadding,
              vertical: 8,
            ),
            sliver: SliverToBoxAdapter(
              child: AppSearchBar(
                hint: 'Search by name or phone...',
                onChanged: (query) {
                  setState(() => _searchQuery = query);
                },
              ),
            ),
          ),

          // Customer Count
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.horizontalPadding + 4,
            ),
            sliver: SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: customersAsync.when(
                  data: (customers) => Text(
                    '${customers.length} customer${customers.length != 1 ? 's' : ''}',
                    style: theme.textTheme.bodySmall,
                  ),
                  loading: () => const Text('Loading...'),
                  error: (_, __) => const Text('Error loading customers'),
                ),
              ),
            ),
          ),

          // Customer List
          customersAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, _) => SliverFillRemaining(
              child: Center(child: Text('Error: $err')),
            ),
            data: (customers) {
              if (customers.isEmpty) {
                return SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.people_outline_rounded,
                    title: _searchQuery.isEmpty
                        ? 'No customers yet'
                        : 'No results found',
                    subtitle: _searchQuery.isEmpty
                        ? 'Add your first customer to get started'
                        : 'Try a different search term',
                    actionLabel:
                        _searchQuery.isEmpty ? 'Add Customer' : null,
                    onAction: _searchQuery.isEmpty
                        ? () => context.push('/customers/add')
                        : null,
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.horizontalPadding,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final customer = customers[index];
                      // Use providers for these calculations now
                      final totalBorrowedAsync = ref.watch(customerTotalBorrowedProvider(customer.id));
                      final totalPaidAsync = ref.watch(customerTotalPaidProvider(customer.id));
                      final activeLoansAsync = ref.watch(customerActiveLoansCountProvider(customer.id));

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: CustomerCard(
                          customer: customer,
                          totalBorrowed: totalBorrowedAsync.value ?? 0.0,
                          totalPaid: totalPaidAsync.value ?? 0.0,
                          activeLoans: activeLoansAsync.value ?? 0,
                        ),
                      )
                          .animate()
                          .fadeIn(
                            duration: 300.ms,
                            delay: Duration(
                              milliseconds: (index * 40).clamp(0, 400),
                            ),
                          )
                          .slideY(begin: 0.05, end: 0, duration: 300.ms);
                    },
                    childCount: customers.length,
                  ),
                ),
              );
            },
          ),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),

      // FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/customers/add'),
        icon: const Icon(Icons.person_add_rounded, size: 20),
        label: const Text('New Customer'),
      ),
    );
  }
}
