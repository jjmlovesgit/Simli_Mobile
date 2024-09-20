import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

extension BuildContextExtension on BuildContext {
  AppLocalizations get localizeData => AppLocalizations.of(this)!;

  Color get primary => Theme.of(this).colorScheme.primary;

  Color get surface => Theme.of(this).colorScheme.surface;
  Color get secondary => Theme.of(this).colorScheme.secondary;
}
