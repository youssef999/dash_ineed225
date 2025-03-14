import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
// ignore: unused_import
import 'package:googleapis/servicecontrol/v1.dart' as servicecontrol;

class NotificationService {

    static Future<String> getAccessToken() async {

    final serviceAccountJson ={
      "type": "service_account",
      "project_id": "servicesapp2024",
      "private_key_id": "895b93908e33c72631e02ebdc5b19dad9d0dfb92",
      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCoywsEZZV2UKCU\n++mGXknAr/AWe7/09nLjFt8DFravT/PdHBO+cn2qWejmrKAbRtFjWPvMEE37f2oa\n5Aj2XeRJ1u5lDYqQ8ho90LFiJ8G0IBj9fGMnALSzfI9DOXvyIqoFBBtdjF1zXSVL\n3zH+ZMYBBi4t9lPk8gMkHo5g/BpZyea4RA4M+9TME2VoVTAK7F1R0lRfr5nACrLE\nXzPi1sVu7LieBd4skz4/N8R5bBfeoXEI25EOZUYLNsZuwl7PGnqJ9ZxoXHC0WzpS\nUG+nc7tufhtLI5N2449amfUAGAdhgClbVvb3z4wkThCi2L7FVR2OfuZCtsgl/KMZ\n+SrVqOP9AgMBAAECggEAFDnyecYnfRxHxdqS/vY8/cFHcpZFKBhBJ5u1wRO/c+4P\ngaMr7YIgM2HfQgcVD3eyvyYqVCdvBNBdmVfSiB0zrjJ6cjMHc/uC7/3aR7IOaOSA\nwh1d705LGQf3zd0tUFRdjcjSc6kOiLS0c61M+xg9zuEb9weBwZlLjZA4zP/gs3oH\neaJopg916Y3QwzAR+1Lq94QAJXc74W6o1CwNHoKvwD8HbXRt/RvpgMK9U1/1S/gT\noRhQOX/So3hAqSKyaO/OLKBmR0ANIwv2kvlDhTl+ER3kqLN/D72Y9wBbgXlorNFz\nfx8HV+5N0LKXVkeHnVXSeMsqsVUO6b/3jcU/+Yx3SQKBgQDg6Zo8+toeVHzp1WIH\nceRdQsyxqN7OX7MOH2HzOOaPuPeuki4ubk8wRVMneb7ZA0fm3yS7oBxt2yXbvrqO\namf40dXD0rX32Xp7T5PH4VysklirwoTxH3j/RFtcAZ6UphRiWzSpzE+4+SI44krm\nH2Gt7YBeamCLDgAzoGsuV+NtiQKBgQDAH7B7XRZQAMscJsl+K7/1F3UyZh+MSSOy\nqseBXmgxxMOKranbCDWcK8a8AxDZ5z52wN9y0eTtXe1EQRJZj63I15IlULgivofd\nJDQ7qbq7KT3iIPYR07Lwn1+o7olqk0GV1yY9Ig6xmc/TY2S4IMYjqefA1aGWyP0i\ncjwRWCF51QKBgQCGZA99kIb0yJc7Qf2pZSyHbXrSTY2U0yoyrh3hL4bVKjkVXtOp\netBmj4X4eI7JLWSxV3SjiDB0lBYzD+x5XKtzyi5pLGb/CjxdolczgD3YADprp3e4\nfI3YOgg9GdqgB/z2KHl3XFXmuTbxtoX6q5W6T8f8oqO9c0g7kQd6UZnbwQKBgQC2\nfmN5Cxcir14/Q2ip/Iy+FqYwVWkqLF9IW4hejnqSq8DCfeuWLtodmkeQV6kuEsX2\nr4aQ3meCQXIbH2R6xkvhN0OPRnliJ3GO0dD7y2GgXrB1l7GlhV23yutm4A6PuYjW\n+CNOdodWlDAhL4yAikErpzyIo2R2gjxQ+Amuv/QscQKBgG8QFt9aJWGBtF9mXTIe\ncQlzu3q0KIY18Pg4ZHgtGkp00PGHcmLW63F9dPsmNp4kLyp6Lp3Tj8bA2LbM20Wl\nF8ia4Ktctu2AzQ9pR6FWaAJCit/+i3y1RhXXhC1ydSh4lnBjrBshuOtULx/7iLE8\nY5LaPACh9TntO7x1lWrXa6xu\n-----END PRIVATE KEY-----\n",
      "client_email": "serviceappfcm@servicesapp2024.iam.gserviceaccount.com",
      "client_id": "115763657468661021643",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/serviceappfcm%40servicesapp2024.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };
    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];
    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );
    auth.AccessCredentials credentials =
    await auth.obtainAccessCredentialsViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
        scopes,
        client);
    client.close();
    return credentials.accessToken.data;
  }


  static Future<void> sendNotification(
      String deviceToken, String title, String body,String loc)

  async {
    print("Device tokeeeen====$deviceToken");

    final String accessToken = await getAccessToken();

    String endpointFCM =
        'https://fcm.googleapis.com/v1/projects/servicesapp2024/messages:send';

    final Map<String, dynamic> message = {
     
       "message": {
        "token":
        deviceToken,
        "notification": {"title": title+loc, "body": body+loc,
        //"key":loc
        },
        "data": {
         // "bodyLocKey":loc,
          "route": "serviceScreen",
        }
      }
    };

    final http.Response response = await http.post(
      Uri.parse(endpointFCM),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(message),
    );
    if (response.statusCode == 200) {
      print('Notification sent successfully');
      Fluttertoast.showToast(
        msg: "تم إرسال الإشعار بنجاح",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else {
      print("Failed to send notification: ${response.statusCode}");
      print('Failed to send notification');
      Fluttertoast.showToast(
        msg: "فشل في إرسال الإشعار",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  static Future<void> sendNotificationToAll(String title, String body,int roleId,String loc) async {
    
    String topic='users';

    if(roleId==1){
      topic=='serviceProviders';
    }

    final String accessToken = await getAccessToken();
    String endpointFCM =
        'https://fcm.googleapis.com/v1/projects/servicesapp2024/messages:send';
    final Map<String, dynamic> message = {
      "message": {
        "topic": topic, // Use a topic to send to all subscribers
        "notification": {
          "title": title+loc,
           "body": body+loc,
        },
        "data": {
          "route": "serviceScreen",
        }
      }
    };

    final http.Response response = await http.post(
      Uri.parse(endpointFCM),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      print('Notification sent to all successfully');
      Fluttertoast.showToast(
        msg: "تم إرسال الإشعار إلى الجميع بنجاح",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else {
      print('Failed to send notification to all');
      Fluttertoast.showToast(
        msg: "فشل في إرسال الإشعار إلى الجميع",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }
}
