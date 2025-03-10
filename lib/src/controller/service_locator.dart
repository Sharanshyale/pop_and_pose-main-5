import 'package:get_it/get_it.dart';
import 'package:pop_and_pose/src/feature/screen/camera/data/camera_repository.dart';
import 'package:pop_and_pose/src/feature/screen/camera/data/ssdp_discovery_.dart';
import 'package:pop_and_pose/src/feature/screen/camera/domain/camera_service.dart';
import 'package:pop_and_pose/src/feature/screen/camera/domain/camera_service_impl.dart';

final locator = GetIt.instance;

void setupLocator() {
  // Register SSDPDIscovery
  locator.registerLazySingleton<SSDPDiscovery>(() => SSDPDiscovery());

  // Register CameraRepository with dependency on SSDPDiscovery
  locator.registerLazySingleton<CameraRepository>(
    () => CameraRepository(locator.get<SSDPDiscovery>()),
  );

  // Register CameraService with dependency on CameraRepository
  locator.registerLazySingleton<CameraService>(
    () => CameraServiceImpl(locator.get<CameraRepository>()),
  );
}
