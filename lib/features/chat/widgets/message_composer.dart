import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

class MessageComposer extends StatefulWidget {
  final Function(String) onSendMessage;
  final Function(File, int) onSendVoiceMessage;

  const MessageComposer({
    super.key,
    required this.onSendMessage,
    required this.onSendVoiceMessage,
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
    final path = '${tempDir.path}/${const Uuid().v4()}.m4a';
    await _recorder.startRecorder(toFile: path, codec: Codec.aacMP4);
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
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
