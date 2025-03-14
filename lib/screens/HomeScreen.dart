import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import '../widgets/CustomDrawer.dart';

class HomeScreen extends StatefulWidget {

  final String title;

  const HomeScreen({super.key, required this.title});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final CarouselSliderController  _controller = CarouselSliderController ();

  int _current = 0;

  final List<String> imgList = [
    'https://xxllfyzeciydpjwwyeef.supabase.co/storage/v1/object/public/assets/weight_bridge_record_control_carousel/w2.jpg',
    'https://xxllfyzeciydpjwwyeef.supabase.co/storage/v1/object/public/assets/weight_bridge_record_control_carousel/w33.jpg',
    'https://xxllfyzeciydpjwwyeef.supabase.co/storage/v1/object/public/assets/weight_bridge_record_control_carousel/w34.jpg',
    'https://xxllfyzeciydpjwwyeef.supabase.co/storage/v1/object/public/assets/weight_bridge_record_control_carousel/w35.jpg'
  ];

  List<Widget> get imageSliders => imgList
      .map(
        (item) => ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        item,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) =>
        const Icon(Icons.broken_image, size: 100),
      ),
    ),
  ).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        drawer: CustomDrawer(parentContext: context),
        body: Column(
          children: [

            // 🎠 Carousel Slider
            CarouselSlider(
              items: imageSliders,
              carouselController: _controller,
              options: CarouselOptions(
                autoPlay: true,
                enlargeCenterPage: true,
                aspectRatio: 2.0,
                onPageChanged: (index, reason) {
                  // setState(() {
                  //   _current = index;
                  // });

                  _current = index; // Avoid calling setState here
                },
              ),
            ),

            // 🔘 Carousel Dots Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: imgList.asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () => _controller.animateToPage(entry.key),
                  child: Container(
                    width: 10.0,
                    height: 10.0,
                    margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (_current == entry.key
                          ? Colors.blueAccent
                          : Colors.grey)
                          .withOpacity(0.9),
                    ),
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: 10),

            Text(
              'Welcome to the Weight Bridge Record Control',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 10),

            Text(
              'Manage your weight bridge operations seamlessly with our user-friendly interface.',
              style: TextStyle(fontSize: 16, color: Colors.black87),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 10),

            Text(
              'Use the navigation bar above to explore the system.',
              style: TextStyle(fontSize: 16, color: Colors.black87),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 10),

            Text(
              '24/7 Service Available!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 10),

            Text(
              'We\'re here to assist you anytime, day or night. Your operations matter to us!',
              style: TextStyle(fontSize: 16, color: Colors.black87),
              textAlign: TextAlign.center,
            ),

          ],
        )
    );
  }
}