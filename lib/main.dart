import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/route_manager.dart';
import 'package:pop_and_pose/src/constant/api_constants.dart';
import 'package:pop_and_pose/src/constant/navigation_service.dart';
import 'package:pop_and_pose/src/controller/network_controller.dart';
import 'package:pop_and_pose/src/controller/service_locator.dart';
import 'package:pop_and_pose/src/feature/screen/camera/domain/camera_service.dart';
import 'package:pop_and_pose/src/feature/screen/camera/presentation/bloc/camera_bloc.dart';
import 'package:pop_and_pose/src/feature/widgets/app_loading.dart';
import 'package:pop_and_pose/src/routes/routes.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  _setupDesktop();
  runApp(const MyApp());
}

Future<void> _setupDesktop() async {
  await windowManager.ensureInitialized();
  WindowManager.instance.setMinimumSize(minimumWindowSize);

  WindowOptions windowOptions = const WindowOptions(
    size: minimumWindowSize,
    center: true,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppBase();
  }
}

class AppBase extends StatelessWidget {
  const AppBase({super.key});

  @override
  Widget build(BuildContext context) {
    final AppRouter appRouter = AppRouter();
    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitDown,
        DeviceOrientation.portraitUp,
      ],
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => CameraBloc(locator.get<CameraService>()),
        ),
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        onGenerateRoute: appRouter.onGenerateRoute,
        navigatorKey: NavigationService.navigatorKey,
        builder: (context, navigator) {
          // Directly return the navigator without the ConnectivityWrapper
          return Center(child: navigator ?? AppLoading());
        },
        theme: ThemeData(
          useMaterial3: true,
        ),
      ),
    );
  }
}
