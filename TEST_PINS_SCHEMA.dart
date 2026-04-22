// Test script to verify pins schema and connectivity
// Run this in main.dart temporarily to debug

import 'package:appwrite/appwrite.dart';

Future<void> testPinsSchema() async {
  try {
    final client = Client();
    client
      .setEndpoint('https://nyc.cloud.appwrite.io/v1')
      .setProject('69c7c467000dcf77499e');

    final databases = Databases(client);
    
    // Try to get the pins collection info
    print('Testing Pins Collection Access...');
    
    // List documents to verify structure
    final response = await databases.listDocuments(
      databaseId: '69c7c496001cc7881cd0',
      collectionId: 'pins',
      queries: [Query.limit(1)],
    );
    
    print('✅ Pins collection accessible!');
    print('Document count: ${response.total}');
    
    if (response.documents.isNotEmpty) {
      final doc = response.documents.first;
      print('\n📋 First pin document:');
      print('ID: ${doc.$id}');
      print('Data keys: ${doc.data.keys.toList()}');
      
      // Check if latitude and longitude exist
      if (doc.data.containsKey('latitude') && doc.data.containsKey('longitude')) {
        print('✅ latitude and longitude columns found!');
      } else {
        print('❌ ERROR: Missing latitude/longitude columns!');
        print('   Available keys: ${doc.data.keys}');
      }
    } else {
      print('\n⚠️  No pins yet - create one to test schema');
    }
    
  } catch (e) {
    print('❌ Database connection error: $e');
  }
}
