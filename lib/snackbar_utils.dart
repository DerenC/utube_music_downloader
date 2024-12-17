import 'package:flutter/material.dart';

const verticalPadding = 5.0;

void showSuccessSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      padding: EdgeInsets.fromLTRB(
        15.0,
        verticalPadding,
        6.0,
        verticalPadding,
      ),
      content: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: Color(0xFF22A06B),
          ),
          SizedBox(width: 17.0), // `17`
          Flexible(child: Text(message)),
        ],
      ),
      backgroundColor: const Color(0xFFDCFFF1),
      // backgroundColor: Colors.greenAccent[100],
      showCloseIcon: true,
    ),
  );
}

void showErrorSnackbar(BuildContext context, String message) {
  const leftPadding = 20.0;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      padding: EdgeInsets.fromLTRB(
        leftPadding,
        verticalPadding,
        7.0,
        verticalPadding,
      ),
      content: Row(
        children: [
          Text(
            "!",
            style: TextStyle(
              color: const Color.fromARGB(255, 234, 109, 30),
              fontSize: 30.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: leftPadding),
          Flexible(child: Text(message)),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 251, 225, 206),
      // backgroundColor: Color.fromARGB(255, 255, 148, 77),
      showCloseIcon: true,
    ),
  );
}

void showInformationSnackbar(BuildContext context, String message) {
  const verticalPadding = 5.0;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      padding: EdgeInsets.fromLTRB(15.0, verticalPadding, 6.0, verticalPadding),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Icon(
            Icons.info,
            color: Color(0xFF0049B0),
          ),
          SizedBox(width: 17.0),
          Flexible(child: Text(message)),
        ],
      ),
      backgroundColor: const Color(0xFFCCE0FF),
      showCloseIcon: true,
    ),
  );
}

void showSomethingWentWrongSnackbar(BuildContext context) {
  showErrorSnackbar(context, 'Something went wrong, please try again');
}