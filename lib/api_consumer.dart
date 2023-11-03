import 'package:ar_furniture_app/global.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

class ApiConsumer {
  Future<Uint8List> removeImageBackgroundApi(String imagePath) async {
    var requestApi = http.MultipartRequest(
        "POST", Uri.parse("https://api.remove.bg/v1.0/removebg"));

    requestApi.files
        .add(await http.MultipartFile.fromPath("image_file", imagePath));
    requestApi.headers.addAll({"X-API-Key": apiKeyRemoveImageBackground});

    //send request and receive response
    final responseFromApi = await requestApi.send();

    if (responseFromApi.statusCode == 200) {
      http.Response getTransparentImageFromResponse =
          await http.Response.fromStream(responseFromApi);
      return getTransparentImageFromResponse.bodyBytes;
    } else {
      throw Exception("Error Occurred:: ${responseFromApi.statusCode}");
    }
  }
}
