
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sea/services/fb_auth.dart';
import 'package:sea/services/fb_database.dart';
import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../models/ChatVideoContainerModel.dart';
import '../models/URLModel.dart';
import 'helpers.dart';

class FBStorage {

  static Reference storage = FirebaseStorage.instance.ref();

  static get25x25Image(String imageURL) {
    final split = imageURL.split('?');
    if(split.length != 2) {
      return imageURL;
    }
    return '${split[0].substring(0,split[0].length - 4)}_25x25.png?${split[1]}';
  }

  static get50x50Image(String imageURL) {
    final split = imageURL.split('?');
    if(split.length != 2) {
      return imageURL;
    }
    return '${split[0].substring(0,split[0].length - 4)}_50x50.png?${split[1]}';
  }

  static get100x100Image(String imageURL) {
    final split = imageURL.split('?');
    if(split.length != 2) {
      return imageURL;
    }
    return '${split[0].substring(0,split[0].length - 4)}_100x100.png?${split[1]}';
  }

  static get200x200Image(String imageURL) {
    final split = imageURL.split('?');
    if(split.length != 2) {
      return imageURL;
    }
    return '${split[0].substring(0,split[0].length - 4)}_200x200.png?${split[1]}';
  }

  static get350x350Image(String imageURL) {
    final split = imageURL.split('?');
    if(split.length != 2) {
      return imageURL;
    }
    return '${split[0].substring(0,split[0].length - 4)}_350x350.png?${split[1]}';
  }

  /// compress image file to make it load faster but with lower quality,
  /// change the quality parameter to control the quality of the image after
  /// being compressed(100 = max quality - 0 = low quality)
  /// @param file the image file that will be compressed
  /// @return File a new compressed file with smaller size
  static Future<File> compressImage(File file) async {
    File compressedImage = await FlutterNativeImage.compressImage(
      file.path,
      quality: 99,
    );
    return compressedImage;
  }

  /// compress video file to make it load faster but with lower quality,
  /// change the quality parameter to control the quality of the video after
  /// being compressed
  /// @param file the video file that will be compressed
  /// @return File a new compressed file with smaller size
  static Future<File> _compressVideo(File file) async {
    MediaInfo? info = await VideoCompress.compressVideo(file.path,
        quality: VideoQuality.DefaultQuality,
        deleteOrigin: false,
        includeAudio: true,
        frameRate: 24);
    if (info != null) {
      File compressedVideo = File(info.path!);
      return compressedVideo;
    } else {
      return file;
    }
  }

  static Future<URL> uploadEventPhotoToFireStorage(
      File image, BuildContext context) async {
    showProgress(context, 'Uploading photo...', false);
    File compressedImage = await compressImage(image);
    var uniqueID = const Uuid().v4();
    Reference upload = storage.child('tenants/${FBDatabase.tenantID}/${FBAuth().getUserID()!}/event_photos/$uniqueID/$uniqueID.png');
    UploadTask uploadTask = upload.putFile(compressedImage);
    uploadTask.snapshotEvents.listen((event) {
      updateProgress(
          'Uploading image ${(event.bytesTransferred.toDouble() / 1000).toStringAsFixed(2)} /'
              '${(event.totalBytes.toDouble() / 1000).toStringAsFixed(2)} '
              'KB');
    });
    uploadTask.whenComplete(() {}).catchError((onError) {
      print((onError as PlatformException).message);
    });
    var storageRef = (await uploadTask.whenComplete(() {})).ref;
    var downloadUrl = await storageRef.getDownloadURL();
    var metaData = await storageRef.getMetadata();
    hideProgress();
    return URL(
        mime: metaData.contentType ?? 'image', url: downloadUrl.toString());
  }

  static Future<URL> uploadPostPhotoToFireStorage(
      File image, BuildContext context) async {
    showProgress(context, 'Uploading photo...', false);
    File compressedImage = await compressImage(image);
    var uniqueID = const Uuid().v4();
    Reference upload = storage.child('tenants/${FBDatabase.tenantID}/${FBAuth().getUserID()!}/post_photos/$uniqueID/$uniqueID.png');
    UploadTask uploadTask = upload.putFile(compressedImage);
    uploadTask.snapshotEvents.listen((event) {
      updateProgress(
          'Uploading image ${(event.bytesTransferred.toDouble() / 1000).toStringAsFixed(2)} /'
              '${(event.totalBytes.toDouble() / 1000).toStringAsFixed(2)} '
              'KB');
    });
    uploadTask.whenComplete(() {}).catchError((onError) {
      print((onError as PlatformException).message);
    });
    var storageRef = (await uploadTask.whenComplete(() {})).ref;
    var downloadUrl = await storageRef.getDownloadURL();
    var metaData = await storageRef.getMetadata();
    hideProgress();
    return URL(
        mime: metaData.contentType ?? 'image', url: downloadUrl.toString());
  }

