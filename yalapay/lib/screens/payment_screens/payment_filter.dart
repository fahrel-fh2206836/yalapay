import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yalapay/constants/constants.dart';
import 'package:yalapay/providers/payment_provider.dart';
import 'package:yalapay/widget/filter_dropdown.dart';

class FilterSection extends ConsumerStatefulWidget {
  final String invoiceId;
  const FilterSection({super.key, required this.invoiceId});

  @override
  _FilterSectionState createState() => _FilterSectionState();
}

class _FilterSectionState extends ConsumerState<FilterSection> {
  final modeController = TextEditingController();
  bool isModeFilter = false;
  bool isAfterDateFilter = false;
  DateTime? selectedDate;
  String selectedFilter = "No Filter";

  @override
  void dispose() {
    modeController.dispose();
    super.dispose();
  }

  void setFilterState(String filterOn, WidgetRef ref) {
    setState(() {
      selectedFilter = filterOn;
      isModeFilter = filterOn == "Payment Mode";
      isAfterDateFilter = filterOn == "After Date";

      if (filterOn == "No Filter") {
        clearFilters(ref, widget.invoiceId);
      } else if (isModeFilter) {
        // Apply immediately if mode already chosen
        onFilterChanged(ref, widget.invoiceId);
      } else if (isAfterDateFilter) {
        // Only apply if a date is already picked; otherwise wait for pick
        if (selectedDate != null) {
          onFilterChanged(ref, widget.invoiceId);
        }
      }
    });
  }

  void onFilterChanged(WidgetRef ref, String invoiceId) {
    final paymentNotifier = ref.read(paymentNotifierProvider.notifier);

    if (isModeFilter && modeController.text.isNotEmpty) {
      paymentNotifier.filterPaymentByMode(modeController.text, invoiceId);
      return;
    }

    if (isAfterDateFilter && selectedDate != null) {
      final d = selectedDate!;
      final startOfDay = DateTime(d.year, d.month, d.day);
      paymentNotifier.filterPaymentByDate(
          startOfDay, invoiceId); // TS-based in notifier/repo
      return;
    }

    // Fallback
    paymentNotifier.getPaymentsByInvoiceId(invoiceId);
  }

  void clearFilters(WidgetRef ref, String invoiceId) {
    setState(() {
      selectedFilter = "No Filter";
      isModeFilter = false;
      isAfterDateFilter = false;
      modeController.clear();
      selectedDate = null;
    });
    ref
        .read(paymentNotifierProvider.notifier)
        .getPaymentsByInvoiceId(invoiceId);
  }

  @override
  Widget build(BuildContext context) {
    final paymentModes = ref.watch(paymentModeProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: darkTertiary,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  "Filter By:",
                  style: getTextStyle('mediumBold', color: Colors.white),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: FilterDropdown(
                      selectedFilter: selectedFilter,
                      options: const [
                        "No Filter",
                        "Payment Mode",
                        "After Date",
                      ],
                      onSelected: (value) {
                        if (value != null) {
                          setFilterState(value, ref);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            FilterControls(
              modeController: modeController,
              isModeFilter: isModeFilter,
              isAfterDateFilter: isAfterDateFilter,
              onDatePicked: (date) {
                setState(() => selectedDate = date);
                // Apply immediately once the user picks a date
                final startOfDate = DateTime(date.year, date.month, date.day);
                ref
                    .read(paymentNotifierProvider.notifier)
                    .filterPaymentByDate(startOfDate, widget.invoiceId);
              },
              paymentModes: paymentModes,
              selectedDate: selectedDate,
              onModeChanged: () => onFilterChanged(ref, widget.invoiceId),
            ),
            if (selectedFilter != "No Filter")
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => clearFilters(ref, widget.invoiceId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lightPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "Clear Filters",
                    style: getTextStyle('small', color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class FilterControls extends StatefulWidget {
  final TextEditingController modeController;
  final bool isModeFilter;
  final bool isAfterDateFilter;
  final Function(DateTime) onDatePicked;
  final AsyncValue<List<String>> paymentModes;
  final DateTime? selectedDate;
  final VoidCallback onModeChanged;

  const FilterControls({
    super.key,
    required this.modeController,
    required this.isModeFilter,
    required this.isAfterDateFilter,
    required this.onDatePicked,
    required this.paymentModes,
    required this.selectedDate,
    required this.onModeChanged,
  });

  @override
  _FilterControlsState createState() => _FilterControlsState();
}

class _FilterControlsState extends State<FilterControls> {
  String? selectedMode;

  @override
  void initState() {
    super.initState();
    widget.modeController.addListener(widget.onModeChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.isModeFilter) buildModeFilter(),
        if (widget.isAfterDateFilter) buildDateFilter(),
      ],
    );
  }

  Widget buildModeFilter() {
    final modes = widget.paymentModes.asData?.value;
    if (modes == null) return const SizedBox.shrink();

    selectedMode ??= modes.isNotEmpty ? modes.first : '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: SizedBox(
        width: double.infinity,
        child: FilterDropdown(
          selectedFilter: selectedMode!,
          options: modes,
          onSelected: (value) {
            setState(() {
              selectedMode = value;
              widget.modeController.text = value ?? '';
              widget.onModeChanged();
            });
          },
        ),
      ),
    );
  }

  Widget buildDateFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () async {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );
            if (pickedDate != null) {
              widget.onDatePicked(pickedDate);
              setState(() {});
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color:
                    widget.selectedDate == null ? borderColor : lightSecondary,
                width: widget.selectedDate == null ? 1 : 2,
              ),
            ),
          ),
          child: Text(
            widget.selectedDate != null
                ? '${widget.selectedDate!.year.toString().padLeft(4, '0')}-'
                    '${widget.selectedDate!.month.toString().padLeft(2, '0')}-'
                    '${widget.selectedDate!.day.toString().padLeft(2, '0')}'
                : "Select Date",
            style: getTextStyle('small', color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
