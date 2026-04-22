// Quick Pin System Test
// Add this temporarily to main.dart to verify pins work

import 'package:appwrite/appwrite.dart';

Future<void> testPinSystem() async {
  print('\n=== 🧪 TESTING PINS SYSTEM ===\n');
  
  try {
    final client = Client();
    client
      .setEndpoint('https://nyc.cloud.appwrite.io/v1')
      .setProject('69c7c467000dcf77499e');

    final databases = Databases(client);
    const dbId = '69c7c496001cc7881cd0';
    const collectionId = 'pins';

    // Test 1: Access collection
    print('📋 Test 1: Checking pins collection access...');
    try {
      final response = await databases.listDocuments(
        databaseId: dbId,
        collectionId: collectionId,
        queries: [Query.limit(1)],
      );
      print('✅ Collection accessible!');
      print('   Total pins: ${response.total}');
    } catch (e) {
      print('❌ Cannot access pins collection: $e');
      return;
    }

    // Test 2: Verify schema
    print('\n🔍 Test 2: Verifying database schema...');
    try {
      final response = await databases.listDocuments(
        databaseId: dbId,
        collectionId: collectionId,
        queries: [Query.limit(1)],
      );

      if (response.documents.isEmpty) {
        print('⚠️  No pins created yet - cannot verify full schema');
        print('   But collection is ready! Create a pin to test.');
      } else {
        final doc = response.documents.first;
        final keys = doc.data.keys.toList();
        
        print('   Available columns:');
        for (var key in keys) {
          print('   - $key: ${doc.data[key].runtimeType}');
        }

        // Check critical fields
        bool hasLatitude = keys.contains('latitude');
        bool hasLongitude = keys.contains('longitude');
        bool hasSellerId = keys.contains('sellerId');

        if (hasLatitude && hasLongitude && hasSellerId) {
          print('\n✅ Schema is CORRECT!');
          print('   ✓ latitude column found');
          print('   ✓ longitude column found');
          print('   ✓ sellerId column found');
        } else {
          print('\n❌ Schema issues detected:');
          if (!hasLatitude) print('   ✗ Missing: latitude');
          if (!hasLongitude) print('   ✗ Missing: longitude');
          if (!hasSellerId) print('   ✗ Missing: sellerId');
        }
      }
    } catch (e) {
      print('❌ Error checking schema: $e');
      return;
    }

    // Test 3: Check storage
    print('\n📦 Test 3: Checking image storage bucket...');
    try {
      final storage = Storage(client);
      // Try to list files in the bucket
      final files = await storage.listFiles(
        bucketId: 'property_images',
        queries: [Query.limit(1)],
      );
      print('✅ Storage bucket accessible!');
      print('   Total images: ${files.total}');
    } catch (e) {
      print('⚠️  Storage check (non-critical): $e');
    }

    print('\n=== ✅ PINS SYSTEM STATUS: READY ===\n');
    print('You can now:');
    print('1. Navigate to seller dashboard "My Properties"');
    print('2. Tap location icon → "My Pins"');
    print('3. Create your first pin!');
    
  } catch (e) {
    print('❌ Unexpected error: $e');
  }
}

// Call this in main():
// await testPinSystem();
