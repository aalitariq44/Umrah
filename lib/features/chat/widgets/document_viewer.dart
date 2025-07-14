import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DocumentViewer extends StatelessWidget {
  final String? fileName;
  final String? fileUrl;
  final VoidCallback? onTap;

  const DocumentViewer({
    super.key,
    this.fileName,
    this.fileUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () => _openDocument(),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[50],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getFileIcon(fileName),
              color: _getFileIconColor(fileName),
              size: 24,
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName ?? 'Document',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _getFileExtension(fileName).toUpperCase(),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.open_in_new,
              color: Colors.grey[600],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon(String? fileName) {
    if (fileName == null) return Icons.insert_drive_file;
    
    final extension = _getFileExtension(fileName).toLowerCase();
    
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'txt':
        return Icons.text_snippet;
      case 'zip':
      case 'rar':
      case '7z':
        return Icons.archive;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'mp4':
      case 'avi':
      case 'mov':
        return Icons.video_file;
      case 'mp3':
      case 'wav':
      case 'flac':
        return Icons.audio_file;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileIconColor(String? fileName) {
    if (fileName == null) return Colors.grey;
    
    final extension = _getFileExtension(fileName).toLowerCase();
    
    switch (extension) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'xls':
      case 'xlsx':
        return Colors.green;
      case 'ppt':
      case 'pptx':
        return Colors.orange;
      case 'txt':
        return Colors.grey[700]!;
      case 'zip':
      case 'rar':
      case '7z':
        return Colors.purple;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Colors.pink;
      case 'mp4':
      case 'avi':
      case 'mov':
        return Colors.indigo;
      case 'mp3':
      case 'wav':
      case 'flac':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _getFileExtension(String? fileName) {
    if (fileName == null || !fileName.contains('.')) return '';
    return fileName.split('.').last;
  }

  Future<void> _openDocument() async {
    if (fileUrl == null) {
      debugPrint('رابط الملف غير متوفر');
      return;
    }

    try {
      final uri = Uri.parse(fileUrl!);
      
      // محاولة فتح الملف في التطبيق المناسب
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // فتح في التطبيق الخارجي
        );
      } else {
        debugPrint('لا يمكن فتح الملف: $fileUrl');
      }
    } catch (e) {
      debugPrint('خطأ في فتح الملف: $e');
    }
  }
}
