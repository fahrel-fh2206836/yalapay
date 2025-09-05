import 'package:flutter/material.dart';

const darkPrimary = Color(0xFF151535);

const darkSecondary = Color(0xFF202060);

const darkTertiary = Color(0xFF0c0c22);

const lightPrimary = Color(0xFF602080);

const lightSecondary = Color(0xFFB030B0);

const borderColor = Color.fromARGB(255, 64, 64, 99);

Color getInvoiceStatusColor(String status) {
  switch (status) {
    case 'Paid':
      return lightSecondary;
    case 'Partially Paid':
      return Colors.yellow;
    default:
      return Colors.grey;
  }
}

Color getChequeStatusColor(String status) {
  switch (status) {
    case 'Awaiting':
      return Colors.yellow;
    case 'Deposited':
      return lightSecondary;
    case 'Cashed':
      return Colors.green;
    default:
      return Colors.red;
  }
}

Color getPaymentModeColor(String paymentMode) {
  switch (paymentMode) {
    case 'Cheque':
      return lightSecondary;
    default:
      return Colors.grey;
  }
}

const textStyles = {
  'smallLight': TextStyle(
      fontFamily: 'DMSans', fontSize: 14, fontWeight: FontWeight.w100),
  'mediumLight': TextStyle(
      fontFamily: 'DMSans', fontSize: 18, fontWeight: FontWeight.w100),
  'largeLight': TextStyle(
      fontFamily: 'DMSans', fontSize: 22, fontWeight: FontWeight.w100),
  'xlargeLight': TextStyle(
      fontFamily: 'DMSans', fontSize: 28, fontWeight: FontWeight.w100),
  'xxlargeLight': TextStyle(
      fontFamily: 'DMSans', fontSize: 36, fontWeight: FontWeight.w100),
  'small': TextStyle(
      fontFamily: 'DMSans', fontSize: 14, fontWeight: FontWeight.normal),
  'medium': TextStyle(
      fontFamily: 'DMSans', fontSize: 18, fontWeight: FontWeight.normal),
  'large': TextStyle(
      fontFamily: 'DMSans', fontSize: 22, fontWeight: FontWeight.normal),
  'xlarge': TextStyle(
      fontFamily: 'DMSans', fontSize: 28, fontWeight: FontWeight.normal),
  'xxlarge': TextStyle(
      fontFamily: 'DMSans', fontSize: 36, fontWeight: FontWeight.normal),
  'smallBold': TextStyle(
      fontFamily: 'DMSans', fontSize: 14, fontWeight: FontWeight.w700),
  'mediumBold': TextStyle(
      fontFamily: 'DMSans', fontSize: 18, fontWeight: FontWeight.w700),
  'largeBold': TextStyle(
      fontFamily: 'DMSans', fontSize: 22, fontWeight: FontWeight.w700),
  'xlargeBold': TextStyle(
      fontFamily: 'DMSans', fontSize: 28, fontWeight: FontWeight.w700),
  'xxlargeBold': TextStyle(
      fontFamily: 'DMSans', fontSize: 36, fontWeight: FontWeight.w700),
};

List<BoxShadow> containerShadow() {
  return [
    BoxShadow(
      color: Colors.black.withOpacity(0.3), // color
      spreadRadius: 2, // spread
      blurRadius: 5, // softness
      offset: const Offset(0, 3), //shadow effect
    ),
  ];
}

TextStyle getTextStyle(String size, {Color? color}) {
  return textStyles[size]?.copyWith(color: color ?? Colors.black) ??
      TextStyle(color: color ?? Colors.black);
}

// screen height constant
double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;

// screen width constant
double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;

const whiteButtonTextStyle = TextStyle(
  fontFamily: 'DMSans',
  fontSize: 20,
  fontWeight: FontWeight.bold,
  color: Colors.white,
);

final purpleButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: lightPrimary,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  ),
);

final pinkButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: lightSecondary,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  ),
);

final greyButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: const Color.fromARGB(255, 85, 85, 85),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  ),
);

List<String> days =
    List.generate(31, (i) => (i + 1).toString().padLeft(2, '0'));
List<String> month =
    List.generate(12, (i) => (i + 1).toString().padLeft(2, '0'));

const String baseDirectory = 'assets/images/cheques/';

List<Map> imageList = [
  {'value': 'cheque1.jpg', 'image': '${baseDirectory}cheque1.jpg'},
  {'value': 'cheque2.jpg', 'image': '${baseDirectory}cheque2.jpg'},
  {'value': 'cheque3.jpg', 'image': '${baseDirectory}cheque3.jpg'},
  {'value': 'cheque4.jpg', 'image': '${baseDirectory}cheque4.jpg'},
  {'value': 'cheque5.jpg', 'image': '${baseDirectory}cheque5.jpg'},
  {'value': 'cheque6.jpg', 'image': '${baseDirectory}cheque6.jpg'},
  {'value': 'cheque7.jpg', 'image': '${baseDirectory}cheque7.jpg'},
];

enum DateType { cashedDate, depositDate, returnedDate }
