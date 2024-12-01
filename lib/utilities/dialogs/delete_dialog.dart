import 'package:flutter/material.dart';
import 'package:studieapp/utilities/dialogs/generic_dialog.dart';

Future<bool> showDeleteDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: 'Verwijderen',
    content: 'Weet u zeker dat u dit item wilt verwijderen?',
    optionsBuilder: () => {
      'Cancel': false,
      'OK': true,
    },
  ).then((value) => value ?? false);
}
