import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yalapay/constants/constants.dart';
import 'package:yalapay/providers/payment_mode_provider.dart';
import 'package:yalapay/providers/payment_provider.dart';
import 'package:yalapay/widget/add_screen_text_field.dart';
import 'package:yalapay/widget/filter_dropdown.dart';

class FilterSection extends ConsumerStatefulWidget {
  const FilterSection({super.key});

  @override
  _FilterSectionState createState() => _FilterSectionState();
}

class _FilterSectionState extends ConsumerState<FilterSection> {
  final minAmountController = TextEditingController();
  final modeController = TextEditingController();
  bool isAmountFilter = false;
  bool isModeFilter = false;
  bool isAfterDateFilter = false;
  DateTime? selectedDate;
  String selectedFilter = "No Filter";

  @override
  void initState() {
    super.initState();
    minAmountController.addListener(() {
      if (isAmountFilter && minAmountController.text.isNotEmpty) {
        onFilterChanged(ref);
      }
    });
    modeController.addListener(() {
      if (isModeFilter && modeController.text.isNotEmpty) {
        onFilterChanged(ref);
      }
    });
  }

  void setFilterState(String filterOn, WidgetRef ref) {
    setState(() {
      selectedFilter = filterOn;
      isAmountFilter = filterOn == 'Minimum Amount';
      isModeFilter = filterOn == "Payment Mode";
      isAfterDateFilter = filterOn == "After Date";

      if (filterOn == "No Filter") {
        clearFilters(ref);
      } else {
        onFilterChanged(ref); // Trigger filter update when filter type changes
      }
    });
  }

  void onFilterChanged(WidgetRef ref) {
    final paymentNotifier = ref.read(paymentNotifierProvider.notifier);

    if (isAmountFilter && minAmountController.text.isNotEmpty) {
      paymentNotifier
          .filterPaymentByAmount(double.parse(minAmountController.text));
    } else if (isModeFilter && modeController.text.isNotEmpty) {
      paymentNotifier.filterPaymentByMode(modeController.text);
    } else if (isAfterDateFilter && selectedDate != null) {
      paymentNotifier.filterPaymentByDate(
          selectedDate!.toIso8601String().split('T').first);
    } else {
      paymentNotifier.showAllPayments();
    }
  }

  void clearFilters(WidgetRef ref) {
    setState(() {
      selectedFilter = "No Filter";
      isAmountFilter = false;
      isModeFilter = false;
      isAfterDateFilter = false;
      minAmountController.clear();
      modeController.clear();
      selectedDate = null;
    });
    ref.read(paymentNotifierProvider.notifier).showAllPayments();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
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
                            "Minimum Amount",
                            "Payment Mode",
                            "After Date"
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
                  minAmountController: minAmountController,
                  modeController: modeController,
                  isAmountFilter: isAmountFilter,
                  isModeFilter: isModeFilter,
                  isAfterDateFilter: isAfterDateFilter,
                  onDatePicked: (date) {
                    setState(() => selectedDate = date);
                    onFilterChanged(ref);
                  },
                  paymentModes: paymentModes,
                  selectedDate: selectedDate,
                  onAmountChanged: () => onFilterChanged(ref),
                  onModeChanged: () => onFilterChanged(ref),
                ),
                if (selectedFilter != "No Filter")
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => clearFilters(ref),
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
      },
    );
  }
}

class FilterControls extends StatefulWidget {
  final TextEditingController minAmountController;
  final TextEditingController modeController;
  final bool isAmountFilter;
  final bool isModeFilter;
  final bool isAfterDateFilter;
  final Function(DateTime) onDatePicked;
  final AsyncValue<List<String>> paymentModes;
  final DateTime? selectedDate;
  final VoidCallback onAmountChanged;
  final VoidCallback onModeChanged;

  const FilterControls({
    super.key,
    required this.minAmountController,
    required this.modeController,
    required this.isAmountFilter,
    required this.isModeFilter,
    required this.isAfterDateFilter,
    required this.onDatePicked,
    required this.paymentModes,
    required this.selectedDate,
    required this.onAmountChanged,
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

    // Update the state whenever the controllers change
    widget.minAmountController.addListener(widget.onAmountChanged);
    widget.modeController.addListener(widget.onModeChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.isAmountFilter) buildAmountFilter(),
        if (widget.isModeFilter) buildModeFilter(),
        if (widget.isAfterDateFilter) buildDateFilter(),
      ],
    );
  }

  Widget buildAmountFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: AddScreensTextField(
        controller: widget.minAmountController,
        label: 'Min Amount',
        height: 50,
        type: TextInputType.number,
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear, color: Colors.white),
          onPressed: () {
            widget.minAmountController.clear();
            widget.onAmountChanged();
          },
        ),
      ),
    );
  }

  Widget buildModeFilter() {
    final modes = widget.paymentModes.asData?.value;

    if (modes == null) {
      return const SizedBox.shrink();
    }

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
              widget.onModeChanged(); // Trigger filtering on selection
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
                ? widget.selectedDate!
                    .toLocal()
                    .toIso8601String()
                    .split('T')
                    .first
                : "Select Date",
            style: getTextStyle('small', color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
