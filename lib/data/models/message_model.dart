import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

enum MessageStatus { sending, sent, delivered, read, failed }
enum MessageType { text, image, voice, audio, document, location, contact }

class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String text;
  final Timestamp timestamp;
  final MessageStatus status;
  final MessageType type;
  final String? url;
  final int? duration;
  final String? contactName;
  final String? contactNumber;
  final String? imageUrl;
  final String? fileName;
  final double? latitude;
  final double? longitude;
  final int? fileSize;
  final String? mimeType;
  final File? localFile; // For local preview

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.timestamp,
    this.status = MessageStatus.sending,
    this.type = MessageType.text,
    this.url,
    this.duration,
    this.contactName,
    this.contactNumber,
    this.imageUrl,
    this.fileName,
    this.latitude,
    this.longitude,
    this.fileSize,
    this.mimeType,
    this.localFile,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'timestamp': timestamp,
      'status': status.toString().split('.').last,
      'type': type.toString().split('.').last,
      'url': url,
      'duration': duration,
      'contactName': contactName,
      'contactNumber': contactNumber,
      'imageUrl': imageUrl,
      'fileName': fileName,
      'latitude': latitude,
      'longitude': longitude,
      'fileSize': fileSize,
      'mimeType': mimeType,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    String statusStr = '';
    if (map['status'] != null) {
      statusStr = map['status'].toString();
    }
    String typeStr = '';
    if (map['type'] != null) {
      typeStr = map['type'].toString();
    }
    return Message(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      text: map['text'] ?? '',
      timestamp: map['timestamp'],
      status: statusStr.isNotEmpty ? statusStr.toMessageStatus() : MessageStatus.sent,
      type: typeStr.isNotEmpty ? typeStr.toMessageType() : MessageType.text,
      url: map['url'],
      duration: map['duration'],
      contactName: map['contactName'],
      contactNumber: map['contactNumber'],
      imageUrl: map['imageUrl'],
      fileName: map['fileName'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      fileSize: map['fileSize'],
      mimeType: map['mimeType'],
    );
  }
}

extension on String {
  MessageStatus toMessageStatus() {
    return MessageStatus.values.firstWhere(
      (e) => e.toString().split('.').last == this,
      orElse: () => MessageStatus.sent,
    );
  }

  MessageType toMessageType() {
    return MessageType.values.firstWhere(
      (e) => e.toString().split('.').last == this,
      orElse: () => MessageType.text,
    );
  }
}
