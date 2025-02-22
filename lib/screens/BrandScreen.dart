import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/Brand.dart';
import '../screens/song/SongFilterByBrandScreen.dart';
import '../widgets/CustomDrawer.dart';

class BrandScreen extends StatefulWidget {
  final String title;

  const BrandScreen({super.key, required this.title});

  @override
  State<BrandScreen> createState() => _BrandScreenState();
}

class _BrandScreenState extends State<BrandScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  /// Stream to fetch brands with real-time updates.
  Stream<List<Brand>> brandStream() {
    return supabase
        .from('brands')
        .stream(primaryKey: ['id'])
        .order('name', ascending: true)
        .map((data) => data.map((brand) => Brand.fromJson(brand)).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(parentContext: context),
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {}); // Refresh StreamBuilder
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Brand>>(
        stream: brandStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final brands = snapshot.data ?? [];

          if (brands.isEmpty) {
            return const Center(child: Text('No brands available.'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {}); // Trigger stream refresh
            },
            child: ListView.builder(
              itemCount: brands.length,
              itemBuilder: (context, index) {
                final brand = brands[index];
                return ListTile(
                  title: Text(brand.name),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      brand.image_path,
                      width: 80,
                      height: 80,
                      fit: BoxFit.scaleDown,
                      errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => SongFilterByBrandScreen(title: brand.name, brand: brand,),),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
