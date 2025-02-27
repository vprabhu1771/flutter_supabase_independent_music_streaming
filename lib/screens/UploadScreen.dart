import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UploadScreen extends StatefulWidget {
  final String title;

  const UploadScreen({Key? key, required this.title}) : super(key: key);

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _songNameController = TextEditingController();
  bool isUploading = false;
  String? uploadedFileUrl;

  String? userId;

  @override
  void initState() {
    super.initState();

    setState(() {
      userId = supabase.auth.currentUser!.id;
    });

  }

  Future<void> uploadSong() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'aac'],
      );

      if (result == null) return; // User canceled file picker

      final file = File(result.files.single.path!);
      final fileName = result.files.single.name;
      final songName = _songNameController.text.trim();

      setState(() => isUploading = true);

      // Upload the file to Supabase Storage
      final response = await supabase.storage.from('assets').upload('songs/$fileName', file);

      if (response == null) {
        throw response;
      }

      final publicUrl = supabase.storage.from('assets').getPublicUrl('songs/$fileName');

      setState(() {
        isUploading = false;
        uploadedFileUrl = publicUrl;
      });

      // Insert song details into the 'songs' table
      final insertResponse = await supabase.from('songs').insert({
        'name': songName,
        'image_path': publicUrl,
        'song_path': publicUrl,
        'genre_id': 6,
        'brand_id': 1,
        'user_id': userId,
        'created_at': DateTime.now().toIso8601String(),
      });

      if (insertResponse != null) {
        throw insertResponse!;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Song uploaded and saved successfully!')),
      );

      _songNameController.clear(); // Clear input field after successful upload
    } catch (e) {
      setState(() => isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload Failed: $e')),
      );
    }
  }

  @override
  void dispose() {
    _songNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _songNameController,
                decoration: const InputDecoration(
                  labelText: 'Song Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a song name' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: const Text('Pick and Upload Song'),
                onPressed: isUploading ? null : uploadSong,
              ),
              const SizedBox(height: 20),
              if (isUploading) const CircularProgressIndicator(),
              if (uploadedFileUrl != null) ...[
                const SizedBox(height: 20),
                const Text('File Uploaded!'),
                Text(
                  uploadedFileUrl!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.blue),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