  static Future<ChatVideoContainer> uploadPostVideoToFireStorage(
      File video, BuildContext context) async {
    showProgress(context, 'Uploading video...', false);
    var uniqueID = const Uuid().v4();
    File compressedVideo = await _compressVideo(video);
    Reference upload = storage.child('tenants/${FBDatabase.tenantID}/${FBAuth().getUserID()!}/post_videos/$uniqueID/$uniqueID.mp4');
    SettableMetadata metadata = SettableMetadata(contentType: 'video');
    UploadTask uploadTask = upload.putFile(compressedVideo, metadata);
    uploadTask.snapshotEvents.listen((event) {
      updateProgress(
          'Uploading video ${(event.bytesTransferred.toDouble() / 1000).toStringAsFixed(2)} /'
              '${(event.totalBytes.toDouble() / 1000).toStringAsFixed(2)} '
              'KB');
    });
    var storageRef = (await uploadTask.whenComplete(() {})).ref;
    var downloadUrl = await storageRef.getDownloadURL();
    var metaData = await storageRef.getMetadata();
    final uint8list = await VideoThumbnail.thumbnailFile(
        video: video.path,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.PNG);
    final file = File(uint8list!);
    String thumbnailDownloadUrl = await uploadVideoThumbnailToFireStorage(file);
    hideProgress();
    return ChatVideoContainer(
        videoUrl: URL(
            url: downloadUrl.toString(), mime: metaData.contentType ?? 'video'),
        thumbnailUrl: thumbnailDownloadUrl);
  }

  static Future<URL> uploadGroupBackgroundPhotoToFireStorage(
      File image, BuildContext context) async {
    showProgress(context, 'Uploading image...', false);
    File compressedImage = await compressImage(image);
    var uniqueID = const Uuid().v4();
    Reference upload = storage.child('tenants/${FBDatabase.tenantID}/groupBackgroundPhotos/$uniqueID/$uniqueID.png');
    UploadTask uploadTask = upload.putFile(compressedImage);
    uploadTask.snapshotEvents.listen((event) {
      updateProgress(
          'Uploading image ${(event.bytesTransferred.toDouble() / 1000).toStringAsFixed(2)} /'
              '${(event.totalBytes.toDouble() / 1000).toStringAsFixed(2)} '
              'KB');
    });
    uploadTask.whenComplete(() {}).catchError((onError) {
      print((onError as PlatformException).message);
    });
    var storageRef = (await uploadTask.whenComplete(() {})).ref;
    var downloadUrl = await storageRef.getDownloadURL();
    var metaData = await storageRef.getMetadata();
    hideProgress();
    return URL(
        mime: metaData.contentType ?? 'image', url: downloadUrl.toString());
  }

  static Future<URL> uploadGroupProfilePhotoToFireStorage(
      File image, BuildContext context) async {
    showProgress(context, 'Uploading image...', false);
    File compressedImage = await compressImage(image);
    var uniqueID = const Uuid().v4();
    Reference upload = storage.child('tenants/${FBDatabase.tenantID}/groupProfilePhotos/$uniqueID/$uniqueID.png');
    UploadTask uploadTask = upload.putFile(compressedImage);
    uploadTask.snapshotEvents.listen((event) {
      updateProgress(
          'Uploading image ${(event.bytesTransferred.toDouble() / 1000).toStringAsFixed(2)} /'
              '${(event.totalBytes.toDouble() / 1000).toStringAsFixed(2)} '
              'KB');
    });
    uploadTask.whenComplete(() {}).catchError((onError) {
      print((onError as PlatformException).message);
    });
    var storageRef = (await uploadTask.whenComplete(() {})).ref;
    var downloadUrl = await storageRef.getDownloadURL();
    var metaData = await storageRef.getMetadata();
    hideProgress();
    return URL(
        mime: metaData.contentType ?? 'image', url: downloadUrl.toString());
  }

  static Future<URL> uploadUserProfilePhotoToFireStorage(
      File image, BuildContext context) async {
    showProgress(context, 'Uploading image...', false);
    File compressedImage = await compressImage(image);
    var uniqueID = const Uuid().v4();
    Reference upload = storage.child('tenants/${FBDatabase.tenantID}/users/${FBAuth().getUserID()!}/profilePhotos/$uniqueID/$uniqueID.png');
    UploadTask uploadTask = upload.putFile(compressedImage);
    uploadTask.snapshotEvents.listen((event) {
      updateProgress(
          'Uploading image ${(event.bytesTransferred.toDouble() / 1000).toStringAsFixed(2)} /'
              '${(event.totalBytes.toDouble() / 1000).toStringAsFixed(2)} '
              'KB');
    });
    uploadTask.whenComplete(() {}).catchError((onError) {
      print((onError as PlatformException).message);
    });
    var storageRef = (await uploadTask.whenComplete(() {})).ref;
    var downloadUrl = await storageRef.getDownloadURL();
    var metaData = await storageRef.getMetadata();
    hideProgress();
    return URL(
        mime: metaData.contentType ?? 'image', url: downloadUrl.toString());
  }

