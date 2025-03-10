import 'dart:ui';

class CameraAPIConstants {
  static const String url = 'url';
  static const String takePictureUrl = '/ver100/shooting/control/shutterbutton';
  static const String liveViewUrl = '/ver100/shooting/liveview';
  static const String liveViewScrollUrl = '/ver100/shooting/liveview/scroll';
  static const String isoUrl = '/ver100/shooting/iso';
  static const String wbUrl = '/ver100/shooting/settings/wb';
  static const String contentsUrl = '/ver100/contents';

  static const String liveViewSize = 'liveviewsize';
  static const String cameraDisplay = 'cameradisplay';
  static const String quality = 'quality';
  static const String autoFocus = 'af';

  static const String value = 'value';
  static const String iosValue = 'isoValue';

  static const ssdpAddrV4 = "239.255.255.250";
  static const ssdpPort = 1900;
  static const ssdpMX = 3;
  static const ssdpST =
      'urn:schemas-canon-com:service:ICPO-CameraControlAPIService:1';
  static const int maxRetries = 3;
  static const Duration retryDelay =
      Duration(seconds: 3); // Time between retries

  static const ddRegex =
      '<ns:X_accessURL xmlns:ns="urn:schemas-canon-com:schema-upnp">(.+?)</ns:X_accessURL>';

  static const ssdpRequest =
      "M-SEARCH * HTTP/1.1\r\nHOST: ${CameraAPIConstants.ssdpAddrV4}:${CameraAPIConstants.ssdpPort}\r\nMAN: \"ssdp:discover\"\r\nMX: ${CameraAPIConstants.ssdpMX}\r\nST: ${CameraAPIConstants.ssdpST}\r\n\r\n";
}

class BaseurlForBackend {
  static const String baseUrL = "https://pop-pose-backend.vercel.app";
  static const String startUserJourney = "/api/user/start";
  static const String getCopiesEndPoint = "/api/copies/getAllCopies";
  static const String framesEndpoint = "/api/frame/frames";
  static const String selectFramesendPoint = "/api/user/:userId/select-frame";
  static const String uploadimagebase = "/api/user/save-images";
  static const String registerDevice = "/api/background/register";

  static const startUserJourney1 = "$baseUrL$startUserJourney";
  static const getCopies = "$baseUrL$getCopiesEndPoint";
  static const getFrames = "$baseUrL$framesEndpoint";
  static const selectFrame = "$baseUrL$selectFramesendPoint";
  static const uploadimage = "$baseUrL$uploadimagebase";
}

class PaytmAPIConstants {
  static const String paytmBaseUrlStaging = "https://securegw-stage.paytm.in";
  static const String paytmBaseUrlProduction = "https://securegw.paytm.in";

  static const String createQrCodeEndpoint = "/paymentservices/qr/create";
  static const String checkTransactionStatusEndpoint = "/v3/order/status";

  static String get createQrCodeUrlStaging =>
      "$paytmBaseUrlStaging$createQrCodeEndpoint";
  static String get transactionStatusUrlStaging =>
      "$paytmBaseUrlStaging$checkTransactionStatusEndpoint";

  static String get createQrCodeUrlProduction =>
      "$paytmBaseUrlProduction$createQrCodeEndpoint";
  static String get transactionStatusUrlProduction =>
      "$paytmBaseUrlProduction$checkTransactionStatusEndpoint";

  static const String clientId = "C11";
  static const String version = "v1";
}

const minimumWindowSize = Size(1200, 900);
