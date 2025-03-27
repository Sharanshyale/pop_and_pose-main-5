import 'dart:typed_data';

import 'package:equatable/equatable.dart';

abstract class CameraState extends Equatable {
  @override
  List<Object?> get props => [];
 String get userId => '';
 
}

class CameraInitialState extends CameraState {}

class CameraDiscoveringState extends CameraState {}

class CameraConnectedState extends CameraState {}

class CameraDisconnectedState extends CameraState {}

class CameraPictureTakenState extends CameraState {}

class LiveViewStartingState extends CameraState {}

class LiveViewStartedState extends CameraState {}

class CameraPictureCapturedState extends CameraState {
  final Uint8List imageBytes; // Holds the captured image in bytes

  CameraPictureCapturedState({required this.imageBytes});

  @override
  List<Object?> get props => [imageBytes];
}

class LiveViewFetchedState extends CameraState {
  final Uint8List frame;
  LiveViewFetchedState(this.frame);

  @override
  List<Object?> get props => [frame];
}

class LiveViewErrorState extends CameraState {
  final String errorMessage;
  LiveViewErrorState(this.errorMessage);
}

class CameraError extends CameraState {
  final String message;
  CameraError(this.message);

  @override
  List<Object?> get props => [message];
}

class ThumbnailsFetchedState extends CameraState {
  final List<Uint8List> thumbnailsList;
  ThumbnailsFetchedState(this.thumbnailsList);
}

class IsoSetSuccessState extends CameraState {
  final int value;
  IsoSetSuccessState(this.value);
}
class UserState extends CameraState{
final String userId;
UserState({required this.userId})  ;
  @override
  List<Object?> get props => [userId];
}

class UserInitialState extends CameraState {

}
class UserUpdatedState extends CameraState {
  final String userId;

  UserUpdatedState(this.userId);
}