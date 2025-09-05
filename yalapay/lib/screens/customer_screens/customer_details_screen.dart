import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yalapay/constants/constants.dart';
import 'package:yalapay/model/address.dart';
import 'package:yalapay/model/contact_details.dart';
import 'package:yalapay/providers/customer_provider.dart';
import 'package:yalapay/providers/invoice_provider.dart';
import 'package:yalapay/providers/show_nav_bar_provider.dart';
import 'package:yalapay/styling/frosted_glass.dart';
import 'package:yalapay/widget/details_row.dart';
import 'package:yalapay/widget/edit_screen_fields.dart';
import 'package:yalapay/widget/section_title_with_icon.dart';
import 'package:yalapay/widget/update_record_confirmation.dart';

class CustomerDetailsScreen extends ConsumerStatefulWidget {
  const CustomerDetailsScreen({super.key, required this.customerId});
  final String customerId;

  @override
  ConsumerState<CustomerDetailsScreen> createState() => _CustomerDetailsState();
}

class _CustomerDetailsState extends ConsumerState<CustomerDetailsScreen> {
  bool isEditing = false;

  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController streetNameController = TextEditingController();
  final TextEditingController cityNameController = TextEditingController();
  final TextEditingController countryNameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(showNavBarNotifierProvider.notifier).showBottomNavBar(false);
    });
  }

  @override
  void dispose() {
    companyNameController.dispose();
    streetNameController.dispose();
    cityNameController.dispose();
    countryNameController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customer = ref
        .read(customerNotifierProvider.notifier)
        .getCustomer(widget.customerId);

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
            automaticallyImplyLeading: false,
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
            title: isEditing
                ? Text(
                    "Editing Customer",
                    style: getTextStyle('largeBold', color: Colors.white),
                  )
                : Text(
                    "Customer Details",
                    style: getTextStyle('largeBold', color: Colors.white),
                  ),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                ref
                    .read(showNavBarNotifierProvider.notifier)
                    .showBottomNavBar(true);
                Navigator.of(context).pop();
              },
            ),
            actions: [
              IconButton(
                icon: Icon(isEditing ? Icons.done : Icons.edit),
                onPressed: () {
                  setState(() {
                    isEditing = !isEditing;
                    if (isEditing) {
                      initializeControllers(customer);
                    }
                  });
                },
              ),
            ],
          ),
          body: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/bg4.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 120, 16, 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              color: lightSecondary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person_2_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                        CompanyNameSection(
                          isEditing: isEditing,
                          controller: companyNameController,
                          companyName: customer.companyName,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FrostedGlassBox(
                      boxWidth: double.infinity,
                      isCurved: true,
                      boxChild: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: AddressSection(
                          isEditing: isEditing,
                          controllers: [
                            streetNameController,
                            cityNameController,
                            countryNameController
                          ],
                          address: customer.address,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FrostedGlassBox(
                      boxWidth: double.infinity,
                      isCurved: true,
                      boxChild: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ContactDetailsSection(
                          isEditing: isEditing,
                          controllers: [
                            firstNameController,
                            lastNameController,
                            emailController,
                            mobileController
                          ],
                          contactDetails: customer.contactDetails,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 100,
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: isEditing
              ? ClipRRect(
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: ElevatedButton(
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            showUpdateConfirmationDialog(context);
                          },
                          style: purpleButtonStyle,
                          child: Text(
                            "Update",
                            style: getTextStyle('small', color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }

  void showUpdateConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          type: "Customer",
          title: "Confirm Update",
          content: "Are you sure you want to update the customer details?",
          onConfirm: updateCustomer,
        );
      },
    );
  }

  void initializeControllers(customer) {
    companyNameController.text = customer.companyName;
    streetNameController.text = customer.address.street;
    cityNameController.text = customer.address.city;
    countryNameController.text = customer.address.country;
    firstNameController.text = customer.contactDetails.firstName;
    lastNameController.text = customer.contactDetails.lastName;
    emailController.text = customer.contactDetails.email;
    mobileController.text = customer.contactDetails.mobile;
  }

  void updateCustomer() {
    if (!isAllFilled()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("All fields are required."),
        backgroundColor: lightSecondary,
      ));
      return;
    }
    final customerId = widget.customerId;
    ref
        .read(customerNotifierProvider.notifier)
        .updateCompanyName(customerId, companyNameController.text);
    ref.read(customerNotifierProvider.notifier).updateAddress(
        customerId,
        streetNameController.text,
        cityNameController.text,
        countryNameController.text);
    ref.read(customerNotifierProvider.notifier).updateContactDetails(
        customerId,
        firstNameController.text,
        lastNameController.text,
        emailController.text,
        mobileController.text);

    ref
        .read(invoiceNotifierProvider.notifier)
        .updateInvoiceCust(customerId, companyNameController.text);

    setState(() {
      isEditing = false;
    });
  }

  bool isAllFilled() {
    return [
      companyNameController,
      streetNameController,
      cityNameController,
      countryNameController,
      firstNameController,
      lastNameController,
      emailController,
      mobileController
    ].every((controller) => controller.text.isNotEmpty);
  }
}

class CompanyNameSection extends StatelessWidget {
  final bool isEditing;
  final TextEditingController controller;
  final String companyName;

  const CompanyNameSection({
    super.key,
    required this.isEditing,
    required this.controller,
    required this.companyName,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        isEditing
            ? EditScreenTextField(
                label: "Company Name",
                controller: controller,
                width: 250,
                centerText: true,
              )
            : Text(
                companyName,
                style: getTextStyle('mediumBold', color: Colors.white),
              ),
      ],
    );
  }
}

class AddressSection extends StatelessWidget {
  final bool isEditing;
  final List<TextEditingController> controllers;
  final Address address;

  const AddressSection({
    super.key,
    required this.isEditing,
    required this.controllers,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionTitleWithIcon(
          icon: Icons.location_on,
          title: "Address",
          child: Column(
            children: [
              DetailsRow(
                label: "Street",
                value: address.street,
                controller: isEditing ? controllers[0] : null,
              ),
              DetailsRow(
                label: "City",
                value: address.city,
                controller: isEditing ? controllers[1] : null,
              ),
              DetailsRow(
                label: "Country",
                value: address.country,
                controller: isEditing ? controllers[2] : null,
                divider: false,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ContactDetailsSection extends StatelessWidget {
  final bool isEditing;
  final List<TextEditingController> controllers;
  final ContactDetails contactDetails;

  const ContactDetailsSection({
    super.key,
    required this.isEditing,
    required this.controllers,
    required this.contactDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionTitleWithIcon(
          icon: Icons.contact_page,
          title: "Contact Details",
          child: Column(
            children: [
              DetailsRow(
                label: "First Name",
                value: contactDetails.firstName,
                controller: isEditing ? controllers[0] : null,
              ),
              DetailsRow(
                label: "Last Name",
                value: contactDetails.lastName,
                controller: isEditing ? controllers[1] : null,
              ),
              DetailsRow(
                label: "Email",
                value: contactDetails.email,
                controller: isEditing ? controllers[2] : null,
              ),
              DetailsRow(
                label: "Mobile No.",
                value: contactDetails.mobile,
                controller: isEditing ? controllers[3] : null,
                divider: false,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
