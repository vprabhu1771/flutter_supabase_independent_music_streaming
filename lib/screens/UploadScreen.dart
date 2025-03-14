import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/Brand.dart';
import '../models/Genre.dart';

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
  List<Genre> genres = [];
  List<Brand> brands = [];
  Genre? selectedGenre;
  Brand? selectedBrand;

  @override
  void initState() {
    super.initState();
    userId = supabase.auth.currentUser?.id;
    fetchGenres();
    fetchBrands();
  }

  Future<void> fetchGenres() async {
    final data = await supabase.from('genres').select();
    setState(() {
      genres = data.map<Genre>((json) => Genre.fromJson(json)).toList();
    });
  }

  Future<void> fetchBrands() async {
    final data = await supabase.from('brands').select();
    setState(() {
      brands = data.map<Brand>((json) => Brand.fromJson(json)).toList();
    });
  }

  Future<void> uploadSong() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedGenre == null || selectedBrand == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both genre and brand.')),
      );
      return;
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'aac'],
      );

      if (result == null) return;

      final file = File(result.files.single.path!);
      final fileName = "${DateTime.now().millisecondsSinceEpoch}.mp3";
      final songName = _songNameController.text.trim();

      setState(() => isUploading = true);

      final response = await supabase.storage.from('assets').upload('songs/$fileName', file);
      if (response == null) {
        throw response;
      }

      final publicUrl = supabase.storage.from('assets').getPublicUrl('songs/$fileName');

      setState(() {
        isUploading = false;
        uploadedFileUrl = publicUrl;
      });

      await supabase.from('songs').insert({
        'name': songName,
        'image_path': publicUrl,
        'song_path': publicUrl,
        'genre_id': selectedGenre!.id,
        'brand_id': selectedBrand!.id,
        'user_id': userId,
        'created_at': DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Song uploaded successfully!')),
      );

      _songNameController.clear();
      setState(() {
        selectedGenre = null;
        selectedBrand = null;
      });
    } catch (e) {
      setState(() => isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload Failed: $e')),
      );
    }
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
            children: [
              TextFormField(
                controller: _songNameController,
                decoration: const InputDecoration(
                  labelText: 'Song Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a song name' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Genre>(
                value: selectedGenre,
                items: genres.map((Genre genre) {
                  return DropdownMenuItem<Genre>(
                    value: genre,
                    child: Text(genre.name),
                  );
                }).toList(),
                onChanged: (value) => setState(() => selectedGenre = value),
                decoration: const InputDecoration(
                  labelText: 'Select Genre',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Brand>(
                value: selectedBrand,
                items: brands.map((Brand brand) {
                  return DropdownMenuItem<Brand>(
                    value: brand,
                    child: Text(brand.name),
                  );
                }).toList(),
                onChanged: (value) => setState(() => selectedBrand = value),
                decoration: const InputDecoration(
                  labelText: 'Select Brand',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: const Text('Pick and Upload Song'),
                onPressed: isUploading ? null : uploadSong,
              ),
              if (isUploading) const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
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