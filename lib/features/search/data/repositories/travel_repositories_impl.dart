import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../domain/repositories/travel_repositories.dart';
import '../../domain/entities/travel_package.dart';

class TravelRepositoryImpl implements TravelRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Future<List<TravelPackage>> getPackages() async {
    try {
      print('Fetching packages from Firestore...'); // 디버그 로그 추가
      final snapshot = await _firestore.collection('packages').get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        // print('Raw package data: $data'); // 파이어베이스에서 받아온 원본 데이터 확인

        // 명시적으로 minParticipants 확인
        // final minPart = data['minParticipants'];
        // print('minParticipants from Firestore: $minPart (type: ${minPart.runtimeType})');

        final package = TravelPackage(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          price: (data['price'] ?? 0).toDouble(),
          region: data['region'] ?? '',
          mainImage: data['mainImage'],
          descriptionImages: List<String>.from(data['descriptionImages'] ?? []),
          guideName: data['guideName'] ?? '',
          guideId: data['guideId'] ?? '',
          // 여기서 minParticipants 처리를 명확하게
          minParticipants: (data['minParticipants'] as num?)?.toInt() ?? 4, // 기본값을 4로 설정
          maxParticipants: (data['maxParticipants'] as num?)?.toInt() ?? 8,
          nights: (data['nights'] ?? 1).toInt(),
          departureDays: List<int>.from(data['departureDays'] ?? [1,2,3,4,5,6,7]),
        );

        // print('Converted package minParticipants: ${package.minParticipants}'); // 변환된 데이터 확인
        return package;
      }).toList();
    } catch (e) {
      print('Error fetching packages: $e');
      rethrow;  // 에러를 던져서 디버깅을 용이하게
    }
  }

  @override
  Future<void> addPackage(TravelPackage package) async {
    try {
      print('Starting to add package...');

      // 저장하기 전 데이터 확인을 위한 로그
      // print('Package data being saved:');
      // print('minParticipants: ${package.minParticipants}');
      // print('maxParticipants: ${package.maxParticipants}');

      String? mainImageUrl;
      List<String> descriptionImageUrls = [];

      // 메인 이미지 업로드
      if (package.mainImage != null) {
        print('Uploading main image...');
        final mainImageFile = File(package.mainImage!);
        final mainImageRef = _storage.ref('package_images/${DateTime.now().millisecondsSinceEpoch}_main.jpg');
        await mainImageRef.putFile(mainImageFile);
        mainImageUrl = await mainImageRef.getDownloadURL();
        print('Main image uploaded: $mainImageUrl');
      }

      // 설명 이미지들 업로드
      for (String imagePath in package.descriptionImages) {
        print('Uploading description image...');
        final file = File(imagePath);
        final imageRef = _storage.ref('package_images/${DateTime.now().millisecondsSinceEpoch}_${descriptionImageUrls.length}.jpg');
        await imageRef.putFile(file);
        final imageUrl = await imageRef.getDownloadURL();
        descriptionImageUrls.add(imageUrl);
        print('Description image uploaded: $imageUrl');
      }

      // 패키지 데이터 준비
      final packageData = {
        'title': package.title,
        'description': package.description,
        'price': package.price,
        'region': package.region,
        'mainImage': mainImageUrl,
        'descriptionImages': descriptionImageUrls,
        'createdAt': FieldValue.serverTimestamp(),
        'guideName': package.guideName,
        'guideId': package.guideId,
        'minParticipants': package.minParticipants,
        'maxParticipants': package.maxParticipants,
        'nights': package.nights,
        'departureDays': package.departureDays,
      };

      // 데이터 유효성 검사
      if (package.minParticipants <= 0) {
        throw '최소 인원은 0보다 커야 합니다';
      }
      if (package.maxParticipants < package.minParticipants) {
        throw '최대 인원은 최소 인원보다 작을 수 없습니다';
      }

      print('Saving package data to Firestore:');
      print('minParticipants: ${packageData['minParticipants']}');
      print('maxParticipants: ${packageData['maxParticipants']}');

      // Firestore에 데이터 저장
      final docRef = await _firestore.collection('packages').add(packageData);
      print('Package saved with ID: ${docRef.id}');

      // 저장된 데이터 확인
      final savedDoc = await docRef.get();
      final savedData = savedDoc.data();
      print('Saved package data:');
      print('minParticipants: ${savedData?['minParticipants']}');
      print('maxParticipants: ${savedData?['maxParticipants']}');

    } catch (e) {
      print('Error adding package: $e');
      rethrow;
    }
  }
}