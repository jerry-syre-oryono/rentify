import 'dart:typed_data';
import 'package:appwrite/appwrite.dart';
import '../utils/constants.dart';

class AppwriteConfig {
  static late Client client;
  static late Account account;
  static late Databases databases;
  static late Storage storage;

  static void init() {
    client = Client()
        .setEndpoint(AppConstants.appwriteEndpoint)
        .setProject(AppConstants.appwriteProjectId);
        // .setSelfSigned(); // Remove in production with valid SSL
    
    account = Account(client);
    databases = Databases(client);
    storage = Storage(client);
  }

  // Helper: Get image view URL (using /view instead of /preview to avoid transformation limits on free plan)
  static String getImageUrl(String fileId) {
    final endpoint = AppConstants.appwriteEndpoint;
    final project = AppConstants.appwriteProjectId;
    final bucket = AppConstants.imagesBucketId;
    
    return '$endpoint/storage/buckets/$bucket/files/$fileId/view?project=$project';
  }

  // Alternative using SDK if needed (though the above string is standard)
  static Future<Uint8List> getImagePreview(String fileId) async {
    return await storage.getFilePreview(
      bucketId: AppConstants.imagesBucketId,
      fileId: fileId,
    );
  }
}
