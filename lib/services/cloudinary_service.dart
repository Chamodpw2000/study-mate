import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:crypto/crypto.dart';

Future<Map<String, dynamic>> uploadToCloudinary(
    FilePickerResult? filePickerResult) async {
  if (filePickerResult == null || filePickerResult.files.isEmpty) {
    return {"error": "No file selected"};
  }

  File file = File(filePickerResult.files.single.path!);
  String cloudName = dotenv.env["CLOUDINARY_CLOUD_NAME"] ?? "";
  String apiKey = dotenv.env["CLOUDINARY_API_KEY"] ?? "";
  String apiSecret = dotenv.env["CLOUDINARY_API_SECRET"] ?? "";

  var uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/raw/upload");
  var request = http.MultipartRequest("POST", uri);

  String basicAuth = 'Basic ' + base64Encode(utf8.encode('$apiKey:$apiSecret'));
  request.headers['authorization'] = basicAuth;

  var fileBytes = await file.readAsBytes();
  var multipartFile = http.MultipartFile.fromBytes('file', fileBytes,
      filename: file.path.split("/").last);

  request.files.add(multipartFile);
  request.fields["upload_preset"] = "preset-for-file-upload";
  request.fields["resource_type"] = "raw";
  request.fields["folder"] = "pdfs";
  request.fields["tags"] = "pdf_upload";

  var response = await request.send();
  var responseBody = await response.stream.bytesToString();

  return jsonDecode(responseBody);
}

void _showSuccessNotification(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.white),
          SizedBox(width: 8),
          Text(
            'File downloaded successfully!',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
}

Future<bool> downloadFileFromCloudinary(
    String? url, String? fileName, BuildContext context) async {
  if (url == null || fileName == null) {
    showNoPdfNotification(context);
    return false;
  }

  try {
    var status = await Permission.storage.request();
    var manageStatus = await Permission.manageExternalStorage.request();

    if (status == PermissionStatus.granted &&
        manageStatus == PermissionStatus.granted) {
      print("Storage permissions granted");
    } else {
      await openAppSettings();
    }

    Directory? downloadsDir = Directory('/storage/emulated/0/Download');
    if (!downloadsDir.existsSync()) {
      print("Downloads directory not found");
      return false;
    }

    String filePath = '${downloadsDir.path}/$fileName';

    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      File file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      print("File downloaded successfully! Saved at: $filePath");
      // ignore: use_build_context_synchronously
      _showSuccessNotification(context);

      return true;
    } else {
      print("Failed to download file. Status code: ${response.statusCode}");
      return false;
    }
  } catch (e) {
    print("Error downloading file: $e");
    return false;
  }
}

void showNoPdfNotification(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(Icons.warning, color: Colors.white),
          SizedBox(width: 8),
          Text(
            'No PDF attached to this note',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.orange,
      duration: Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
}

Future<bool> deleteFromCloudinary(String publicId) async {
  String cloudName = dotenv.env["CLOUDINARY_CLOUD_NAME"] ?? "";
  String apiKey = dotenv.env["CLOUDINARY_API_KEY"] ?? "";
  String apiSecret = dotenv.env["CLOUDINARY_SECRET_KEY"] ?? "";

  int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

  String toSign = 'public_id=$publicId&timestamp=$timestamp$apiSecret';

  var bytes = utf8.encode(toSign);
  var digest = sha1.convert(bytes);
  String signature = digest.toString();

  var uri =
      Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/raw/destroy/");

  var responce = await http.post(uri, body: {
    "public_id": publicId,
    "timestamp": timestamp.toString(),
    "api_key": apiKey,
    "signature": signature
  });

  if (responce.statusCode == 200) {
    var responceBody = jsonDecode(responce.body);
    print(responceBody);
    if (responceBody["result"] == "ok") {
      print("File Deleted Successfully");
      return true;
    } else {
      print("Failed to delete file");
      return false;
    }
  } else {
    print(
        "Failed to delete file, status: ${responce.statusCode} : ${responce.reasonPhrase}");
    return false;
  }
}