  static Future<URL> uploadOpponentLogoToFireStorage(
      File image, BuildContext context) async {
    showProgress(context, 'Uploading image...', false);
    File compressedImage = await compressImage(image);
    var uniqueID = const Uuid().v4();
    Reference upload = storage.child('tenants/${FBDatabase.tenantID}/opponents/$uniqueID/$uniqueID.png');
    UploadTask uploadTask = upload.putFile(compressedImage);
    uploadTask.snapshotEvents.listen((event) {
      updateProgress(
          'Uploading image ${(event.bytesTransferred.toDouble() / 1000).toStringAsFixed(2)} /'
              '${(event.totalBytes.toDouble() / 1000).toStringAsFixed(2)} '
              'KB');
    });
    uploadTask.whenComplete(() {}).catchError((onError) {
      print((onError as PlatformException).message);
    });
    var storageRef = (await uploadTask.whenComplete(() {})).ref;
    var downloadUrl = await storageRef.getDownloadURL();
    var metaData = await storageRef.getMetadata();
    hideProgress();
    return URL(
        mime: metaData.contentType ?? 'image', url: downloadUrl.toString());
  }

  static Future<URL> uploadChatImageToFireStorage(
      File image, BuildContext context) async {
    showProgress(context, 'Uploading image...', false);
    File compressedImage = await compressImage(image);
    var uniqueID = const Uuid().v4();
    Reference upload = storage.child('tenants/${FBDatabase.tenantID}/users/${FBAuth().getUserID()!}/images/$uniqueID/$uniqueID.png');
    UploadTask uploadTask = upload.putFile(compressedImage);
    uploadTask.snapshotEvents.listen((event) {
      updateProgress(
          'Uploading image ${(event.bytesTransferred.toDouble() / 1000).toStringAsFixed(2)} /'
              '${(event.totalBytes.toDouble() / 1000).toStringAsFixed(2)} '
              'KB');
    });
    uploadTask.whenComplete(() {}).catchError((onError) {
      print((onError as PlatformException).message);
    });
    var storageRef = (await uploadTask.whenComplete(() {})).ref;
    var downloadUrl = await storageRef.getDownloadURL();
    var metaData = await storageRef.getMetadata();
    hideProgress();
    return URL(
        mime: metaData.contentType ?? 'image', url: downloadUrl.toString());
  }

  static Future<ChatVideoContainer> uploadChatVideoToFireStorage(
      File video, BuildContext context) async {
    showProgress(context, 'Uploading video...', false);
    var uniqueID = const Uuid().v4();
    File compressedVideo = await _compressVideo(video);
    Reference upload = storage.child('tenants/${FBDatabase.tenantID}/users/${FBAuth().getUserID()!}/videos/$uniqueID/$uniqueID.mp4');
    SettableMetadata metadata = SettableMetadata(contentType: 'video');
    UploadTask uploadTask = upload.putFile(compressedVideo, metadata);
    uploadTask.snapshotEvents.listen((event) {
      updateProgress(
          'Uploading video ${(event.bytesTransferred.toDouble() / 1000).toStringAsFixed(2)} /'
              '${(event.totalBytes.toDouble() / 1000).toStringAsFixed(2)} '
              'KB');
    });
    var storageRef = (await uploadTask.whenComplete(() {})).ref;
    var downloadUrl = await storageRef.getDownloadURL();
    var metaData = await storageRef.getMetadata();
    final uint8list = await VideoThumbnail.thumbnailFile(
        video: downloadUrl,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.PNG);
    final file = File(uint8list!);
    String thumbnailDownloadUrl = await uploadVideoThumbnailToFireStorage(file);
    hideProgress();
    return ChatVideoContainer(
        videoUrl: URL(
            url: downloadUrl.toString(), mime: metaData.contentType ?? 'video'),
        thumbnailUrl: thumbnailDownloadUrl);
  }

  static Future<String> uploadVideoThumbnailToFireStorage(File file) async {
    var uniqueID = const Uuid().v4();
    File compressedImage = await compressImage(file);
    Reference upload = storage.child('tenants/${FBDatabase.tenantID}/users/${FBAuth().getUserID()!}/thumbnails/$uniqueID/$uniqueID.png');
    UploadTask uploadTask = upload.putFile(compressedImage);
    var downloadUrl =
    await (await uploadTask.whenComplete(() {})).ref.getDownloadURL();
    return downloadUrl.toString();
  }


}