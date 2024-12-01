import 'package:flutter/material.dart';
import 'package:studieapp/utilities/dialogs/generic_dialog.dart';

Future<bool> showPublishDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Publiceren',
    content:
        'Weet u zeker dat u de nieuwste versie van deze woordenlijst wilt publiceren?',
    optionsBuilder: () => {
      'Cancel': false,
      'OK': true,
    },
  ).then(
    (value) => value ?? false,
  );
}
