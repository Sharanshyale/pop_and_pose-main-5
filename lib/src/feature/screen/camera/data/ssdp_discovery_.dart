import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:pop_and_pose/src/constant/api_constants.dart';
import 'package:pop_and_pose/src/utils/api_service.dart';
import 'package:pop_and_pose/src/utils/log.dart';

class SSDPDiscovery {
  
    Future<String?> sendSSDPRequest() async {
    String? url;
    
    int attempts = 0;

    while (attempts < CameraAPIConstants.maxRetries) {
      try {
        // Bind to the UDP socket on any available port
        final rawSocket =
            await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
        rawSocket.broadcastEnabled = true;

        // Join the multicast group
        rawSocket.joinMulticast(InternetAddress(CameraAPIConstants.ssdpAddrV4));

        Log.d("Joined multicast group: ${CameraAPIConstants.ssdpAddrV4}");

        // Send the SSDP M-SEARCH request to the multicast address
        rawSocket.send(Uint8List.fromList(CameraAPIConstants.ssdpRequest.codeUnits),
            InternetAddress(CameraAPIConstants.ssdpAddrV4), CameraAPIConstants.ssdpPort);
        Log.d("Sent SSDP request to ${CameraAPIConstants.ssdpAddrV4}:${CameraAPIConstants.ssdpPort}");

        // Wait for a response for a limited time
        final completer = Completer<String?>();
        rawSocket.listen((RawSocketEvent event) async {
          if (event == RawSocketEvent.read) {
            final Datagram? packet = rawSocket.receive();
            if (packet != null) {
              final response = String.fromCharCodes(packet.data);
              Log.d("Received SSDP response: $response");
              var ddLocation = findParameterValue(response, "Location");
              if (ddLocation != null) {
                url = await getBaseUrl(ddLocation);
                completer
                    .complete(url); // Complete with the discovered location
              }
            }
          }
        });
        url = await completer.future.timeout(const Duration(seconds: 5),
            onTimeout: () {
          Log.d("Discovery attempt ${attempts + 1} timed out.");
          return null;
        });

        if (url != null) {
          return url; // Return the discovered URL if found
        }
      } catch (e) {
        Log.e("Error during SSDP request: $e");
      }

      // Wait before retrying
      attempts++;
      if (attempts < CameraAPIConstants.maxRetries) {
        Log.d("Retrying in 3 seconds...");
        await Future.delayed(CameraAPIConstants.retryDelay);
      }
    }

    Log.e("Failed to discover SSDP after $CameraAPIConstants.maxRetries attempts.");
    return null; // Return null if no response after retries
  }

  String? findParameterValue(String message, String paramName) {
    final name = paramName.endsWith(":") ? paramName : "$paramName:";
    final regex = RegExp('$name\\s*(.*?)\\r\\n');
    final match = regex.firstMatch(message);
    
    return match?.group(1)?.trim();
  }

  static Future<String?> getBaseUrl(String ddLocation) async {
    try {
      // Send GET request using sendGetRequest
      final response = await ApiService.sendGetRequest(ddLocation);

      // Process the response body
      final xml = response.body;

      // Parse XML for the required base URL
      final RegExp pattern = RegExp(CameraAPIConstants.ddRegex);
      final matches = pattern.allMatches(xml);

      for (var match in matches) {
        final baseUrl = match.group(1);
        if (baseUrl != null) {
          Log.d("Extracted Base URL: $baseUrl");
          return baseUrl;
        }
      }

      Log.e("No valid base URL found in the response.");
      return null;
    } catch (e) {
      Log.e("Error in getBaseUrl: $e");
      return null;
    }
  }
}
