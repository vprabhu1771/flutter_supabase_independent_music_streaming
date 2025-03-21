import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
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
  String? uploadedImageUrl;
  String? userId;
  List<Genre> genres = [];
  List<Brand> brands = [];
  Genre? selectedGenre;
  Brand? selectedBrand;
  File? coverImageFile;

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

  Future<void> pickCoverImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        coverImageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> uploadCoverImage(File imageFile) async {
    try {
      final fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
      final response = await supabase.storage.from('assets').upload('covers/$fileName', imageFile);
      if (response == null) {
        throw response;
      }
      return supabase.storage.from('assets').getPublicUrl('covers/$fileName');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image Upload Failed: $e')),
      );
      return null;
    }
  }

  Future<void> uploadSong() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedGenre == null || selectedBrand == null || coverImageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select genre, brand, and upload a cover image.')),
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

      // Upload Cover Image First
      final coverUrl = await uploadCoverImage(coverImageFile!);
      if (coverUrl == null) throw Exception('Failed to upload cover image');

      final response = await supabase.storage.from('assets').upload('songs/$fileName', file);
      if (response == null) {
        throw response;
      }

      final publicUrl = supabase.storage.from('assets').getPublicUrl('songs/$fileName');

      setState(() {
        isUploading = false;
        uploadedFileUrl = publicUrl;
        uploadedImageUrl = coverUrl;
      });

      await supabase.from('songs').insert({
        'name': songName,
        'image_path': coverUrl,
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
        coverImageFile = null;
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
              GestureDetector(
                onTap: pickCoverImage,
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: coverImageFile == null
                      ? const Center(child: Text('Tap to select cover image'))
                      : Image.file(coverImageFile!, fit: BoxFit.cover),
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
