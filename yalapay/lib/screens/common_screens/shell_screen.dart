import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yalapay/constants/constants.dart';
import 'package:yalapay/providers/cheque_provider.dart';
import 'package:yalapay/providers/customer_provider.dart';
import 'package:yalapay/providers/invoice_provider.dart';
import 'package:yalapay/providers/show_nav_bar_provider.dart';
import 'package:yalapay/routes/app_router.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class ShellScreen extends ConsumerStatefulWidget {
  final Widget? child;
  const ShellScreen({super.key, this.child});

  @override
  ConsumerState<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends ConsumerState<ShellScreen> {
  int currentIndex = 0;

  void showAllData({bool showAllCheque = true}) {
    ref.read(customerNotifierProvider.notifier).showAll();
    ref.read(invoiceNotifierProvider.notifier).showAll();
    if (showAllCheque) {
      ref.read(chequeNotifierProvider.notifier).showAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    final showBottomNavBar = ref.watch(showNavBarNotifierProvider);
    ref.watch(customerNotifierProvider);
    ref.watch(invoiceNotifierProvider);
    ref.watch(chequeNotifierProvider);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: showBottomNavBar
          ? Theme(
              data: Theme.of(context).copyWith(
                canvasColor: darkTertiary,
              ),
              child: CurvedNavigationBar(
                index: currentIndex,
                color: darkTertiary,
                backgroundColor: darkPrimary,
                buttonBackgroundColor: const Color.fromARGB(255, 226, 62, 226),
                items: const [
                  Icon(Icons.dashboard_rounded, color: Colors.white),
                  Icon(Icons.supervised_user_circle_rounded,
                      color: Colors.white),
                  Icon(Icons.monetization_on_rounded, color: Colors.white),
                  Icon(Icons.receipt_rounded, color: Colors.white),
                  Icon(Icons.description_rounded, color: Colors.white),
                ],
                onTap: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                  switch (index) {
                    case 0:
                      context.go(AppRouter.dashboard.path);
                      showAllData();
                      break;
                    case 1:
                      context.go(AppRouter.customer.path);
                      showAllData();
                      break;
                    case 2:
                      context.go(AppRouter.invoice.path);
                      showAllData();
                      break;
                    case 3:
                      context.go(AppRouter.cheque.path);
                      showAllData(showAllCheque: false);
                      ref
                          .read(chequeNotifierProvider.notifier)
                          .setByStatus('Awaiting');
                      break;
                    case 4:
                      context.go(AppRouter.report.path);
                      showAllData();
                      break;
                  }
                  ref
                      .read(showNavBarNotifierProvider.notifier)
                      .showBottomNavBar(true);
                },
              ),
            )
          : null,
    );
  }
}
