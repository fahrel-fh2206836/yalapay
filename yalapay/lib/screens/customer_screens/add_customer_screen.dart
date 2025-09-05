import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yalapay/constants/constants.dart';
import 'package:yalapay/model/address.dart';
import 'package:yalapay/model/contact_details.dart';
import 'package:yalapay/model/customer.dart';
import 'package:yalapay/providers/customer_provider.dart';
import 'package:yalapay/providers/show_nav_bar_provider.dart';
import 'package:yalapay/widget/add_screen_text_field.dart';
import 'package:yalapay/widget/section_title_with_icon.dart';

class AddCustomerScreen extends ConsumerStatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  ConsumerState<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends ConsumerState<AddCustomerScreen> {
  final companyController = TextEditingController();
  final streetController = TextEditingController();
  final cityController = TextEditingController();
  final countryController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(showNavBarNotifierProvider.notifier).showBottomNavBar(false);
    });
  }

  void clearAll() {
    for (var controller in [
      companyController,
      streetController,
      cityController,
      countryController,
      firstNameController,
      lastNameController,
      mobileController,
      emailController
    ]) {
      controller.clear();
    }
  }

  bool isAllFilled() => [
        companyController,
        streetController,
        cityController,
        countryController,
        firstNameController,
        lastNameController,
        mobileController,
        emailController
      ].every((controller) => controller.text.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (!didPop) {
            ref
                .read(showNavBarNotifierProvider.notifier)
                .showBottomNavBar(true);
            Navigator.of(context).pop(result);
          }
          return;
        },
        child: Scaffold(
          extendBodyBehindAppBar: true,
          extendBody: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  color: Colors.black.withOpacity(0.2),
                ),
              ),
            ),
            title: Text(
              "Add Customer",
              style: getTextStyle('largeBold', color: Colors.white),
            ),
            centerTitle: true,
          ),
          body: Stack(
            children: [
              buildBackground(),
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    buildCompanyInfoSection(),
                    const SizedBox(height: 20),
                    buildAddressSection(),
                    const SizedBox(height: 20),
                    buildContactDetailsSection(),
                    const SizedBox(height: 110),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: buildBottomNavigationBar(context),
        ),
      ),
    );
  }

  Widget buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/bg4.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        color: Colors.black.withOpacity(0.3),
      ),
    );
  }

  Widget buildCompanyInfoSection() {
    return StyledContainer(
      child: SectionTitleWithIcon(
        icon: Icons.business,
        title: "Company Information",
        child: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: AddScreensTextField(
            label: "Company Name",
            controller: companyController,
            activeBorderColor: lightSecondary,
          ),
        ),
      ),
    );
  }

  Widget buildAddressSection() {
    return StyledContainer(
      child: SectionTitleWithIcon(
        icon: Icons.location_on,
        title: "Address",
        child: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Column(
            children: [
              AddScreensTextField(
                controller: streetController,
                label: "Street",
                activeBorderColor: lightSecondary,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AddScreensTextField(
                    controller: cityController,
                    label: "City",
                    width: 150,
                    activeBorderColor: lightSecondary,
                  ),
                  AddScreensTextField(
                    controller: countryController,
                    label: "Country",
                    width: 150,
                    activeBorderColor: lightSecondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildContactDetailsSection() {
    return StyledContainer(
      child: SectionTitleWithIcon(
        icon: Icons.contact_page,
        title: "Contact Details",
        child: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Column(
            children: [
              AddScreensTextField(
                controller: firstNameController,
                label: "First Name",
              ),
              const SizedBox(height: 20),
              AddScreensTextField(
                controller: lastNameController,
                label: "Last Name",
              ),
              const SizedBox(height: 20),
              AddScreensTextField(
                controller: mobileController,
                label: "Mobile Number",
                type: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              AddScreensTextField(
                controller: emailController,
                label: "Email Address",
                type: TextInputType.emailAddress,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBottomNavigationBar(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: BottomAppBar(
          color: Colors.black.withOpacity(0.4),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => handleAddCustomer(context),
                    style: purpleButtonStyle,
                    child: Text(
                      "Add Customer",
                      style: getTextStyle('small', color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: clearAll,
                    style: purpleButtonStyle,
                    child: Text(
                      "Clear All",
                      style: getTextStyle('small', color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void handleAddCustomer(BuildContext context) {
    if (!isAllFilled()) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All fields are required.')));
      return;
    }

    bool customerExists = ref
        .read(customerNotifierProvider.notifier)
        .isCustomerExistByName(companyController.text);

    if (!customerExists) {
      Address address = Address(
        city: cityController.text,
        country: countryController.text,
        street: streetController.text,
      );
      ContactDetails contact = ContactDetails(
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        email: emailController.text,
        mobile: mobileController.text,
      );
      Customer customer = Customer(
        id: (int.parse(ref.watch(customerNotifierProvider).last.id) + 1)
            .toString(),
        companyName: companyController.text,
        address: address,
        contactDetails: contact,
      );

      ref.read(customerNotifierProvider.notifier).addCustomer(customer);
      clearAll();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Customer Added.')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Company Name Already Exists!')));
    }
  }
}

class StyledContainer extends StatelessWidget {
  final Widget child;

  const StyledContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: darkPrimary.withOpacity(0.6),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }
}
