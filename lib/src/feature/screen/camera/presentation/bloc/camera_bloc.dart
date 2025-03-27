import 'dart:async';
import 'dart:typed_data';
import 'package:http/http.dart' as http;


import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pop_and_pose/src/feature/screen/camera/domain/camera_service.dart';
import 'package:pop_and_pose/src/feature/screen/camera/presentation/bloc/camera_event.dart';
import 'package:pop_and_pose/src/feature/screen/camera/presentation/bloc/camera_state.dart';
import 'package:pop_and_pose/src/utils/log.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  final CameraService _cameraService;
  final _frameController = StreamController<Uint8List>();

  Stream<Uint8List> get liveViewFrameStream => _frameController.stream;

  CameraBloc(this._cameraService) : super(CameraInitialState()) {
    on<DiscoverCameraEvent>(_onDiscoverCamera);
    on<TakePictureEvent>(_onPictureTaken);
    on<StartLiveViewEvent>(_onStartLiveView);
    on<FetchLiveViewEvent>(_onFetchLiveView);
    on<FetchThumbnailsList>(_onFetchThumbnailsList);
    on<StopLiveViewEvent>(_onStopLiveView);
    on<SetISOEvent>(_setIsoValue);
    on<SetWhiteBalanceEvent>(_setWhiteBalance);
   
  }

  Future<void> _onDiscoverCamera(
      DiscoverCameraEvent event, Emitter<CameraState> emit) async {
    emit(CameraDiscoveringState());

    try {
      if (await _cameraService.discoverCamera()) {
        emit(CameraConnectedState());
      } else {
        emit(CameraDisconnectedState());
      }
    } catch (e) {
      throw CameraError('Failed to discover camera $e');
    }
  }

  FutureOr<void> _onPictureTaken(
      TakePictureEvent event, Emitter<CameraState> emit) async {
    try {
      // Capture the image as Uint8List
      final imageBytes = await _cameraService.takePicture();

      // Emit the state with the captured image bytes
      emit(CameraPictureCapturedState(imageBytes: imageBytes));
    } catch (e) {
      emit(CameraError("Failed to take picture: $e"));
    }
  }

  Future<void> _onStartLiveView(
      StartLiveViewEvent event, Emitter<CameraState> emit) async {
    emit(LiveViewStartingState());
    try {
      final response = await _cameraService.startLiveView();
      if (response?.statusCode == 200) {
        emit(LiveViewStartedState());
        add(FetchLiveViewEvent());
      }
    } catch (e) {
      emit(CameraError("Failed to start Live view $e"));
    }
  }

  Future<void> _onStopLiveView(
      StopLiveViewEvent event, Emitter<CameraState> emit) async {
    try {
      await _cameraService.stopLiveView();
      Log.d('Stopped live view response ==>');
    } catch (e) {
      emit(CameraError("Failed to stop Live view $e"));
    }
  }

  // Fetch live view frames
  Future<void> _onFetchLiveView(
      FetchLiveViewEvent event, Emitter<CameraState> emit) async {
    try {
      await for (var frame in await _cameraService.fetchLiveView()) {
        if (frame != null && frame.isNotEmpty) {
          emit(LiveViewFetchedState(frame));
        } else {
          Log.e("Received empty live view frame");
        }
      }
    } catch (e) {
      Log.e("Error fetching live view frames: $e");
      emit(CameraError("Exception during live view streaming"));
    }
  }

  // Fetch thumbnails as Uint8List
  Future<void> _onFetchThumbnailsList(
      FetchThumbnailsList event, Emitter<CameraState> emit) async {
    try {
      // Fetch thumbnail URLs
      final thumbnailUrls = await _cameraService.getThumbnailsList();
      print('hhhh$thumbnailUrls');
      if (thumbnailUrls == null || thumbnailUrls.isEmpty) {
        emit(CameraError('No thumbnails found'));
        return;
      }

      // Download thumbnails as Uint8List
      final List<Uint8List> thumbnails = [];
      for (final url in thumbnailUrls) {
        try {
          final response = await http.get(Uri.parse(url));
          if (response.statusCode == 200) {
            thumbnails.add(response.bodyBytes);
          } else {
            Log.e('Failed to download thumbnail from $url');
          }
        } catch (e) {
          Log.e('Error downloading thumbnail: $e');
        }
      }

      if (thumbnails.isEmpty) {
        emit(CameraError('Failed to download thumbnails'));
      } else {
        emit(ThumbnailsFetchedState(thumbnails));
      }
    } catch (e) {
      emit(CameraError('Failed to fetch thumbnails list: $e'));
    }
  }

  Future<void> _setIsoValue(
      SetISOEvent event, Emitter<CameraState> emit) async {
    await _cameraService.setISO(event.value);
  }

  Future<void> _setWhiteBalance(
      SetWhiteBalanceEvent event, Emitter<CameraState> emit) async {
    await _cameraService.setWhiteBalance(event.value);
  }


  
}