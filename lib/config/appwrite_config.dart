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

  // Helper: Get image preview URL
  static String getImageUrl(String fileId) {
    return '${AppConstants.appwriteEndpoint}/storage/buckets/${AppConstants.imagesBucketId}/files/$fileId/preview?project=${AppConstants.appwriteProjectId}';
  }
}
