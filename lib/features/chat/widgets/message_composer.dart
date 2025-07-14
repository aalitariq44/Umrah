import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

class MessageComposer extends StatefulWidget {
  final Function(String) onSendMessage;
  final Function(File, int) onSendVoiceMessage;
  final Function(Contact) onSendContact;
  final Function(File) onSendImage;
  final Function(File) onSendDocument;
  final Function(File) onSendAudio;
  final Function(Position) onSendLocation;

  const MessageComposer({
    super.key,
    required this.onSendMessage,
    required this.onSendVoiceMessage,
    required this.onSendContact,
    required this.onSendImage,
    required this.onSendDocument,
    required this.onSendAudio,
    required this.onSendLocation,
  });

  @override
  State<MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends State<MessageComposer> {
  final TextEditingController _messageController = TextEditingController();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  Timer? _timer;
  int _recordDuration = 0;

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _timer?.cancel();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _initRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }
    await _recorder.openRecorder();
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      widget.onSendMessage(_messageController.text);
      _messageController.clear();
    }
  }

  Future<void> _startRecording() async {
    final tempDir = await getTemporaryDirectory();
    final path = '${tempDir.path}/${const Uuid().v4()}.webm';
    await _recorder.startRecorder(toFile: path, codec: Codec.opusWebM);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordDuration++;
      });
    });
    setState(() {
      _isRecording = true;
    });
  }

  Future<void> _stopRecording() async {
    final path = await _recorder.stopRecorder();
    _timer?.cancel();
    final duration = _recordDuration;
    setState(() {
      _isRecording = false;
      _recordDuration = 0;
    });
    if (path != null) {
      widget.onSendVoiceMessage(File(path), duration);
    }
  }

  void _showAttachmentMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              children: [
                _buildAttachmentMenuItem(
                  icon: Icons.camera_alt,
                  label: 'كاميرا',
                  color: Colors.red,
                  onTap: () async {
                    Navigator.pop(context);
                    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
                    if (pickedFile != null) {
                      widget.onSendImage(File(pickedFile.path));
                    }
                  },
                ),
                _buildAttachmentMenuItem(
                  icon: Icons.mic,
                  label: 'تسجيل',
                  color: Colors.lightBlue,
                  onTap: () async {
                     Navigator.pop(context);
                     final result = await FilePicker.platform.pickFiles(type: FileType.audio);
                     if (result != null) {
                       widget.onSendAudio(File(result.files.single.path!));
                     }
                  },
                ),
                _buildAttachmentMenuItem(
                  icon: Icons.person,
                  label: 'جهة الاتصال',
                  color: Colors.blue,
                  onTap: () async {
                    Navigator.pop(context);
                    if (await FlutterContacts.requestPermission()) {
                      final contact = await FlutterContacts.openExternalPick();
                      if (contact != null) {
                        widget.onSendContact(contact);
                      }
                    }
                  },
                ),
                _buildAttachmentMenuItem(
                  icon: Icons.photo_library,
                  label: 'معرض الصور',
                  color: Colors.yellow[700]!,
                  onTap: () async {
                    Navigator.pop(context);
                    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      widget.onSendImage(File(pickedFile.path));
                    }
                  },
                ),
                _buildAttachmentMenuItem(
                  icon: Icons.location_on,
                  label: 'موقعي',
                  color: Colors.cyan,
                  onTap: () async {
                    Navigator.pop(context);
                    final position = await _determinePosition();
                    widget.onSendLocation(position);
                  },
                ),
                _buildAttachmentMenuItem(
                  icon: Icons.insert_drive_file,
                  label: 'مستند',
                  color: Colors.green,
                  onTap: () async {
                    Navigator.pop(context);
                    final result = await FilePicker.platform.pickFiles(type: FileType.any);
                    if (result != null) {
                      widget.onSendDocument(File(result.files.single.path!));
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAttachmentMenuItem({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: _isRecording
                ? Text('Recording... ${_recordDuration}s')
                : TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'اكتب رسالة...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
          ),
          IconButton(
            icon: Icon(_isRecording ? Icons.stop : Icons.mic),
            onPressed: _isRecording ? _stopRecording : _startRecording,
          ),
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: _showAttachmentMenu,
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
