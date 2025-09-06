import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:yalapay/constants/constants.dart';
import 'package:yalapay/providers/cheque_provider.dart';
import 'package:yalapay/providers/invoice_provider.dart';
import 'package:yalapay/providers/logged_in_user_provider.dart';
import 'package:yalapay/routes/app_router.dart';
import 'package:yalapay/services/auth_service.dart';
import 'package:yalapay/styling/background.dart';
import 'package:yalapay/widget/filter_dropdown.dart';

class Dashboard extends ConsumerStatefulWidget {
  const Dashboard({super.key});

  @override
  ConsumerState<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends ConsumerState<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return const BackgroundGradient(
      colors: [
        lightPrimary,
        Color.fromARGB(255, 43, 9, 98),
        darkPrimary,
      ],
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: Stack(
          children: [
            SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              child: Center(
                child: Column(
                  children: [
                    DashboardAppBar(),
                    DashboardHeader(),
                    InvoiceSummary(),
                    ChequeSummaryScrollable(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardAppBar extends ConsumerWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;

  const DashboardAppBar({super.key})
      : preferredSize = const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      backgroundColor: darkTertiary,
      automaticallyImplyLeading: false,
      title: Image.asset(
        "assets/images/yalapay_text_logo_dark.png",
        width: 110,
      ),
      elevation: 5,
      actions: [
        IconButton(
          onPressed: () async {
            ref.read(loggedInUserNotifierProvider.notifier).clearUser();
            await AuthService().signout(context: context);
            context.go(AppRouter.login.path);
          },
          icon: const Icon(Icons.logout),
        ),
      ],
    );
  }
}

class DashboardHeader extends ConsumerWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: darkTertiary,
        border: Border(
          top: BorderSide(color: borderColor),
          bottom: BorderSide(color: borderColor),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          "Dashboard",
          style: getTextStyle('xlargeBold', color: Colors.white),
        ),
      ),
    );
  }
}

class InvoiceSummary extends ConsumerStatefulWidget {
  const InvoiceSummary({super.key});

  @override
  ConsumerState<InvoiceSummary> createState() => _InvoiceSummaryState();
}

class _InvoiceSummaryState extends ConsumerState<InvoiceSummary> {
  String selectedFilter = "All";
  late Future<Map<String, double>> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _summaryFuture = ref
        .read(invoiceNotifierProvider.notifier)
        .getAllInvoiceDuePendingBalance();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(loggedInUserNotifierProvider);
    final String formattedDate = DateFormat('MM/dd').format(DateTime.now());

    return FutureBuilder<Map<String, double>>(
      future: _summaryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(24.0),
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Failed to load invoices: ${snapshot.error}',
              style: getTextStyle('small', color: Colors.redAccent),
            ),
          );
        }

        final invoiceValues = snapshot.data ??
            const {
              'All': 0.0,
              'Due in 30 Days': 0.0,
              'Due in 60 Days': 0.0,
            };

        if (!invoiceValues.containsKey(selectedFilter)) {
          selectedFilter = invoiceValues.keys.first;
        }

        return Column(
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Invoice Statistics",
                    style: getTextStyle('medium', color: Colors.white),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: FilterDropdown(
                      selectedFilter: selectedFilter,
                      options: invoiceValues.keys.toList(),
                      onSelected: (value) {
                        if (value == null) return;
                        setState(() => selectedFilter = value);
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: const EdgeInsets.all(24.0),
                height: screenHeight(context) * 0.23,
                width: screenWidth(context),
                decoration: BoxDecoration(
                  boxShadow: containerShadow(),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomLeft,
                    colors: [
                      Color.fromARGB(255, 237, 139, 237),
                      Color.fromARGB(255, 191, 64, 191),
                      Color.fromARGB(255, 81, 21, 111),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset("assets/images/yalapay_logo_white.png",
                        width: 44),
                    Text("Total Invoices ($selectedFilter)",
                        style: getTextStyle('small', color: Colors.white)),
                    Text(
                      (invoiceValues[selectedFilter] ?? 0).toStringAsFixed(2),
                      style: getTextStyle('xxlargeBold', color: Colors.white),
                    ),
                    Text(
                      "${user.firstName} ${user.lastName} • $formattedDate",
                      style: getTextStyle('small', color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class ChequeSummaryScrollable extends ConsumerStatefulWidget {
  const ChequeSummaryScrollable({super.key});

  @override
  ConsumerState<ChequeSummaryScrollable> createState() =>
      _ChequeSummaryScrollable();
}

class _ChequeSummaryScrollable extends ConsumerState<ChequeSummaryScrollable> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: ref
            .read(chequeNotifierProvider.notifier)
            .getChequeTotalByAllStatus(),
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return const CircularProgressIndicator();
          }
          final chequeData = [
            {
              "title": "Awaiting",
              "value": 'QAR ${snapshot.data?['awaiting'].toString()}',
              "icon": Icons.timer_outlined
            },
            {
              "title": "Deposited",
              "value": 'QAR ${snapshot.data?['deposited'].toString()}',
              "icon": Icons.send_outlined
            },
            {
              "title": "Cashed",
              "value": 'QAR ${snapshot.data?['cashed'].toString()}',
              "icon": Icons.attach_money
            },
            {
              "title": "Returned",
              "value": 'QAR ${snapshot.data?['returned'].toString()}',
              "icon": Icons.keyboard_return
            },
          ];
          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
                child: Row(
                  children: [
                    Text(
                      "Cheque Statistics",
                      style: getTextStyle('medium', color: Colors.white),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: chequeData.length,
                  itemBuilder: (context, index) {
                    return ChequeBox(
                      title: chequeData[index]["title"] as String,
                      value: chequeData[index]["value"] as String,
                      icon: chequeData[index]["icon"] as IconData,
                    );
                  },
                ),
              ),
            ],
          );
        });
  }
}

class ChequeBox extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const ChequeBox({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: SizedBox(
          width: 180,
          height: 180,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
              side: const BorderSide(color: borderColor, width: 1),
            ),
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleIconContainer(icon: icon),
                      const SizedBox(width: 10),
                      Text(
                        title,
                        style: getTextStyle('medium', color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        value,
                        style: getTextStyle('mediumBold', color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

class CircleIconContainer extends StatelessWidget {
  final IconData icon;

  const CircleIconContainer({
    super.key,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: lightSecondary,
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(8.0),
      child: Icon(icon, color: Colors.white, size: 16),
    );
  }
}
