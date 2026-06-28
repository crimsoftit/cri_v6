import 'package:cri_v6/bindings/general_bindings.dart';
import 'package:cri_v6/common/widgets/loaders/default_loader.dart';
import 'package:cri_v6/main.dart';
import 'package:cri_v6/routes/app_routes.dart';
import 'package:cri_v6/utils/themes/themes.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class App extends StatelessWidget {
  const App({super.key});

  // --- This widget is the root of your application.
  // --- use this class to configure themes, initial bindings, animations, etc. ----
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      darkTheme: CAppTheme.darkTheme,
      debugShowCheckedModeBanner: true,
      getPages: CAppRoutes.pages,
      initialBinding: CGeneralBindings(),
      navigatorKey: globalNavigatorKey,
      scrollBehavior: const MaterialScrollBehavior(),
      theme: CAppTheme.lightTheme,
      themeMode: ThemeMode.system,

      // -- show loader or circular progress indicator as AuthRepo decides on the relevant screen to load --
      home: const DefaultLoaderScreen(),
    );
  }
}
