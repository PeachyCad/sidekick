import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:oktoast/oktoast.dart';
import 'package:window_size/window_size.dart';

import 'modules/common/app_shell.dart';
import 'modules/common/constants.dart';
import 'modules/common/organisms/hive_error_screen.dart';
import 'modules/projects/project.dto.dart';
import 'modules/projects/projects.service.dart';
import 'modules/settings/settings.dto.dart';
import 'modules/settings/settings.service.dart';
import 'modules/settings/settings.utils.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Hive.registerAdapter(SidekickSettingsAdapter());
  Hive.registerAdapter(ProjectPathAdapter());
  await Hive.initFlutter();

  try {
    await SettingsService.init();
    await ProjectsService.init();
  } on FileSystemException {
    print("There was an issue opening the DB");
  }

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle(kAppTitle);
    setWindowMinSize(const Size(800, 500));
    setWindowMaxSize(Size.infinite);
  }

  runApp(ProviderScope(child: FvmApp()));
}

/// Fvm App
class FvmApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (SettingsService.box == null) {
      return const HiveErrorScreen();
    }

    return ValueListenableBuilder(
      valueListenable: SettingsService.box.listenable(),
      builder: (context, box, widget) {
        final settings = SettingsService.read();

        return OKToast(
          child: MaterialApp(
            title: kAppTitle,
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: getThemeMode(settings.themeMode),
            home: const AppShell(),
          ),
        );
      },
    );
  }
}
